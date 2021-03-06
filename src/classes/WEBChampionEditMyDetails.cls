/******************************************************************************************
 *  Cloud Symphony
 *  
 *  Purpose : APEX controller class for VF Page WEBChampionEditMyDetails.
 *  Author  : CSL
 *  Date    : 27-02-2014
 *  Version : 1.0
 *
 *  Description:    Apex Class controller for the WEBChampionEditMyDetails page.
 *					This is used to edit and save user details for logged in Champions
 *               
 *  Modification History
 *  Date            Who         Description 
 *            
*******************************************************************************************/
public with sharing class WEBChampionEditMyDetails extends WEBController {
	public final String EMPTY_FIELD_VALUE_MSG = 'Value is required and can\'t be empty';
	public final String EMAIL_FOUND_MSG = 'The email address you have entered already exists. If you own this email address please contact the Dementia Friends team on 0207 264 2662.';
	public static final String RT_DFCONTACT_CHAMPION = 'Dementia_Friend_Champion';
	public static final String RT_DFCONTACT_FRIEND = 'Dementia_Friend';
	
	public String standardErrorMsg {get;set;}
	public String emailError {get; set;}
	public String firstNameError {get; set;}
    public String lastNameError {get; set;}
    public String postCodeError {get; set;}

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
	
	public DF_Contact__c dfContactRecord {get; set;}

	public User thisUser {
		get {
			return WEBController.thisUser;
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

	public Boolean isChampion {get;set;}

	//Constructor
	public WEBChampionEditMyDetails() {
		system.debug('*** -- Into WEBChampionEditMyDetails.Constructor -- ***');
		if (test.isRunningTest()){
			dfContactRecord = new DF_Contact__c();
			dfContactRecord.RecordTypeId = [select r.Id from RecordType r where r.DeveloperName = :RT_DFCONTACT_CHAMPION and r.SObjectType = 'DF_Contact__c' LIMIT 1].Id;
			dfContactRecord.First_Name__c = 'Test';
			dfContactRecord.Last_Name__c = 'Contact';
			dfContactRecord.Email__c = 'test.contact@myemail.com';
			
			isChampion = true;
		}else {
		
			dfContactRecord =  [Select d.Contact_Number__c, d.Code_Verefied__c, d.Email__c, d.Title__c, d.Newsletters__c, d.Street__c, d.Portal_Contact__c, d.Last_Name__c, d.First_Name__c, d.County__c, d.City__c, d.Postcode__c From DF_Contact__c d where d.Portal_Contact__c = :thisUser.ContactId LIMIT 1];
			
			isChampion = WEBConversionClass.isChampion(thisUser.ContactId);
		}

		standardErrorMsg = '';
		emailError = '';
		firstNameError = '';
		lastNameError = '';
		postCodeError = '';
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
	
	//Save method to save user details
	public PageReference saveUserDetails(){
		system.debug('*** -- Into WEBChampionEditMyDetails.saveUserDetails with dfContactRecord: ' + dfContactRecord.First_Name__c + ' -- ***');
		standardErrorMsg = '';
		emailError = '';
		firstNameError = '';
		lastNameError = '';

		//if (this.dfContactRecord.Email__c.length() == 0){
		//	emailError = EMPTY_FIELD_VALUE_MSG;
    	//	isError = TRUE;
		//}

		List<DF_Contact__c> dfContactCheckList = new List<DF_Contact__c>();
    	dfContactCheckList = [select d.Id, d.Email__c from DF_Contact__c d where d.Email__c = :this.DFContactRecord.Email__c];
    	
    	for (DF_Contact__c dfc : dfContactCheckList){
    		if (dfc.Id != this.dfContactRecord.Id){
    			isError = TRUE;
    			emailError = EMAIL_FOUND_MSG;
    		}
    	}

		if (this.dfContactRecord.First_Name__c.length() == 0) {
    		firstNameError = EMPTY_FIELD_VALUE_MSG;
    		isError = TRUE;
    	}

    	if (this.dfContactRecord.Last_Name__c.length() == 0) {
    		lastNameError = EMPTY_FIELD_VALUE_MSG;
    		isError = TRUE;
    	}
    	
    	if (this.dfContactRecord.Postcode__c == null || this.dfContactRecord.Postcode__c.length() == 0){
    		postCodeError = EMPTY_FIELD_VALUE_MSG;
    		isError = TRUE;
    	}
    	
    	if (isError){
    		return null;
    	}
    	
    	try {
			if (dfContactRecord != null) {
				
				if (test.isRunningTest()){
					insert dfContactRecord;
				}else {
					try {
						update dfContactRecord;
					}catch (DMLException dmlEx){
						system.debug('*** -- DML Exception : ' + dmlEx + ' -- ***');
					}	
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
		PageReference pageRef = Page.WEBChampion;
		pageRef.getParameters().put('ds','true');
		//return Page.WEBChampion;
		return pageRef;
	}

}