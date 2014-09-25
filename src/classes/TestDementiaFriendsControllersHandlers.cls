@isTest
private class TestDementiaFriendsControllersHandlers {
/*
Mike Tinson 24 Jan 2014

After creating trigger handler classes for DF_Contact, DF_Event and DF_EventAttendee.
Need a test class

*/
static testMethod void TestDementiaFriendsHandlers ()
{
   DF_Contact__c dfcon = new DF_Contact__c(Name='Test dfcontact'
                                           ,First_Name__c='Test'
                                           ,Last_Name__c='dfcontact'
                                           ,Status__c='Prospective'
                                           ,email__c= 'email'+datetime.now().format('YYYYMMDDhhmmsshhmm')+'@alztest.com'
                                           ,RecordTypeId=[Select Id from RecordType where SObjectType='DF_Contact__c' and Name Like 'Dementia Friend Champion'].Id
                                           ,Contact_Number__c='12345678'
                                           ,Eligible__c=FALSE
                                           ,Contacted__c=FALSE
                                           ,Attended__c=FALSE,Note__c='Test Notes');
    insert dfcon;
    DF_Event__c dfeve = new DF_Event__c(Name='dfevent test' 
                                           ,RecordTypeId=[Select Id from RecordType where SObjectType='DF_Event__c' and Name Like 'Champion Training Course'].Id
                                           ,Session_Organiser__c=dfcon.Id, Event_Date_Time__c = system.now());
    insert dfeve;
    DF_EventAttendee__c dfeveattnd = new DF_EventAttendee__c(DF_Contact__c=dfcon.Id,DF_Event__c=dfeve.Id);
    insert dfeveattnd;
    Test.startTest();
    ApexPages.currentPage().getParameters().put('id',dfeve.Id);
    DfEventAttendeeController dfevAt = new DfEventAttendeeController(new ApexPages.Standardcontroller(dfeve));  
    dfevAt.getListEventAttendees();
    dfevAt.save();       
    update dfeveattnd;
    update dfeve;
    update dfcon;
    delete dfeveattnd;
    delete dfeve;
    delete dfcon;
    Test.stopTest();
}
static testMethod void TestDementiaFriendsHandlers2 ()
{
   // insert and update multiple rows
   
   DF_Contact__c dfcon = new DF_Contact__c(Name='Test dfcontact',First_Name__c='Test',Last_Name__c='dfcontact',Status__c='Prospective',Email__c='test'+datetime.now().format('YYYYMMDDhhmmsshhmm')+'@dfcon.com',
   RecordTypeId=[Select Id from RecordType where SObjectType='DF_Contact__c' and Name Like 'Dementia Friend Champion'].Id,
                                            Contact_Number__c='12345678',Eligible__c=FALSE,Contacted__c=FALSE,
                                            Attended__c=FALSE,Note__c='Test Notes');
   DF_Contact__c dfcon2 = new DF_Contact__c(Name='Test dfcontact2',First_Name__c='Test',Last_Name__c='dfcontact2',Status__c='Prospective',Email__c='test2'+datetime.now().format('YYYYMMDDhhmmsshhmm')+'@dfcon.com',
   RecordTypeId=[Select Id from RecordType where SObjectType='DF_Contact__c' and Name Like 'Dementia Friend Champion'].Id,
                                            Contact_Number__c='12345678',Eligible__c=FALSE,Contacted__c=FALSE,
                                            Attended__c=FALSE,Note__c='Test Notes');

    List <DF_Contact__c> lstDFC = New List<DF_Contact__c>();
    lstDFC.add(dfcon);
    lstDFC.add(dfcon2);
    
    test.startTest();
    
    insert lstDFC;
    update lstDFC;
    
    
    DF_Event__c dfeve = new DF_Event__c(Name='dfevent test'
                              ,RecordTypeId=[Select Id from RecordType where SObjectType='DF_Event__c' and Name Like 'Champion Training Course'].Id
                              ,Session_Organiser__c=dfcon.Id, Event_Date_Time__c = system.now());
    DF_Event__c dfeve2 = new DF_Event__c(Name='dfevent test2'
                               , RecordTypeId=[Select Id from RecordType where SObjectType='DF_Event__c' and Name Like 'Champion Training Course'].Id
                               , Session_Organiser__c=dfcon2.Id, Event_Date_Time__c = system.now());


    List<DF_Event__c> lstDFE = new List<DF_Event__c>();
    
    lstDFE.add(dfeve);
    lstDFE.add(dfeve2);
        
    insert lstDFE;
    update lstDFE;
    
    
    
    
    DF_EventAttendee__c dfeveattnd = new DF_EventAttendee__c(DF_Contact__c=dfcon.Id,DF_Event__c=dfeve.Id);
    DF_EventAttendee__c dfeveattnd2 = new DF_EventAttendee__c(DF_Contact__c=dfcon.Id,DF_Event__c=dfeve.Id);
    List<DF_EventAttendee__c> lstDFEA = New List<DF_EventAttendee__c>();
    lstDFEA.add(dfeveattnd);
    lstDFEA.add(dfeveattnd2);
    insert lstDFEA;
    update lstDFEA;

	test.stopTest();

    /*
    now deletes
    */
    //delete lstDFEA;
    //delete lstDFE;
    //delete lstDFC;
    
    
}

/******************************************************************************************
 * Apex Class to test Partner_OrganisationStatistics. 
*******************************************************************************************/

Static testMethod void testPartner_OrganisationStatistics(){
        //record for champion
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE sObjectType =: 'DF_Contact__c' AND Name =: 'Dementia Friend Champion' AND isActive = TRUE];
        //record for RSO
        RecordType rtRSO = [SELECT Id, Name FROM RecordType WHERE sObjectType =: 'DF_Contact__c' AND Name =: 'RSO' AND isActive = TRUE];

              
        //New Partner_Organisation__c Record to be added to the DF_Contact__c test Data.
        Partner_Organisation__c pa = new Partner_Organisation__c(Name='Test Org', DFC_Code__c='ABC123', Partner_External_Id__c=1234);
        insert pa;              
        //RSO
        DF_Contact__c dfRSO = new DF_Contact__c(Name='Test RSO'
                                                , Postcode__c='ZZ1 2XX'
                                                , recordtypeid=rtRSO.id
                                                ,First_Name__c = 'Test', Last_Name__c ='DFC'
                                                ,email__c= 'email'+datetime.now().format('YYYYMMDDhhmmsshhmm')+'@alztest.com');
        insert dfRSO;
        //RSO Area Lookup
        RSO_AreaLookup__c dfAreaLookup = new RSO_AreaLookup__c(Name='Test RSO',DFContactId__c=dfRSO.id,Postcode_Supported__c='NW,SE');
        insert dfAreaLookup;        
        //New DF_Contact__c Record to be added to the test Data.
        //Now insert data causing the DF_Contact__c trigger to fire. 
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', pa.id);  
        Partner_OrganisationStatistics Partner_OrganisationCls= new Partner_OrganisationStatistics(new ApexPages.StandardController(pa));
        System.Debug('################## Total_No_of_Friends_Created  = ' + Partner_OrganisationCls.Total_No_of_Friends_Created + ' #######');
        System.Debug('################## Number_of_Champions_Identified   = ' + Partner_OrganisationCls.Number_of_Champions_Identified + ' #######');
        // now rerun with a champion associated with the partner organisation
        DF_Contact__c df = new DF_Contact__c(Name='Test DFC2'
                                            , Partner_Organisation_ID__c = pa.id
                                            , Contact_Ext_Id__c = 12345678
                                            , Postcode__c='ZZ1 2XX'
                                            , recordtypeid=rt.id
                                            , First_Name__c = 'Test'
                                            , Last_Name__c ='DFC2'
                                            , email__c= 'email2'+datetime.now().format('YYYYMMDDhhmmsshhmm')+'@alztest.com'
                                            , Total_No_of_Friends_Created__c = 99);
        insert df;        
        Partner_OrganisationCls = new Partner_OrganisationStatistics(new ApexPages.StandardController(pa));
        System.Debug('################## Total_No_of_Friends_Created  = ' + Partner_OrganisationCls.Total_No_of_Friends_Created + ' #######');
        System.Debug('################## Number_of_Champions_Identified   = ' + Partner_OrganisationCls.Number_of_Champions_Identified + ' #######');
        System.AssertEquals(Partner_OrganisationCls.Total_No_of_Friends_Created , 99.0);
        System.AssertEquals(Partner_OrganisationCls.Number_of_Champions_Identified, 1.0);
        Test.stopTest(); 
    }
/******************************************************************************************
 * Apex Class to test RSO Statistics. 
*******************************************************************************************/

Static testMethod void testRSOtatistics(){
        //record for champion
        //RecordType rt = [SELECT Id, Name FROM RecordType WHERE sObjectType =: 'DF_Contact__c' AND Name =: 'Dementia Friend Champion' AND isActive = TRUE];
        //record for RSO
        RecordType rtRSO = [SELECT Id, Name FROM RecordType WHERE sObjectType =: 'DF_Contact__c' AND Name =: 'RSO' AND isActive = TRUE];

              
        //New Partner_Organisation__c Record to be added to the DF_Contact__c test Data.
        Partner_Organisation__c pa = new Partner_Organisation__c(Name='Test Org', DFC_Code__c='ABC123', Partner_External_Id__c=1234);
        insert pa;              
        //RSO
        DF_Contact__c dfRSO = new DF_Contact__c(Name='Test RSO'
                                                , Postcode__c='ZZ1 2XX'
                                                , recordtypeid=rtRSO.id
                                                 ,First_Name__c = 'Test', Last_Name__c ='DFC'
                                                 ,email__c= 'email1'+datetime.now().format('YYYYMMDDhhmmsshhmm')+'@alztest.com');
        insert dfRSO;
        //RSO Area Lookup
        RSO_AreaLookup__c dfAreaLookup = new RSO_AreaLookup__c(Name='Test RSO',DFContactId__c=dfRSO.id,Postcode_Supported__c='ZZ');
        insert dfAreaLookup;        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', dfRSO.id);  
        DFRSOStatistics RSOCls= new DFRSOStatistics(new ApexPages.StandardController(dfRSO));
        System.Debug('################## Total_No_of_Friends_Created   = ' + RSOCls.Total_No_of_Friends_Created  + ' #######');
        System.Debug('################## Total_No_of_Champions_Created= ' + RSOCls.Total_No_of_Champions_Created + ' #######');
        // now run with a champion associated with the partner organisation
        DF_Contact__c df = new DF_Contact__c(Name='Test DFC2'
                                            ,Partner_Organisation_ID__c = pa.id
                                            , Contact_Ext_Id__c = 12345699
                                            , Postcode__c='ZZ1 2XX'
                                            , RecordTypeId=[Select Id from RecordType where SObjectType='DF_Contact__c' and Name Like 'Dementia Friend Champion'].Id
                                            , First_Name__c = 'Test'
                                            , Last_Name__c ='DFC'
                                            , email__c= 'email2'+datetime.now().format('YYYYMMDDhhmmsshhmm')+'@alztest.com'
                                            , Total_No_of_Friends_Created__c = 99);
        insert df;        
        RSOCls = new DFRSOStatistics(new ApexPages.StandardController(dfRSO));
        System.Debug('################## Total_No_of_Friends_Created  = ' + RSOCls.Total_No_of_Friends_Created + ' #######');
        System.Debug('################## Total_No_of_Champions_Created= ' + RSOCls.Total_No_of_Champions_Created+ ' #######');
        System.AssertEquals(RSOCls.Total_No_of_Friends_Created, 99.0);
        System.AssertEquals(RSOCls.Total_No_of_Champions_Created, 1.0);
        Test.stopTest(); 
    }



}