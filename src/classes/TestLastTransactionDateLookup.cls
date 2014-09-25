@isTest
public with sharing class TestLastTransactionDateLookup {

/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : Test Class for LastTransactionDateLookup Class.
 *  Author  : Ian Smith
 *  Date    : 28-01-2014
 *  Version : 0.1 Unit Test
 *
 *  Description:  Apex Class to test LastTransactionDateLookup Class. 
 *               
 *  Modification History
 *
 *  Date          Who      Description 
 *  dd-mm-yyyy    ??    ??
 *                             
*******************************************************************************************/

    static testMethod void TestLastDateModifiedLookup(){
              
    // New Contact Record to be added to the Friend_Survey__c test Data.
    Partner_Organisation__c pa = new Partner_Organisation__c(Name='Test Org', DFC_Code__c='ABC123', Partner_External_Id__c=1234);
    insert pa;              
    
    //Now insert data causing the DF_Contact__c trigger to fire. 
    Test.startTest();
    
        LastTransactionDateLookup handler = new LastTransactionDateLookup();
        handler.UpdateLastTransactionDate(pa.id, datetime.now());
    
    Test.stopTest();
                 
    }  
 
}