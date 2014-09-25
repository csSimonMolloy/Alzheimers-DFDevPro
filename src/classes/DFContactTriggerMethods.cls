/******************************************************************************************
 *  Cloud Symphony
 *  
 *  Purpose : APEX method class for VF Trigger DF_ContactTrigger
 *  Author  : CSL
 *  Date    : 27-02-2014
 *  Version : 1.0
 *
 *  Description:    Apex Class that will hold methods called by the DF_ContactTrigger
 * 					
 *               
 *  Modification History
 *  Date            Who         Description 
 *            
*******************************************************************************************/
public with sharing class DFContactTriggerMethods {
	public static final String RT_NEWSLETTER = 'E_Newsletter_Subscriber';
	public static final String RT_DEMENTIA_FRIEND = 'Dementia_Friend';
	public static final String RT_DEMENTIA_FRIEND_CHAMPION = 'Dementia_Friend_Champion';
	public static final String DUPLICATE_DETECTED_ERROR = 'Already Registered';

	//This method will check for duplicate DF Contact records and if it finds any
	//will add an error to the record to stop the insert.
	public static void dedupeDFContacts(List<DF_Contact__c> inDFContacts){
		Set<String> dfContactEmails = new Set<String>();
		Map<String, DF_Contact__c> existingDFContacts = new Map<String, DF_Contact__c>();
		for (DF_Contact__c dfc : inDFContacts){
			dfContactEmails.add(dfc.Email__c);
		}
		
		for (DF_Contact__c dfc : [select d.Id, d.Email__c from DF_Contact__c d where d.Email__c in :dfContactEmails]){
			existingDFContacts.put(dfc.Email__c, dfc);	
		}
		
		for (DF_Contact__c dfc : inDFContacts){
			DF_Contact__c existingDFContact = existingDFContacts.get(dfc.Email__c);
			if (existingDFContact != null){
				dfc.addError(DUPLICATE_DETECTED_ERROR);
			}
		}
		
	}

	//This method will take any incoming DF_Contact__c records (insert only) and create corresponding Contact records
	public static void createContacts(List<DF_Contact__c> inDFContacts){
		
		system.debug('*** -- Into createContacts -- ***');
		
		String accountId = WEBGlobalSettings.webAccountOwnerId;
		
		Map<String, RecordType> contactRTMap = new Map<String, RecordType>();
		for (RecordType r : [select r.Id, r.DeveloperName from RecordType r where r.IsActive = true and r.SObjectType = 'Contact']){
			contactRTMap.put(r.DeveloperName, r);
		}
		Map<Id, RecordType> dfContactRTMap = new Map<Id, RecordType>([select r.Id, r.DeveloperName from RecordType r where r.IsActive = true and r.SObjectType = 'DF_Contact__c']);
		Map<String, Contact> contactSavedMap = new Map<String, Contact>();
		
		List<Contact> contactsToSave = new List<Contact>();
		Set<String> emailSet = new Set<String>();
		Set<String> lastNameSet = new Set<String>();
		Set<Id> contactIdSet = new Set<Id>();
		
		for (DF_Contact__c dfc : inDFContacts){
			emailSet.add(dfc.Email__c);
			lastNameSet.add(dfc.Last_Name__c);
		}
		
		Map<String, Contact> contactMap = new Map<String, Contact>();
		for (Contact c : [select c.LastName, c.Email from Contact c where c.LastName in :lastNameSet and c.Email in :emailSet]){
			//contactMap.put(c.LastName + '~' + c.Email, c);
			contactMap.put(c.Email.toLowerCase(), c);
		}
		
		for (DF_Contact__c dfc : inDFContacts){
			//if (contactMap.get(dfc.Last_Name__c+'~'+dfc.Email__c) == null){
			if (contactMap.get(dfc.Email__c.toLowerCase()) == null){
				RecordType dfcRT = dfContactRTMap.get(dfc.RecordTypeId);
				Contact c = new Contact();
				c.RecordTypeId = contactRTMap.get(dfcRT.DeveloperName).Id;
				c.LastName = dfc.Last_Name__c;
				c.FirstName = dfc.First_Name__c;
				c.Email = dfc.Email__c;
				c.Title = dfc.Title__c;
				c.Newsletters__c = dfc.Newsletters__c;
				c.AccountId = accountId;
				contactsToSave.add(c);
				contactSavedMap.put(c.Email.toLowerCase(), c);
			}
		}
		
		system.debug('*** -- insert contactsToSave -- ***');
		insert contactsToSave;
		
		system.debug('*** -- update Portal_Contact -- ***');
		//for (DF_Contact__c dfc : inDFContacts){
		//	Contact c = contactSavedMap.get(dfc.Last_Name__c + '~' + dfc.Email__c);
		//	if (c != null){
		//		dfc.Portal_Contact__c = c.Id;
		//	}
		//}
	}
	
	//This method will make sure the DF_Contact has a link to the Portal Contact
	@future(callout=false)
	public static void assignPortalContact(Set<Id> dfContactIDs){
		List<DF_Contact__c> inDFContacts = new List<DF_Contact__c>();
		List<DF_Contact__c> saveDFContacts = new List<DF_Contact__c>();
		inDFContacts = [select d.Email__c, d.Last_Name__c, d.Id, d.RecordTypeId from DF_Contact__c d where d.Id in :dfContactIDs];
		
		if (inDFContacts.size() > 0){
			Set<String> emailSet = new Set<String>();
			Set<String> lastNameSet = new Set<String>();
			
			for (DF_Contact__c dfc : inDFContacts){
				emailSet.add(dfc.Email__c);
				lastNameSet.add(dfc.Last_Name__c);
			}
			
			Map<String, Contact> contactMap = new Map<String, Contact>();
			for (Contact c : [select c.Id, c.LastName, c.Email from Contact c where c.LastName in :lastNameSet and c.Email in :emailSet]){
				//contactMap.put(c.LastName + '~' + c.Email, c);
				contactMap.put(c.Email.toLowerCase(), c);
			}
			
			for (DF_Contact__c dfc : inDFContacts){
				//Contact c = contactMap.get(dfc.Last_Name__c + '~' + dfc.Email__c);
				Contact c = contactMap.get(dfc.Email__c.toLowerCase());
				if (c != null){
					dfc.Portal_Contact__c = c.Id;
					saveDFContacts.add(dfc);
				}
			}
			
			if (saveDFContacts.size() > 0){
				update saveDFContacts;
			}
		}
		
	}
	
	//This method will take any updated DF_Contact__c records, and find the corresponding Contact, and update it (if it's been changed)
	//2014-06-25 : CSL : We need to update this method to try and find a corresponding Contact record by email
	//Or create a new one if the DF_Contact__c.Portal_Contact__c == NULL
	public static void updateContacts(List<DF_Contact__c> inDFContacts){
		
		Map<String, RecordType> contactRTMap = new Map<String, RecordType>();
		Map<Id, RecordType> contactRTMapById = new Map<Id, RecordType>();
		
		String accountId = WEBGlobalSettings.webAccountOwnerId;
		
		Set<Id> contactIdSet = new Set<Id>();
		Set<String> contactEmailSet = new Set<String>();
		List<Contact> contactsToSave = new List<Contact>();
		Set<Id> dfContactIdsToUpdate = new Set<Id>();
		boolean contactFound;
		List<Contact> contactsToInsert = new List<Contact>();
		
		for (RecordType r : [select r.Id, r.DeveloperName from RecordType r where r.IsActive = true and r.SObjectType = 'Contact']){
			contactRTMap.put(r.DeveloperName, r);
			contactRTMapById.put(r.Id, r);
		}

		Map<Id, RecordType> dfContactRTMap = new Map<Id, RecordType>([select r.Id, r.DeveloperName from RecordType r where r.IsActive = true and r.SObjectType = 'DF_Contact__c']);
		
		for (DF_Contact__c dfc : inDFContacts){
			if (dfc.Portal_Contact__c != null){
				contactIdSet.add(dfc.Portal_Contact__c);
			}else {
				contactEmailSet.add(dfc.Email__c);
			}
		}
		
		Map<Id, Contact> contactMap = new Map<Id, Contact>([select c.RecordTypeId, c.FirstName, c.LastName, c.Email, c.Title, c.Phone, c.Newsletters__c, c.MailingPostalCode from Contact c where c.Id in :contactIdSet]);
		Map<String, Contact> contactByEmailMap = new Map<String, Contact>();
		
		for (Contact c : [select c.RecordTypeId, c.FirstName, c.LastName, c.Email, c.Title, c.Phone, c.Newsletters__c, c.MailingPostalCode from Contact c where c.Email in :contactEmailSet]){
			contactByEmailMap.put(c.Email, c);
		}
		
		for (DF_Contact__c dfc : inDFContacts){
			contactFound = false;	
		
			RecordType dfcRT = dfContactRTMap.get(dfc.RecordTypeId);
			if (dfc.Portal_Contact__c != null){
				Contact c = contactMap.get(dfc.Portal_Contact__c);
				if (c != null){
					boolean contactChanged = false;
					contactFound = true;
					if (c.Email != dfc.Email__c){
						c.Email = dfc.Email__c;
						contactChanged = true;
					}
					if (c.LastName != dfc.Last_Name__c){
						c.LastName = dfc.Last_Name__c;
						contactChanged = true;
					}
					if (c.FirstName != dfc.First_Name__c){
						c.FirstName = dfc.First_Name__c;
						contactChanged  = true;
					}
					if (c.Title != dfc.Title__c){
						c.Title = dfc.Title__c;
						contactChanged = true;
					}
					if (c.Phone != dfc.Contact_Number__c){
						c.Phone = dfc.Contact_Number__c;
						contactChanged = true;
					}
					if (c.Newsletters__c != dfc.Newsletters__c){
						c.Newsletters__c = dfc.Newsletters__c;
						contactChanged = true;
					}
					if (c.MailingPostalCode != dfc.Postcode__c){
						c.MailingPostalCode = dfc.Postcode__c;
						contactChanged = true;
					}
					RecordType conRT = contactRTMapById.get(c.RecordTypeId);
					if (conRT.Id != dfcRT.Id){
						c.RecordTypeId = contactRTMap.get(dfcRT.DeveloperName).Id;
						contactChanged = true; 
					}
					 
					if (contactChanged) contactsToSave.add(c);
				}
			}else {
				Contact c = contactByEmailMap.get(dfc.Email__c);
				if (c != null){
					boolean contactChanged = false;
					contactFound = true;
					if (c.Email != dfc.Email__c){
						c.Email = dfc.Email__c;
						contactChanged = true;
					}
					if (c.LastName != dfc.Last_Name__c){
						c.LastName = dfc.Last_Name__c;
						contactChanged = true;
					}
					if (c.FirstName != dfc.First_Name__c){
						c.FirstName = dfc.First_Name__c;
						contactChanged  = true;
					}
					if (c.Title != dfc.Title__c){
						c.Title = dfc.Title__c;
						contactChanged = true;
					}
					if (c.Phone != dfc.Contact_Number__c){
						c.Phone = dfc.Contact_Number__c;
						contactChanged = true;
					}
					if (c.Newsletters__c != dfc.Newsletters__c){
						c.Newsletters__c = dfc.Newsletters__c;
						contactChanged = true;
					}
					if (c.MailingPostalCode != dfc.Postcode__c){
						c.MailingPostalCode = dfc.Postcode__c;
						contactChanged = true;
					}
					RecordType conRT = contactRTMapById.get(c.RecordTypeId);
					if (conRT.Id != dfcRT.Id){
						c.RecordTypeId = contactRTMap.get(dfcRT.DeveloperName).Id;
						contactChanged = true; 
					}
					 
					if (contactChanged) contactsToSave.add(c);
					
					dfContactIdsToUpdate.add(dfc.Id);
				}
			}
			
			if (!contactFound){
				Contact c = new Contact();
				c.RecordTypeId = contactRTMap.get(dfcRT.DeveloperName).Id;
				c.LastName = dfc.Last_Name__c;
				c.FirstName = dfc.First_Name__c;
				c.Email = dfc.Email__c;
				c.Title = dfc.Title__c;
				c.Newsletters__c = dfc.Newsletters__c;
				c.AccountId = accountId;
				
				contactsToInsert.add(c);
				dfContactIdsToUpdate.add(dfc.Id);
			}
			
		}
	
		if (contactsToSave.size() > 0){
			update contactsToSave;
		}
		
		if (contactsToInsert.size() > 0){
			insert contactsToInsert;		
		}

		if (dfContactIdsToUpdate.size() > 0){
			DFContactTriggerMethods.assignPortalContact(dfContactIdsToUpdate);
		}
	
	}

}