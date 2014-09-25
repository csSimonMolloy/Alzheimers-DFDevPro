/******************************************************************************************
 *  Cloud Symphony
 *  
 *  Purpose : APEX controller class for VF Page WEBContactForm.
 *  Author  : CSL
 *  Date    : 27-02-2014
 *  Version : 1.0
 *
 *  Description:    Apex Class controller for the WEBContactForm class.
 *                  Provides functionality for web site visitors / users to submit a WEBContactMessage record
 *                  Calls out to the reCaptcha security application
 *               
 *  Modification History
 *  Date            Who         Description 
 *            
*******************************************************************************************/
public with sharing class WEBContactForm extends WEBController {
    public final String CONTACT_SNIPPET_NAME = 'Contact_Snippet';
    public final String THANK_YOU_SNIPPET = 'ContactFormThankyou';
    public final String EMPTY_FIELD_VALUE_MSG = 'Value is required and can\'t be empty';
    public final String INVALID_EMAIL_ADDRESS = 'The email address you have provided is not valid';
    public final String MISSING_CAPTCHA_ERROR = 'Missing reCAPTCHA input';
    public final String STANDARD_ERROR_MSG = 'Please correct the mistakes highlighted below';
    public final String NEWSLETTER_CONTACT_RT = 'E_Newsletter_Subscriber';
    //original message : Captcha value is wrong: incorrect-captcha-sol - but changing to something nicer
    public final String RECAPTCHA_VALIDATION_FAILED = 'You have not typed in the validation words correctly.  Please try again.';
    public final String DEFAULT_CONTACT_OPTION_EMAIL = 'dementiafriendsweb@alzheimers.org.uk';
    public final String DEFAULT_RECAPTCHA_BASE_URL = 'https://www.google.com/recaptcha/api/verify';
    public final String DEFAULT_RECAPTCHA_PRIVATE_KEY = '6Lc-wO4SAAAAACD6-YESZ_7gtgeJdGmuc4NG8gwg';
    public final String DEFAULT_RECAPTCHA_PUBLIC_KEY = '6Lc-wO4SAAAAAExvZIBvdvhgKVyjbprSn9Ygwkwb';

    //reCAPTCHA code
    // The API endpoint for the reCAPTCHA service
    //private static String baseUrl = 'https://www.google.com/recaptcha/api/verify';
    public String baseURL {get; set;}
    // The keys you get by signing up for reCAPTCHA for your domain
    //private static String privateKey = '6Lc-wO4SAAAAACD6-YESZ_7gtgeJdGmuc4NG8gwg';
    public String privateKey {get; set;}
    
    public String publicKey {get; set;}
    
    //public String publicKey { 
    //    get { return '6Lc-wO4SAAAAAExvZIBvdvhgKVyjbprSn9Ygwkwb'; }
    //} 
    // Create properties for the non-VF component input fields generated
    // by the reCAPTCHA JavaScript.
    public String challenge { 
        get {
            return ApexPages.currentPage().getParameters().get('recaptcha_challenge_field');
        }
    }
    public String response  { 
        get {
            return ApexPages.currentPage().getParameters().get('recaptcha_response_field');
        }
    }
    
    //public String response {get; set;}
    
    // Whether the submission has passed reCAPTCHA validation or not
    public Boolean verified { get; private set; }
    //end of reCAPTACHA code
    
    public String lastName {get; set;}
    public String firstName {get; set;}
    public String email {get; set;}
    public String addressStreet {get; set;}
    public String addressCity {get; set;}
    public String addressCounty {get; set;}
    public String addressPostcode {get; set;}
    public String phone {get; set;}
    public String webSubject {get; set;}
    public String webMessage {get; set;}
    public String standardErrorMsg {get; set;}
    public String firstNameErrorClass {get; set;}
    public String firstNameError {get; set;}
    public String lastNameErrorClass {get; set;}
    public String lastNameError {get; set;}
    public String emailErrorClass {get; set;}
    public String emailError {get; set;}
    public String webSubjectErrorClass {get; set;}
    public String webSubjectError {get; set;}
    public String reCAPTCHAErrorClass {get; set;}
    public String reCAPTCHAError {get; set;}
    public String contactOptionEmailAddress {get; set;}

    public Page_Snippet__c contactFormText {
        get {
            if (contactFormText == null){
                contactFormText = [Select p.Unique_Name__c, p.Name__c, p.Name, p.Id, p.Body_Text__c From Page_Snippet__c p where p.Unique_Name__c = :CONTACT_SNIPPET_NAME LIMIT 1];
            }
            return contactFormText;
        }
        set;
    }
    
    public Page_Snippet__c thankyouText{
        get {
            if (thankyouText == null){
                thankyouText = [Select p.Unique_Name__c, p.Name__c, p.Name, p.Id, p.Body_Text__c From Page_Snippet__c p where p.Unique_Name__c = :THANK_YOU_SNIPPET LIMIT 1];
            }
            return thankyouText;
        }
        set;
    }
    
    public WEBContactMessage__c contactMessage {get; set;}
    
    public Contact contactRecord {
        get {
            if (contactRecord == null){
                contactRecord = new Contact();
            }
            return contactRecord;
        }
        set;
    }
    
    public List<SelectOption> subjectList {
        get {
            if (subjectList == null){
                subjectList = new List<SelectOption>();
                Schema.DescribeFieldResult F = WEBContactMessage__c.Subject__c.getDescribe();
                subjectList.add(new SelectOption('NONE','-None-'));
                for (Schema.PicklistEntry p : F.getPicklistValues()){
                    subjectList.add(new SelectOption(p.getValue(), p.getLabel()));
                }
            }
            return subjectList;
        }
        set;
    }
    
    public RecordType newsletterContactRT {get; set;}
    public RecordType newsletterDFContactRT {get; set;}
    public DF_Contact__c loggedInContact {get; set;}
    
    //Constructor
    public WEBContactForm(){
        Global_Setting__c baseURLSetting = Global_Setting__c.getInstance('RecaptchaBaseURL');
        if (baseURLSetting == null){
            baseURL = DEFAULT_RECAPTCHA_BASE_URL;
        }else {
            baseURL = baseURLSetting.Value__c;
        }
        
        Global_Setting__c recaptchaPrivateKey = Global_Setting__c.getInstance('RecaptchaPrivateKey');
        if (recaptchaPrivateKey == null){
            privateKey = DEFAULT_RECAPTCHA_PRIVATE_KEY;
        }else {
            privateKey = recaptchaPrivateKey.Value__c;
        }
        
        Global_Setting__c recaptchaPublicKey = Global_Setting__c.getInstance('RecaptchaPublicKey');
        if (recaptchaPublicKey == null){
            publicKey = DEFAULT_RECAPTCHA_PUBLIC_KEY;
        }else {
            publicKey = recaptchaPublicKey.Value__c;
        }
        
        newsletterContactRT = [select r.Id from RecordType r where r.SObjectType = 'Contact' and r.DeveloperName = :NEWSLETTER_CONTACT_RT LIMIT 1];
        newsletterDFContactRT = [select r.Id from RecordType r where r.SObjectType = 'DF_Contact__c' and r.DeveloperName = :NEWSLETTER_CONTACT_RT LIMIT 1];
        
        contactMessage = new WEBContactMessage__c();
        //Here we check if the user is logged in, and if so, retrieve info from the Contact / DF Contact record
        //TODO : Is Logged In code
        
        if (WEBController.isLoggedIn){
            User loggedInUser = [select u.Id, u.ContactId from User u where u.Id = :UserInfo.getUserId()];
            loggedInContact = [Select d.Street__c, d.Status__c, d.Postcode__c, d.Portal_Contact__c, d.Name__c, d.Name, d.Last_Name__c, d.First_Name__c, d.Email__c, d.County__c, d.Country__c, 
                                d.Contact_Number__c, d.City__c From DF_Contact__c d where d.Portal_Contact__c = :loggedInUser.ContactId LIMIT 1];
                                
            lastName = loggedInContact.Last_Name__c;
            firstName = loggedInContact.First_Name__c;
            email = loggedInContact.Email__c;               
            
        }
        
        
        this.verified = false;
    } 
    
    //Submit method
    public PageReference submitContactForm(){
        boolean isError = false;
        if (firstName == null || firstName.trim().length() == 0){
            standardErrorMsg = STANDARD_ERROR_MSG;
            firstNameError = EMPTY_FIELD_VALUE_MSG;
            firstNameErrorClass = 'error';
            isError = true;
        }else {
            standardErrorMsg = null;
            firstNameError = '';
            firstNameErrorClass = '';
        }
            
        if (lastName == null || lastName.trim().length() == 0){
            standardErrorMsg = STANDARD_ERROR_MSG;
            lastNameError = EMPTY_FIELD_VALUE_MSG;
            lastNameErrorClass = 'error';
            isError = true;
        }else {
            standardErrorMsg = null;
            lastNameError = '';
            lastNameErrorClass = '';
        }

        if (email == null || email.trim().length() == 0){
            standardErrorMsg = STANDARD_ERROR_MSG;
            emailError = EMPTY_FIELD_VALUE_MSG;
            emailErrorClass = 'error';
            isError = true;
        }else {
            Pattern emailPattern = Pattern.compile('([a-zA-Z0-9_\\-\\.]+)@(((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3}))');
            Matcher emailMatcher = emailPattern.matcher(email);
            system.debug('*** -- emailPatternMatcher = ' + emailMatcher.matches() + ' -- ***');
            if (!emailMatcher.matches()){
                standardErrorMsg = STANDARD_ERROR_MSG;
                emailError = INVALID_EMAIL_ADDRESS;
                emailErrorClass = 'error';
                isError = true;
            }else {
                standardErrorMsg = null;
                emailErrorClass = '';
                emailError = '';    
            }
            
        }
        
        if (webSubject == null || webSubject.trim().length() == 0 || 'NONE'.equalsIgnoreCase(webSubject)){
            standardErrorMsg = STANDARD_ERROR_MSG;
            webSubjectError = EMPTY_FIELD_VALUE_MSG;
            webSubjectErrorClass = 'error';
            isError = true;
        }else {
            standardErrorMsg = null;
            webSubjectErrorClass = '';
            webSubjectError = '';
            //Get the contact option email address, so we know who to send this to
            Contact_Option__c contactOption = Contact_Option__c.getInstance(webSubject);
            if (contactOption != null){
                contactOptionEmailAddress = contactOption.Email_Address__c;
            }else {
                contactOptionEmailAddress = DEFAULT_CONTACT_OPTION_EMAIL;
            }
        }
        
        //if (challenge == null || response == null){
        system.debug('*** -- reCAPTCHA response = ' + response + ' -- ***');
        if (response == null){
            standardErrorMsg = STANDARD_ERROR_MSG;
            reCAPTCHAError = MISSING_CAPTCHA_ERROR;
            reCAPTCHAErrorClass = 'error';
            isError = true;
        }else {
            system.debug('*** -- Call verify method -- ***');
            if (!verify()){
                standardErrorMsg = STANDARD_ERROR_MSG;
                reCAPTCHAError = RECAPTCHA_VALIDATION_FAILED;
                reCAPTCHAErrorClass = 'error';
                isError = true;
            }   
        }
        
        if (isError){
            system.debug('*** -- Error in form -- ***');
            system.debug('*** -- lastNameErrorClass = ' + lastNameErrorClass + ' -- ***');
            system.debug('*** -- firstNameErrorClass = ' + firstNameErrorClass + ' -- ***');
            return null;
        }else {
            //If the user is logged in, we can associate this WEBContactMessage with their contact record
            //TODO : Is Logged In Code
            contactMessage.FirstName__c = firstName;
            contactMessage.LastName__c = lastName;
            contactMessage.Email__c = email;
            contactMessage.Address_Street__c = addressStreet;
            contactMessage.Address_City__c = addressCity;
            contactMessage.Address_County__c = addressCounty;
            contactMessage.Address_Postcode__c = addressPostcode;
            contactMessage.Contact_Phone__c = phone;
            contactMessage.Subject__c = webSubject;
            contactMessage.Message__c = webMessage;
            
            //TODO : Do we need to search for a Contact if NOT logged in? 
            
            system.debug('*** -- About to set the Sent To address to : ' + contactOptionEmailAddress + ' -- ***');
            //Assign the email that this contact message will be sent to
            contactMessage.Sent_To_Email__c = contactOptionEmailAddress;
            
            contactMessage.Date_Received__c = date.today();
            
            insert contactMessage;
            
            //We now call the method that will send the email
            sendContactMessageEmail(contactMessage);
            
            return Page.WEBContactFormThankyou;
            
        }
            
    }
    
    public void sendContactMessageEmail(WEBContactMessage__c contactMessage){
    	List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
		//Get the Org Wide Email address lookup value
		String ORG_WIDE_EMAIL_ADDRESS_ID = '';
		String DEFAULT_ORG_WIDE_EMAIL_ADDRESS = '0D2200000004Dq3';
		Global_Setting__c globalSetting = Global_Setting__c.getInstance('orgWideEmailAddress');
	    if (globalSetting != null && globalSetting.Value__c != null) {
	        ORG_WIDE_EMAIL_ADDRESS_ID = globalSetting.Value__c;
	    }
	    
	    String[] sendToAddress = new List<String>();
	    sendToAddress.add(contactMessage.Sent_To_Email__c);
	    	    
	    Messaging.SingleEmailMessage sme = new Messaging.SingleEmailMessage();
	    sme.setSaveAsActivity(false);
	    sme.setToAddresses(sendToAddress);
	    sme.setSubject('New WEB Contact Message re : ' + contactMessage.Subject__c);
	    
	    
		if (ORG_WIDE_EMAIL_ADDRESS_ID != ''){
			sme.setOrgWideEmailAddressId(ORG_WIDE_EMAIL_ADDRESS_ID);
		}else {
			sme.setOrgWideEmailAddressId(DEFAULT_ORG_WIDE_EMAIL_ADDRESS);
		}
		
		String returnChar = '<br/><br/>';
		String strHTMLBody = 'There has been a new Contact Message submitted to the Dementia Friends website.  Message below:' + returnChar;
		strHTMLBody += 'From : ' + contactMessage.FirstName__c + ' ' + contactMessage.LastName__c + returnChar;
		strHTMLBody += 'Email : ' + contactMessage.Email__c + returnChar;
		strHTMLBody += 'Subject : ' + contactMessage.Subject__c + returnChar;
		strHTMLBody += 'Message : ' + contactMessage.Message__c + returnChar;
		
		sme.setHtmlBody(strHTMLBody);
		
		emailsToSend.add(sme);
		
		Messaging.sendEmail(emailsToSend);
		    	
    }
    
    //reCAPTCHA code Verify method
    public boolean verify() {
        System.debug('reCAPTCHA verification attempt');
        // On first page load, form is empty, so no request to make yet
        if ( challenge == null || response == null ) { 
            System.debug('reCAPTCHA verification attempt with empty form');
            return false;
        }
                    
        HttpResponse r = makeRequest(baseUrl,
            'privatekey=' + privateKey + 
            '&remoteip='  + remoteHost + 
            '&challenge=' + challenge +
            '&response='  + response
        );
        
        if ( r!= null ) {
            this.verified = (r.getBody().startsWithIgnoreCase('true'));
        }
        
        if(this.verified) {
            // If they pass verification, you might do something interesting here
            // Or simply return a PageReference to the "next" page
            return true;
        }
        else {
            
            return false; 
        }
    }

    public PageReference reset() {
        return null; 
    }   

    /* Private helper methods */
    
    private static HttpResponse makeRequest(string url, string body)  {
        HttpResponse response = null;
        HttpRequest req = new HttpRequest();   
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody (body);
        if (test.isRunningTest()){
            response = new HTTPResponse();
            response.setBody('true');
        }else {
            try {
                Http http = new Http();
                response = http.send(req);
                System.debug('reCAPTCHA response: ' + response);
                System.debug('reCAPTCHA body: ' + response.getBody());
            } catch(System.Exception e) {
                System.debug('ERROR: ' + e);
            }   
        }
        
        return response;
    }   
        
    private String remoteHost { 
        get { 
            String ret = '127.0.0.1';
            // also could use x-original-remote-host 
            Map<String, String> hdrs = ApexPages.currentPage().getHeaders();
            if (hdrs.get('x-original-remote-addr')!= null)
                ret =  hdrs.get('x-original-remote-addr');
            else if (hdrs.get('X-Salesforce-SIP')!= null)
                ret =  hdrs.get('X-Salesforce-SIP');
            return ret;
        }
    }
    
    

}