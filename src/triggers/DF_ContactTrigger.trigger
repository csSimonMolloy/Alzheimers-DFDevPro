trigger DF_ContactTrigger on DF_Contact__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

    /* The code is broken down into a Trigger and an Apex “handler” class that implements the actual functionality.
       It’s best practice to only have one trigger for each object and to avoid complex logic in triggers. 
       To simplify testing and resuse, triggers should delegate to Apex classes which contain the actual execution logic.*/

    System.debug('****** DF_ContactTrigger ******');

    // Delegate responsibility to the DF_ContactTriggerHandler Class.
    DF_ContactTriggerHandler handler = new DF_ContactTriggerHandler(Trigger.isExecuting, Trigger.size);

    if(Trigger.isInsert && Trigger.isBefore)
    {
        //Call the Handler OnBeforeInsert Method and execute trigger logic.
        //2014-04-24 : SM : TODO : Temporarily removing this code : 
        handler.OnBeforeInsert(Trigger.new, Trigger.newMap);

    }
    else if(Trigger.isInsert && Trigger.isAfter){
        //Call the Handler OnAfterInsert Method and execute trigger logic.
        handler.OnAfterInsert(Trigger.new, Trigger.newMap);
        DFContactTriggerMethods.createContacts(trigger.new);
        
        //2014-04-30 : SM : We need to call an @future method to update the DF Contact
        //with the created Contact record (field : Portal_Contact__c)
        Set<Id> dfContactIDs = new Set<Id>();   
        for (DF_Contact__c dfc : trigger.new){
            dfContactIDs.add(dfc.Id);
        }     
        
        if (dfContactIDs.size() > 0){
            DFContactTriggerMethods.assignPortalContact(dfContactIDs);
        }
        
        
    }
    else if(Trigger.isUpdate && Trigger.isBefore)
    {
        //Call the Handler OnBeforeUpdate Method and execute trigger logic.
        //2014-04-24 : SM : TODO : Temporarily removing this code : 
        handler.OnBeforeUpdate(Trigger.old,Trigger.oldMap,Trigger.new, Trigger.newMap);
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        //Call the Handler OnAfterUpdate Method and execute trigger logic.
        handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
        //2014-04-08 : SM : Call new method to make sure Contact record is up to date
        //If a DF_Contact__c record is updated
        DFContactTriggerMethods.updateContacts(trigger.new);
        
    }
    else if(Trigger.isDelete && Trigger.isBefore){

    }
    else if(Trigger.isDelete && Trigger.isAfter){
        //Call the Handler OnAfterDelete Method and execute trigger logic.
        //2014-04-24 : SM : TODO : Temporarily removing this code : 
        handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
        
    }
    else if(Trigger.isUnDelete){
  
    }

}