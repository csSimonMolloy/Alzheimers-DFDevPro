/*
* 2014-03-17 : SM : Test class for the BatchContactCreate class
 */
@isTest
private class TestBatchContactCreate {

	private static final String RT_NEWSLETTER = 'E_Newsletter_Subscriber';
	private static final String RT_DEMENTIA_FRIEND = 'Dementia_Friend';
	private static final String RT_DEMENTIA_FRIEND_CHAMPION = 'Dementia_Friend_Champion';

    static testMethod void testBatchCreate() {
    	Account portalAccount = new Account(Name = '** PORTAL REGISTRATION ACCOUNT **');
    	insert portalAccount;
    	
    	Map<String, RecordType> dfContactRTMap = new Map<String, RecordType>();
		for (RecordType r : [select r.Id, r.DeveloperName from RecordType r where r.IsActive = true and r.SObjectType = 'DF_Contact__c']){
			dfContactRTMap.put(r.DeveloperName, r);
		}
		
		List<DF_Contact__c> contactsToSave = new List<DF_Contact__c>();
    	
 	    for(integer i = 0; i<85; i++){
	    	DF_Contact__c dfc = new DF_Contact__c();
	    	dfc.RecordTypeId = dfContactRTMap.get(RT_DEMENTIA_FRIEND).Id;
	    	dfc.First_Name__c = 'DFirst' + i;
	    	dfc.Last_Name__c = 'DLast'+i;
	    	dfc.Email__c = 'dfirst' + i + '.dlast' + i + '@myemail.com';
	    	contactsToSave.add(dfc);
		}
		
		for(integer i = 0; i<85; i++){
	    	DF_Contact__c dfc = new DF_Contact__c();
	    	dfc.RecordTypeId = dfContactRTMap.get(RT_DEMENTIA_FRIEND_CHAMPION).Id;
	    	dfc.First_Name__c = 'CFirst' + i;
	    	dfc.Last_Name__c = 'CLast'+i;
	    	dfc.Email__c = 'cfirst' + i + '.clast' + i + '@myemail.com';
	    	contactsToSave.add(dfc);
		}
		
		for(integer i = 0; i<30; i++){
	    	DF_Contact__c dfc = new DF_Contact__c();
	    	dfc.RecordTypeId = dfContactRTMap.get(RT_NEWSLETTER).Id;
	    	dfc.First_Name__c = 'EFirst' + i;
	    	dfc.Last_Name__c = 'ELast'+i;
	    	dfc.Email__c = 'efirst' + i + '.elast' + i + '@myemail.com';
	    	contactsToSave.add(dfc);
	    	
	    	if (i == 0) system.debug('*** -- dfcEmail = ' + dfc.Email__c + ' -- ***');
		}
   
   		insert contactsToSave;
   		
   		test.startTest();
   		
   		BatchContactCreate bcc = new BatchContactCreate();
   		bcc.query = 'Select d.Title__c, d.Street__c, d.Status__c, d.RecordTypeId, d.Postcode__c, d.Portal_Contact__c, d.Last_Name__c, d.Id, d.First_Name__c, d.Email__c, d.County__c, d.Country__c, d.Contact_Number__c, d.City__c, d.Newsletters__c From DF_Contact__c d where d.Portal_Contact__c = \'\' LIMIT 200';
   		
   		ID batchprocessid = Database.executeBatch(bcc);

		test.stopTest();

		RecordType rtNewsLetter = [select r.Id from RecordType r where r.DeveloperName = :RT_NEWSLETTER and SObjectType = 'Contact' LIMIT 1];
		RecordType rtFriend = [select r.Id from RecordType r where r.DeveloperName = :RT_DEMENTIA_FRIEND and SObjectType = 'Contact' LIMIT 1];
		RecordType rtChampion = [select r.Id from RecordType r where r.DeveloperName = :RT_DEMENTIA_FRIEND_CHAMPION and SObjectType = 'Contact' LIMIT 1];

		List<Contact> newsLetterContacts = [select c.Id from Contact c where c.RecordTypeId = :rtNewsLetter.Id];
		List<Contact> friendContacts = [select c.Id from Contact c where c.RecordTypeId = :rtFriend.Id];
		List<Contact> championContacts = [select c.Id from Contact c where c.RecordTypeId = :rtChampion.Id];
   		
   		system.assertNotEquals(null, newsLetterContacts);
   		system.debug('*** -- newsLetterContacts.size = ' + newsLetterContacts.size() + ' -- ***');
   		system.assertNotEquals(null, friendContacts);
   		system.assertNotEquals(null, championContacts);
   		
   		DF_Contact__c dfcNewsLetter = [select d.Id, d.Portal_Contact__c from DF_Contact__c d where d.Email__c = 'efirst0.elast0@myemail.com' LIMIT 1];
   		DF_Contact__c dfcFriend = [select d.Id, d.Portal_Contact__c from DF_Contact__c d where d.Email__c = 'dfirst0.dlast0@myemail.com' LIMIT 1];
   		DF_Contact__c dfcChampion = [select d.Id, d.Portal_Contact__c from DF_Contact__c d where d.Email__c = 'cfirst0.clast0@myemail.com' LIMIT 1];
   		
   		Contact cNewsLetter = [select c.Id, c.DF_Contact__c from Contact c where c.Email = 'efirst0.elast0@myemail.com' LIMIT 1];
   		Contact cFriend = [select c.Id, c.DF_Contact__c from Contact c where c.Email = 'dfirst0.dlast0@myemail.com' LIMIT 1];
   		Contact cChampion = [select c.Id, c.DF_Contact__c from Contact c where c.Email = 'cfirst0.clast0@myemail.com' LIMIT 1];
   		
   		system.debug('*** -- dfcNewsLetter ID = ' + dfcNewsLetter.Portal_Contact__c + ' -- ***');
   		system.debug('*** -- dfcFriend ID = ' + dfcFriend.Portal_Contact__c + ' -- ***');
   		system.debug('*** -- dfcChampion ID = ' + dfcChampion.Portal_Contact__c + ' -- ***');
   		
   		system.debug('*** -- cNewsLetter ID = ' + cNewsLetter.Id + ' -- ***');
   		system.debug('*** -- cFriend ID = ' + cFriend.Id + ' -- ***');
   		system.debug('*** -- cChampion ID = ' + cChampion.Id + ' -- ***');
   		

    }
}