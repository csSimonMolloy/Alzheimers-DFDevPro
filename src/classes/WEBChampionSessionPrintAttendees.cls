/******************************************************************************************
 *  Cloud Symphony
 *  
 *  Purpose : APEX controller class for VF Page WEBChampionSessionPrintAttendees.
 *  Author  : CSL
 *  Date    : 27-02-2014
 *  Version : 1.0
 *
 *  Description:    Apex Class controller for the WEBChampionSessionPrintAttendees class.
 *					This returns the relevent event record to the page for rendering as PDF
 *               
 *  Modification History
 *  Date            Who         Description 
 *  2014-07-28		CSL			Changing the code that brings in the DF Event Attendees so it doesn't
 *								look at records with status CANCELLED          
*******************************************************************************************/
public with sharing class WEBChampionSessionPrintAttendees extends WEBController {

	public final String STATUS_CANCELLED = 'Cancelled';
	public Boolean isChampion {get;set;}

	public List<DF_EventAttendee__c> attendees {
		get {
			if (attendees == null)
				attendees = new List<DF_EventAttendee__c>();
			return attendees;
		}
		set;
	}

	public String messageArea {get;set;}
	public String messageAreaClass {get;set;}

	public Integer noOfAttendees {
		get {
			return attendees.size();
		}
	}

	//Constructor
	public WEBChampionSessionPrintAttendees() {
		isChampion = WEBController.isChampion;

		String currentSession = ApexPages.currentPage().getParameters().get('eventId');

        if (currentSession != null) {
            System.debug('*** Found Event Parameter ' + currentSession);
                
            attendees = [SELECT Id, DF_Contact__r.Title__c, DF_Contact__r.First_Name__c, DF_Contact__r.Last_Name__c, DF_Contact__r.Email__c 
            			FROM DF_EventAttendee__c 
            			WHERE DF_Event__r.Id = :currentSession
            			AND Event_Status__c != :STATUS_CANCELLED];
		}
	}
}