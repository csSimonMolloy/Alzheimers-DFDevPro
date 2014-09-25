/******************************************************************************************
 *  Cloud Symphony
 *  
 *  Purpose : APEX controller class for VF Page WEBChampion.
 *  Author  : CSL
 *  Date    : 27-02-2014
 *  Version : 1.0
 *
 *  Description:    Apex Class that looks after the WEBChampion VF Page.
 *					This class determins what to render for the Champion on the Champion Dashboard
 * 					based on different flags etc.
 *               
 *  Modification History
 *  Date            Who         Description 
 *  27/05/2014		CSL			New code to enable 'You have sessions to be reported on' prompt                  
*******************************************************************************************/
public with sharing class WEBChampion extends WEBController {
	public final String CHAMPION_CODE = 'Register Champions\' code';
	public final String CHAMPION_CODE_ENTERED = 'Registered Champions\' code';
	public final String INVALID_CHAMPION_CODE = 'The Champions\' code you entered was not recognised. Please try again.';
	public final String ALERT_ERROR_CLASS = 'alert-error';
	public final String STATUS_CANCELLED = 'Cancelled';
	public final String RT_CHAMPION_COURSE = 'Champion_Training_Course';

	public User thisUser {
		get {
			return WEBController.thisUser;
		}
		set;
	}

	public List<DF_Event__c> upcomingEvents {
		get {
			if (upcomingEvents == null){
				upcomingEvents = new List<DF_Event__c>();
			}
			return upcomingEvents;
		}
		set;
	}
	
	public List<DF_Event__c> eventsRequiringFeedback {
		get {
			if (eventsRequiringFeedback == null){
				eventsRequiringFeedback = new List<DF_Event__c>();
			}
			return eventsRequiringFeedback;
		}
		set;
	}

	public Boolean isChampion {get;set;}
	public Boolean isChampionConverted {get; set;}
	public Boolean registeredAsChampion {get;set;}
	public Boolean newChampionRegistration {get; set;}
	public Boolean showReportingPrompt {get; set;}

	public String championCode {get;set;}
	public String championCodeError {get;set;}
	public String championCodeText {get;set;}

	public String messageArea {get;set;}
	public String messageAreaClass {get;set;}

	public Integer sessionCount {get;set;}
	public Integer friendCount {get;set;}
	public Integer friendActionCount {get;set;}
	public boolean isTraining {get; set;}
	public boolean isSession {get; set;}
	public boolean showViewDetailsButton {get; set;}
	public boolean showSaveConfirmation {get; set;}
	
	public Map<Id, RecordType> rtMap {get; set;}
	public Map<String, RecordType> rtMapByName {get; set;}
	
	public List<DF_EventAttendee__c> myTraining {get; set;}
	
	public DF_Contact__c contact {get; set;}
	
	public Page_Snippet__c totalFriendsSnippet {
		get {
			if (totalFriendsSnippet == null){
				totalFriendsSnippet = [select p.Body_Text__c, p.Unique_Name__c from Page_Snippet__c p where p.Unique_Name__c = 'DementiaFriendsTotalSnippet' LIMIT 1];
			}
			return totalFriendsSnippet;
		}
		set ;
	}

	public PageReference registerCode() {
		messageArea = null;
		messageAreaClass = null;
		championCodeError = '';
		if (championCode.length() == 0) {
			messageArea = INVALID_CHAMPION_CODE;
			messageAreaClass = ALERT_ERROR_CLASS;
		}else{
			system.debug('*** -- Registering code ' + championCode + ' -- ***');
			registeredAsChampion = WEBConversionClass.convertFriendToChampion(thisUser.ContactId, championCode);
			
			List<DF_Contact__c> contacts = [SELECT Id, Number_of_Friends_Influenced__c, Code_Verefied__c, Status__c FROM DF_Contact__c WHERE Portal_Contact__r.Id = :WEBController.thisUser.ContactId LIMIT 1];
			contact = null;

			if (!contacts.isEmpty()){
				contact = contacts[0];
			}
			
			isChampion = WEBConversionClass.isChampion(thisUser.contactId);
			isChampionConverted = WEBConversionClass.isChampionConverted(thisUser.contactId);
			if (!contact.Code_Verefied__c){
				messageArea = INVALID_CHAMPION_CODE;
				messageAreaClass = ALERT_ERROR_CLASS;
			}
			
		}
		return null;
	}

	public PageReference convertBackToFriend() {
		system.debug('*** -- Into convertBackToFriend -- ***');
		Boolean isSuccess = WEBConversionClass.convertChampionToFriend(thisUser.contactId, WEBGlobalSettings.friendConvertCode);
		system.debug('*** -- Conversion returned : ' + isSuccess + ' -- ***');

		if (isSuccess) {
			PageReference pr = Page.WEBFriend;
			pr.getParameters().put('convertBack', 'TRUE');
			return pr;
		}
		else
			return null;
	}

	public WEBChampion() {
		system.debug('*** -- Into WEBChampion Constructor -- ***');
		sessionCount = 0;
		friendCount = 0;
		friendActionCount = 0;
		registeredAsChampion = FALSE;
		newChampionRegistration = false;
		isSession = false;
		isTraining = false;
		showReportingPrompt = false;
		if (ApexPages.currentPage().getParameters().get('nr') != null){
			newChampionRegistration = true;	
		}
		
		if (ApexPages.currentPage().getParameters().get('ds') != null){
			showSaveConfirmation = true;
		}else {
			showSaveConfirmation = false;
		}

		rtMapByName = new Map<String, RecordType>();
		rtMap = new Map<Id, RecordType>();
		for (RecordType r : [select r.Id, r.DeveloperName from RecordType r where r.SobjectType = 'DF_Event__c' and r.IsActive = true]){
			rtMap.put(r.Id, r);
			rtMapByName.put(r.DeveloperName, r);
		}

		List<DF_Contact__c> contacts = [SELECT Id, Number_of_Friends_Influenced__c, Code_Verefied__c, Status__c FROM DF_Contact__c WHERE Portal_Contact__r.Id = :WEBController.thisUser.ContactId LIMIT 1];

		contact = null;

		if (!contacts.isEmpty())
			contact = contacts[0];

		if (contact != null) {
			friendCount = contact.Number_of_Friends_Influenced__c.intValue();
		}

		upcomingEvents = new List<DF_Event__c>();
		
		for (DF_Event__c dfe : [SELECT Id, Name, Event_Date_Time__c, Street__c, City__c, County__c, Postcode__c, Number_of_Attendees__c, Number_of_Places__c, Number_of_Attendee_Records__c FROM DF_Event__c WHERE Session_Organiser__c = :contact.Id AND Event_Date_Time__c >= TODAY and Event_Status__c != :STATUS_CANCELLED LIMIT 20]){
			if (dfe.Event_Date_Time__c.getTime() > system.now().getTime()){
				upcomingEvents.add(dfe);
			}
		}

		//upcomingEvents = [SELECT Id, Name, Event_Date_Time__c, Street__c, City__c, County__c, Postcode__c, Number_of_Attendees__c, Number_of_Places__c, Number_of_Attendee_Records__c FROM DF_Event__c WHERE Session_Organiser__c = :contact.Id AND Event_Date_Time__c >= TODAY and Event_Status__c != :STATUS_CANCELLED LIMIT 20];
		
		eventsRequiringFeedback = new List<DF_Event__c>();
		for (DF_Event__c dfe : [SELECT Id, Name, Event_Date_Time__c, Street__c, City__c, County__c, Postcode__c, Number_of_Attendees__c, Number_of_Places__c FROM DF_Event__c WHERE Session_Organiser__c = :contact.Id AND Event_Date_Time__c <= TODAY AND (Number_of_Attendees__c = null OR Number_of_Attendees__c = 0) and Event_Status__c != :STATUS_CANCELLED LIMIT 10]){
			
			if (dfe.Event_Date_Time__c.getTime() < system.now().getTime()){
				eventsRequiringFeedback.add(dfe);
			}
		}
		
		//eventsRequiringFeedback = [SELECT Id, Name, Event_Date_Time__c, Street__c, City__c, County__c, Postcode__c, Number_of_Attendees__c, Number_of_Places__c FROM DF_Event__c WHERE Session_Organiser__c = :contact.Id AND Event_Date_Time__c < TODAY AND (Number_of_Attendees__c = null OR Number_of_Attendees__c = 0) and Event_Status__c != :STATUS_CANCELLED LIMIT 10];
		if (eventsRequiringFeedback.size() > 0){
			showReportingPrompt = true;
		}

		List<DF_Event__c> events = [SELECT Id FROM DF_Event__c WHERE Session_Organiser__r.Portal_Contact__r.Id = :WEBController.thisUser.ContactId LIMIT 1000];

		if (events != null && !events.isEmpty())
			sessionCount = events.size();

		isChampion = WEBConversionClass.isChampion(thisUser.contactId);
		isChampionConverted = WEBConversionClass.isChampionConverted(thisUser.contactId);
		system.debug('*** -- WEBChampion isChampion = ' + isChampion + ' -- ***');
		system.debug('*** -- WEBChampion isChampionConverted = ' + isChampionConverted + ' -- ***');
		myTraining = new List<DF_EventAttendee__c>();
		if (isChampionConverted){
				championCodeText = CHAMPION_CODE_ENTERED;
		}else {
				RecordType championRT = rtMapByName.get(RT_CHAMPION_COURSE);
				championCodeText = CHAMPION_CODE;
				myTraining = [SELECT Id, DF_Event__r.Event_Date_Time__c, DF_Event__r.City__c, DF_Event__r.Postcode__c, DF_Event__r.Number_of_Attendees__c, DF_Event__r.RecordTypeId 
							FROM DF_EventAttendee__C WHERE DF_Contact__r.Portal_Contact__c = :thisUser.ContactId
							and DF_Event__r.RecordTypeId = :championRT.Id LIMIT 1];
				if (!myTraining.isEmpty()){
					isTraining = true;
					isSession = false;
					showViewDetailsButton = true;
				}
		}

		system.debug('*** -- WEBChampion Champion Code Text ' + championCodeText + ' -- ***');

		List<DF_EventAttendee__c> myEventContacts = [SELECT DF_Contact__r.Id FROM DF_EventAttendee__c WHERE DF_Event__c = :events LIMIT 1000];

		List<Id> myEventContactsId = new List<Id>();
		
		if (myEventContacts != null && !myEventContacts.isEmpty()) {
		
			for (DF_EventAttendee__c att : myEventContacts) {
				myEventContactsId.add(att.DF_Contact__r.Id);
			}

			List<Action__c> myEventContactsActions = [SELECT Id FROM Action__c WHERE DF_Contact__r.Id = :myEventContactsId LIMIT 1000];
	
			if (myEventContactsActions != null && !myEventContactsActions.isEmpty())
				friendActionCount = myEventContactsActions.size();
		}
	}
}