/******************************************************************************************
 *  Cloud Symphony
 *  
 *  Purpose : APEX controller class for VF Component WEBChampionContactDetails.
 *  Author  : CSL
 *  Date    : 27-02-2014
 *  Version : 1.0
 *
 *  Description:    Apex Class controller for the VF Component WEBChampionDetails
 *               
 *  Modification History
 *  Date            Who         Description 
                   
*******************************************************************************************/
public with sharing class WEBChampionContactDetailsClass {

    public Datetime courseDate{get;set;}
    public String courseDetails{get;set;}
    public String courseStreet{get;set;}
    public String courseCity{get;set;}
    public String courseCounty{get;set;}
    public String courseCountry{get;set;}
    public String coursePostcode{get;set;}
    public String firstName{get;set;}
    public String lastName{get;set;}
    public String address1{get;set;}
    public String address2{get;set;}
    public String town_City{get;set;}
    public String county{get;set;}
    public String postCode{get;set;}
    public String EventId{get;set;}
    public List<DF_Contact__c> contacts {get;set;}
    public List<DF_Event__c> events {get;set;}
    public Boolean displayThankyoupage{get;set;}
    public Boolean displayFormPage{get;set;}
    
    public User thisUser {
        get {
            return WEBController.thisUser;
        }
        set;
    }

    //Constructor
    public WEBChampionContactDetailsClass(){
        EventId = ApexPages.currentPage().getParameters().get('event');
        displayThankyoupage = false;
        displayFormPage = true;
        if (EventId != null){
            getEventInformation();
        }
        getContactInformation();
    }
    
    //Returns the event information for the selected event
    public void getEventInformation(){
        events = new List<DF_Event__c>();
        events = [SELECT Id, Event_Date_Time__c,Street__c,Postcode__c,City__c,Country__c,County__c,Location__c, Number_of_Attendees__c, Number_of_Places__c  FROM DF_Event__c WHERE Id=:EventId LIMIT 1];
        
        if (events.size() > 0){
            for (DF_Event__c dfevents:events){
                courseDetails = dfevents.Location__c;
                courseDate = dfevents.Event_Date_Time__c;
                courseStreet = dfevents.Street__c;
                courseCity = dfevents.City__c;
                courseCounty = dfevents.County__c;
                courseCountry = dfevents.Country__c;
                coursePostcode = dfevents.Postcode__c;
            }
        }
    }
    
    //Returns contact information for the logged in contact
    public void getContactInformation(){
        contacts = new List<DF_Contact__c>();
        contacts = [SELECT Id, First_Name__c,Last_Name__c,Street__c,City__c,Country__c,County__c,Postcode__c,Portal_Contact__r.Id FROM DF_Contact__c WHERE Portal_Contact__r.Id = :WEBController.thisUser.ContactId LIMIT 1];
        
        if (contacts.size() > 0){
            for (DF_Contact__c dfcontact:contacts){
                firstName = dfcontact.First_Name__c;
                lastName = dfcontact.Last_Name__c;
                address1 = dfcontact.Street__c;
                //address2 = dfcontact.Street__c;
                town_City = dfcontact.City__c;
                county = dfcontact.County__c;
                postCode = dfcontact.Postcode__c;
            }
        }
    }

    //Submits the event booking form
    public PageReference submitForm(){
        DF_Event__c selectedEvent = events[0];
        if (contacts.size() > 0){
            for (DF_Contact__c dfcontact:contacts){
                 dfcontact.First_Name__c = firstName;
                 dfcontact.Last_Name__c = lastName;
                 dfcontact.Street__c = address1;
                 //dfcontact.Street__c = address2;
                 dfcontact.City__c = town_City;
                 dfcontact.County__c = county;
                 dfcontact.Postcode__c = postCode;
            }   
            try{
            update contacts;
            }catch(System.DmlException e){
                system.debug('We have found an DML Exception please check the following error : '+e);
            }
            
            //Now we need to create the Event Attendee record
             DF_EventAttendee__c attendanceRecord = new DF_EventAttendee__c();
            attendanceRecord.DF_Contact__c = contacts[0].Id;
            attendanceRecord.DF_Event__c = events[0].Id;
            
            system.debug('*** -- Insert record -- ***');
            
            insert attendanceRecord;
            
            if (selectedEvent.Number_of_Attendees__c == null){
                selectedEvent.Number_of_Attendees__c = 0;
            }
            
            if (selectedEvent.Number_of_Attendees__c == selectedEvent.Number_of_Places__c){
                //Do we want to save this record?
                
            }else if (selectedEvent.Number_of_Attendees__c < selectedEvent.Number_of_Places__c){
                selectedEvent.Number_of_Attendees__c = selectedEvent.Number_of_Attendees__c + 1;    
            }
            
            
            update selectedEvent;
            
        }
        displayThankyoupage = true;
        displayFormPage = false;
        return null;
    }

}