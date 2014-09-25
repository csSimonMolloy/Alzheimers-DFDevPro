/******************************************************************************************
 *  Cloud Symphony
 *  
 *  Purpose : Main APEX class for all WEB* classes
 *            
 *  Author  : CSL
 *  Date    : 27-02-2014
 *  Version : 1.0
 *
 *  Description:    WEBController holds all methods / functionality that is common
 *                  for all WEB* classes.  Includes 'register' method which will 
 *                  call out to the standard Site functionality 
 *               
 *  Modification History
 *  Date            Who         Description 
 *            
*******************************************************************************************/
global abstract class WEBController {
    public static final String pageId_PARAM = 'pageId';
    public static final String USER_TYPE_CHAMPION = 'Champion';
    public static final String USER_TYPE_FRIEND = 'Friend';
    public static final String RT_DFCONTACT_CHAMPION = 'Dementia_Friend_Champion';
    public static final String RT_DFCONTACT_FRIEND = 'Dementia_Friend';
    
    public static String pageId {
        get {
            return ApexPages.currentPage().getParameters().get(pageId_PARAM);
        }
    }

    public static final String showPreview_PARAM = 'preview';
    public static Boolean showPreview {
        get {
            Boolean showPreview = false;

            if (ApexPages.currentPage().getParameters().get(showPreview_PARAM) != null
                && ApexPages.currentPage().getParameters().get(showPreview_PARAM).equalsIgnoreCase('true')) {

                showPreview = true;
            }

            return showPreview;
        }
    }

    public Boolean showCookiePolicy {
        get {
            if (showCookiePolicy == null) {
                showCookiePolicy = true;
            }

            return showCookiePolicy;
        }
        private set;
    }

    public static Boolean isLoggedIn {
        get {
            return (UserInfo.getUserType() == 'Guest' ? false : true);
        }
    }

    public static Boolean isChampion {
        get { 
            if (thisUser != null && thisUser.contactId != null)
                return WEBConversionClass.isChampion(thisUser.contactId);

            return FALSE;
        }
    }
    
    public static Boolean isChampionConverted {
        get {
            if (thisUser != null && thisUser.contactId != null)
                return WEBConversionClass.isChampionConverted(thisUser.contactId);
            
            return false;
        }
    }

    public static Boolean userAlreadyExists {
        get {
            if (userAlreadyExists == null){
                userAlreadyExists = false;
            }
            return userAlreadyExists;
        }
        set;
    }

    public static User thisUser {
        get {
            if (thisUser == null
                    && isLoggedIn) {

                thisUser = [SELECT Id, Email, Username, AccountId, ContactId, firstName, lastName, title, CommunityNickname
                                FROM User
                                WHERE Id = :UserInfo.getUserId()];

            }

            return thisUser;
        }
        private set;
    }

    public static Id userAccountId {
        get {
            return (thisUser == null ? null : thisUser.AccountId);
        }
    }

    public DF_Contact__c dfContact {get; set;}

    private static final String XUACompatible_PARAM = 'X-UA-Compatible';
    private static final String XUACompatible_VALUE = 'IE=edge';
    //Constructor
    public WEBController() {
        isChampion = false;
        system.debug('*** -- Into WEBController constructor -- ***');
        ApexPages.currentPage().getHeaders().put(XUACompatible_PARAM, XUACompatible_VALUE);

        Cookie cookiePolicyAcceptance = ApexPages.currentPage().getCookies().get('cookiePolicyAcceptance');

        if (cookiePolicyAcceptance == null) {
            showCookiePolicy = true;

            List<Cookie> cookies = new List<Cookie>();
            cookies.add(new Cookie('cookiePolicyAcceptance', 'true', null, 15552000, false));

            ApexPages.currentPage().setCookies(cookies);
        } else {
            showCookiePolicy = false;
        }
        
        //2014-04-03 : SM : We also need to return the DF_Contact__c record
        if (test.isRunningTest()){

            DF_Contact__c dfContactRecord = new DF_Contact__c();
            dfContactRecord.RecordTypeId = [select r.Id from RecordType r where r.DeveloperName = :RT_DFCONTACT_CHAMPION and r.SObjectType = 'DF_Contact__c' LIMIT 1].Id;
            dfContactRecord.First_Name__c = 'Test';
            dfContactRecord.Last_Name__c = 'Contact';
            dfContactRecord.Email__c = 'test.contact@myemail.com';
            
            isChampion = true;
            
            dfContact = dfContactRecord;
        }else {
            if (thisUser != null){
                List<DF_Contact__c> dfContactList = [select d.Postcode__c, d.Contact_Number__c from DF_Contact__c d where d.Portal_Contact__c = :thisUser.ContactId LIMIT 1];
                if (dfContactList != null){
                    dfContact = dfContactList[0];
                }
            }   
        }
        
    }
    
    /**
     * Return base site URL with https protocol and domain.
     * Note: Hardcoded part of portal domain to detect production
     */
    public String baseSiteSecureURL {
        get {
            if ( baseSiteSecureURL == null ) {
                Site site = [SELECT Subdomain, UrlPathPrefix FROM Site LIMIT 1];
                String host = URL.getSalesforceBaseUrl().getHost();
                baseSiteSecureURL = 'https://';
                baseSiteSecureURL += ( host.indexOf('dementiafriends') >= 0 ) ? site.Subdomain + '.secure.force.com/' : host + '/';
            }
            return baseSiteSecureURL;
        }
        private set;
    }

    public PageReference loginRedirect() {
        PageReference returnReference;

        if (isLoggedIn == false) {
            returnReference = loginReference;
        }

        return returnReference;
    }

    public PageReference loginReference {
        get {
            PageReference loginReference = Page.WEBLogin;
            loginReference.setRedirect(true);

            return loginReference;
        }
    }

    public String loginUrl {
        get {
            return loginReference.getUrl();
        }
    }

    public String homepageUrl {
        get {
            return Page.WEBHome.getUrl();
        }
    }

    public static Boolean checkUserExists(String emailAddress) {
        List<User> users = [SELECT UserType
                                FROM User
                                WHERE Email = :emailAddress
                                        AND IsActive = true];

        return (users.size() > 0);
    }

    //Registration method
    public static PageReference registerUser(String title, String firstName, String lastName, String telephone, String emailAddress, String postCode, String password, String password2, String userType, boolean newsletters) {
        // it's okay if password is null - we'll send the user a random password in that case
        if (!(password == password2)) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
            ApexPages.addMessage(msg);
            return null;
        }    
        //2014-03-28 : SM : We need to make sure that the user does not already exist before trying to create it
        
        List<User> checkUserList = new List<User>();
        checkUserList = [select u.Id from User u where u.Email = :emailAddress and u.IsActive = true];
        if (checkUserList.size() > 0){
            //We already have this user
            userAlreadyExists = true;
            return null;
        }
        
        User u = new User();
        u.Username = emailAddress;
        u.FirstName = firstName;
        u.LastName = lastName;
        u.Email = emailAddress;
        u.Phone = telephone;
        u.Title = title;
        u.Newsletters__c = newsletters;
        //2014-04-08 : CSL : Decision made to use the email address as the nickname for Community Registrations
        //2014-05-07 : CSL : We need to trim the email address before setting the Nickname, otherwise anything longer than 40 characters will fail 
        //u.CommunityNickname = firstName+lastName;
        if (emailAddress.length() > 40){
            u.CommunityNickname = emailAddress.substring(0,40);
        }else {
            u.CommunityNickname = emailAddress;
        }
        
        String accountId = WEBGlobalSettings.webAccountOwnerId;

        // lastName is a required field on user, but if it isn't specified, we'll default it to the username
        //2014-03-27 : SM : We need to change the below code to 
        String userId = Site.createPortalUser(u, accountId, password, TRUE);
        //So that we send the user email
        //String userId = Site.createPortalUser(u, accountId, password);

        System.debug('*** User Created - ' + userId);

        RecordType friendRT = [select r.Id from RecordType r where r.SobjectType = 'Contact' and r.IsActive = true and r.DeveloperName = :RT_DFCONTACT_FRIEND LIMIT 1];
        RecordType friendDFRT = [select r.Id from RecordType r where r.SobjectType = 'DF_Contact__c' and r.IsActive = true and r.DeveloperName = :RT_DFCONTACT_FRIEND LIMIT 1];
        RecordType championRT = [select r.Id from RecordType r where r.SobjectType = 'Contact' and r.IsActive = true and r.DeveloperName = :RT_DFCONTACT_CHAMPION LIMIT 1];
        RecordType championDFRT = [select r.Id from RecordType r where r.SobjectType = 'DF_Contact__c' and r.IsActive = true and r.DeveloperName = :RT_DFCONTACT_CHAMPION LIMIT 1];

        List<Contact> contactList = new List<Contact>();
        List<DF_Contact__c> dfContactList = new List<DF_Contact__c>();
        Contact contactRecord;
        DF_Contact__c dfContact;

        if (userId != null) {
            User newUser = [select u.Title, u.Newsletters__c, u.Phone, u.ContactId from User u where u.Id = :userId LIMIT 1];
            if (newUser != null){
                contactList = [select c.Id, c.DF_Contact__c from Contact c where c.Id = :newUser.ContactId LIMIT 1];
                dfContactList = [select d.Title__c, d.Contact_Number__c, d.Newsletters__c, Postcode__c from DF_Contact__c d where d.Portal_Contact__c = :newUser.ContactId LIMIT 1];
                
                system.debug('*** -- contactListSize = ' + contactList.size() + ' -- ***');
                system.debug('*** -- dfContactListSize = ' + dfContactList.size() + ' -- ***');
                                
                if (contactList.size() > 0 && dfContactList.size() > 0){
                    
                    contactRecord = contactList[0];
                    dfContact = dfContactList[0];
                    
                    system.debug('*** -- ContactID = ' + contactRecord.Id + ' -- ***');
                    system.debug('*** -- DFContactID = ' + dfContact.Id + ' -- ***');
                    
                    if (dfContact != null){
                        boolean doUpdate = false;
                        if (dfContact.Title__c != newUser.Title){
                            dfContact.Title__c = newUser.Title;
                            doUpdate = true;
                        }
                        if (dfContact.Newsletters__c != u.Newsletters__c){
                            dfContact.Newsletters__c = u.Newsletters__c;
                            doUpdate = true;
                        }
                        
                        if (dfContact.Contact_Number__c != u.Phone){
                            dfContact.Contact_Number__c = u.Phone;
                            doUpdate = true;
                        }
                        if (dfContact.Postcode__c != postCode){
                            dfContact.Postcode__c = postCode;
                            doUpdate = true;
                        }
                        
                        //2014-04-28 : SM : As we are registering, if we already have a Contact & DF_Contact__c from the 
                        //Newsletter signup, we need to make sure the record type is set correctly.
                        boolean doUpdateContact = false;
                        
                        system.debug('*** -- About to do record type -- ***');
                        if (USER_TYPE_FRIEND.equalsIgnoreCase(userType)){
                            if (dfContact.RecordTypeId != friendDFRT.Id){
                                dfContact.RecordTypeId = friendDFRT.Id;
                                doUpdate = true;
                            }
                                
                            if (contactRecord.RecordTypeId != friendRT.Id){
                                contactRecord.RecordTypeId = friendRT.Id;
                                doUpdateContact = true;
                            }
                        }else if (USER_TYPE_CHAMPION.equalsIgnoreCase(userType)){
                            if (dfContact.RecordTypeId != championDFRT.Id){
                                dfContact.RecordTypeId = championDFRT.Id;
                                doUpdate = true;
                            }
                                
                            if (contactRecord.RecordTypeId != championRT.Id){
                                contactRecord.RecordTypeId = championRT.Id;
                                doUpdateContact = true;
                            }
                        }
                        
                        if (doUpdate){
                            update dfContact;
                        }
                        if (contactRecord != null){
                            if (contactRecord.DF_Contact__c != dfContact.Id){
                                contactRecord.DF_Contact__c = dfContact.Id;
                                doUpdateContact = true;
                            }
                            
                            if (doUpdateContact){
                                update contactRecord;
                            }
                        }
                    }
                }
            }
            String returnPageUrl; 
            if (password != null && password.length() > 1) {
                //We need to check which User Type, so we know which Dashboard to send the user back to
                if (USER_TYPE_FRIEND.equalsIgnoreCase(userType)){
                    returnPageUrl = '/WEBFriend';
                }else if (USER_TYPE_CHAMPION.equalsIgnoreCase(userType)){
                    returnPageUrl = '/WEBChampion';
                }
                return Site.login(emailAddress, password, returnPageURL);
            }
            else {
                //PageReference page = System.Page.SiteRegisterConfirm;
                //PageReference page = System.Page.WEBSiteRegisterConfirm;
                //2014-01-04 : SM : Request to redirect to Login screen on successful registration
                PageReference page = System.Page.WEBLogin;
                page.setRedirect(true);
                return page;
            }
        }
        return null;
    }
}