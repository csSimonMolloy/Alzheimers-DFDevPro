/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : Updates RSO for selected DF Contact records
 *  Author  : Mike Tinson
 *  Date    : 23 April 2014
 *  Version : 1
 *
 *  Description:  Update RSO on DF Contact  
 *                Usage - call using the following
 *               String query =  'select id, name, PostCode__c, Regional_Support_Officer__c, Email__c from DF_Contact__c  WHERE RecordType_Name__c = \'Dementia Friend Champion\' and Regional_Support_Officer__c=null AND Email__c!=Null';
 *               DFRegionalSupportOfficerReassignment dfRSOReassign = New DFRegionalSupportOfficerReassignment();
 *               dfRSOReassign.query= query;
 *               ID batchprocessid = Database.executeBatch(dfRSOReassign, 10);
 *               
 *  Modification History
 *  Date            Who         Description 
 *  
 *  
 ******************************************************************************************/

global class DFRegionalSupportOfficerReassignment implements Database.Batchable<sObject>{
Public String query {get;set;}
Public String email{get;set;}


global Database.querylocator start(Database.BatchableContext BC){
    System.debug('################query##############' + query);
    return Database.getQueryLocator(query);}

global void execute(Database.BatchableContext BC, List<sObject> scope){
    List<DF_Contact__c> dfContactList = new List<DF_Contact__c>();
    List <DF_Contact__c> dfContactUpdatesList = New List <DF_Contact__c>();
    Map<String,String> postCodesMap = new Map<String,String> ();
    Map<String,String> contactRSOMap = new Map<String,String>();

   for(sObject s : scope)
    {
        DF_Contact__c a = (DF_Contact__c)s;
        dfContactList.add(a);
    }

if (dfContactList.size() > 0) {
    System.Debug('#################### size = ' + dfContactList.size());

        for(DF_Contact__c df : dfContactList)
        {
            if(df.Postcode__c  != null ){
                postCodesMap.put(df.Id,df.Postcode__c);
            } else{
                postCodesMap.put(df.Id,'ZZ1 1ZZ');
            }

        }
        System.Debug ('############### postCodesMap.size ' + postCodesMap.size());
        if(postCodesMap.isEmpty() == false){
            // routine copied from DF contact trigger
            // creates a map of RSO Postcodes and matches to postcode of DF contacts
            //contactRSOMap = mapDFContactsRSO(postCodesMap);
                    Id DefaultRSOId;
                    Map<String,String> newPostCodesMap = new Map<String,String>();
                    for(String dfId : PostCodesMap.keyset())
                    {
                        String mapValue = PostCodesMap.get(dfId);
                        system.debug(mapValue.length());
                        if(mapValue.length() >= 2)
                        {
                            if(mapValue.subString(1,2) == '0' || mapValue.subString(1,2) == '1' || mapValue.subString(1,2) == '2' ||
                                mapValue.subString(1,2) == '3' || mapValue.subString(1,2) == '4' || mapValue.subString(1,2) == '5' ||
                                mapValue.subString(1,2) == '6' || mapValue.subString(1,2) == '7' || mapValue.subString(1,2) == '8' ||
                                mapValue.subString(1,2) == '9')
                            
                                newPostCodesMap.put(dfId,mapValue.subString(0,1));              
                            else                
                                newPostCodesMap.put(dfId,mapValue.subString(0,2));
                       }
                    }
                    
                    //Map<String,String> contactRSOMap = new Map<String,String> ();
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
                            for(String dfID : newPostCodesMap.keyset())
                            {
                                for(String str : postCodes)
                                {
                                    if(str == newPostCodesMap.get(dfID))
                                    {
                                        contactRSOMap.put(dfID,rec.DFContactId__c);
                                        break;
                                    }
                                }   
                            }
                        }
                    }
                    //now check for those that do not match
                    for(String dfAllId : PostCodesMap.keyset()){
                        
                        if (!contactRSOMap.containsKey(dfAllId )){
                            system.debug('£££££' + dfAllId + ' is missing');
                            if (DefaultRSOId!=Null){
                                contactRSOMap.put(dfAllId ,DefaultRSOId);
                            }
                        }
                    }
                    system.debug('£££££'+contactRSOMap); 

        
        for(DF_Contact__c df : dfContactList)
        {
            for(String str : contactRSOMap.keyset())
            {
                if(df.Id == str)
                {
                    df.Regional_Support_Officer__c = contactRSOMap.get(str);
                    System.Debug('################ ' + df.id + ' = ' + df.Regional_Support_Officer__c );
                    dfContactUpdatesList.add(df);
                    break;
                }
            }
        }
    }

    if (dfContactUpdatesList.size() > 0)
    {
        Savepoint sp = Database.setSavepoint();
        try {
            update(dfContactUpdatesList);
            }
        catch(Exception e){
                    System.debug('### An exception occurred: ' + e.getMessage());
                    Database.rollback(sp);
            }
    }

}
    
}
global void finish(Database.BatchableContext BC){
    // First, reserve email capacity for the current Apex transaction to ensure
    // that we won't exceed our daily email limits when sending email after
    // the current transaction is committed.
    //Messaging.reserveSingleEmailCapacity(1);

    //Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

   // mail.setToAddresses(new String[] {email});
   // mail.setReplyTo('mike.tinson@alzheimers.org.uk');
   // mail.setSenderDisplayName('Batch Processing');
   // mail.setSubject('Batch Process Completed');
   // String strMessage = 'Batch Process has completed';
   // strMessage = strMessage  + '\n query: ' + query;
   // mail.setPlainTextBody( strMessage );
    //mail.setPlainTextBody('Batch Process Completed');
   // Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
}



}