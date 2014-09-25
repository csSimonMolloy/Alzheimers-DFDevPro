/******************************************************************************************
 *  Cloud Symphony
 *  
 *  Purpose : APEX controller class for VF Page WEBFriendEditMyDetails.
 *  Author  : CSL
 *  Date    : 27-02-2014
 *  Version : 1.0
 *
 *  Description:    Apex Class controller for the WEBFriendEditMyDetails page.
 *					This controller will look after editing and viewing profile information 
 *					from the DF_Contact__c record
 *               
 *  Modification History
 *  Date            Who         Description 
 *            
*******************************************************************************************/
public with sharing class WEBFriendEditMyDetails extends WEBController {
	public final String EMPTY_FIELD_VALUE_MSG = 'Value is required and can\'t be empty';
	public final String EMAIL_FOUND_MSG = 'The email address you have entered already exists. If you own this email address please contact the Dementia Friends team on 0207 264 2662.';
	public static final String RT_CONTACT_CHAMPION = 'Dementia_Friend_Champion';
	public static final String RT_DFCONTACT_FRIEND = 'Dementia_Friend';
		
	public String standardErrorMsg {get;set;}
	public String emailError {get; set;}
	public String firstNameError {get; set;}
    public String lastNameError {get; set;}

    public Boolean isError = FALSE;

	public List<SelectOption> titleList {
		get {
			if (titleList == null){
				titleList = new List<SelectOption>();
				titleList.add(new SelectOption('-None-','-None-'));
				titleList.add(new SelectOption('Mr.','Mr.'));
				titleList.add(new SelectOption('Mrs.','Mrs.'));
				titleList.add(new SelectOption('Miss.','Miss.'));
				titleList.add(new SelectOption('Ms.','Ms.'));
				titleList.add(new SelectOption('Other','Other'));			
			}
			return titleList;
		}
		set;
	}

	public Page_Snippet__c totalFriendsSnippet {
		get {
			if (totalFriendsSnippet == null){
				totalFriendsSnippet = [select p.Body_Text__c, p.Unique_Name__c from Page_Snippet__c p where p.Unique_Name__c = 'DementiaFriendsTotalSnippet' LIMIT 1];
			}
			return totalFriendsSnippet;
		}
		set ;
	}

	public DF_Contact__c dfContactRecord {get; set;}

	public User thisUser {
		get {
			//if (thisUser == null)
			//	thisUser = WEBController.thisUser;
			//return thisUser;
			return WEBController.thisUser;
		}
		set;
	}

	public WEBFriendEditMyDetails() {
		if (test.isRunningTest()){
			dfContactRecord = new DF_Contact__c();
			dfContactRecord.RecordTypeId = [select r.Id from RecordType r where r.DeveloperName = :RT_DFCONTACT_FRIEND and r.SObjectType = 'DF_Contact__c' LIMIT 1].Id;
			dfContactRecord.First_Name__c = 'Test';
			dfContactRecord.Last_Name__c = 'Contact';
			dfContactRecord.Email__c = 'test.contact@myemail.com';
			
		}else {
			dfContactRecord =  [Select d.Email__c, d.Title__c, d.Newsletters__c, d.Street__c, d.Portal_Contact__c, d.Last_Name__c, d.First_Name__c, d.County__c, d.City__c, d.Postcode__c, d.Contact_Number__c From DF_Contact__c d where d.Portal_Contact__c = :thisUser.ContactId LIMIT 1];
		}
		
		standardErrorMsg = '';
		emailError = '';
		firstNameError = '';
		lastNameError = '';
	}
	
	@Future
	//This needs to be a future call as you can't mix DML statements on setup objects & non setup objects
	public static void updateUserRecord(String userId, String emailAddress, String firstName, String lastName){
		try {
			User u = [select u.Email, u.UserName, u.CommunityNickname, u.Firstname, u.Lastname from User u where u.Id = :userId LIMIT 1];
			u.Firstname = firstName;
			u.Lastname = lastName;
			u.Email = emailAddress;
			u.CommunityNickname = emailAddress;
			u.UserName = emailAddress;
			
			update u;
		}catch (DMLException dmlEx){
			system.debug('*** -- Error saving user : ' + dmlEx + ' -- ***');
		}
	}
	
	public PageReference saveUserDetails(){
		standardErrorMsg = '';
		emailError = '';
		firstNameError = '';
		lastNameError = '';

		//if (this.dfContactRecord.Email__c.length() == 0){
		//	emailError = EMPTY_FIELD_VALUE_MSG;
    	//	isError = TRUE;
		//}

		if (this.dfContactRecord.First_Name__c.length() == 0) {
    		firstNameError = EMPTY_FIELD_VALUE_MSG;
    		isError = TRUE;
    	}

    	if (this.dfContactRecord.Last_Name__c.length() == 0) {
    		lastNameError = EMPTY_FIELD_VALUE_MSG;
    		isError = TRUE;
    	}
    	
    	List<DF_Contact__c> dfContactCheckList = new List<DF_Contact__c>();
    	dfContactCheckList = [select d.Id, d.Email__c from DF_Contact__c d where d.Email__c = :this.DFContactRecord.Email__c];
    	
    	for (DF_Contact__c dfc : dfContactCheckList){
    		if (dfc.Id != this.dfContactRecord.Id){
    			isError = TRUE;
    			emailError = EMAIL_FOUND_MSG;
    		}
    	}
    	
    	if (isError){
    		return null;
    	}
    	
    	try {
			if (dfContactRecord != null) {
				
				if (test.isRunningTest()){
					insert dfContactRecord;
				}else {
					update dfContactRecord;
				}
				
				//Check to see if core data has been changed and if so, update the user record
				if (thisUser.Email != dfContactRecord.Email__c ||
					thisUser.Firstname != dfContactRecord.First_Name__c ||
					thisUser.Lastname != dfContactRecord.Last_Name__c){
						system.debug('*** -- About to call the user save future method -- ***');
						updateUserRecord(thisUser.Id, dfContactRecord.Email__c, dfContactRecord.First_Name__c, dfContactRecord.Last_Name__c);						
					}
				}

		} catch (Exception e) {
			standardErrorMsg = e.getMessage();
		}
		
		PageReference pageRef = Page.WEBFriend;
		pageRef.getParameters().put('ds','true');
		//return Page.WEBChampion;
		return pageRef;
	}
	
	/*
	public PageReference saveUserDetails () {
		standardErrorMsg = '';
		firstNameError = '';
		lastNameError = '';

		if (this.thisUser.firstName.length() == 0) {
    		firstNameError = EMPTY_FIELD_VALUE_MSG;
    		isError = TRUE;
    	}

    	if (this.thisUser.lastName.length() == 0) {
    		lastNameError = EMPTY_FIELD_VALUE_MSG;
    		isError = TRUE;
    	}

    	if (isError)
    		return null;
		
		// Update the Contact Record
		List<Contact> contacts = [SELECT Id, firstName, lastName, Newsletters__c FROM Contact WHERE Id = :thisUser.ContactId LIMIT 1];

		Contact c = null;

		if (contacts.size() > 0)
			c = contacts[0];

		try {
			if (c!=null) {
				
				c.firstName=this.thisUser.firstName;
				c.lastName=this.thisUser.lastName;

				update c;
			}

			update thisUser;

		} catch (Exception e) {
			standardErrorMsg = e.getMessage();
		}
		
		return Page.WEBFriend;
	}
*/
	
}