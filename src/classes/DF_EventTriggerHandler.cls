public with sharing class DF_EventTriggerHandler {
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : APEX Handler Class contains the execution logic of the DF_Event__c Trigger.
 *  Author  : Ian Smith
 *  Date    : 24-01-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Apex Class calls the LastTransactionDateLookup Apex Class to update the 
 *                  lastTransactionDate__c field for the DF_Event__c Record.
 *
 *          The Class also calls updateDFContactSessionStats method to update the 
 *          Session stats for the Session_Organiser__c for DF_Event they are related to.
 *               
 *  Modification History
 *  Date            Who         Description 
 *  24-01-2014      MTinson     Added Call to UpdateLastTransactionDate Class.
 *  11-03-2014      STadikonda  Added call to Update Contact Session Stats 
 *  24-03-2014      Mike Tinson    If no completed sessions, average conversions is zero  
 *  12/05/2014		CSL		  Commenting out code for LastTransactionDateLookup                      
*******************************************************************************************/

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public DF_EventTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    
    
    public void OnAfterInsert(DF_Event__c[] dfEvent, Map<ID, DF_Event__c> dfEventMap)
    {
        System.debug('****** DF_EventTriggerHandler.OnAfterInsert  ******');
        
        List<Id> dfEventIds = new List<Id>();
        List<Id> sessionOrganisers = new List<Id> ();
        Datetime dtLastTransactionDate = datetime.now();
        
        //Iterate over the DF_Event Object for the DF_Event/s being Inserted via the DF_Event__c Trigger. 
        for(DF_Event__c dfe : dfEvent)
        {
          //Add the DF_Event Id field to a List Collection.
            dfEventIds.add(dfe.Id);
            
            if(dfe.Session_Organiser__c != NULL){
        //Add the DF_Event Session_Organiser__c field to a List Collection.
                sessionOrganisers.add(dfe.Session_Organiser__c);
            }
        }
        System.debug('****** dfEventIds.Size ******' + dfEventIds.Size());
    System.debug('****** sessionOrganisers.Size ******' + sessionOrganisers.Size());
    
        if(dfEventIds.isEmpty() == false)
        {
            if(sessionOrganisers.isEmpty() == false)
            {
              //Call Apex Method to calculate DF Champion Session Statistics.
                updateDFContactSessionStats(sessionOrganisers);
            }
                             
            //Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime. 
            //2014-05-12 : CSL : Temporarily commenting out the code to look at the LastTransactionDateLookup records
            //LastTransactionDateLookup handler = new LastTransactionDateLookup();
            //handler.UpdateLastTransactionDate(dfEventIds[0], dtLastTransactionDate); 
        }
    }   


    
    public void OnAfterUpdate(DF_Event__c[] olddfEvent, DF_Event__c[] updateddfEvent, Map<ID, DF_Event__c> dfEventMap){
    
        System.debug('****** DF_EventTriggerHandler.OnAfterUpdate  ******');
        
        List<Id> dfEventIds = new List<Id>();
        List<Id> sessionOrganisers = new List<Id> ();
        Datetime dtLastTransactionDate = datetime.now();
        
        //Iterate over the DF_Event Object for the DF_Event/s being Updated via the DF_Event__c Trigger.
        for(DF_Event__c df : updateddfEvent)
        {
          //Add the DF_Event Id field to a List Collection.
            dfEventIds.add(df.Id);
            
            if(df.Session_Organiser__c != NULL)
            {
                //Add the DF_Event Session_Organiser__c field to a List Collection.
                sessionOrganisers.add(df.Session_Organiser__c);
            }
        }
        System.debug('****** dfEventIds.Size ******' + dfEventIds.Size());
        System.debug('****** sessionOrganisers.Size ******' + sessionOrganisers.Size());

        if(dfEventIds.isEmpty() == false)
        {
            if(sessionOrganisers.isEmpty() == false)
            {
              //Call Apex Method to calculate DF Champion Session Statistics
              updateDFContactSessionStats(sessionOrganisers);
            }
     
            //Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime. 
            //2014-05-12 : CSL : Temporarily commenting out the code to look at the LastTransactionDateLookup records
            //LastTransactionDateLookup handler = new LastTransactionDateLookup();
            //handler.UpdateLastTransactionDate(dfEventIds[0], dtLastTransactionDate); 
        }
    }
    
    

    public void OnAfterDelete(DF_Event__c[] oldDFEvent, Map<ID, DF_Event__c> DFEventMap){
    
        System.debug('****** DF_EventTriggerHandler.OnAfterDelete  ******');
        
        List<Id> dfEventIds = new List<Id>();
        List<Id> sessionOrganisers = new List<Id> ();
        Datetime dtLastTransactionDate = datetime.now();
        
        //Iterate over the DF_Event Object for the DF_Event/s being Deleted via the DF_Event__c Trigger.
        for(DF_Event__c df : oldDFEvent)
        {
          //Add the DF_Event Id field to a List Collection.
            dfEventIds.add(df.Id);
            
            if(df.Session_Organiser__c != NULL)
            {
                //Add the DF_Event Session_Organiser__c field to a List Collection.
                sessionOrganisers.add(df.Session_Organiser__c);
            }
        }
        System.debug('****** dfEventIds.Size ******' + dfEventIds.Size());
    System.debug('****** sessionOrganisers.Size ******' + sessionOrganisers.Size());
    
        if(dfEventIds.isEmpty() == false)
        {
            if(sessionOrganisers.isEmpty() == false)
      {
        //Call Apex Method to calculate DF Champion Session Statistics
                updateDFContactSessionStats(sessionOrganisers);
            }
            
            //Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime. 
            //2014-05-12 : CSL : Temporarily commenting out the code to look at the LastTransactionDateLookup records
            //LastTransactionDateLookup handler = new LastTransactionDateLookup();
            //handler.UpdateLastTransactionDate(dfEventIds[0], dtLastTransactionDate); 
        }
    }
        
        
        
    public boolean IsTriggerContext
    {
        get{ return m_isExecuting;}
    }
    
   
      
    public void updateDFContactSessionStats(List<Id> sessionOrganisers)
    {
    System.debug('****** updateDFContactSessionStats  ******');
      
    //Get a List of DF_Events for the incoming sessionOrganisers.
    List<DF_Event__c> lstDFEvent = [SELECT Id,Session_Organiser__c,Event_Status__c,Number_of_Attendees__c,Public_Event__c FROM DF_Event__c WHERE Session_Organiser__c IN : sessionOrganisers];
    Set<Id> seshIds = new Set<Id>();
    
    for(DF_Event__c dfCon : lstDFEvent)
    {
      //Add the DF_Event Session_Organiser__c field to a List Collection.
      seshIds.add(dfCon.Session_Organiser__c);
    }
    System.debug('##### lstDFEvent: ' + lstDFEvent.Size());

    //Get a List of DF_Contacts for all seshIds..
    List<DF_Contact__c> lstDFCon = [SELECT Id FROM DF_Contact__c WHERE Id IN : seshIds];
    System.debug('##### lstCon: ' + lstDFCon.Size());

        if(lstDFCon.isEmpty() == false)
        {
          //Iterate over the Df_Contact Object for all records in lstDFCon. 
          for(Df_Contact__c dfc : lstDFCon)
          {
        Double noOfAttendees = 0.0;
              Double privateSessions = 0.0;
              Double publicSessions = 0.0;
              Double totalCompletedSessions = 0.0;
              Double totalAvailableSessions = 0.0;
              Double totalCancelledSessions = 0.0;
  
              for(Df_Event__c eventRec : lstDFEvent)
              {
                //Ensure the Session Organiser is the same as the DF_Contact.
                  if(eventRec.Session_Organiser__c == dfc.ID)
                  {
                      if(eventRec.Event_Status__c == 'Completed')
                      {
                          totalCompletedSessions = totalCompletedSessions + 1;
                          
                          if(eventRec.Number_of_Attendees__c == NULL)
                          {
                              eventRec.Number_of_Attendees__c = 0.0;
                          }else
                          {
                            noOfAttendees = noOfAttendees + eventRec.Number_of_Attendees__c;
                            System.debug('##### noOfAttendees: ' + noOfAttendees);
                          }  
                          
                          if(eventRec.Public_Event__c == TRUE)
                          {
                              publicSessions = publicSessions + 1;
                          }else
                          {
                              privateSessions = privateSessions + 1;
                          }
                      }
                      else if(eventRec.Event_Status__c == 'Available')
                      {
                          totalAvailableSessions = totalAvailableSessions + 1;
                      }
                      else if(eventRec.Event_Status__c == 'Cancelled')
                      {
                        totalCancelledSessions = totalCancelledSessions + 1;  
                      }
                  }               
              } 
               dfc.Total_No_of_Completed_Info_Sessions__c = totalCompletedSessions;
               dfc.Total_No_of_Cancelled_Info_Sessions__c = totalCancelledSessions;
               dfc.Total_No_of_Available_Info_Sessions__c = totalAvailableSessions;
               dfc.Total_No_of_Friends_Created__c = noOfAttendees;
               System.debug('##### Totals: ' + ' totalCompleted: ' + totalCompletedSessions
                                + ' totalCancelled: ' + totalCancelledSessions
                                + ' totalAvailable: ' + totalAvailableSessions
                                + ' noOfAttendees: '  + noOfAttendees);
               
               if(totalCompletedSessions != 0.0){
                   dfc.Average_No_of_Friends_Created__c = noOfAttendees/totalCompletedSessions;
               }else {
                   dfc.Average_No_of_Friends_Created__c = 0;
               }
               dfc.Number_of_Private_Sessions_Run__c = privateSessions;
               dfc.Number_of_Public_Sessions_Run__c =  publicSessions;            
          }
          
          //Attempt to Update the DF_Contact record with the Session Stats. 
            try{
                update lstDFCon;
                System.debug('****** Update Session Stats ******');
            }
            catch(DMLException e){
                System.debug('****** Error Updating Session Stats ******');
            }          
        }
    }
}