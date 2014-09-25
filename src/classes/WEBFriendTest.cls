@isTest(seeAllData=false)
public with sharing class WEBFriendTest {
		static testMethod void friendTest() {
			
		Account a = new Account(Name='Test Account Name');
  		insert a;
        
        Contact c = new Contact();
            c.firstname = 'Test';
            c.LastName = 'TestContact';
            c.AccountId = a.Id;
            c.Email = 'test.testcontact@myemail.com';
            insert c;
            
        Profile profileForUser = [SELECT Id FROM Profile WHERE Name='DF HVCP']; 
		
		User user1 = new User(Alias = 'standt',Email='light@testorg.com',EmailEncodingKey='UTF-8',LastName='Testing', LanguageLocaleKey='en_US', 
                        	  LocaleSidKey='en_US', ProfileId = profileForUser.Id, TimeZoneSidKey='America/Los_Angeles',UserName=Math.random() + '@test.com',ContactId =c.id );
        insert user1;   
        
        DF_Contact__c DFc = new DF_Contact__c();
        DFc.RecordTypeId = [Select Id From RecordType Where DeveloperName=:WEBConversionClass.RT_CONTACT_CHAMPION And sObjectType='DF_Contact__c'].Id;
        DFc.First_Name__c = c.FirstName;
        DFc.Last_Name__c = c.LastName;
        DFc.Email__c = c.Email;
        DFc.Portal_Contact__c = c.Id;
        insert DFc;
        
       System.runAs(user1) {
		
		
		WEBFriend controller;
	    
	    Test.startTest();
	    controller = new WEBFriend();

	    controller.sessionCode = '';
	    
	    system.assertEquals(null,controller.registerCode());

	    controller.sessionCode = WEBGlobalSettings.friendConvertCode;
	    
	    system.assertEquals(null,controller.registerCode());
	    
	    controller.convertToChampion();
	    
	    Test.stoptest();
       }
	}
}