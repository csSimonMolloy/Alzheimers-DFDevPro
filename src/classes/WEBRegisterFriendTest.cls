@IsTest global with sharing class WEBRegisterFriendTest {
    @IsTest(SeeAllData=false) global static void registerFriendTest () {
        // Instantiate a new controller with all parameters in the page
        WEBRegisterFriend controller = new WEBRegisterFriend ();

        PageReference registerFriend = Page.WEBRegisterFriend;
       	registerFriend.getParameters().put('recaptcha_challenge_field','test values');
       	registerFriend.getParameters().put('recaptcha_response_field','test values');
       	test.setCurrentPage(registerFriend);

       	controller = new WEBRegisterFriend ();
                
        System.assertNotEquals(controller,null);  
        
        controller.title = '';
		controller.firstName = '';
		controller.lastName = '';
		controller.postCode = '';
		controller.telephone = '';
		controller.emailAddress = '';
		controller.password = '';
		controller.password2 = '';
        
        controller.registerFriend();

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

        System.assertEquals(controller.registerFriend(), null);                         
    }    
}