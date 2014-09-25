/**
 * An apex page controller that exposes the site login functionality
 */
@IsTest global with sharing class WEBLoginTest {
    @IsTest(SeeAllData=false) global static void loginTest () {
        // Instantiate a new controller with all parameters in the page
        WEBLogin controller = new WEBLogin ();
        controller.emailAddress = 'test@salesforce.com';
        controller.password = '123456'; 
                
        System.assertEquals(controller.login(),null); 
        
        WEBLogin controller2 = new WEBLogin ();
        controller2.emailAddress = '';
        controller2.password = ''; 
                
        System.assertEquals(controller2.login(),null);                           
    }    
}