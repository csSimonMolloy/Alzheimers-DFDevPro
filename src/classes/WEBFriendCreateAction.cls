public with sharing class WEBFriendCreateAction extends WEBController {
	public final String ID_PARAM = 'Id';
	
	public Boolean publicCheckbox {get;set;}
	public String action {get;set;}
	public Action__c act {get; set;}
	

	public PageReference cancel() {
		return Page.WEBFriend;
	}

	public PageReference save() {
		if (act == null){	
			act = new Action__c(Action__c = action, Public__c = publicCheckbox);
			
		
			if (action.length() > 0)
			{
				List<DF_Contact__c> dfcList = new List<DF_Contact__c>();
				dfcList = [SELECT id FROM DF_Contact__c WHERE Portal_Contact__c = :WEBController.thisUser.ContactId LIMIT 1];
				
				if (dfcList.size() > 0) {	
					act.DF_Contact__c = dfcList[0].Id;
					if (act.Public__c){
						act.Homepage__c = true;
					}
					insert act;
				}
			}
		}else {
			system.debug('*** -- About to save -- ***');
			
			try {
				act.Action__c = action;
				act.Public__c = publicCheckBox;
				if (act.Public__c){
					act.Homepage__c = true;
				}
				update act;	
			}catch (Exception e){
				system.debug('*** -- Caught Exception : ' + e + ' -- ***');
			}
			
		}
		
		PageReference pageRef = Page.WEBFriend;
		pageRef.getParameters().put('sa',act.Id);
		return pageRef;
	}

	public WEBFriendCreateAction() {
		if (ApexPages.currentPage().getParameters().get(ID_PARAM) != null){
			act = [select a.Public__c, a.DF_Contact__c, a.Action__c from Action__c a where a.Id = :ApexPages.currentPage().getParameters().get(ID_PARAM) LIMIT 1];
			action = act.Action__c;
			publicCheckbox = act.Public__c;	
		}else {
			action = '';
			publicCheckbox = true;	
		}
		
	}
}