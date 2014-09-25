public with sharing class WEBRecentActions {
	public List<Action__c> actions {
		get {
			if (actions == null)
				actions = new List<Action__c>();
			return actions;
		}
		private set;
	}

	public WEBRecentActions() {
		actions = [SELECT DF_Contact__r.Name, DF_Contact__r.Id, Id, Action__c, Public__c, Homepage__c FROM Action__c WHERE Public__c = TRUE AND Homepage__c = TRUE ORDER BY CreatedDate DESC LIMIT 10];
		system.debug('*** -- got Actions -- ***');
		
	}
}