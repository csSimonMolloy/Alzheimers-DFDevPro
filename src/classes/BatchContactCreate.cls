/*
* 2014-03-17 : SM : This class will be called to batch-create a list of Contact records, based on new DF_Contact__c records 
*/
global class BatchContactCreate implements Database.Batchable <Sobject> {

	global static final String RT_NEWSLETTER = 'E_Newsletter_Subscriber';
	global static final String RT_DEMENTIA_FRIEND = 'Dementia_Friend';
	global static final String RT_DEMENTIA_FRIEND_CHAMPION = 'Dementia_Friend_Champion';
	global static final String RT_ADMIN = 'Admin';
	global static final String PROFILE_ID_NAME = 'DF HVCP';
	global static final String PORTAL_ACCOUNT_NAME = '** PORTAL REGISTRATION ACCOUNT **';	
	
	global String query {get; set;}
	global List<DF_Contact__c> processList = new List<DF_Contact__c>();
	
	global Database.querylocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
		//List<DF_Contact__c> dfContactList = [Select d.Title__c, d.Street__c, d.Status__c, d.RecordTypeId, d.Postcode__c, d.Portal_Contact__c, d.Last_Name__c, d.Id, d.First_Name__c, d.Email__c, d.County__c, 
		//										d.Country__c, d.Contact_Number__c, d.City__c, d.Newsletters__c From DF_Contact__c d where d.Portal_Contact__c = ''];
		//return dfContactList;
	}
	
	global void execute(Database.BatchableContext info, List<Sobject> scope){
		system.debug('*** -- About to process ' + scope.size() + ' records in BatchContactCreate.execute -- ***');
		
		//Portal Account
		Account portalAccount = [select a.Id, a.Name from Account a where a.Name = :PORTAL_ACCOUNT_NAME LIMIT 1];
		List<User> usersToSave = new List<User>();
		Profile portalProfile = [select p.Id, p.Name from Profile p where p.Name = :PROFILE_ID_NAME LIMIT 1];
		
		Map<String, RecordType> contactRTMap = new Map<String, RecordType>();
		for (RecordType r : [select r.Id, r.DeveloperName from RecordType r where r.IsActive = true and r.SObjectType = 'Contact']){
			contactRTMap.put(r.DeveloperName, r);
		}
		Map<Id, RecordType> dfContactRTMap = new Map<Id, RecordType>([select r.Id, r.DeveloperName from RecordType r where r.IsActive = true and r.SObjectType = 'DF_Contact__c']);	
		
		List<Contact> contactsToSave = new List<Contact>();
		Map<Id, DF_Contact__c> dfContactMap = new Map<Id, DF_Contact__c>();
		
		system.debug('*** -- Process all records in scope -- ***');
		for (SObject s : scope){
			DF_Contact__c dfc = (DF_Contact__c) s;
			dfContactMap.put(dfc.Id, dfc);
			processList.add(dfc);
			RecordType dfcRT = dfContactRTMap.get(dfc.RecordTypeId);
			Contact c = new Contact();
			c.RecordTypeId = contactRTMap.get(dfcRT.DeveloperName).Id;
			c.AccountId = portalAccount.Id;
			c.Title = dfc.Title__c;
			c.LastName = dfc.Last_Name__c;
			c.FirstName = dfc.First_Name__c;
			c.Email = dfc.Email__c;
			//c.Phone = dfc.Contact_Number__c;
			c.MailingStreet = dfc.Street__c;
			c.MailingCity = dfc.City__c;
			c.MailingState = dfc.County__c;
			c.MailingPostalCode = dfc.Postcode__c;
			c.MailingCountry = dfc.Country__c;
			c.DF_Contact__c = dfc.Id;
			c.Newsletters__c = dfc.Newsletters__c;
			contactsToSave.add(c);
		}
		
		system.debug('*** -- Insert contacts -- ***');
		insert contactsToSave;
		
		//Set this flag to send the emails or not on registration
		Boolean sendUserEmail = false;
		//Set this flag to TRUE to stop inserts failing if there are any errors
		Boolean allOrNone = false;
		
		system.debug('*** -- Process contacts for Users -- ***');
		for (Contact c : contactsToSave){
			if (c.RecordTypeId == contactRTMap.get(RT_DEMENTIA_FRIEND).Id || c.RecordTypeId == contactRTMap.get(RT_DEMENTIA_FRIEND_CHAMPION).Id){
				//We now need to create a User record for each contact if it is not E_NewsLetter type or Admin type
				
				String alias;
				if (c.LastName.length() < 4) {
					alias = c.FirstName.substring(0,1) + c.LastName;
				}else {
					alias = c.FirstName.substring(0,1) + c.LastName.substring(0,4);	
				}
				
			    if (alias.length() > 8) {
			        alias = alias.substring(0, 8);
			    }
			    String nickName = c.Email;
			    if (nickName.length() > 40) {
			        nickName = nickName.substring(0, 40);
			    }
			
			    User newUser = new User(
			    		Title = c.Title,
			            UserName = c.Email,
			            LastName = c.LastName,
			            FirstName = c.FirstName,
			            Email = c.Email,
			            Phone = c.Phone,
			            MobilePhone = c.MobilePhone,
			            Street = c.MailingStreet,
			            City = c.MailingCity,
			            State = c.MailingState,
			            Country = c.MailingCountry,
			            PostalCode = c.MailingPostalCode,
			            CommunityNickName = nickName,
			            Alias = alias,
			            Newsletters__c = c.Newsletters__c,
			
			            ContactId = c.Id,
			            ProfileId = portalProfile.Id,
			
			            emailencodingkey = 'UTF-8',
			            languagelocalekey = 'en_US',
			            localesidkey = 'en_GB',
			            timezonesidkey = 'GMT'
			    );
			
			    Database.DMLOptions dmo = new Database.DMLOptions();
			    dmo.EmailHeader.triggerUserEmail = sendUserEmail;
			    newUser.setOptions(dmo);
			
			    usersToSave.add(newUser);
			    
				DF_Contact__c dfc = dfContactMap.get(c.DF_Contact__c);
				if (dfc != null){
					/*
					RecordType dfcRT = dfContactRTMap.get(dfc.RecordTypeId);
					if (RT_DEMENTIA_FRIEND_CHAMPION.equalsIgnoreCase(dfcRT.DeveloperName)){
						if (dfc.Code_Verefied__c){
							dfc.Status__c = 'Converted';
						}else if (!dfc.Code_Verefied__c){
							dfc.Status__c = 'Prospective';
						}
						
					}else if (RT_DEMENTIA_FRIEND.equalsIgnoreCase(dfc.RecordTypeId)){
						
					}*/
					
					dfc.Portal_Contact__c = c.Id;
				}
			}
		}
		
		system.debug('*** -- Update DF Contacts -- ***');
		update dfContactMap.values();
		
		system.debug('*** -- Insert users -- ***');
		if (!usersToSave.isEmpty()) {
    		Database.SaveResult[] results = Database.insert(usersToSave, allOrNone);
		}
	}
	
	global void finish(Database.BatchableContext BC){
		//This method has intentionally been left blank
	}

}