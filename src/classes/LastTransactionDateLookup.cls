public with sharing class LastTransactionDateLookup {

/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : Apex Class to Update the lastTransactionDate__c field in the LastTransactionDateLookup__c Object.
 *  Author  : Ian Smith
 *  Date    : 23-01-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:    Apex Class to Update/Insert the lastTransactionDate__c field in the LastTransactionDateLookup__c
 *                  Object for a given Object. If a record for the Object does not exist, then a new record 
 *                  will be created in the LastTransactionDateLookup__c Object.  
 *               
 *  Modification History
 *
 *  Date            Who     Description 
 *  12-02-2014      MT      Use apex getSObjectType() call to get the object type.
 *  10-04-2014    IanSm   Added InsertLastTransactionDate Method.                        
*******************************************************************************************/
    
    Public void UpdateLastTransactionDate(Id recordId, DateTime dtLastTransactionDate){
        
        //Update lastTransactionDate__c in LastTransactionDateLookup__c Object for a given sObject.     
        System.debug('****** LastTransactionDateLookup.UpdateLastTransactionDate ****** '); 
        
        //Call the getSObjectType function passing in a recordId to get the sObject API Name.
        string strObjectPrefix = String.valueOf(recordId);
        Schema.SObjectType token = recordId.getSObjectType();
        String strObjectName = String.valueof(token);                
        
        List<LastTransactionDateLookup__c> lst = [SELECT id, lastTransactionDate__c, objectAPIName__c, objectPrefix__c FROM LastTransactionDateLookup__c WHERE objectAPIName__c=:strObjectName];
        
        if (lst.size() > 0){
            for (LastTransactionDateLookup__c  lu : lst) {
                lu.lastTransactionDate__c = dtLastTransactionDate;
                lu.objectPrefix__c = strObjectPrefix.substring(0,3);
            }
            System.debug('****** Updating ****** ' + strObjectName + ' to ' + dtLastTransactionDate);
            
            //Update the LastTransactionDateLookup__c Object with the dtLastTransactionDate.
            try{
                update lst;
                System.debug('****** Updating Record for ****** ' + strObjectName);
            }
            catch(DMLException e){
                System.debug('****** Error Updating Record for  ****** ' + strObjectName);
                
                Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {'crssupport@alzheimers.org.uk'};
                mail.setToAddresses(toAddresses);
                mail.setReplyTo('crssupport@alzheimers.org.uk');
                mail.setSenderDisplayName('Apex error message');
                mail.setSubject('Unable to create LastTransactionDateLookup Record for: ' + strObjectName + ' Apex Classs LastTransactionDateLookup.');
                mail.setPlainTextBody(e.getMessage());
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }            
        }
        else
        {
            //Instantiate the object and add values for new record.
            LastTransactionDateLookup__c lastTrans = new LastTransactionDateLookup__c();
            lastTrans.Name = strObjectName;
            lastTrans.lastTransactionDate__c = datetime.now();
            lastTrans.objectAPIName__c = strObjectName;
            lastTrans.objectPrefix__c = strObjectPrefix.substring(0,3);
            
            try{
                insert lastTrans;
                System.debug('****** Creating Record for ****** ' + strObjectName);
            }
            catch(DMLException e){
                System.debug('****** Error Inserting Record for  ****** ' + strObjectName);
                
                Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {'crssupport@alzheimers.org.uk'};
                mail.setToAddresses(toAddresses);
                mail.setReplyTo('crssupport@alzheimers.org.uk');
                mail.setSenderDisplayName('Apex error message');
                mail.setSubject('Unable to create LastTransactionDateLookup Record for: ' + strObjectName + ' Apex Classs LastTransactionDateLookup.');
                mail.setPlainTextBody(e.getMessage());
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    }
    
    

  Public void InsertLastTransactionDate(Id recordId, DateTime dtLastTransactionDate){
        
        //Insert LastTransactionDateLookup__c Object for a given sObject.     
        System.debug('****** LastTransactionDateLookup.InsertLastTransactionDate ****** '); 
        
        //Call the getSObjectType function passing in a recordId to get the sObject API Name.
        string strObjectPrefix = String.valueOf(recordId);
        Schema.SObjectType token = recordId.getSObjectType();
        String strObjectName = String.valueof(token);                
        
        if (strObjectName != Null){
          
      //Instantiate the object and add values for new record.
            LastTransactionDateLookup__c lastTrans = new LastTransactionDateLookup__c();
            lastTrans.Name = strObjectName;
            lastTrans.lastTransactionDate__c = datetime.now();
            lastTrans.objectAPIName__c = strObjectName;
            lastTrans.objectPrefix__c = strObjectPrefix.substring(0,3);
            
            try{
                insert lastTrans;
                System.debug('****** Creating Record for ****** ' + strObjectName);
            }
            catch(DMLException e){
                System.debug('****** Error Inserting Record for  ****** ' + strObjectName);
                
                Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {'crssupport@alzheimers.org.uk'};
                mail.setToAddresses(toAddresses);
                mail.setReplyTo('crssupport@alzheimers.org.uk');
                mail.setSenderDisplayName('Apex error message');
                mail.setSubject('Unable to create LastTransactionDateLookup Record for: ' + strObjectName + ' Apex Classs LastTransactionDateLookup.');
                mail.setPlainTextBody(e.getMessage());
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    }    


}