/******************************************************************************************
 *  Cloud Symphony
 *  
 *  Purpose : APEX test class for WEBChampionEditMyDetails.
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
@IsTest public with sharing class WEBChampionEditMyDetailsTest {
	@IsTest(SeeAllData=true) public static void championEditMyDetailsTest() {

		WEBChampionEditMyDetails controller = new WEBChampionEditMyDetails();
		
		List<SelectOption> titleList = controller.titleList;

		System.assertEquals(null,controller.saveUserDetails());

		controller.thisUser.firstName = '';
		controller.thisUser.lastName = '';
		
		controller.dfContactRecord.First_Name__c = '';
		controller.dfContactRecord.Last_Name__c = '';
		controller.dfContactRecord.Postcode__c = '';

		System.assertEquals(null,controller.saveUserDetails());
		
		test.startTest();
		
		Profile p = [select p.Id from Profile p where p.Name = 'DF HVCP' LIMIT 1];
		
		String profileId = p.Id;
		
		User u = [select u.Id, u.Email, u.FirstName, u.LastName from User u where u.IsActive = true and u.ProfileId = :profileId LIMIT 1];
		
		WEBChampionEditMyDetails.updateUserRecord(u.Id, u.Email, u.FirstName, u.LastName);
		
		test.stopTest();
		
	}
}