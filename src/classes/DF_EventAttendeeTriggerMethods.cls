/*
* 2014-03-25 : SM : This class holds methods called from the DF_EventAttendee__c trigger
*/
public class DF_EventAttendeeTriggerMethods {
	public static final String CHAMPION_RT = 'Champion_Training_Course';
	public static final String SESSION_RT = 'Dementia_Friend_Awareness_Session';
	public static final String EVENT_STATUS_CANCELLED = 'Cancelled';
	public static final String ATTENDEE_STATUS_CANCELLED = 'Cancelled';
	public static final String ATTENDEE_STATUS_NOSHOW = 'No Show';
	public static final String ATTENDEE_STATUS_ATTENDED = 'Attended';
	public static final String VF_CHAMPION_TRAINING_BOOKED = 'VF_Champion_Training_Booked';
	public static final String VF_CHAMPION_TRAINING_UNREGISTERED = 'VF_Champion_Training_Unregistered';
	public static final String VF_FRIEND_SESSION_BOOKING_CONFIRMED = 'VF_Friend_Session_Booking_Confirmed';
	public static final String VF_FRIEND_SESSION_CANCELLED = 'VF_Friend_Session_Cancelled';
	public static final String VF_NEW_ATTENDEE_ON_SESSION = 'VF_New_Attendee_On_Session';
	public static final String VF_NEW_INFORMATION_SESSIONS = 'VF_New_Information_Sessions';
	public static final String VF_SESSION_ATTENDEE_CANCELLATION = 'VF_Session_Attendee_Cancellation';
	public static final String VF_UPDATED_SESSION_INFORMATION = 'VF_Updated_Session_Information';
		
	//2014-03-25 : SM : This method will process ALL incoming DF_EventAttendee__c records and send the appropriate emails to either the
	//DF_Contact__c record or the Session_Organiser__c record
	public static void processNotificationEmails(List<DF_EventAttendee__c> inRecords, boolean isDelete, boolean isInsert){
		Map<String, EmailTemplate> emailTemplateMap = new Map<String, EmailTemplate>();
		List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
		for (EmailTemplate e : [select e.Id, e.DeveloperName from EmailTemplate e where e.IsActive = true and e.TemplateType = 'visualforce']){
			system.debug('*** -- Putting ' + e.DeveloperName + ' with ' + e.Id + ' -- ***');
			emailTemplateMap.put(e.DeveloperName, e);
		}
		
		//Get the Org Wide Email address lookup value
		String ORG_WIDE_EMAIL_ADDRESS_ID = '';
		Global_Setting__c globalSetting = Global_Setting__c.getInstance('orgWideEmailAddress');
        if (globalSetting != null && globalSetting.Value__c != null) {
	        ORG_WIDE_EMAIL_ADDRESS_ID = globalSetting.Value__c;
        }
		
		Map<Id, RecordType> rtMap = new Map<Id, RecordType>();
		Set<Id> dfEventIdSet = new Set<Id>();
		Set<Id> dfContactIdSet = new Set<Id>();
		
		for (RecordType rt : [select r.Id, r.DeveloperName from RecordType r where r.SObjectType = 'DF_Event__c' and r.IsActive = true]){
			rtMap.put(rt.Id, rt);
		}
		
		for (DF_EventAttendee__c dfe : inRecords){
			dfEventIdSet.add(dfe.DF_Event__c);
			dfContactIdSet.add(dfe.DF_Contact__c);
		}
		
		Map<Id, DF_Event__c> dfEventMap = new Map<Id, DF_Event__c>([select d.Id, d.RecordTypeId, d.Event_Date_Time__c, d.Event_Status__c, d.Number_of_Attendees__c,d.Session_Organiser__c, d.Session_Organiser__r.Name, d.Session_Organiser__r.Portal_Contact__c from DF_Event__c d where d.Id in :dfEventIdSet]);
		Map<Id, DF_Contact__c> dfContactMap = new Map<Id, DF_Contact__c>([select d.Id, d.Portal_Contact__c from DF_Contact__c d where d.Id in :dfContactIdSet]);
		
		//We need to loop through each DF_EventAttendee__c record and work out which emails need to be sent
		for (DF_EventAttendee__c dfe : inRecords){
			boolean isTrainingCourse = false;
			boolean isSession = false;
			
			DF_Event__c event = dfEventMap.get(dfe.DF_Event__c);
			DF_Contact__c con = dfContactMap.get(dfe.DF_Contact__c);
			//2014-07-03 : CSL : We now need to check the Event Date Time and only process those
			//Events that are scheduled for today or after today
			//Date todayDate = Date.today();
			//if (event.Event_Date_Time__c.date() < todayDate){
				if (event != null){
					Date todayDate = system.today();
					system.debug('*** -- event Date Time = ' + event.Event_Date_Time__c + ' -- ***');
					system.debug('*** -- Event Date Time days between ' + todayDate.daysBetween(event.Event_Date_Time__c.date()) + ' -- ***');
					if (todayDate.daysBetween(event.Event_Date_Time__c.date()) < 0 || EVENT_STATUS_CANCELLED.equalsIgnoreCase(event.Event_Status__c)){
						//We don't do anything if this event is before todays date
					}else {
						if (CHAMPION_RT.equalsIgnoreCase(rtMap.get(event.RecordTypeId).DeveloperName)){
						//This event attendee is against a Training Course
							isTrainingCourse = true;
						}else if (SESSION_RT.equalsIgnoreCase(rtMap.get(event.RecordTypeId).DeveloperName)){
							//This event attendee is against an Awareness Session
							isSession = true;
						}
						//We don't run this method on Insert / Update any more
						if (isTrainingCourse){
								if (con.Portal_Contact__c != null){
									Messaging.SingleEmailMessage sme = new Messaging.SingleEmailMessage();
									sme.setTemplateId(emailTemplateMap.get(VF_CHAMPION_TRAINING_UNREGISTERED).Id);
									system.debug('*** -- OUT4 dfe.DF_Contact__r.Portal_Contact__c = ' + con.Portal_Contact__c + ' -- ***');
									sme.setTargetObjectId(con.Portal_Contact__c);
									sme.setWhatId(dfe.Id);
									sme.setSaveAsActivity(false);
									if (ORG_WIDE_EMAIL_ADDRESS_ID != ''){
										sme.setOrgWideEmailAddressId(ORG_WIDE_EMAIL_ADDRESS_ID);
									}
									emailsToSend.add(sme);
								}
							}else if (isSession){
								//This is a cancelled attendee so we send an email to the DF_Contact__c record
								if (event.Session_Organiser__r.Portal_Contact__c != null){
									Messaging.SingleEmailMessage sme = new Messaging.SingleEmailMessage();
									sme.setTemplateId(emailTemplateMap.get(VF_SESSION_ATTENDEE_CANCELLATION).Id);
									system.debug('*** -- OUT5 dfe.DF_Event__r.Session_Organiser__c = ' + event.Session_Organiser__c + ' -- ***');
									sme.setTargetObjectId(event.Session_Organiser__r.Portal_Contact__c);
									sme.setWhatId(dfe.Id);
									sme.setSaveAsActivity(false);
									if (ORG_WIDE_EMAIL_ADDRESS_ID != ''){
										sme.setOrgWideEmailAddressId(ORG_WIDE_EMAIL_ADDRESS_ID);
									}
									emailsToSend.add(sme);
								}
							}
						}
					
					//}
				}
			//}
		}
		
		//2014-05-02 : CSL : We are temporarily disabling the sending of these emails
		if (emailsToSend.size() > 0){
			Messaging.sendEmail(emailsToSend);
		} 
		
	}
	
	
	//2014-03-25 : SM : This method will process ALL incoming DF_EventAttendee__c records and send the appropriate emails to either the
	//DF_Contact__c record or the Session_Organiser__c record
	@future(callout=false)
	public static void processNotificationEmailsFuture(Set<Id> inIdSet, boolean isDelete, boolean isInsert){
		List<DF_EventAttendee__c> inRecords = new List<DF_EventAttendee__c>();
		inRecords = [Select d.Trainer__c, d.Name, d.Id, d.Event_Status__c, d.EventAttendeeStatus__c, d.DF_Event__c, 
						d.DF_EntAtExt_Id__c, d.DF_Contact__c From DF_EventAttendee__c d where d.Id in :inIdSet];
		Map<String, EmailTemplate> emailTemplateMap = new Map<String, EmailTemplate>();
		List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
		for (EmailTemplate e : [select e.Id, e.DeveloperName from EmailTemplate e where e.IsActive = true and e.TemplateType = 'visualforce']){
			system.debug('*** -- Putting ' + e.DeveloperName + ' with ' + e.Id + ' -- ***');
			emailTemplateMap.put(e.DeveloperName, e);
		}
		
		//Get the Org Wide Email address lookup value
		String ORG_WIDE_EMAIL_ADDRESS_ID = '';
		Global_Setting__c globalSetting = Global_Setting__c.getInstance('orgWideEmailAddress');
        if (globalSetting != null && globalSetting.Value__c != null) {
	        ORG_WIDE_EMAIL_ADDRESS_ID = globalSetting.Value__c;
        }
		
		Map<Id, RecordType> rtMap = new Map<Id, RecordType>();
		Set<Id> dfEventIdSet = new Set<Id>();
		Set<Id> dfContactIdSet = new Set<Id>();
		
		for (RecordType rt : [select r.Id, r.DeveloperName from RecordType r where r.SObjectType = 'DF_Event__c' and r.IsActive = true]){
			rtMap.put(rt.Id, rt);
		}
		
		for (DF_EventAttendee__c dfe : inRecords){
			dfEventIdSet.add(dfe.DF_Event__c);
			dfContactIdSet.add(dfe.DF_Contact__c);
		}
		
		Map<Id, DF_Event__c> dfEventMap = new Map<Id, DF_Event__c>([select d.Id, d.RecordTypeId, d.Event_Date_Time__c, d.Number_of_Attendees__c,d.Session_Organiser__c, d.Session_Organiser__r.Name, d.Session_Organiser__r.Portal_Contact__c from DF_Event__c d where d.Id in :dfEventIdSet]);
		Map<Id, DF_Contact__c> dfContactMap = new Map<Id, DF_Contact__c>([select d.Id, d.Portal_Contact__c from DF_Contact__c d where d.Id in :dfContactIdSet]);
		
		//We need to loop through each DF_EventAttendee__c record and work out which emails need to be sent
		for (DF_EventAttendee__c dfe : inRecords){
			boolean isTrainingCourse = false;
			boolean isSession = false;
			
			DF_Event__c event = dfEventMap.get(dfe.DF_Event__c);
			DF_Contact__c con = dfContactMap.get(dfe.DF_Contact__c);
			//2014-07-03 : CSL : We now need to check the Event Date Time and only process those
			//Events that are scheduled for today or after today
			//Date todayDate = Date.today();
			//if (event.Event_Date_Time__c.date() < todayDate){
				if (event != null){
					system.debug('*** -- event Date Time = ' + event.Event_Date_Time__c + ' -- ***');
					Date todayDate = system.today();
					system.debug('*** -- Event Date Time days between ' + todayDate.daysBetween(event.Event_Date_Time__c.date()) + ' -- ***');
					if (todayDate.daysBetween(event.Event_Date_Time__c.date()) < 0){
						//We don't do anything if this event is before todays date
					}else {
						if (CHAMPION_RT.equalsIgnoreCase(rtMap.get(event.RecordTypeId).DeveloperName)){
						//This event attendee is against a Training Course
						isTrainingCourse = true;
						}else if (SESSION_RT.equalsIgnoreCase(rtMap.get(event.RecordTypeId).DeveloperName)){
							//This event attendee is against an Awareness Session
							isSession = true;
						}
						if (!isDelete){
							if (!ATTENDEE_STATUS_ATTENDED.equalsIgnoreCase(dfe.EventAttendeeStatus__c) && 
								!ATTENDEE_STATUS_NOSHOW.equalsIgnoreCase(dfe.EventAttendeeStatus__c) && 
								!ATTENDEE_STATUS_CANCELLED.equalsIgnoreCase(dfe.EventAttendeeStatus__c)){
									if (isTrainingCourse){
										if (isInsert){
											if (con.Portal_Contact__c != null){
												Messaging.SingleEmailMessage sme = new Messaging.SingleEmailMessage();
												sme.setTemplateId(emailTemplateMap.get(VF_CHAMPION_TRAINING_BOOKED).Id);
												system.debug('*** -- OUT1 dfe.DF_Contact__r.Portal_Contact__c = ' + con.Portal_Contact__c + ' -- ***');
												sme.setTargetObjectId(con.Portal_Contact__c);
												sme.setWhatId(dfe.Id);
												sme.setSaveAsActivity(false);
												if (ORG_WIDE_EMAIL_ADDRESS_ID != ''){
													sme.setOrgWideEmailAddressId(ORG_WIDE_EMAIL_ADDRESS_ID);
												}
												emailsToSend.add(sme);
											}
										}
									}else if(isSession){
										if (isInsert){
											if (con.Portal_Contact__c != null){
												Messaging.SingleEmailMessage sme = new Messaging.SingleEmailMessage();
												sme.setTemplateId(emailTemplateMap.get(VF_FRIEND_SESSION_BOOKING_CONFIRMED).Id);
												system.debug('*** -- OUT2 dfe.DF_Contact__r.Portal_Contact__c = ' + con.Portal_Contact__c + ' -- ***');
												sme.setTargetObjectId(con.Portal_Contact__c);
												sme.setWhatId(dfe.Id);
												sme.setSaveAsActivity(false);
												if (ORG_WIDE_EMAIL_ADDRESS_ID != ''){
													sme.setOrgWideEmailAddressId(ORG_WIDE_EMAIL_ADDRESS_ID);
												}
												emailsToSend.add(sme);
											}
										
											if (event.Session_Organiser__r.Portal_Contact__c != null){
												Messaging.SingleEmailMessage sme1 = new Messaging.SingleEmailMessage();
												sme1.setTemplateId(emailTemplateMap.get(VF_NEW_ATTENDEE_ON_SESSION).Id);
												system.debug('*** -- OUT3 dfe.DF_Event__r.Session_Organiser__c = ' + event.Session_Organiser__c + ' -- ***');
												sme1.setTargetObjectId(event.Session_Organiser__r.Portal_Contact__c);
												sme1.setWhatId(dfe.Id);
												sme1.setSaveAsActivity(false);
												if (ORG_WIDE_EMAIL_ADDRESS_ID != ''){
													sme1.setOrgWideEmailAddressId(ORG_WIDE_EMAIL_ADDRESS_ID);
												}
												emailsToSend.add(sme1);
											}
										}
									}
								}
						//We don't run the Delete part in the future method
						}
					}
				}
			//}
		}
		
		//2014-05-02 : CSL : We are temporarily disabling the sending of these emails
		if (emailsToSend.size() > 0){
			Messaging.sendEmail(emailsToSend);
		} 
		
	}

}