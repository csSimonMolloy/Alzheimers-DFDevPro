/**
 * 2014-08-01 : CSL : This class is to test the DFContactAttendeeFlagPhase1 Batch class
 * 
 */
@isTest
private class TestDFContactAttendeeFlagPhase1 {
	
	private static String RANDOM_STRING = String.valueOf(system.now().format('yyyyMMddHHmmssSSS')) + String.valueOf(Crypto.getRandomInteger()).substring(1,4);
	private static String EMAIL_ADDRESS = RANDOM_STRING + '_dummy@test.com';
	private static String PASSWORD = 'Qwerty12345';
	private static String FRIEND_RT_NAME = 'Dementia_Friend';
	private static String CHAMPION_RT_NAME = 'Dementia_Friend_Champion';
	private static String SESSION_RT_NAME = 'Dementia_Friend_Awareness_Session';
	private static String TRAINING_RT_NAME = 'Champion_Training_Course';
	private static User adminUser;
	private static User guestUser;
	private static User portalUser;
	private static Contact contactRecord;
	private static Contact soContactRecord;
	private static DF_Contact__c sessionOrganiser;
	private static DF_Contact__c dfContactRecord;
	private static DF_Event__c testSession;
	private static DF_Event__c testTraining;
	
    private static void setUpSystemData(){
		RecordType dfcFriend = [select r.Id from RecordType r where r.DeveloperName = :FRIEND_RT_NAME and r.SobjectType = 'DF_Contact__c' and IsActive = true LIMIT 1];
		RecordType cFriend = [select r.Id from RecordType r where r.DeveloperName = :FRIEND_RT_NAME and r.SobjectType = 'Contact' and IsActive = true LIMIT 1];
		RecordType dfcChampion = [select r.Id from RecordType r where r.DeveloperName = :CHAMPION_RT_NAME and r.SobjectType = 'DF_Contact__c' and IsActive = true LIMIT 1];
		RecordType cChampion = [select r.Id from RecordType r where r.DeveloperName = :CHAMPION_RT_NAME and r.SobjectType = 'Contact' and IsActive = true LIMIT 1];
		
		adminUser = [Select Id From User Where Profile.Name='System Administrator' And IsActive=true limit 1];
		guestUser = [Select Id From User Where UserType='Guest' limit 1];
		portalUser = [Select Id, ContactId from User where Profile.Name='DF HVCP' and IsActive = true LIMIT 1];
		contactRecord = [Select FirstName, LastName, Email from Contact where Id = :portalUser.ContactId LIMIT 1];
		soContactRecord = [Select FirstName, LastName, Email from Contact where RecordTypeId = :cChampion.Id LIMIT 1];
		
    	Global_Setting__c setting = Global_Setting__c.getInstance('webAccountOwnerId');
    	if (setting == null){
    		setting = new Global_Setting__c(Name='webAccountOwnerId',Value__c=adminUser.Id);
        	insert setting;
    	}
    	List<DF_Contact__c> dfConList = new List<DF_Contact__c>();
    	dfConList = [select d.First_Name__c, d.Last_Name__c, d.Email__c, d.RecordTypeId, d.Portal_Contact__c from DF_Contact__c d where d.Portal_Contact__c = :contactRecord.Id LIMIT 1];
    	if (dfConList.size() == 0){
	    	dfContactRecord = new DF_Contact__c();
	    	dfContactRecord.RecordTypeId = [select r.Id from RecordType r where r.DeveloperName = :CHAMPION_RT_NAME and r.SObjectType = 'DF_Contact__c' LIMIT 1].Id;
	    	dfContactRecord.Portal_Contact__c = portalUser.ContactId;
	    	dfContactRecord.First_Name__c = contactRecord.FirstName;
	    	dfContactRecord.Last_Name__c = contactRecord.LastName;
	    	dfContactRecord.Email__c = contactRecord.Email;
	    	if (dfContactRecord.Email__c == null) dfContactRecord.Email__c = 'test.email@myemail.com';
	    	dfContactRecord.Attended__c = true;
	    	insert dfContactRecord;
    	}else {
    		dfContactRecord = dfConList[0];
    	}
    	
    	List<DF_Contact__c> soDFConList = new List<DF_Contact__c>();
    	soDFConList = [select d.First_Name__c, d.Last_Name__c, d.Email__c, d.RecordTypeId, d.Portal_Contact__c from DF_Contact__c d where d.Portal_Contact__c = :soContactRecord.Id LIMIT 1];
    	if (soDFConList.size() == 0){
    		sessionOrganiser = new DF_Contact__c();
	    	sessionOrganiser.RecordTypeId = [select r.Id from RecordType r where r.DeveloperName = :CHAMPION_RT_NAME and r.SObjectType = 'DF_Contact__c' LIMIT 1].Id;
	    	sessionOrganiser.Portal_Contact__c = soContactRecord.Id;
	    	sessionOrganiser.First_Name__c = soContactRecord.FirstName;
	    	sessionOrganiser.Last_Name__c = soContactRecord.LastName;
	    	sessionOrganiser.Email__c = soContactRecord.Email;
	    	insert sessionOrganiser;
    	}else {
    		sessionOrganiser = soDFConList[0];
    	}
    	
    	testSession = new DF_Event__c();
    	testSession.RecordTypeId = [select r.Id from RecordType r where r.DeveloperName = :SESSION_RT_NAME and r.IsActive = true and r.SObjectType = 'DF_Event__c' LIMIT 1].Id;
    	testSession.Name = 'Test Session';
    	testSession.Event_Date_Time__c = DateTime.now().addDays(7);
    	testSession.Event_Status__c = 'Available';
    	testSession.Number_of_Places__c = 10;
    	testSession.Session_Organiser__c = sessionOrganiser.Id;
    	insert testSession;
    	
    	testTraining = new DF_Event__c();
    	testTraining.RecordTypeId = [select r.Id from RecordType r where r.DeveloperName = :TRAINING_RT_NAME and r.IsActive = true and r.SObjectType = 'DF_Event__c' LIMIT 1].Id;
    	testTraining.Name = 'Test Training';
    	testTraining.Event_Date_Time__c = DateTime.now().addDays(7);
    	testTraining.Event_Status__c = 'Available';
    	testTraining.Number_of_Places__c = 10;
    	testTraining.Session_Organiser__c = sessionOrganiser.Id;
    	insert testTraining;
    	
	}
	/*
	@IsTest(SeeAllData=true)
    static void testSessionTrigger() {
		setupSystemData();
		
		system.debug('*** -- Test Code Debug - ' + dfContactRecord.Portal_Contact__c + ' -- ***');
		
		DF_EventAttendee__c dfe1 = new DF_EventAttendee__c();
		dfe1.DF_Contact__c = dfContactRecord.Id;
		dfe1.DF_Event__c = testSession.Id;
		system.debug('*** -- Test Code Debug 2 - ' + dfe1.DF_Contact__r.Portal_Contact__c + ' -- ***');
		//This should fire the first trigger
		test.startTest();
		insert dfe1;
		test.stopTest();
		delete dfe1;
		
		    	
    }
    */
    @IsTest(SeeAllData=true)
    static void testBatchPhase1() {
		setupSystemData();
		
		system.debug('*** -- Test Code Debug - ' + dfContactRecord.Portal_Contact__c + ' -- ***');
		
		DF_EventAttendee__c dfe1 = new DF_EventAttendee__c();
		dfe1.DF_Contact__c = dfContactRecord.Id;
		dfe1.DF_Event__c = testTraining.Id;
		system.debug('*** -- Test Code Debug 2 - ' + dfe1.DF_Contact__r.Portal_Contact__c + ' -- ***');
		//This should fire the first trigger
		insert dfe1;
		
		test.startTest();
		
		RecordType rt = [SELECT Id, Name FROM RecordType WHERE sObjectType =: 'DF_Contact__c' AND Name =: 'Dementia Friend Champion' AND isActive = TRUE];
		String query = 'SELECT d.Name, d.Id, d.Attended__c, d.Note__c, (Select Id, Event_Status__c, EventAttendeeStatus__c, DF_Event__r.Name From DF_EventAttendees__r) From DF_Contact__c d where d.Attended__c = true and d.RecordTypeId = \'' + rt.Id + '\' LIMIT 200';
		
		
		DFContactAttendeeFlagPhase1 dfcafp1 = new DFContactAttendeeFlagPhase1();
		dfcafp1.query = query;
		
		Database.executeBatch(dfcafp1);
		
		test.stopTest();		    	
    }
}