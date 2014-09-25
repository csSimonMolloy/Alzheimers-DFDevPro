/*
* 2014-02-17 : SM : New trigger to process inserted / updated / deleted Contacts
*/

trigger ContactTrigger on Contact (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

    if (trigger.isAfter){
        if (trigger.isInsert){
            //ContactTriggerMethods.createDFContacts(trigger.new);
        }else if (trigger.isUpdate){
            //2014-03-28 : SM : This method isn't needed as the Contact record will never be updated
            //ContactTriggerMethods.updateDFContacts(trigger.new);
        }
    }

}