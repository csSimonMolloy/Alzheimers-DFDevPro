/******************************************************************************************
 *  Cloud Symphony
 *  
 *  Purpose : APEX controller class for VF Page WEBChampionSessionFeedback.
 *  Author  : CSL
 *  Date    : 27-02-2014
 *  Version : 1.0
 *
 *  Description:    Apex Class controller for the WEBChampionSessionFeedback class.
 *					This is used to create Session Feedback records for DF Events
 *               
 *  Modification History
 *  Date            Who         Description 
 *            
*******************************************************************************************/
public with sharing class WEBChampionSessionFeedback extends WEBController {
    
    public final String STATUS_CANCELLED = 'Cancelled';
    public final String STATUS_CLOSED = 'Closed';
    
    
    public Boolean isChampion {get;set;}
    public Boolean isConverted {get; set;}
    
    public String messageArea {get;set;}
    public String messageAreaClass {get;set;}

	//2014-05-19 : CSL : Adding in totalFriendsSnippet for display on the VF page
	public Page_Snippet__c totalFriendsSnippet {
		get {
			if (totalFriendsSnippet == null){
				totalFriendsSnippet = [select p.Body_Text__c, p.Unique_Name__c from Page_Snippet__c p where p.Unique_Name__c = 'DementiaFriendsTotalSnippet' LIMIT 1];
			}
			return totalFriendsSnippet;
		}
		set ;
	}

    public DF_Event__c event {
        get {
            if (event == null)
                event = new DF_Event__c();
            return event;
        }
        set;
    }

    public List<SelectOption> sessionList {
        get {
            if (sessionList == null)
                sessionList = new List<SelectOption>();
            return sessionList;
        }
        set;
    }

    public Integer sessionListSize {
        get {
            return sessionList.size();
        }
        set;
    }

    public Boolean thereAreNoSessions {get;set;}

    public String selectedSession {get;set;}

    public Integer noOfAttendees {get;set;}
    public String sessionComments {get;set;}

    public List<DF_Event__c> eventsRequiringFeedback {
        get {
            if (eventsRequiringFeedback == null)
                eventsRequiringFeedback = new List<DF_EVENT__c>();
            
            return eventsRequiringFeedback;
        }
        set;
    }

	//Save method
    public PageReference save() {

        if (event.Id == null && selectedSession != null) {
            event = [SELECT Id, Name, Event_Description__c, Comments__c, Number_of_Attendees__c
                        FROM DF_Event__c
                        WHERE Id = :selectedSession];
        }

        if (event != null) {
            event.Number_of_Attendees__c = noOfAttendees;
            event.Comments__c = sessionComments;
            
            upsert event;
        }
        
        return Page.WEBChampionManageMySessions;
    }
    
    public PageReference cancelSession() {
    	if (event.Id == null && selectedSession != null) {
            event = [SELECT Id, Name, Event_Description__c, Comments__c, Number_of_Attendees__c, Event_Status__c
                        FROM DF_Event__c
                        WHERE Id = :selectedSession];
        }

        if (event != null) {
            event.Event_Status__c = 'Cancelled';
            event.Comments__c = sessionComments;
            
            upsert event;
        }
        
        return Page.WEBChampionManageMySessions;
    }

	//Constructor
    public WEBChampionSessionFeedback() {
        noOfAttendees = 0;
        sessionComments = '';
        thereAreNoSessions = FALSE;

        isChampion = WEBController.isChampion;
        isConverted = WEBController.isChampionConverted;

        String currentSession = ApexPages.currentPage().getParameters().get('eventId');

        if (currentSession != null) {
            System.debug('*** Found Event Parameter ' + currentSession);
                
            event = [SELECT Id, Name, Event_Description__c, Comments__c, Number_of_Attendees__c
                        FROM DF_Event__c
                        WHERE Id = :currentSession];

            if (event != null) {
                if (event.Number_of_Attendees__c != null)
                    noOfAttendees = event.Number_of_Attendees__c.intValue();
                if (event.Comments__c != null)
                    sessionComments = event.Comments__c;
            } else {
                thereAreNoSessions = TRUE;
            }
        } else {
            // Must be choosing multiple sessions
			
			eventsRequiringFeedback = new List<DF_Event__c>();
			for (DF_Event__c dfe : [SELECT Id, Name, Event_Date_Time__c, Street__c, City__c, County__c, Postcode__c, Number_of_Attendees__c, Number_of_Places__c 
									FROM DF_Event__c WHERE Session_Organiser__r.Portal_Contact__r.Id = :WEBController.thisUser.ContactId 
									AND Event_Date_Time__c <= TODAY 
									AND (Number_of_Attendees__c = null OR Number_of_Attendees__c = 0) 
									and (Event_Status__c != :STATUS_CANCELLED AND Event_Status__c != :STATUS_CLOSED) ORDER BY Event_Date_Time__c DESC LIMIT 10]){
				
				if (dfe.Event_Date_Time__c.getTime() < system.now().getTime()){
					eventsRequiringFeedback.add(dfe);
				}
			}
			
			//2014-05-21 : CSL : Changing this SOQL statement temporarily to show the 'Report On Event' screen
            //eventsRequiringFeedback = [SELECT Id, Name, Event_Date_Time__c, Street__c, City__c, County__c, Postcode__c, Number_of_Attendees__c, Number_of_Places__c FROM DF_Event__c WHERE Session_Organiser__r.Portal_Contact__r.Id = :WEBController.thisUser.ContactId AND Event_Date_Time__c < TODAY AND (Number_of_Attendees__c = null OR Number_of_Attendees__c = 0) and Event_Status__c != :STATUS_CANCELLED LIMIT 10];
            //TEST CODE
            //eventsRequiringFeedback = [SELECT Id, Name, Event_Date_Time__c, Street__c, City__c, County__c, Postcode__c, Number_of_Attendees__c, Number_of_Places__c FROM DF_Event__c WHERE Session_Organiser__r.Portal_Contact__r.Id = :WEBController.thisUser.ContactId AND Event_Date_Time__c <= TODAY LIMIT 10];
            if (eventsRequiringFeedback == null || eventsRequiringFeedback.size() == 0) {
                thereAreNoSessions = TRUE;

                return;
            }

            for (DF_Event__c sess : eventsRequiringFeedback) {
                SelectOption s = new SelectOption(sess.Id, sess.Name + ' ' + sess.Event_Date_Time__c.format('dd/MM/yyyy'));
                sessionList.add(s);
            }
        }
        
    }
    
    //Test methods
	 public testmethod static void tesWEBChampionFeedback(){
	 	
	   DF_Contact__c dfcon = new DF_Contact__c(Name='Test dfcontact',First_Name__c='Test',Last_Name__c='dfcontact',Status__c='Prospective',Email__c='test@dfcon.com',
	   RecordTypeId=[Select Id from RecordType where SObjectType='DF_Contact__c' and Name Like 'Dementia Friend Champion'].Id,
	                                            Contact_Number__c='12345678',Eligible__c=FALSE,Contacted__c=FALSE,
	                                            Attended__c=FALSE,Note__c='Test Notes');
	    insert dfcon;
	    
	   DF_Event__c evnt = new DF_Event__c(Name='test12',Event_Description__c='test Description',Event_Status__c='Available',Event_Date_Time__c=system.now(),Street__c='teststreet',City__c='testcity',County__c='uk',Postcode__c='12345678912',Number_of_Places__c=1234,
	                               Session_Organiser__c=dfcon.id,Comments__c ='testcommetns',Number_of_Attendees__c=1234); 
	   insert evnt;
	   
	   ApexPages.currentPage().getParameters().put('eventId', evnt.id);
	   
	   WEBChampionSessionFeedback webfeedback = new WEBChampionSessionFeedback();
	   webfeedback.save();
	    
	 }
	 public testmethod static void tesWEBChampionFeedbacktwo(){
	 	
	   DF_Contact__c dfcon = new DF_Contact__c(Name='Test dfcontact',First_Name__c='Test',Last_Name__c='dfcontact',Status__c='Prospective',Email__c='test@dfcon.com',
	   RecordTypeId=[Select Id from RecordType where SObjectType='DF_Contact__c' and Name Like 'Dementia Friend Champion'].Id,
	                                            Contact_Number__c='12345678',Eligible__c=FALSE,Contacted__c=FALSE,
	                                            Attended__c=FALSE,Note__c='Test Notes');
	    insert dfcon;
	    
	   DF_Event__c evnt = new DF_Event__c(Name='test12',Event_Description__c='test Description',Event_Status__c='Available',Event_Date_Time__c=system.now(),Street__c='teststreet',City__c='testcity',County__c='uk',Postcode__c='12345678912',Number_of_Places__c=1234,
	                               Session_Organiser__c=dfcon.id,Comments__c ='testcommetns',Number_of_Attendees__c=1234); 
	   insert evnt;
	   
	  // ApexPages.currentPage().getParameters().put('eventId', evnt.id);
	   
	   WEBChampionSessionFeedback webfeedback = new WEBChampionSessionFeedback();
	   webfeedback.selectedSession = evnt.id;
	   webfeedback.save();
	    
	 }
}