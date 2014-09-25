/*
* 2014-03-23 : CSL : This class holds methods called from the DF_Event__c trigger.
*/

public with sharing class DFEventTriggerMethods {
    
    public static final String CHAMPION_RT = 'Champion_Training_Course';
    public static final String SESSION_RT = 'Dementia_Friend_Awareness_Session';
    public static final String STATUS_CANCELLED = 'Cancelled';
    public static final String STATUS_NOSHOW = 'No Show';
    public static final String STATUS_ATTENDED = 'Attended';
    public static final String VF_CHAMPION_TRAINING_BOOKED = 'VF_Champion_Training_Booked';
    public static final String VF_CHAMPION_TRAINING_UNREGISTERED = 'VF_Champion_Training_Unregistered';
    public static final String VF_FRIEND_SESSION_BOOKING_CONFIRMED = 'VF_Friend_Session_Booking_Confirmed';
    public static final String VF_FRIEND_SESSION_CANCELLED = 'VF_Friend_Session_Cancelled';
    public static final String VF_NEW_ATTENDEE_ON_SESSION = 'VF_New_Attendee_On_Session';
    public static final String VF_NEW_INFORMATION_SESSIONS = 'VF_New_Information_Sessions';
    public static final String VF_SESSION_ATTENDEE_CANCELLATION = 'VF_Session_Attendee_Cancellation';
    public static final String VF_UPDATED_SESSION_INFORMATION = 'VF_Updated_Session_Information';
    
    public static Map<String, EmailTemplate> emailTemplateMap {get; set;}
    
    public static boolean isFutureRunning=false;
    
    //This method will send emails to all registered people if a DF_Event__c is CANCELLED or UPDATED
    public static void sendEmailNotifications(List<DF_Event__c> inEvents, Map<Id, DF_Event__c> oldEvents){
        emailTemplateMap = new Map<String, EmailTemplate>();
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        for (EmailTemplate e : [select e.Id, e.DeveloperName from EmailTemplate e where e.IsActive = true and e.TemplateType = 'visualforce']){
            system.debug('*** -- Putting ' + e.DeveloperName + ' with ' + e.Id + ' -- ***');
            emailTemplateMap.put(e.DeveloperName, e);
        }
        
        
        Map<Id, RecordType> rtMap = new Map<Id, RecordType>();
        Map<Id, DF_Event__c> dfEventMap = new Map<Id, DF_Event__c>();
        Set<Id> dfEventIdSet = new Set<Id>();
        
        for (RecordType rt : [select r.Id, r.DeveloperName from RecordType r where r.SObjectType = 'DF_Event__c' and r.IsActive = true]){
            rtMap.put(rt.Id, rt);
        }
        
        for (DF_Event__c dfe : inEvents){
            dfEventIdSet.add(dfe.Id);
        }
        
        for (DF_Event__c dfe : [Select d.Id, d.Event_Status__c, d.RecordTypeId, d.City__c, d.Comments__c, d.Country__c, d.County__c, d.Event_Date_Time__c, d.Event_Description__c, d.Location__c, d.Postcode__c,     
                                d.Session_Organiser__c, d.Street__c, d.Total_Session_Hours__c, d.Wheel_Chair_Access__c, 
                                (Select Id, Name, DF_Contact__c, DF_Contact__r.Portal_Contact__c, DF_Event__c, EventAttendeeStatus__c From DF_EventAttendees__r) 
                                From DF_Event__c d where d.Id in :dfEventIdSet]){
            dfEventMap.put(dfe.Id, dfe);
        }
        
        //We now can process all DF_Events__c, and see if they are cancelled, or just updated
        for (DF_Event__c dfe : inEvents){
            DF_Event__c processEvent = dfEventMap.get(dfe.Id);
            DF_Event__c oldEvent = oldEvents.get(dfe.Id);
            boolean eventUpdated = false;
            if (STATUS_CANCELLED.equalsIgnoreCase(processEvent.Event_Status__c) && SESSION_RT.equalsIgnoreCase(rtMap.get(processEvent.RecordTypeId).DeveloperName)){
            	DateTime dateTimeToday = system.now();
            	if (processEvent.Event_Date_Time__c.getTime() >= dateTimeToday.getTime()){
                	cancelEvent(processEvent);
            	}	
            }else if (SESSION_RT.equalsIgnoreCase(rtMap.get(processEvent.RecordTypeId).DeveloperName)) {
                //Event is not cancelled, so we need to check all fields to see if anything has changed
                if (oldEvent != null){
                    if (processEvent.City__c != oldEvent.City__c) eventUpdated = true;
                    if (processEvent.Comments__c != oldEvent.Comments__c) eventUpdated = true;
                    if (processEvent.Country__c != oldEvent.Country__c) eventUpdated = true;
                    if (processEvent.County__c != oldEvent.County__c) eventUpdated = true;
                    if (processEvent.Event_Date_Time__c != oldEvent.Event_Date_Time__c) eventUpdated = true;
                    if (processEvent.Event_Description__c != oldEvent.Event_Description__c) eventUpdated = true;
                    if (processEvent.Location__c != oldEvent.Location__c) eventUpdated = true;
                    if (processEvent.Postcode__c != oldEvent.Postcode__c) eventUpdated = true;
                    if (processEvent.Session_Organiser__c != oldEvent.Session_Organiser__c) eventUpdated = true;
                    if (processEvent.Street__c != oldEvent.Street__c) eventUpdated = true;
                    if (processEvent.Total_Session_Hours__c != oldEvent.Total_Session_Hours__c) eventUpdated = true;
                    if (processEvent.Wheel_Chair_Access__c != oldEvent.Wheel_Chair_Access__c) eventUpdated = true;
                    
                    if (eventUpdated){
                        changedEvent(processEvent);
                    }
                }
            }   
        }
    }
    
    private static void cancelEvent(DF_Event__c inEvent){
        //Get the Org Wide Email address lookup value
        String ORG_WIDE_EMAIL_ADDRESS_ID = '';
        Global_Setting__c globalSetting = Global_Setting__c.getInstance('orgWideEmailAddress');
        if (globalSetting != null && globalSetting.Value__c != null) {
            ORG_WIDE_EMAIL_ADDRESS_ID = globalSetting.Value__c;
        }
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        List<DF_EventAttendee__c> dfeSaveList = new List<DF_EventAttendee__c>();
        
        for (DF_EventAttendee__c dfe : inEvent.DF_EventAttendees__r){
            if (dfe.DF_Contact__r.Portal_Contact__c != null){
                Messaging.SingleEmailMessage sme = new Messaging.SingleEmailMessage();
                sme.setTemplateId(emailTemplateMap.get(VF_FRIEND_SESSION_CANCELLED).Id);
                system.debug('*** -- OUT1 dfe.DF_Contact__r.Portal_Contact__c = ' + dfe.DF_Contact__r.Portal_Contact__c + ' -- ***');
                sme.setTargetObjectId(dfe.DF_Contact__r.Portal_Contact__c);
                sme.setWhatId(dfe.Id);
                sme.setSaveAsActivity(false);
                if (ORG_WIDE_EMAIL_ADDRESS_ID != ''){
                    sme.setOrgWideEmailAddressId(ORG_WIDE_EMAIL_ADDRESS_ID);
                }
                emailsToSend.add(sme);
            }
            
            if (!STATUS_ATTENDED.equalsIgnoreCase(dfe.EventAttendeeStatus__c) && 
                !STATUS_NOSHOW.equalsIgnoreCase(dfe.EventAttendeeStatus__c) &&
                !STATUS_CANCELLED.equalsIgnoreCase(dfe.EventAttendeeStatus__c)){
                    dfe.EventAttendeeStatus__c = STATUS_CANCELLED;
                    dfeSaveList.add(dfe);       
                }
        }
        
        if (emailsToSend.size() > 0){
            Messaging.sendEmail(emailsToSend);
        }
        
        if (dfeSaveList.size() > 0){
            update dfeSaveList;
        }
    }
    
    private static void changedEvent(DF_Event__c inEvent){
        //Get the Org Wide Email address lookup value
        String ORG_WIDE_EMAIL_ADDRESS_ID = '';
        Global_Setting__c globalSetting = Global_Setting__c.getInstance('orgWideEmailAddress');
        if (globalSetting != null && globalSetting.Value__c != null) {
            ORG_WIDE_EMAIL_ADDRESS_ID = globalSetting.Value__c;
        }
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        for (DF_EventAttendee__c dfe : inEvent.DF_EventAttendees__r){
            if (dfe.DF_Contact__r.Portal_Contact__c != null){
                Messaging.SingleEmailMessage sme = new Messaging.SingleEmailMessage();
                sme.setTemplateId(emailTemplateMap.get(VF_UPDATED_SESSION_INFORMATION).Id);
                system.debug('*** -- OUT1 dfe.DF_Contact__r.Portal_Contact__c = ' + dfe.DF_Contact__r.Portal_Contact__c + ' -- ***');
                sme.setTargetObjectId(dfe.DF_Contact__r.Portal_Contact__c);
                sme.setWhatId(dfe.Id);
                sme.setSaveAsActivity(false);
                if (ORG_WIDE_EMAIL_ADDRESS_ID != ''){
                    sme.setOrgWideEmailAddressId(ORG_WIDE_EMAIL_ADDRESS_ID);
                }
                emailsToSend.add(sme);
            }
        }
        
        if (emailsToSend.size() > 0){
            Messaging.sendEmail(emailsToSend);
        }
    }
    
    @future (callout=true)  // future method needed to run callouts from Triggers
    static public void sendEmailToMembers(set<id> dfEventIds){
        
        FutureHandler.setIsFutureRunning(true);
      
        map<id,DF_Event__c> dfEventMap=new map<id,DF_Event__c>([select id,Name,Event_Date_Time__c,Available_On_Website__c,Location_Geographic_Details__Latitude__s,Location_Geographic_Details__Longitude__s,Postcode__c 
                                            from DF_Event__c where id IN :dfEventIds]);
        DF_Event__c sDFEvent;
        
        if(dfEventMap!=null && dfEventMap.size() > 0)
            sDFEvent=dfEventMap.values().get(0);
        
        String address='';
        if (sDFEvent != null){ 
	        if(sDFEvent.Postcode__c!=null){
	             address=sDFEvent.Postcode__c;
	        }
	        if((address!=null || address!='')){
	                    
	            address = EncodingUtil.urlEncode(address, 'UTF-8');
	            
	            try{  
	                
	                if(sDFEvent.Location_Geographic_Details__Latitude__s==null && 
	                sDFEvent.Location_Geographic_Details__Longitude__s==null){
	                    
	                    Http h = new Http();
	                    HttpRequest req = new HttpRequest();
	                    req.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?key=AIzaSyCt8-YgkPglTjv7i7hWe01-M3JUZF1VshM&address='+address+'&sensor=false');
	                    req.setMethod('GET');
	                    req.setTimeout(60000);
	                    
	                    system.debug('Request http test'+req);
	                    HttpResponse res = h.send(req);
	                    system.debug('response http test'+res);
	                    // parse coordinates from response
	                    system.debug('resposnse get body method'+res.getBody());
	                    JSONParser parser = JSON.createParser(res.getBody());
	                    double lat = null;
	                    double lon = null;
	                
	                    while(parser.nextToken() != null){
	                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
	                            (parser.getText() == 'location')){
	                                parser.nextToken(); // object start
	                                while (parser.nextToken() != JSONToken.END_OBJECT){
	                                    String txt = parser.getText();
	                                    parser.nextToken();
	                                    if (txt == 'lat')
	                                        lat = parser.getDoubleValue();
	                                    else if (txt == 'lng')
	                                        lon = parser.getDoubleValue();
	                                }
	                        
	                        }
	                    }
	                
	                    system.debug('test address lat'+lat);
	                    system.debug('test address long'+lon);
	                    // update coordinates if we get back 
	                    if (lat != null && lon!=null){
	                        sDFEvent.Location_Geographic_Details__Latitude__s = lat;
	                        sDFEvent.Location_Geographic_Details__Longitude__s = lon;
	                        update sDFEvent;        
	                    }    
	                }
	                
	                map<id,Saved_Search__c> savedSearchMap=new map<id,Saved_Search__c>
	                                        ([select id,Email__c,Geolocation__Latitude__s,Geolocation__Longitude__s,Post_Code__c,Range__c,Sent_Mail__c,Type__c from Saved_Search__c where Sent_Mail__c=False ]); 
	                
	                set<String> emailList=new set<String>();
	                list<Saved_Search__c> distanceList= new list<Saved_Search__c>();
	                for(Saved_Search__c sSavedSearch:savedSearchMap.values()){
	                    
	                    if(sSavedSearch.Geolocation__Latitude__s!=null && 
	                        sSavedSearch.Geolocation__Longitude__s!=null && 
	                          sDFEvent.Location_Geographic_Details__Latitude__s!=null && 
	                            sDFEvent.Location_Geographic_Details__Longitude__s!=null){
	                        
	                        Double distanceVal=calculateDistance(Double.valueOf(sSavedSearch.Geolocation__Latitude__s),
	                                                             Double.valueOf(sSavedSearch.Geolocation__Longitude__s),
	                                                             Double.valueOf(sDFEvent.Location_Geographic_Details__Latitude__s),
	                                                             Double.valueOf(sDFEvent.Location_Geographic_Details__Longitude__s));
	                        
	                        System.debug('**** : '+distanceVal);
	                        
	                        if(distanceVal<=sSavedSearch.Range__c)
	                        {
	                         if(!(emailList.contains(sSavedSearch.Email__c)))
	                         {
	                             emailList.add(sSavedSearch.Email__c);//Store the email list
	                             distanceList.add(sSavedSearch);
	                         }
	                        } 
	                        
	                    }
	                    
	                }//for ends
	                
	                list<string> FinalEmaillist = new list<string>();
	                FinalEmaillist.addAll(emailList);
	                System.debug('$$$$ : '+FinalEmaillist);
	                
	                //Send the emails to FinalEmaillist
	                                 
	            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	                    mail.setToAddresses(FinalEmaillist);
	                    mail.saveAsActivity = false;
	                    mail.setSubject('Dementia Friend Awareness Session');
	                    mail.setPlainTextBody('Hi ,According to your search ,The Event ' +sDFEvent.Name + ' is going to happen at '+sDFEvent.Postcode__c + ' postal area on '+sDFEvent.Event_Date_Time__c+ '. ' );
	                                    
	            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	            
	            //change the email sent flag to sent
	            list<Saved_Search__c> emailsentlist= new list<Saved_Search__c>();
	            
	            for(Saved_Search__c savedsearch: distanceList)  
	            {
	                savedsearch.Sent_Mail__c = True;
	                emailsentlist.add(savedsearch); 
	            }//for ends
	            
	            update emailsentlist;//updates the records that recieved mail
	            
	            }//try ends 
	            
	            catch (Exception e) {
	            }
	            
	        }//address if ends
        }
    }//Method ends
    
    private static Double EARTH_RADIUS = 3963.167;//6371.00; // Radius in Kilometers default
        
    public static Double calculateDistance(Double lat1, Double lon1, Double lat2,   Double lon2){
      Double Radius = DFEventTriggerMethods.EARTH_RADIUS; //6371.00;
      Double dLat = DFEventTriggerMethods.toRadians(lat2-lat1);
      Double dLon = DFEventTriggerMethods.toRadians(lon2-lon1);            
      Double a = Math.sin(dLat/2) * Math.sin(dLat/2) +
      Math.cos(DFEventTriggerMethods.toRadians(lat1)) *   Math.cos(DFEventTriggerMethods.toRadians(lat2)) *
      Math.sin(dLon/2) * Math.sin(dLon/2);
      Double c = 2 * Math.asin(Math.sqrt(a));
      return Radius * c;        
    }
    
    public static Double toRadians(Double degree){
       // Value degree * Pi/180
       Double res = degree * 3.1415926 / 180;
       return res;  
    }
    
}