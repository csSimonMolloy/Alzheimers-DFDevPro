/******************************************************************************************
 *  Cloud Symphony
 *  
 *  Purpose : APEX controller class for VF Page WEBChampionManageMySessions.
 *  Author  : CSL
 *  Date    : 27-02-2014
 *  Version : 1.0
 *
 *  Description:    Apex Class controller for the WEBChampionManageMySessions page.
 *               
 *  Modification History
 *  Date            Who         Description 
 *             
*******************************************************************************************/
public with sharing class WEBChampionManageMySessions extends WEBController {
	public final String STATUS_AVAILABLE = 'Available';
	public final String STATUS_CANCELLED = 'Cancelled';
	public final String STATUS_FULL = 'Full';


	public List<DF_Event__c> upcomingEvents {
		get {
			if (upcomingEvents == null)
				upcomingEvents = new List<DF_EVENT__c>();
			
			return upcomingEvents;
		}
		set;
	}

	public List<DF_Event__c> pastEvents {
		get {
			if (pastEvents == null)
				pastEvents = new List<DF_EVENT__c>();
			
			return pastEvents;
		}
		set;
	}

	public List<DF_Event__c> eventsRequiringFeedback {
		get {
			if (eventsRequiringFeedback == null)
				eventsRequiringFeedback = new List<DF_EVENT__c>();
			
			return eventsRequiringFeedback;
		}
		set;
	}

	public Integer noUpcomingEvents {get;set;}
	public Integer noPastEvents {get;set;}
	public Integer noEventsRequiringFeedback {get;set;}

	public Boolean isChampion {get;set;}
	public Boolean isConverted {get; set;}

	public String messageArea {get;set;}
	public String messageAreaClass {get;set;}

	public Page_Snippet__c totalFriendsSnippet {
		get {
			if (totalFriendsSnippet == null){
				totalFriendsSnippet = [select p.Body_Text__c, p.Unique_Name__c from Page_Snippet__c p where p.Unique_Name__c = 'DementiaFriendsTotalSnippet' LIMIT 1];
			}
			return totalFriendsSnippet;
		}
		set ;
	}
	
	//Constructor
	public WEBChampionManageMySessions() {

		List<DF_Contact__c> contacts = [SELECT Id FROM DF_Contact__c WHERE Portal_Contact__r.Id = :WEBController.thisUser.ContactId LIMIT 1];
		
		DF_Contact__c contact = null;

		System.debug('*** WEBChampionManageMySessions : Checking User');

		isChampion = WEBController.isChampion;
		isConverted = WEBController.isChampionConverted;
		noPastEvents = 0;
		noUpcomingEvents = 0;
		noEventsRequiringFeedback = 0;

		System.debug('*** WEBChampionManageMySessions : User Champion ' + isChampion);

		if (!contacts.isEmpty())
			contact = contacts[0];

		if (contact != null) {
			
			eventsRequiringFeedback = new List<DF_Event__c>();
			upcomingEvents = new List<DF_Event__c>();
			pastEvents = new List<DF_Event__c>();
			for (DF_Event__c dfe : [SELECT Id, Name, Event_Date_Time__c, Street__c, City__c, County__c, Postcode__c, Number_of_Attendees__c, Number_of_Places__c FROM DF_Event__c WHERE Event_Status__c != :STATUS_CANCELLED AND Session_Organiser__c = :contact.Id AND Event_Date_Time__c <= TODAY AND (Number_of_Attendees__c = null OR Number_of_Attendees__c = 0) ORDER BY Event_Date_Time__c DESC]){
				if (dfe.Event_Date_Time__c.getTime() < system.now().getTime()){
					eventsRequiringFeedback.add(dfe);
				}else {
					upcomingEvents.add(dfe);
				}
			}
			for (DF_Event__c dfe : [SELECT Id, Name, Event_Date_Time__c, Street__c, City__c, County__c, Postcode__c, Number_of_Attendees__c, Number_of_Places__c FROM DF_Event__c WHERE Session_Organiser__c = :contact.Id AND Event_Date_Time__c > TODAY and Event_Status__c != :STATUS_CANCELLED ORDER BY Event_Date_Time__c DESC]){
				if (dfe.Event_Date_Time__c.getTime() > system.now().getTime()){
					upcomingEvents.add(dfe);
				}
			}
			//eventsRequiringFeedback = [SELECT Id, Name, Event_Date_Time__c, Street__c, City__c, County__c, Postcode__c, Number_of_Attendees__c, Number_of_Places__c FROM DF_Event__c WHERE Event_Status__c != 'Cancelled' AND Session_Organiser__c = :contact.Id AND Event_Date_Time__c < TODAY AND (Number_of_Attendees__c = null OR Number_of_Attendees__c = 0) ORDER BY Event_Date_Time__c DESC];
			//upcomingEvents = [SELECT Id, Name, Event_Date_Time__c, Street__c, City__c, County__c, Postcode__c, Number_of_Attendees__c, Number_of_Places__c FROM DF_Event__c WHERE Session_Organiser__c = :contact.Id AND Event_Date_Time__c >= TODAY and Event_Status__c != :STATUS_CANCELLED ORDER BY Event_Date_Time__c DESC];
			for (DF_Event__c dfe : [SELECT Id, Name, Event_Date_Time__c, Street__c, City__c, County__c, Postcode__c, Number_of_Attendees__c, Number_of_Places__c FROM DF_Event__c WHERE Session_Organiser__c = :contact.Id AND Event_Date_Time__c <= TODAY AND Number_of_Attendees__c > 0 ORDER BY Event_Date_Time__c DESC]){
				if (dfe.Event_Date_Time__c.getTime() < system.now().getTime()){
					pastEvents.add(dfe);
				}
			}
			//pastEvents = [SELECT Id, Name, Event_Date_Time__c, Street__c, City__c, County__c, Postcode__c, Number_of_Attendees__c, Number_of_Places__c FROM DF_Event__c WHERE Session_Organiser__c = :contact.Id AND Event_Date_Time__c <= TODAY AND Number_of_Attendees__c > 0 ORDER BY Event_Date_Time__c DESC];
		}

		if (eventsRequiringFeedback != null){
			noEventsRequiringFeedback = eventsRequiringFeedback.size();
		}
		
		if (pastEvents != null){
			noPastEvents = pastEvents.size();
		}
		
		if (upcomingEvents != null) {
			noUpcomingEvents = upcomingEvents.size();
		}
	}
}