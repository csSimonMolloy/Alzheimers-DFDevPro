Public Class DFRSOStatistics
/******************************************************************************************
 *  Alzheimer's Society
 *  
 *  Purpose : Calculate and show the statistics for a Dementia Friend Partner Organisation
 *  Author  : Mike Tinson
 *  Date    : 31 March 2014
 *  Version : 1
 *
 *  Description: Read DF Contacts to calculate the statistics for their RSO
 *                  
 *               
 *  Modification History
 *  Date            Who         Description 
 *  
 *  
 ******************************************************************************************/
{
Public Double Registered_Events_Count {get;set;}
Public Double Total_No_of_Friends_Created {get;set;}
//Public Double Average_Number_of_Friends_Created {get;set;}
Public Double Total_No_of_Champions_Created {get;set;}
//Public Double Average_No_of_Champions_Created {get;set;}
Public Double Total_No_of_Completed_Info_Sessions {get;set;}
Public Double Total_No_of_Available_Info_Sessions {get;set;}
Public Double Total_No_of_Cancelled_Info_Sessions {get;set;}
Public Double Number_of_Public_Sessions_Run {get;set;}
Public Double Number_of_Private_Sessions_Run {get;set;}



public DFRSOStatistics(ApexPages.StandardController controller) {
    this();
}
public DFRSOStatistics()
{
    if(ApexPages.currentPage().getParameters().get('id')!=null)
    {
    Id ID =  ApexPages.currentPage().getParameters().get('id');

    getStatistics(ID);
    
    }
}
public void getStatistics(ID pID){
    List<aggregateResult> RSOAgg=[SELECT Regional_Support_Officer__c
                                        ,COUNT(id)
                                        ,SUM(Registered_Events_Count__c) RegEvents
                                        ,SUM(Total_No_of_Friends_Created__c) TotFriends
                                        ,SUM(Total_No_of_Completed_Info_Sessions__c ) TotCompletedSessions
                                        ,SUM(Total_No_of_Available_Info_Sessions__c) TotAvailSessions
                                        ,SUM(Total_No_of_Cancelled_Info_Sessions__c) TotCancSessions
                                        ,SUM(Number_of_Public_Sessions_Run__c) TotPublicSessions
                                        ,SUM(Number_of_Private_Sessions_Run__c) TotPrivateSessions
                                FROM DF_contact__c 
                                WHERE RecordType_Name__c = 'Dementia Friend Champion' 
                                AND  Regional_Support_Officer__c =:pID
                                GROUP BY Regional_Support_Officer__c];
    //retun count of champions and sum of friends, otherwise return zeros 
    IF (RSOAgg.size()>0){
        FOR (AggregateResult argRec : RSOAgg){
            Total_No_of_Friends_Created =(Double)argRec.get('TotFriends') ;
            Total_No_of_Champions_Created= (Double)argRec.get('expr0') ;
            Registered_Events_Count = (Double)argRec.get('RegEvents') ;
            Total_No_of_Completed_Info_Sessions = (Double)argRec.get('TotCompletedSessions') ;
            Total_No_of_Available_Info_Sessions= (Double)argRec.get('TotAvailSessions') ;
            Total_No_of_Cancelled_Info_Sessions= (Double)argRec.get('TotCancSessions') ;
            Number_of_Public_Sessions_Run= (Double)argRec.get('TotPublicSessions') ;
            Number_of_Private_Sessions_Run= (Double)argRec.get('TotPrivateSessions') ;
            //return zero, not null
            if (Total_No_of_Friends_Created==null){
                Total_No_of_Friends_Created=0;
                }
            
            
            if  (Total_No_of_Champions_Created==null){
                Total_No_of_Champions_Created=0;
                }
            if (Registered_Events_Count==null){ 
                Registered_Events_Count=0;
                }
            
            if  (Total_No_of_Completed_Info_Sessions ==null){
                Total_No_of_Completed_Info_Sessions =0;
                }

            if  (Total_No_of_Available_Info_Sessions==null){
                Total_No_of_Available_Info_Sessions=0;
                }
            
            if  (Total_No_of_Cancelled_Info_Sessions==null){
                Total_No_of_Cancelled_Info_Sessions=0;
                }
            if  (Number_of_Public_Sessions_Run==null){
                Number_of_Public_Sessions_Run=0;
                }

            if  (Number_of_Private_Sessions_Run==null){ 
                Number_of_Private_Sessions_Run=0;
                }
        }
    }
    else 
    {
        Total_No_of_Friends_Created =0;
        Total_No_of_Champions_Created= 0 ;
        Registered_Events_Count =0 ;
        Total_No_of_Completed_Info_Sessions = 0 ;
        Total_No_of_Available_Info_Sessions= 0;
        Total_No_of_Cancelled_Info_Sessions= 0 ;
        Number_of_Public_Sessions_Run= 0 ;
        Number_of_Private_Sessions_Run=0 ;
    }

}

}