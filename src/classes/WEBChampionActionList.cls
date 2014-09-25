/******************************************************************************************
 *  Cloud Symphony
 *  
 *  Purpose : APEX controller class for VF Page WEBChampionActionList.
 *  Author  : CSL
 *  Date    : 27-02-2014
 *  Version : 1.0
 *
 *  Description:    Apex Class loads Page Content, Snippets and Sections for Website content.
 *               
 *  Modification History
 *  Date            Who         Description 
                   
*******************************************************************************************/
public with sharing class WEBChampionActionList extends WEBController {
	
	public Boolean isChampion {get;set;}

	public List<Action__c> actions {
		get {
			if (actions == null)
				actions = new List<Action__c>();
			return actions;
		}
		set;
	}

	public User thisUser {
		get {
			return WEBController.thisUser;
		}
		set;
	}

	public Page_Snippet__c totalFriendsSnippet {
		get {
			if (totalFriendsSnippet == null){
				totalFriendsSnippet = [select p.Body_Text__c, p.Unique_Name__c from Page_Snippet__c p where p.Unique_Name__c = 'DementiaFriendsTotalSnippet' LIMIT 1];
			}
			return totalFriendsSnippet;
		}
		set ;
	}

	//Constructor
	public WEBChampionActionList() {

		isChampion = WEBConversionClass.isChampion(thisUser.contactId);

		List<DF_Event__c> events = [SELECT Id FROM DF_Event__c WHERE Session_Organiser__r.Portal_Contact__r.Id = :WEBController.thisUser.ContactId LIMIT 1000];

		List<DF_EventAttendee__c> myEventContacts = [SELECT DF_Contact__r.Id FROM DF_EventAttendee__c WHERE DF_Event__c = :events LIMIT 1000];

		List<Id> myEventContactsId = new List<Id>();
		
		if (myEventContacts != null && !myEventContacts.isEmpty()) {
		
			for (DF_EventAttendee__c att : myEventContacts) {
				myEventContactsId.add(att.DF_Contact__r.Id);
			}

			actions = [SELECT DF_Contact__r.Name, DF_Contact__r.Id, Id, Action__c, Public__c, Homepage__c FROM Action__c WHERE DF_Contact__r.Id = :myEventContactsId LIMIT 20];
		}
	}
}