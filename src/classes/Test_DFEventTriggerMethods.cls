@isTest
private class Test_DFEventTriggerMethods{
	
	private static String FRIEND_RT_NAME = 'Dementia_Friend';
	private static String CHAMPION_RT_NAME = 'Dementia_Friend_Champion';
	private static String SESSION_RT_NAME = 'Dementia_Friend_Awareness_Session';
	private static String TRAINING_RT_NAME = 'Champion_Training_Course';
	private static String STATUS_CANCELLED = 'Cancelled';
	
	private static User adminUser;
	private static User guestUser;
	private static User portalUser;
	private static Contact contactRecord;
	private static Contact soContactRecord;
	private static DF_Contact__c sessionOrganiser;
	private static DF_Contact__c dfContactRecord;
	private static DF_Event__c testSession;
	private static DF_Event__c testTraining;
	private static DF_EventAttendee__c dfe1;

     
     @isTest static void testDFEventTriggerMethods() {
        try{
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseDFeventGenerator());        
           
            Saved_Search__c ssavedsearch= new Saved_Search__c();
            ssavedsearch.Post_Code__c = '560033';
            ssavedsearch.Email__c = 'test@gmail.com';
            ssavedsearch.Sent_Mail__c= false;
            ssavedsearch.Range__c = 5;
            ssavedsearch.Geolocation__Latitude__s = 30;
            ssavedsearch.Geolocation__Longitude__s = 30;
            insert ssavedsearch;
            
            DF_Contact__c contact = new DF_Contact__c();
            contact.First_Name__c = 'simon';
            contact.Last_Name__c= 'molloy';
            contact.Name = 'simonm';
            insert contact;
            
            DF_Event__c dfevent= new DF_Event__c();
            dfevent.Postcode__c = '560033';
            dfevent.Location_Geographic_Details__Latitude__s = 30;
            dfevent.Location_Geographic_Details__Longitude__s = 30;
            dfevent.Session_Organiser__c = contact.id;
            insert dfevent;
            
            DF_Event__c dfevent1 = new DF_Event__c();
            dfevent1.Postcode__c = '516001';
            dfevent1.Session_Organiser__c = contact.id;
            insert dfevent1;
            
            
            Set<Id> dfeventIds = new Set<Id>();
            dfeventIds.add(dfevent.Id);            
            dfeventIds.add(dfevent1.Id); 
           
            DFEventTriggerMethods.sendEmailToMembers(dfeventIds); 
            Double d1 = 90.0;
            Double d2 = 60.0;
            Double d3 = 70.0;
            Double d4 = 50.0;
            
            DFEventTriggerMethods.calculateDistance(d1,d2,d3,d4);
        }
        catch(Exception e){}     
      
    } 
    
    @isTest static void testDFEventTriggerMethods2() {
        try{
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseDFeventGenerator());        
           
            Saved_Search__c ssavedsearch= new Saved_Search__c();
            ssavedsearch.Post_Code__c = '560033';
            ssavedsearch.Email__c = 'test@gmail.com';
            ssavedsearch.Sent_Mail__c= false;
            ssavedsearch.Geolocation__Latitude__s = 30;
            ssavedsearch.Geolocation__Longitude__s = 30;
            insert ssavedsearch;
            
            DF_Contact__c contact = new DF_Contact__c();
            contact.First_Name__c = 'simon';
            contact.Last_Name__c= 'molloy';
            contact.Name = 'simonm';
            insert contact;
            
            DF_Event__c dfevent= new DF_Event__c();
            dfevent.Postcode__c = '560033';
            dfevent.Location_Geographic_Details__Latitude__s = 30;
            dfevent.Location_Geographic_Details__Longitude__s = 30;
            dfevent.Session_Organiser__c = contact.id;
            insert dfevent;
            
            DF_Event__c dfevent1 = new DF_Event__c();
            dfevent1.Postcode__c = '516001';
            dfevent1.Session_Organiser__c = contact.id;
            insert dfevent1;
            
            
            Set<Id> dfeventIds = new Set<Id>();
            dfeventIds.add(dfevent.Id);            
            dfeventIds.add(dfevent1.Id); 
           
            DFEventTriggerMethods.sendEmailToMembers(dfeventIds); 
            Double d1 = 90.0;
            Double d2 = 60.0;
            Double d3 = 70.0;
            Double d4 = 50.0;
            
            DFEventTriggerMethods.calculateDistance(d1,d2,d3,d4);
        }
        catch(Exception e){}     
      
    } 
    
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
	    	dfContactRecord.RecordTypeId = [select r.Id from RecordType r where r.DeveloperName = :FRIEND_RT_NAME and r.SObjectType = 'DF_Contact__c' LIMIT 1].Id;
	    	dfContactRecord.Portal_Contact__c = portalUser.ContactId;
	    	dfContactRecord.First_Name__c = contactRecord.FirstName;
	    	dfContactRecord.Last_Name__c = contactRecord.LastName;
	    	dfContactRecord.Email__c = contactRecord.Email;
	    	if (dfContactRecord.Email__c == null) dfContactRecord.Email__c = 'test.email@myemail.com';
	    	insert dfContactRecord;
    	}else {
    		dfContactRecord = dfConList[0];
    	}
    	
    	List<DF_Contact__c> soDFConList = new List<DF_Contact__c>();
    	soDFConList = [select d.First_Name__c, d.Last_Name__c, d.Email__c, d.RecordTypeId, d.Portal_Contact__c from DF_Contact__c d where d.Portal_Contact__c = :soContactRecord.Id LIMIT 1];
    	if (soDFConList.size() == 0){
    		sessionOrganiser = new DF_Contact__c();
	    	sessionOrganiser.RecordTypeId = [select r.Id from RecordType r where r.DeveloperName = :FRIEND_RT_NAME and r.SObjectType = 'DF_Contact__c' LIMIT 1].Id;
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
    	
    	dfe1 = new DF_EventAttendee__c();
		dfe1.DF_Contact__c = dfContactRecord.Id;
		dfe1.DF_Event__c = testSession.Id;
		system.debug('*** -- Test Code Debug 2 - ' + dfe1.DF_Contact__r.Portal_Contact__c + ' -- ***');
		//This should fire the first trigger
		insert dfe1;
    	
	}
	
	@IsTest(SeeAllData=true)
    static void testSessionTrigger() {
		setupSystemData();
		
		//Update the session and save it - this should fire the 'update' email 
		testSession.Event_Description__c = 'This is an update';
		update testSession;
		
		//Now we cancel the session, and this should fire the 'cancellation' email
		testSession.Event_Status__c = STATUS_CANCELLED;
		update testSession; 
		    	
    }
}