/*
*
* 2014-08-01 : CSL : This is the FIRST of two batch classes that will be run
* to update the DF_EventAttendee__c Status flags on records that are linked to 
* DF Contacts.  This code was originally taken from an Execute Anonymous script
* provided by The Alzheimers Society I.T Department.
*
* To call this class use the following:
//COPY FROM HERE
//RecordType rt = [SELECT Id, Name FROM RecordType WHERE sObjectType =: 'DF_Contact__c' AND Name =: 'Dementia Friend Champion' AND isActive = TRUE];
//String query = 'SELECT DF_Contact__r.Id,DF_Contact__r.Name,COUNT(DF_Contact__c) NumOfAttendees FROM DF_EventAttendee__c WHERE DF_Contact__r.Attended__c = True AND DF_Contact__r.RecordTypeId = \'' + rt.Id + '\' GROUP BY DF_Contact__r.Id,DF_Contact__r.Name HAVING COUNT(DF_Contact__c) = 1 ORDER BY DF_Contact__r.Name ASC';

RecordType rt = [SELECT Id, Name FROM RecordType WHERE sObjectType =: 'DF_Contact__c' AND Name =: 'Dementia Friend Champion' AND isActive = TRUE];
String query = 'SELECT d.Name, d.Id, d.Attended__c, d.Note__c, (Select Id, Event_Status__c, EventAttendeeStatus__c, DF_Event__r.Name From DF_EventAttendees__r) From DF_Contact__c d where d.Attended__c = true and d.RecordTypeId = \'' + rt.Id + '\'';


DFContactAttendeeFlagPhase1 dfcafp1 = new DFContactAttendeeFlagPhase1();
dfcafp1.query = query;

Database.executeBatch(dfcafp1);
//END COPY HERE
*
*/
global class DFContactAttendeeFlagPhase1 implements Database.Batchable<SObject> {
	
	global String query {get; set;}
	
	global Database.QueryLocator start(Database.BatchableContext BC){
    	return Database.getQueryLocator(query);
   	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope){
   		System.debug('### START ###');
		
		
		List<DF_EventAttendee__c> eventAttendeesToSave = new List<DF_EventAttendee__c>();
		
		for (SObject s : scope){
			DF_Contact__c dfc = (DF_Contact__c) s;
			if (dfc.DF_EventAttendees__r.size() > 0){
				for(DF_EventAttendee__c dfea : dfc.DF_EventAttendees__r){
                	dfea.EventAttendeeStatus__c = 'Attended';
                	eventAttendeesToSave.add(dfea);
            	}
			}	
		}
        
        
        if(eventAttendeesToSave.size() > 0){
            
        	//Create a savepoint.
			Savepoint sp = Database.setSavepoint();
            try{
                update(eventAttendeesToSave);
                System.debug('### ' + eventAttendeesToSave.Size() + ' ' + ' DF_EventAttendee__c records Updated.');
            }catch(DmlException e){
            	Database.rollback(sp);
                System.debug('### An exception occurred: ' + e.getMessage());
            }
        }else{
            System.debug('No DF_EventAttendee__c records to Update!');
        }
		
		System.debug('### END ###');
   	}
   	
	global void finish(Database.BatchableContext BC){
		system.debug('*** -- Finished DFContactAttendeeFlagPhase1 -- ***');
	}

}