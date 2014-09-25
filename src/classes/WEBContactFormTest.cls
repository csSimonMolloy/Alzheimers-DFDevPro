/******************************************************************************************
 *  Cloud Symphony
 *  
 *  Purpose : APEX test class for WEBContactForm.
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
@isTest
private class WEBContactFormTest {

    static testMethod void testForm() {
        //TODO : This class will need to be updated once we have the Portal enabled
        //to allow for Is Logged In tests
        
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
         // The following code runs as user 'u' 
         System.debug('Current User: ' + UserInfo.getUserName());
         System.debug('Current Profile: ' + UserInfo.getProfileId()); 
     
               
       	PageReference contactForm = Page.WEBContactForm;
       	contactForm.getParameters().put('recaptcha_challenge_field','test values');
       	contactForm.getParameters().put('recaptcha_response_field','test values');
       	test.setCurrentPage(contactForm);
       	
       
        WEBContactForm wcf = new WEBContactForm();
        
        //Test with no values;
        
        wcf.submitContactForm();
        
        List<WEBContactMessage__c> wcfList;
        wcfList = [select w.Id from WEBContactMessage__c w];
        system.assertEquals(0, wcfList.size());
        
        Schema.DescribeFieldResult F = WEBContactMessage__c.Subject__c.getDescribe();
		List<Schema.Picklistentry> pickListValues = F.getPicklistValues();
		//test with bad values
		
		wcf.firstName = 'Test';
        wcf.lastName = 'Contact';
        wcf.email = 'test';
        wcf.webSubject = pickListValues[0].getValue();
        wcf.webMessage = 'Test Message'; 
        
        wcf.submitContactForm();
        
        wcfList = [select w.Id from WEBContactMessage__c w];
        system.assertEquals(0, wcfList.size());
        
        //test with good values 
        
        wcf.firstName = 'Test';
        wcf.lastName = 'Contact';
        wcf.email = 'test.contact@myemail.com';
        wcf.webSubject = pickListValues[0].getValue();
        wcf.webMessage = 'Test Message'; 
        
        wcf.submitContactForm();
        
        wcfList = [select w.Id from WEBContactMessage__c w];
        system.assertEquals(1, wcfList.size());
       }
        
    }
}