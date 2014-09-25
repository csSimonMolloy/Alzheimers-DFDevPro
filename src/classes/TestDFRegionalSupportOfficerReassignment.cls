/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : Updates RSO for selected DF Contact records
 *  Author  : Mike Tinson
 *  Date    : 23 April 2014
 *  Version : 1
 *
 *  Description:  Test Class for DFRegionalSupportOfficerReassignment batch class.  
 *               
 *  Modification History
 *  Date            Who         Description 
 *  
 *  
 ******************************************************************************************/
@isTest
public class TestDFRegionalSupportOfficerReassignment  {

static testMethod void mainTest(){
        //record for champion
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE sObjectType =: 'DF_Contact__c' AND Name =: 'Dementia Friend Champion' AND isActive = TRUE];
        //record for RSO
        RecordType rtRSO = [SELECT Id, Name FROM RecordType WHERE sObjectType =: 'DF_Contact__c' AND Name =: 'RSO' AND isActive = TRUE];

        //RSO
        DF_Contact__c dfRSO = new DF_Contact__c(Name='Test RSO',First_Name__c = 'Test', Last_Name__c ='RSO', Postcode__c='NW1 2XX', recordtypeid=rtRSO.id, Email__c='test.test'+datetime.now().format('YYYYMMDDhhmmsshhmm')+'@alzheimers.org.uk');
        insert dfRSO;
        
        //RSO Area Lookup
        RSO_AreaLookup__c dfAreaLookup = new RSO_AreaLookup__c(Name='Test RSO',DFContactId__c=dfRSO.id,Postcode_Supported__c='NW,SE');
        insert dfAreaLookup; 

        //New DF_Contact__c Record to be added to the test Data.
        DF_Contact__c df = new DF_Contact__c(Name='Test DFC',First_Name__c = 'Test', Last_Name__c ='DFC', 
                                            Contact_Ext_Id__c = 12345678, Postcode__c='NW1 2XX', recordtypeid=rt.id, Email__c='test.testDFC'+datetime.now().format('YYYYMMDDhhmmsshhmm')+'@alzheimers.org.uk');

        insert df;
        Test.StartTest();

        String query =  'select id, name, PostCode__c, Regional_Support_Officer__c, Email__c from DF_Contact__c  WHERE RecordType_Name__c = \'Dementia Friend Champion\' and id =\'' + df.id + '\''; 
        System.Debug('###query### ' + query);
        
        DFRegionalSupportOfficerReassignment  dfRSOReassign = new DFRegionalSupportOfficerReassignment ();
        dfRSOReassign.query= query;
        dfRSOReassign.email='crssupport@alzheimers.org.uk';
        ID batchprocessid = Database.executeBatch(dfRSOReassign);
        Test.StopTest();

 
}           


}