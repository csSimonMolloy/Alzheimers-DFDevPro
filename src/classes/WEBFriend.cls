/******************************************************************************************
 *  Cloud Symphony
 *  
 *  Purpose : APEX class for the WEBFriend VF Page
 *			  
 *  Author  : CSL
 *  Date    : 27-02-2014
 *  Version : 1.0
 *
 *  Description:    WEBFriend class holds methods and properties used in the
 * 					WEBFriend VF Page	
 *               
 *  Modification History
 *  Date            Who         Description 
 *            
*******************************************************************************************/
public with sharing class WEBFriend extends WEBController {
    public final String EMPTY_FIELD_VALUE_MSG = 'Value is required and can\'t be empty';

    public final String REGISTER = 'Register for a Dementia Friend session';
    public final String REGISTERED = 'You have registered for a Dementia Friend session';
    public final String SESSION_CODE = 'Enter your Session Code :';
    public final String SESSION_CODE_ENTERED = 'You have entered your Session Code';
    public final String ACTION = 'Tell us about your action';
    public final String ACTION_ENTERED = 'You\'ve created an action';
    public final String RT_CHAMPION_COURSE = 'Champion_Training_Course';
    public final String RT_FRIENDSHIP_SESSION = 'Dementia_Friend_Awareness_Session';

    public final String SUCCESSFULLY_CONVERTED = 'You have successfully converted to a Dementia Friend.';

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

    public String sessionCode {get;set;}
    public String sessionCodeError {get;set;}

    public Boolean isMember {get;set;}
    public Boolean isFriend {get;set;}
    public Boolean isFriendConverted {get; set;}
    public Boolean isChampion {get;set;}
    
    public boolean isSession {get; set;}
    public boolean isTraining {get; set;}

    public Boolean hasActions {get;set;}
    public Boolean hasRegisteredForSession {get;set;}
    public Boolean hasSessionCode {get;set;}

    public String registerText {get;set;}
    public String sessionCodeText {get;set;}
    public String actionText {get;set;}

    public Boolean registeredAsFriend {get;set;}
    public Boolean showViewDetailsButton {get; set;}
    public boolean showSaveConfirmation {get; set;}
    public boolean showUnbookedConfirmation {get; set;}
    public String showActionText {get; set;}
    public boolean showAction {get; set;}

    public String messageArea {get;set;}
    public String messageAreaClass {get;set;}

    public List<DF_EventAttendee__c> events {get; set;}
    public List<Action__c> actions {get; set;}
    public Action__c theAction {get; set;}
    
    public Map<Id, RecordType> rtMap {get; set;}
    public Map<String, RecordType> rtMapByName {get; set;}

    public PageReference registerCode() {
        sessionCodeError = '';
        if (sessionCode.length() == 0)
            sessionCodeError = EMPTY_FIELD_VALUE_MSG;
        else
            if (sessionCode == WEBGlobalSettings.friendConvertCode) {

                boolean isSuccess = WEBConversionClass.convertToFriend(thisUser.ContactId, sessionCode);
				
				if (isSuccess){
                	registeredAsFriend = TRUE;
                	isFriend = TRUE;
                	isFriendConverted = TRUE;
                	hasSessionCode = TRUE;
                	hasRegisteredForSession = TRUE;
				}	
            }

        return null;
    }

	public PageReference convertToChampion(){
		PageReference pr = Page.WEBChampion;
		pr.getParameters().put('nr','true');
		if (WEBConversionClass.convertToChampion(thisUser.contactId)){
			return pr;
		}else {
			return null;
		}
	}
	
    public WEBFriend() {
        hasActions = FALSE;
        hasRegisteredForSession = FALSE;
        hasSessionCode = FALSE;
        isTraining = false;
        isSession = false;
        showSaveConfirmation = false;
        showUnbookedConfirmation = false;
        showAction = false;

        isFriend = TRUE;
        isFriendConverted = FALSE;

        sessionCodeError = '';

        registerText = REGISTER;
        sessionCodeText = SESSION_CODE;
        actionText = ACTION;

        registeredAsFriend = FALSE;

		if (ApexPages.currentPage().getParameters().get('ds') != null){
			showSaveConfirmation = true;
		}else {
			showSaveConfirmation = false;
		}
		
		if (ApexPages.currentPage().getParameters().get('ub') != null){
			showUnbookedConfirmation = true;
		}else {
			showUnbookedConfirmation = false;
		}
		
		if (ApexPages.currentPage().getParameters().get('sa') != null){
			showAction = true;
		}else {
			showAction = false;
		}

        // Are we converting back to a Friend from a Champion using the Parameter 'convertBack'
        String convertBackToFriend = ApexPages.currentPage().getParameters().get('convertBack');

        if (convertBackToFriend != null && convertBackToFriend.equalsIgnoreCase('TRUE')) {
            messageArea = SUCCESSFULLY_CONVERTED;
            messageAreaClass = 'alert-success';
            //Boolean isSuccess = WEBConversionClass.convertChampionToFriend(thisUser.contactId, WEBGlobalSettings.friendConvertCode);
        }
		
		rtMapByName = new Map<String, RecordType>();
		rtMap = new Map<Id, RecordType>();
		for (RecordType r : [select r.Id, r.DeveloperName from RecordType r where r.SobjectType = 'DF_Event__c' and r.IsActive = true]){
			rtMap.put(r.Id, r);
			rtMapByName.put(r.DeveloperName, r);
		}
		
        // Get Actions for the Friend
        //2014-03-10 : SM : Creating this list in the header of the class, as we need to be able to see it on the page
        actions = [SELECT Id, Action__c FROM Action__c WHERE DF_Contact__r.Portal_Contact__c = :thisUser.ContactId LIMIT 1];
        if (!actions.isEmpty()) {
            hasActions = TRUE;
            actionText = ACTION_ENTERED;
            theAction = actions[0];
            showActionText = theAction.Action__c;
        }

        //2014-03-10 : SM : Creating this list in the header of the class, as we need to be able to see it on the page
        system.debug('*** -- Get Events -- ***');
        RecordType friendRT = rtMapByName.get(RT_FRIENDSHIP_SESSION);
        //2014-005-18 : A user CAN be booked on more than one event, so I need to take off the LIMIT 1 argument
        
        //events = [SELECT Id, DF_Event__r.Event_Date_Time__c, DF_Event__r.City__c, DF_Event__r.Postcode__c, DF_Event__r.Number_of_Attendees__c, DF_Event__r.RecordTypeId 
        //			FROM DF_EventAttendee__C WHERE DF_Contact__r.Portal_Contact__c = :thisUser.ContactId
        //			and  DF_Event__r.RecordTypeId = :friendRT.Id LIMIT 1];
		events = [SELECT Id, DF_Event__r.Event_Date_Time__c, DF_Event__r.City__c, DF_Event__r.Postcode__c, DF_Event__r.Number_of_Attendees__c, DF_Event__r.RecordTypeId 
        			FROM DF_EventAttendee__C WHERE DF_Contact__r.Portal_Contact__c = :thisUser.ContactId
        			and  DF_Event__r.RecordTypeId = :friendRT.Id];        			
        system.debug('*** -- events.size() = ' + events.size() + ' -- ***');
        
        if (!events.isEmpty()) {
        	//TODO : We may need to address this code if people can book on more than one Session
        	//In the mean time we will assume they can only book on one
            hasRegisteredForSession = TRUE;
            registerText = REGISTERED;
            DF_EventAttendee__c event = events[0];
            showViewDetailsButton = true;
            //2014-05-18 : CSL : As we now need to be able to unbook from sessions in the past, this next line
            //needs to be commented out so they 'View Details' button is always visible
            //if (event.DF_Event__r.Event_Date_Time__c < Date.today()) showViewDetailsButton = false; 
            if (RT_CHAMPION_COURSE.equalsIgnoreCase(rtMap.get(event.DF_Event__r.RecordTypeId).DeveloperName)){
            	isTraining = true;
            }else {
            	isSession = true;
            }
            //2014-03-27 : SM : We cannot assume that just because the date has passed on the event, that they have a Session Code
            //if (event.DF_Event__r.Event_Date_Time__c < Date.today())
            //    hasSessionCode = TRUE;
        }

        if (WEBConversionClass.isFriend(thisUser.ContactId)) {
            System.debug('*** Friend ' + thisUser.ContactId);
            isFriend = TRUE;
        }
        
        if (WEBConversionClass.isFriendConverted(thisUser.ContactId)){
        	isFriendConverted = TRUE;
        	hasSessionCode = TRUE;
        	hasRegisteredForSession = TRUE;
        	registerText = REGISTERED;
        	sessionCodeText = SESSION_CODE_ENTERED;
        }
        
        system.debug('*** -- isFriend = ' + isFriend + ' -- ***');
        system.debug('*** -- isFriendConverted = ' + isFriendConverted + ' -- ***');
                    
    }
}