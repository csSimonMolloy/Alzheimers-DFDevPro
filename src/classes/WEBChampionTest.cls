/******************************************************************************************
 *  Cloud Symphony
 *  
 *  Purpose : APEX test class for WEBChampion.
 *  Author  : CSL
 *  Date    : 27-02-2014
 *  Version : 1.0
 *
 *  Description:    Apex test class.
 *               
 *  Modification History
 *  Date            Who         Description 
 *                    
*******************************************************************************************/
@isTest(seeAllData=false)
public with sharing class WEBChampionTest {
		static testMethod void championTest() {
			
		Account a = new Account(Name='Test Account Name');
  		insert a;
        
        Contact c = new Contact();
            c.firstname = 'Test';
            c.LastName = 'TestContact';
            c.AccountId = a.Id;
            c.Email = 'test.testcontact@myemail.com';
            insert c;
            
        Partner_Organisation__c po = new Partner_Organisation__c();
        po.Name = 'Test';
        po.DFC_Code__c = 'abc123';
        insert po;
            
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
        
        /*DF_Contact__c DFc = [SELECT Id,Code_Verefied__c FROM DF_Contact__c WHERE Portal_Contact__c=:c.Id ];
        
        DFc.Code_Verefied__c = true;
        update DFc;*/
        
       System.runAs(user1) {	
			
		WEBChampion controller;
	    
	    Test.startTest();
	    controller = new WEBChampion();

	    controller.championCode = '';
	    
	    system.assertEquals(null,controller.registerCode());

	   	controller.championCode = 'abc123';
	    
	    system.assertEquals(null,controller.registerCode());

	    system.assertNotEquals(null,controller.convertBackToFriend());
	    
	    Test.stoptest();
       }
	}
}