public with sharing class WEBNewsLetterSignup extends WEBController {
	public final String NEWSLETTER_SIGNUP_SNIPPET_NAME = 'Newsletter_Signup_Snippet';
	public final String EMPTY_FIELD_VALUE_MSG = 'Value is required and can\'t be empty';
	public final String INVALID_EMAIL_ADDRESS = 'The email address you have provided is not valid';
	public final String MISSING_CAPTCHA_ERROR = 'Missing reCAPTCHA input';
	public final String NEWSLETTER_CONTACT_RT = 'E_Newsletter_Subscriber';
	public final String STANDARD_ERROR_MSG = 'Please correct the mistakes highlighted below';
	public final String ALREADY_SIGNED_UP_MSG = 'Our records show you have already signed up for our e-Newsletter';
	//original message : Captcha value is wrong: incorrect-captcha-sol - but changing to something nicer
	public final String RECAPTCHA_VALIDATION_FAILED = 'You have not typed in the validation words correctly.  Please try again.';
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
	public String standardErrorMsg {get; set;}
	public String firstNameErrorClass {get; set;}
	public String firstNameError {get; set;}
	public String lastNameErrorClass {get; set;}
	public String lastNameError {get; set;}
	public String emailErrorClass {get; set;}
	public String emailError {get; set;}
	public String reCAPTCHAErrorClass {get; set;}
	public String reCAPTCHAError {get; set;}
	
	public Page_Snippet__c newsletterSignupText {
		get {
			if (newsletterSignupText == null){
				newsletterSignupText = [Select p.Unique_Name__c, p.Name__c, p.Name, p.Id, p.Body_Text__c From Page_Snippet__c p where p.Unique_Name__c = :NEWSLETTER_SIGNUP_SNIPPET_NAME LIMIT 1];
			}
			return newsletterSignupText;
		}
		set;
	}
	
	/*
	public Contact contactRecord {
		get {
			if (contactRecord == null){
				contactRecord = new Contact();
			}
			return contactRecord;
		}
		set;
	}
	*/
	
	public DF_Contact__c contactRecord {
		get {
			if (contactRecord == null){
				contactRecord = new DF_Contact__c();
			}
			return contactRecord;
		}
		set;
	}
	
	public RecordType newsletterContactRT {get; set;}
	public RecordType newsletterDFContactRT {get; set;}
	
	public WEBNewsLetterSignup(){
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
		
		this.verified = false;
	}
	
	public PageReference signupForNewsletter(){
		boolean isError = false;
		if (firstName == null || firstName.trim().length() == 0){
			standardErrorMsg = STANDARD_ERROR_MSG;
			firstNameError = EMPTY_FIELD_VALUE_MSG;
			firstNameErrorClass = 'error';
			isError = true;
		}else {
			standardErrorMsg = null;
			firstNameErrorClass = '';
		}
			
		if (lastName == null || lastName.trim().length() == 0){
			standardErrorMsg = STANDARD_ERROR_MSG;
			lastNameError = EMPTY_FIELD_VALUE_MSG;
			lastNameErrorClass = 'error';
			isError = true;
		}else {
			standardErrorMsg = null;
			lastNameErrorClass = '';
		}
		//TODO : Need to check the format of the email address
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
			return null;
		}else {
			//First of all check that we don't already have a Newsletter Contact with this information
			//2014-04-28 : SM : Updating class to make sure Newsletter Signup contacts get attached to the WEB Portal Account
			//So that if they register after signing up, it will attach their Newsletter contact to their Portal Account
			//2014-06-03 : CSL : Changing this code.  It was working off of the Contact record, which was causing problems.
			//Now it will work off of the DF_Contact__c record, and use the trigger to create the Contact record.
			
			String accountId = WEBGlobalSettings.webAccountOwnerId;
			system.debug('*** -- accountId = ' + accountId + ' -- ***');
			
			List<Contact> existingContactList = new List<Contact>();
			existingContactList = [select c.Id, c.LastName, c.Email from Contact c where c.RecordTypeId = :newsletterContactRT.Id and c.Email = :email and c.LastName = :lastName LIMIT 1]; 
			List<DF_Contact__c> existingDFContactList = new List<DF_Contact__c>();
			//existingDFContactList = [select d.Id, d.Last_Name__c, d.Email__c from DF_Contact__c d where d.RecordTypeId = :newsletterDFContactRT.Id and d.Email__c = :email and d.Last_Name__c = :lastName LIMIT 1];
			existingDFContactList = [select d.Id, d.Last_Name__c, d.Email__c, d.Newsletters__c from DF_Contact__c d where d.Email__c = :email and d.Last_Name__c = :lastName LIMIT 1];
			 
			if (!existingContactList.isEmpty() || !existingDFContactList.isEmpty()){
				if (existingDFContactList[0].Newsletters__c){
					standardErrorMsg = ALREADY_SIGNED_UP_MSG;
					reCAPTCHAErrorClass = '';
					reCAPTCHAError = '';
					emailErrorClass = '';
					emailError = '';
					lastNameErrorClass = '';
					lastNameError = '';
					firstNameErrorClass = '';
					firstNameError = '';
					return null;	
				}else {
					contactRecord = existingDFContactList[0];
					contactRecord.Newsletters__c = true;
					update contactRecord;
				}
				
			}else {
				
				contactRecord = new DF_Contact__c();
				contactRecord.RecordTypeId = newsletterDFContactRT.Id;
				contactRecord.Last_Name__c = lastName;
				contactRecord.First_Name__c = firstName;
				contactRecord.Name = firstName + ' ' + lastName;
				contactRecord.Email__c = email;
				contactRecord.Newsletters__c = true;
				//system.debug('*** -- setting account id on ContactREcord = ' + accountId + ' -- ***');
				//contactRecord.AccountId = accountId;
				
				system.debug('*** -- About to insert new DF Contact record -- ***');
				insert contactRecord; 	
				
			}
			
			
			//Need a thank you page
			return Page.WEBNewsLetterThankyou;
		}
			
	}
	
	//reCAPTCHA code
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