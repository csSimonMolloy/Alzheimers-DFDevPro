@IsTest public with sharing class WEBForgotPasswordTest {
  	 @IsTest(SeeAllData=true) public static void testForgotPassword() {
    	// Instantiate a new controller with all parameters in the page
    	WEBForgotPassword controller = new WEBForgotPassword();
    	Page_Snippet__c ps = controller.forgotPasswordSnippet;
    	controller.emailAddress = 'test@salesforce.com';     	
    
    	System.assertEquals(controller.forgotPassword(),null); 
    }
}