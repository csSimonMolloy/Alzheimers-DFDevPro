public with sharing class DF_PartnerOrgTriggerHandler {
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : APEX Handler Class contains the execution logic of the Partner_Organisation__c Trigger.
 *  Author  : Ian Smith
 *  Date    : 21-03-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Apex Class calls the LastTransactionDateLookup Apex Class to update the 
 *                  lastTransactionDate__c field for the Partner_Organisation__c Record.
 *               
 *  Modification History
 *  Date            Who         Description 
 *  12/05/2014		CSL		  Commenting out code for LastTransactionDateLookup                            
*******************************************************************************************/

private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public DF_PartnerOrgTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
  
  
  
  public void OnAfterInsert(Partner_Organisation__c[] partnerOrg, Map<ID, Partner_Organisation__c> dfEventAttendeeMap){
        System.debug('****** DF_PartnerOrgTriggerHandler.OnAfterInsert  ******');
        
        List<Id> partnerOrgIds = new List<Id>();
        Datetime dtLastTransactionDate = datetime.now();

    //Iterate over the Partner_Organisation__c Object for the PartnerOrganisation/s being Inserted via the Partner_Organisation__c Trigger.        
        for(Partner_Organisation__c po : partnerOrg){
          //Add the Partner_Organisation__c Id field to a List Collection.
            partnerOrgIds.add(po.Id);
        }
        System.debug('****** partnerOrgIds.Size ******' + partnerOrgIds.Size());

    if(partnerOrgIds.isEmpty() == false)
    {
      //Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime. 
      //2014-05-12 : CSL : Temporarily commenting out the code to look at the LastTransactionDateLookup records
      //LastTransactionDateLookup handler = new LastTransactionDateLookup();
      //handler.UpdateLastTransactionDate(partnerOrgIds[0], dtLastTransactionDate); 
    }
    }   
    
    

    public void OnAfterUpdate(Partner_Organisation__c[] oldPartnerOrg, Partner_Organisation__c[] updatedPartnerOrg, Map<ID, Partner_Organisation__c> partnerOrgMap){
        System.debug('****** DF_PartnerOrgTriggerHandler.OnAfterUpdate  ******');
        
        List<Id> partnerOrgIds = new List<Id>();
        Datetime dtLastTransactionDate = datetime.now();

    //Iterate over the Partner_Organisation__c Object for the PartnerOrganisation/s being Inserted via the Partner_Organisation__c Trigger.        
        for(Partner_Organisation__c po : updatedPartnerOrg){
          //Add the Partner_Organisation__c Id field to a List Collection.
            partnerOrgIds.add(po.Id);
        }
        System.debug('****** partnerOrgIds.Size ******' + partnerOrgIds.Size());

    if(partnerOrgIds.isEmpty() == false)
    {
      //Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime.
      //2014-05-12 : CSL : Temporarily commenting out the code to look at the LastTransactionDateLookup records 
      //LastTransactionDateLookup handler = new LastTransactionDateLookup();
      //handler.UpdateLastTransactionDate(partnerOrgIds[0], dtLastTransactionDate); 
    }
    }

  
  
  public void OnAfterDelete(Partner_Organisation__c[] oldPartnerOrg, Map<ID, Partner_Organisation__c> partnerOrgMap){
    
        System.debug('****** DF_PartnerOrgTriggerHandler.OnAfterUpdate  ******');
        
        List<Id> partnerOrgIds = new List<Id>();
        Datetime dtLastTransactionDate = datetime.now();
        
        //Iterate over the Partner_Organisation__c Object for the PartnerOrganisation/s being Inserted via the Partner_Organisation__c Trigger.
        for(Partner_Organisation__c df : oldPartnerOrg){
          //Add the Partner_Organisation__c Id field to a List Collection.
            partnerOrgIds.add(df.Id);
        }
        System.debug('****** partnerOrgIds.Size ******' + partnerOrgIds.Size());

    if(partnerOrgIds.isEmpty() == false)
    {
      //Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime.
      //2014-05-12 : CSL : Temporarily commenting out the code to look at the LastTransactionDateLookup records 
      //LastTransactionDateLookup handler = new LastTransactionDateLookup();
      //handler.UpdateLastTransactionDate(partnerOrgIds[0], dtLastTransactionDate); 
    }
    }


        
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }    
}