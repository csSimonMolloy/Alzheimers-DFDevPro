@IsTest global with sharing class WEBRegisterChampionTest {
    @IsTest(SeeAllData=false) global static void registerFriendTest () {
        // Instantiate a new controller with all parameters in the page
        WEBRegisterChampion controller = new WEBRegisterChampion ();

        PageReference registerChampion = Page.WEBRegisterChampion;
       	registerChampion.getParameters().put('recaptcha_challenge_field','test values');
       	registerChampion.getParameters().put('recaptcha_response_field','test values');
       	test.setCurrentPage(registerChampion);

       	controller = new WEBRegisterChampion ();
                
        System.assertNotEquals(controller,null);  

		controller.title = 'Mr';
		controller.firstName = 'Test';
		controller.lastName = 'Test';
		controller.postCode = 'Test';
		controller.telephone = '01111111111';
		controller.emailAddress = 'Test@Test.com';
		controller.password = 'Test';
		controller.password2 = 'Test';
		controller.newsletter = FALSE;

		System.assertNotEquals(null,controller.verify());
		System.assertEquals(null,controller.reset());

        System.assertEquals(controller.registerChampion(), null);                         
    }    
    
     @IsTest(SeeAllData=false) 
     global static void registerFriendTestEmptyVals () {
        // Instantiate a new controller with all parameters in the page
        WEBRegisterChampion controller = new WEBRegisterChampion ();

        PageReference registerChampion = Page.WEBRegisterChampion;
       	
       	test.setCurrentPage(registerChampion);

       	controller = new WEBRegisterChampion ();
                
        System.assertNotEquals(controller,null);  

		controller.title = '';
		controller.firstName = '';
		controller.lastName = '';
		controller.postCode = '';
		controller.telephone = '';
		controller.emailAddress = '';
		controller.password = '';
		controller.password2 = '';
		
		controller.verify();
		controller.reset();
		
		//System.assertEquals(null,controller.verify());
		//System.assertEquals(null,controller.reset());
		controller.registerChampion();
        //System.assertEquals(controller.registerChampion(), null);                         
    }    
}