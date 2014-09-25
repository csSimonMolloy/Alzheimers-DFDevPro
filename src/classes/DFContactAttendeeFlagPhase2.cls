/*
*
* 2014-08-01 : CSL : This is the SECOND of two batch classes that will be run
* to update the DF_EventAttendee__c Status flags on records that are linked to 
* DF Contacts.  This code was originally taken from an Execute Anonymous script
* provided by The Alzheimers Society I.T Department.
*
* To call this class use the following:
//COPY FROM HERE
RecordType rt = [SELECT Id, Name FROM RecordType WHERE sObjectType =: 'DF_Contact__c' AND Name =: 'Dementia Friend Champion' AND isActive = TRUE];
String query = 'SELECT d.Name, d.Id, d.Attended__c, d.Note__c, (Select Id, Event_Status__c, EventAttendeeStatus__c, DF_Event__r.Name From DF_EventAttendees__r) From DF_Contact__c d where d.Attended__c = true and d.RecordTypeId = \'' + rt.Id + '\'';

DFContactAttendeeFlagPhase2 dfcafp2 = new DFContactAttendeeFlagPhase2();
dfcafp2.query = query;

Database.executeBatch(dfcafp2);
//END COPY HERE
*
*/
global class DFContactAttendeeFlagPhase2 implements Database.Batchable <SObject> {

	global String query {get; set;}
	
	global Database.QueryLocator start(Database.BatchableContext BC){
    	return Database.getQueryLocator(query);
   	}
   	
   	global void execute(Database.BatchableContext BC, List<sObject> scope){
   		System.debug('### START ###');
//*****  NEW CODE ***** //

		Set<Id> dfContactIds = new Set<Id>();
		
		for (SObject s : scope){
			DF_Contact__c dfc = (DF_Contact__c) s;
			if (dfc.DF_EventAttendees__r.size() > 0){
				dfContactIds.add(dfc.Id);
			}	
		}		

		System.debug('### dfContactIds : ' + dfContactIds.Size());	
        
		List<DF_EventAttendee__c> dfeaIds = new List<DF_EventAttendee__c>([Select Id From DF_EventAttendee__c WHERE DF_Contact__c IN: dfContactIds]);																	
        System.debug('### dfeaIds : ' + dfeaIds.Size());        																    

		Map<Id,DF_Contact__c> dfConMap = new Map<Id, DF_Contact__c>([Select Id, Note__c From DF_Contact__c WHERE Id IN: dfContactIds]);
		System.debug('### dfConMap : ' + dfConMap);

		Set<Id> dfeaAttendedIds = new Set<Id>();
        Set<Id> dfeaNoShowIds = new Set<Id>();
		
		//Loop round the DFEventAttendees for all Contacts in the dfConMap.
		for(DF_EventAttendee__c dfea : [ SELECT Id,DF_Contact__c,EventAttendeeStatus__c,DF_Event__r.City__c,DF_Event__r.Event_Date_Time__c FROM DF_EventAttendee__c WHERE DF_Contact__c IN : dfConMap.Values() ORDER BY DF_Contact__c,CreatedDate DESC]){
			
			DF_Contact__c dfc = dfConMap.get(dfea.DF_Contact__c);
			String strNote = Null;
            
            if(dfc != Null){
                System.debug('### dfc : ' + dfc.Id + ' - ' + dfea.Id);

				strNote = dfc.Note__c;
				
                if(String.isEmpty(strNote)) {
            		//The string is empty or blank or null
                    strNote = strNote + ' ';
        		}
                
                String str = Null;
				Boolean result = false;
				str = dfea.DF_Event__r.City__c + ' ' + dfea.DF_Event__r.Event_Date_Time__c.format('dd/MM/yy');					
				result = strNote.contains(str);
				
				//If the Note__c field contains the concatenated EventCity/DateTime then add to a collection.
				if(result == true){
					dfeaAttendedIds.add(dfea.Id);
				}else{
					dfeaNoShowIds.add(dfea.Id);						
				}
            }
		}	
		System.debug('dfeaAttendedIds.Size : ' + dfeaAttendedIds.Size());
		System.debug('dfeaNoShowIds.Size : ' + dfeaNoShowIds.Size());

		//---------------------------------------------------------------------------------------------------------
        //UPDATE DF_EVENTATTENDEE WITH ATTENDED
		//---------------------------------------------------------------------------------------------------------
		List<DF_EventAttendee__c> manyEAIds = new List<DF_EventAttendee__c>();
        manyEAIds = [SELECT Id FROM DF_EventAttendee__c WHERE Id In:dfeaAttendedIds];
        System.debug('manyEAIds : ' + manyEAIds.Size());

        for(DF_EventAttendee__c dfea : manyEAIds){
        	dfea.EventAttendeeStatus__c = 'Attended';
		}
            
        //Attempt to update the DF_EventAttendee__c Object.
        if(manyEAIds.isEmpty() == false){
        	//Create a savepoint.
			Savepoint sp = Database.setSavepoint();
	        try{
	        	update(manyEAIds);
				System.debug('----- ' + manyEAIds.Size() + ' ----- ' + ' DF_EventAttendee__c records Updated.');
            }catch(DmlException e){
                	Database.rollback(sp);
                    System.debug('### An exception occurred: ' + e.getMessage());
			}
		}else{
			System.debug('No DF_EventAttendee__c records were Updated!');
		} 			
		
		//---------------------------------------------------------------------------------------------------------
        //UPDATE DF_EVENTATTENDEE WITH NO SHOW
		//---------------------------------------------------------------------------------------------------------
		List<DF_EventAttendee__c> noshowEAIds = new List<DF_EventAttendee__c>();
        noshowEAIds = [SELECT Id FROM DF_EventAttendee__c WHERE Id In:dfeaNoShowIds];
        System.debug('noshowEAIds : ' + noshowEAIds.Size());

        for(DF_EventAttendee__c dfea : noshowEAIds){
        	dfea.EventAttendeeStatus__c = 'No Show';
		}
            
        //Attempt to update the DF_EventAttendee__c Object.
        if(noshowEAIds.isEmpty() == false){
        	//Create a savepoint.
			Savepoint sp = Database.setSavepoint();        	
        	try{
				update(noshowEAIds);
                System.debug('----- ' + noshowEAIds.Size() + ' ----- ' + ' DF_EventAttendee__c records Updated.');
            }catch(DmlException e){
                	Database.rollback(sp);
                    System.debug('### An exception occurred: ' + e.getMessage());
			}
		}else{
			System.debug('No DF_EventAttendee__c records were Updated!');
		}
		
		System.debug('### END ###');
   		
   	}
   	
   	global void finish(Database.BatchableContext BC){
		system.debug('*** -- Finished DFContactAttendeeFlagPhase2 -- ***');
	}
		
//***** END OF NEW CODE ***** //

}