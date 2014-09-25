@IsTest global with sharing  class WEBFriendCreateActionTest {
	@IsTest(SeeAllData=false) global static void createActionTest() {
		DF_Contact__c c = new DF_Contact__c();
		c.Portal_Contact__c = WEBController.thisUser.ContactId;
		c.First_Name__c = '*** TEST ***';
		c.Last_Name__c = '*** TEST ***';
		c.Email__c = 'test.test@myemail.com';
		insert c;

		WEBFriendCreateAction controller = new WEBFriendCreateAction ();

        System.assertNotEquals(controller, null);

        controller.publicCheckbox = TRUE;
		controller.action = '***';

		System.assertNotEquals(null, controller.cancel());
		System.assertNotEquals(null, controller.save());
	}
	
	@IsTest(SeeAllData=false) global static void createActionTestWithAction() {
		DF_Contact__c c = new DF_Contact__c();
		c.Portal_Contact__c = WEBController.thisUser.ContactId;
		c.First_Name__c = '*** TEST ***';
		c.Last_Name__c = '*** TEST ***';
		c.Email__c = 'test.test@myemail.com';
		insert c;
		
		Action__c act = new Action__c();
		act.DF_Contact__c = c.Id;
		act.Action__c = '*** TEST ***';
		insert act;
		
		
		PageReference pr = Page.WEBFriendCreateAction;
		pr.getParameters().put('Id',act.Id);
		test.setCurrentPage(pr);
		
		WEBFriendCreateAction controller = new WEBFriendCreateAction ();

        System.assertNotEquals(controller, null);

        controller.publicCheckbox = TRUE;
		controller.action = '***';

		System.assertNotEquals(null, controller.cancel());
		System.assertNotEquals(null, controller.save());
	}
}