public with sharing class DF_ContactTriggerHandler {
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : APEX Handler Class contains the execution logic of the DF_Contact__c Trigger.
 *  Author  : Ian Smith
 *  Date    : 23-01-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Apex Class calls the LastTransactionDateLookup Apex Class to update the 
 *                  lastTransactionDate__c field for the DF_Contact__c Record.
 *               
 *  Modification History
 *  Date            Who         Description 
 *  24-01-2014      MTinson     Added Call to UpdateLastTransactionDate Class.
 *  27-02-2014      NTadikonda  Added Call to Update Parent Organisations Statistics
 *  03-03-2014      NTadikonda  Added Call to Map DF_Contacts to RSOAreaLookUp
 *  24-03-2014      MTinson     Update statistics to remove large reads of data
 *  01-04-2014      Iansm       Removed Call to Update Parent Organisations Statistics.  
 *  11-04-2014      MTinson     Handle missing postcodes in RSO lookup.   
 *  23-04-2014      MTinson     Empty Postcodes in RSO lookup.
 *  12/05/2014		CSL		  Commenting out code for LastTransactionDateLookup                       
*******************************************************************************************/

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    Static final String DFCHAMPION = 'Dementia Friend Champion';
     
    public DF_ContactTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
     public void OnBeforeInsert(DF_Contact__c[] dfContacts, Map<ID, DF_Contact__c> DFContactMap)
     {
       System.debug('****** DF_ContactTriggerHandler.OnBeforeInsert  ******');
       
        Map<String,String> postCodesMap = new Map<String,String> ();
        Map<String,String> contactRSOAreaMap = new Map<String,String> ();
        
        //Get the Dementia Friend Champion Record Type from the DF_Contact__c Object.
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE sObjectType =: 'DF_Contact__c' AND Name =: DFCHAMPION AND isActive = TRUE];
        
        //Iterate over the DF_Contact__c Object for the DF_Contact/s being Inserted via the DF_Contact__c Trigger.
        for(DF_Contact__c df : dfContacts)
        {
            if(rt.Id == df.RecordTypeId  && df.Email__c != NULL)
            {
                //Create a Map Collection of DF_Contacts (DF Champions) where Postcode & Email != Null.
                if (df.Postcode__c==null){
                    postCodesMap.put(df.Email__c,'ZZ1 1ZZ');
                }
                else {
                    postCodesMap.put(df.Email__c,df.Postcode__c);
                }
                System.debug('****** postCodesMap: ' + postCodesMap);
            }
        }
        
        if(postCodesMap.isEmpty() == false)
        {
            contactRSOAreaMap = mapDFContactsRSO(postCodesMap);
        }
           
        for(DF_Contact__c df : dfContacts)
        {
            for(String str : contactRSOAreaMap.keyset())
            {
                if(df.Email__c == str)
                {
                    df.Regional_Support_Officer__c = contactRSOAreaMap.get(str);
                    System.debug('****** Regional_Support_Officer__c: ' + df.Regional_Support_Officer__c);
                    break;
                }
            }
            //2014-06-02 : CSL : We need to make sure the Name field on a DF_Contact__c is equal to First_Name__c + Last_Name__c
            if (df.Name != df.First_Name__c + ' ' + df.Last_Name__c){
            	df.Name = df.First_Name__c + ' ' + df.Last_Name__c;
            }
        }
    }



    public void OnAfterInsert(DF_Contact__c[] dfContacts, Map<ID, DF_Contact__c> DFContactMap){
        System.debug('****** DF_ContactTriggerHandler.OnAfterInsert  ******');
        
        List<Id> dfContactIds = new List<Id>();
        Datetime dtLastTransactionDate = datetime.now();

    //Iterate over the DF_Contact__c Object for the DF_Contact/s being Inserted via the DF_Contact__c Trigger.
        for(DF_Contact__c df : dfContacts){
          //Add the DF_Contact Id field to a List Collection.
            dfContactIds.add(df.id);
        }
        System.debug('****** dfContactIds.Size ******' + dfContactIds.Size());

        if(dfContactIds.isEmpty() == false)
        {
            //Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime.
            //2014-05-12 : CSL : Temporarily commenting out the code to look at the LastTransactionDateLookup records             
            //LastTransactionDateLookup handler = new LastTransactionDateLookup();
            //handler.InsertLastTransactionDate(dfContactIds[0], dtLastTransactionDate); 
        }
    }   
 
 
 
     public void OnBeforeUpdate(DF_Contact__c[] oldDFContact,Map<ID, DF_Contact__c> oldDFContactMap, DF_Contact__c[] updatedDFContact, Map<ID, DF_Contact__c> DFContactMap)
     {
        System.debug('****** DF_ContactTriggerHandler.OnBeforeInsert  ******');
        
        Map<String,String> postCodesMap = new Map<String,String> ();
        Map<String,String> contactRSOAreaMap = new Map<String,String> ();
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE sObjectType =: 'DF_Contact__c' AND Name =: DFCHAMPION AND isActive = TRUE];

        for(DF_Contact__c df : updatedDFContact)
        {
            DF_Contact__c oldDFC = oldDFContactMap.get(df.ID);
            if((oldDFC.Postcode__c != df.Postcode__c || oldDFC.RecordTypeId != df.RecordTypeId ) && rt.Id == df.RecordTypeId )
                if (df.Postcode__c==null){
                    postCodesMap.put(df.Id,'ZZ1 1ZZ');
                }
                else {
                    postCodesMap.put(df.Id,df.Postcode__c);
                }
        }

        if(postCodesMap.isEmpty() == false){
            contactRSOAreaMap = mapDFContactsRSO(postCodesMap);
        }
        
        for(DF_Contact__c df : updatedDFContact)
        {
            for(String str : contactRSOAreaMap.keyset())
            {
                if(df.Id == str)
                {
                    df.Regional_Support_Officer__c = contactRSOAreaMap.get(str);
                    break;
                }
            }
            //2014-06-02 : CSL : We need to make sure the Name field on a DF_Contact__c is equal to First_Name__c + Last_Name__c
            if (df.Name != df.First_Name__c + ' ' + df.Last_Name__c){
            	df.Name = df.First_Name__c + ' ' + df.Last_Name__c;
            }
        }
    }



    public void OnAfterUpdate(DF_Contact__c[] oldDFContact, DF_Contact__c[] updatedDFContact, Map<ID, DF_Contact__c> DFContactMap){
      System.debug('****** DF_ContactTriggerHandler.OnAfterUpdate  ******');
        
        List<Id> dfContactIds = new List<Id>();
        Datetime dtLastTransactionDate = datetime.now();
        
        //Iterate over the DF_Contact__c Object for the DF_Contact/s being Inserted via the DF_Contact__c Trigger.
        for(DF_Contact__c df : updatedDFContact){
          //Add the DF_Contact Id field to a List Collection.
            dfContactIds.add(df.Id);
        }

        if(dfContactIds.isEmpty() == false)
        {
            //Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime.
            //2014-05-12 : CSL : Temporarily commenting out the code to look at the LastTransactionDateLookup records 
            //LastTransactionDateLookup handler = new LastTransactionDateLookup();
            //handler.InsertLastTransactionDate(dfContactIds[0], dtLastTransactionDate); 
        }
    }



    public void OnAfterDelete(DF_Contact__c[] oldDFContact, Map<ID, DF_Contact__c> DFContactMap){
    
        System.debug('****** DF_ContactTriggerHandler.OnAfterUpdate  ******');
        
        List<Id> dfContactIds = new List<Id>();
        Datetime dtLastTransactionDate = datetime.now();
        
        //Iterate over the DF_Contact__c Object for the DF_Contact/s being Inserted via the DF_Contact__c Trigger.
        for(DF_Contact__c OldDF : oldDFContact){
          //Add the DF_Contact Id field to a List Collection.
      dfContactIds.add(OldDF.Id);
        }
        System.debug('****** dfContactIds.Size ******' + dfContactIds.Size());

        if(dfContactIds.isEmpty() == false)
        {
            //Call Apex Class to populate LastTransactionDateLookup__c Object passing a RecordId and current DateTime.
            //2014-05-12 : CSL : Temporarily commenting out the code to look at the LastTransactionDateLookup records 
            //LastTransactionDateLookup handler = new LastTransactionDateLookup();
            //handler.InsertLastTransactionDate(dfContactIds[0], dtLastTransactionDate); 
        }
    }
        
        
        
    public boolean IsTriggerContext
    {
        get{ return m_isExecuting;}
    }
   
   
    /*
    * This routine extracts the postal area from the post code - either the first or 1st+2nd character - upto the first number.
    * These postal areas are then matched against the RSO Lookup records to find the RSO which is responsible for this postal area.
    * If there is not a match, then assign the default RSO - Not Listed, which has a Postal Area of 'N/A'
    */
    public Map<String,String> mapDFContactsRSO(Map<String,String> dfPostCodesMap)
    {   
        Id DefaultRSOId;
        Map<String,String> newDFPostCodesMap = new Map<String,String>();
        for(String dfId : dfPostCodesMap.keyset())
        {
            String mapValue = dfPostCodesMap.get(dfId);
            system.debug(mapValue.length());
            if(mapValue.length() >= 2)
            {
                if(mapValue.subString(1,2) == '0' || mapValue.subString(1,2) == '1' || mapValue.subString(1,2) == '2' ||
                    mapValue.subString(1,2) == '3' || mapValue.subString(1,2) == '4' || mapValue.subString(1,2) == '5' ||
                    mapValue.subString(1,2) == '6' || mapValue.subString(1,2) == '7' || mapValue.subString(1,2) == '8' ||
                    mapValue.subString(1,2) == '9')
                
                    newDFPostCodesMap.put(dfId,mapValue.subString(0,1));              
                else                
                    newDFPostCodesMap.put(dfId,mapValue.subString(0,2));
           }
        }
        system.debug('££££££££ mapDFContactsRSO'+newDFPostCodesMap);
        
        Map<String,String> contactRSOMap = new Map<String,String> ();
        List<RSO_AreaLookup__c> allRSOAreaData = new List<RSO_AreaLookup__c> ();
        allRSOAreaData = [SELECT ID,DFContactId__c,Postcode_Supported__c FROM RSO_AreaLookup__c];
        system.debug(allRSOAreaData);
        //Get default RSO
        for(RSO_AreaLookup__c rec : allRSOAreaData)
        {
            if (rec.Postcode_Supported__c == 'N/A'){
                DefaultRSOId = rec.DFContactId__c;
            }
        }
        
        for(RSO_AreaLookup__c rec : allRSOAreaData)
        {
            if(rec.Postcode_Supported__c != NULL)
            {
                String [] splitInput = rec.Postcode_Supported__c.split(',');
                List<String> postCodes = new List<String>(splitInput);
                for(String dfID : newDFPostCodesMap.keyset())
                {
                    for(String str : postCodes)
                    {
                        if(str == newDFPostCodesMap.get(dfID))
                        {
                            contactRSOMap.put(dfID,rec.DFContactId__c);
                            break;
                        }
                    }   
                }
            }
        }
        //now check for those that do not match
        for(String dfAllId : dfPostCodesMap.keyset()){
            
            if (!contactRSOMap.containsKey(dfAllId )){
                system.debug('£££££' + dfAllId + ' is missing');
                if (DefaultRSOId!=Null){
                    contactRSOMap.put(dfAllId ,DefaultRSOId);
                }
            }
        }
        system.debug('£££££'+contactRSOMap); 
        return contactRSOMap;
    }
}