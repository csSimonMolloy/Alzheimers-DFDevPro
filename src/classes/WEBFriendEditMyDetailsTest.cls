@IsTest public with sharing class WEBFriendEditMyDetailsTest {
	@IsTest(SeeAllData=true) public static void friendEditMyDetailsTest() {
		//WEBController.registerUser('Mr', '*** TEST ***', '*** TEST ***', '', 'test@test.com', '12345678ABC', '12345678ABC');
		
		//User usr = [SELECT id, firstName, lastName FROM User WHERE firstName = '*** TEST ***'];

		//User usr = new User();
		//usr.firstName = '*** TEST ***';
		//usr.lastName = '*** TEST ***';
		//usr.email = 'test@test.com';
		//usr.userName = usr.email;
		//usr.CommunityNickname = usr.firstName+usr.lastName;
		//insert usr;

		WEBFriendEditMyDetails controller = new WEBFriendEditMyDetails();
		List<SelectOption> titleList = controller.titleList;
		//controller.thisUser = usr;

		System.assertNotEquals(null,controller.saveUserDetails());

		controller.thisUser.firstName = '';
		controller.thisUser.lastName = '';

		//System.assertEquals(null,controller.saveUserDetails());
		//controller.thisUser = usr;

		//controller.thisUser.firstName = '*** TEST ***';
		//controller.thisUser.lastName = '*** TEST ***';

		//System.assertEquals(null,controller.saveUserDetails());
		
	}
}