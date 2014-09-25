/******************************************************************************************
 *  Cloud Symphony
 *  
 *  Purpose : APEX controller class for VF Page WEBRegisterChampion.
 *  Author  : CSL
 *  Date    : 27-02-2014
 *  Version : 1.0
 *
 *  Description:    Apex Class controller for the WEBRegisterChampion page.
 *					This will be used when people wish to register as a Champion
 *					Contains a call out to the reCaptcha security application
 *					And the standard Site login code
 *               
 *  Modification History
 *  Date            Who         Description 
 *            
*******************************************************************************************/
public with sharing class WEBRegisterChampion extends WEBController {
	public final String REGISTER_FRIEND_SNIPPET_NAME = 'Register_Friend_Snippet';
	public final String MISSING_CAPTCHA_ERROR = 'Missing reCAPTCHA input';
	public final String RECAPTCHA_VALIDATION_FAILED = 'You have not typed in the validation words correctly.  Please try again.';
	public final String DEFAULT_RECAPTCHA_BASE_URL = 'https://www.google.com/recaptcha/api/verify';
	public final String DEFAULT_RECAPTCHA_PRIVATE_KEY = '6Lc-wO4SAAAAACD6-YESZ_7gtgeJdGmuc4NG8gwg';
	public final String DEFAULT_RECAPTCHA_PUBLIC_KEY = '6Lc-wO4SAAAAAExvZIBvdvhgKVyjbprSn9Ygwkwb';
	public final String EMPTY_FIELD_VALUE_MSG = 'Value is required and can\'t be empty';
	public final String USER_ALREADY_EXISTS_MSG = 'A user already exists with this email address';
	public final String PASSWORDS_DO_NO_MATCH_MSG = 'Passwords did not match';
	public final String ENGLAND_OR_WALES_ERROR_MSG = 'You must live in England or Wales to register';
	public final String OVER_18_ERROR_MSG = 'You must be over 18 to register as a Dementia Friends Champion';
	public final String STANDARD_ERROR_MSG = 'Please correct the mistakes highlighted below';
	public final String USER_TYPE_CHAMPION = 'Champion';
	public final String USER_TYPE_FRIEND = 'Friend';
	public final String RT_CHAMPION = 'Dementia_Friend_Champion';
	
	public List<SelectOption> titleList {
		get {
			if (titleList == null){
				titleList = new List<SelectOption>();
				titleList.add(new SelectOption('NULL','Select...'));
				titleList.add(new SelectOption('Mr.','Mr.'));
				titleList.add(new SelectOption('Mrs.','Mrs.'));
				titleList.add(new SelectOption('Miss','Miss'));
				titleList.add(new SelectOption('Ms.','Ms.'));
				titleList.add(new SelectOption('Other','Other'));
			}
			return titleList;
		}
		set;
	}
	
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
	
	public Page_Snippet__c registerText {
		get {
			if (registerText == null){
				registerText = [Select p.Unique_Name__c, p.Name__c, p.Name, p.Id, p.Body_Text__c From Page_Snippet__c p where p.Unique_Name__c = :REGISTER_FRIEND_SNIPPET_NAME LIMIT 1];
			}
			return registerText;
		}
		set;
	}

	public String title {get;set;}
	public String firstName {get;set;}
	public String lastName {get;set;}
	public String postCode {get;set;}
	public String telephone {get;set;}
	public String emailAddress {get;set;}
	public String password {get;set {password = value == null ? value : value.trim();} }
	public String password2 {get;set {password2 = value == null ? value : value.trim();} }
	public Boolean newsletter {get;set;}
	public Boolean englandOrWales {
		get {
			if (englandOrWales == null){
				englandOrWales = false;
			}
			return englandOrWales;
		}
		set;
	}
	public Boolean over18 {
		get {
			if (over18 == null){
				over18 = false;
			}	
			return over18;	
		}
		set;
	}

	public String standardErrorMsg {get;set;}
	public String titleError {get;set;}
	public String firstNameError {get;set;}
    public String lastNameError {get;set;}
    public String postCodeError {get;set;}
	public String telephoneError {get;set;}
	public String emailAddressError {get;set;}
	public String passwordError {get;set;}
	public String password2Error {get;set;}
	public String englandOrWalesError {get; set;}
	public String over18Error {get; set;}

    public String errorClass {get; set;}
	
	public String reCAPTCHAErrorClass {get; set;}
	public String reCAPTCHAError {get; set;}

	public boolean isError = false;

	public pageReference registerChampion() {
		
		standardErrorMsg = '';
		titleError = '';
		firstNameError = '';
		lastNameError = '';
		postCodeError = '';
		telephoneError = '';
		emailAddressError = '';
		passwordError = '';
    	password2Error = '';
    	englandOrWalesError = '';
    	over18Error = '';
    	isError = false;
    	
    	
    	system.debug('*** -- over18Error length = ' + over18Error.length() + ' -- ***');
    	system.debug('*** -- isError = ' + isError + ' -- ***');

    	system.debug('*** -- reCAPTCHA response = ' + response + ' -- ***');
		if (response == null){
			reCAPTCHAError = MISSING_CAPTCHA_ERROR;
			reCAPTCHAErrorClass = 'error';
			isError = true;
		}else {
			system.debug('*** -- Call verify method -- ***');
			if (!verify()){
				reCAPTCHAError = RECAPTCHA_VALIDATION_FAILED;
				reCAPTCHAErrorClass = 'error';
				isError = true;
			}	
		}
		// REMOVE THIS !!!
		//isError = false;

		//if (this.title.length() == 0) {
    	//	titleError = EMPTY_FIELD_VALUE_MSG;
    	//	isError = TRUE;
    	//}
		if ('NULL'.equalsIgnoreCase(this.title)){
    		titleError = EMPTY_FIELD_VALUE_MSG;
    		isError = TRUE;
    	}
		if (this.firstName.length() == 0) {
    		firstNameError = EMPTY_FIELD_VALUE_MSG;
    		isError = TRUE;
    	}
    	if (this.lastName.length() == 0) {
    		lastNameError = EMPTY_FIELD_VALUE_MSG;
    		isError = TRUE;
    	}
		if (this.postCode.length() == 0) {
    		postCodeError = EMPTY_FIELD_VALUE_MSG;
    		isError = TRUE;
    	}
		if (this.telephone.length() == 0) {
    		telephoneError = EMPTY_FIELD_VALUE_MSG;
    		isError = TRUE;
    	}
    	if (this.emailAddress.length() == 0) {
    		emailAddressError = EMPTY_FIELD_VALUE_MSG;
    		isError = TRUE;
    	}

    	if (!englandOrWales){
    		englandOrWalesError = ENGLAND_OR_WALES_ERROR_MSG;
    		isError = TRUE;
    	}
    	if (!over18){
    		over18Error = OVER_18_ERROR_MSG;
    		isError = TRUE;
    	}

		if (!isError){
			List<DF_Contact__c> checkDFContactList = new List<DF_Contact__c>();
			String checkEmailAddress = emailAddress.toLowerCase();
			//String checkEmailAddress = emailAddress;
			checkDFContactList = [select d.Id, First_Name__c, d.Last_Name__c, d.Email__c, d.Title__c, d.Contact_Number__c, d.Postcode__c, 
									d.RecordTypeId, d.Newsletters__c from DF_Contact__c d where d.Email__c = :checkEmailAddress LIMIT 1];
			DF_Contact__c dfContact;
			
			if (!isError){
				boolean doUpdate = false;
				if (checkDFContactList.size() == 0){
					dfContact = new DF_Contact__c();
					RecordType dfChampionRT = [select r.Id from RecordType r where r.DeveloperName = :RT_CHAMPION and r.SObjectType = 'DF_Contact__c' and r.IsActive = true LIMIT 1];
					dfContact.RecordTypeId = dfChampionRT.Id;
				}else {
					dfContact = checkDFContactList[0];
					doUpdate = true;
				}
				
				dfContact.Name = firstName + ' ' + lastName;
				dfContact.First_Name__c = firstName;
				dfContact.Last_Name__c = lastName;
				dfContact.Title__c = title;
				dfContact.Contact_Number__c = telephone;
				dfContact.Email__c = emailAddress;
				dfContact.Postcode__c = postCode;
				dfContact.Newsletters__c = newsLetter;
				
				if (doUpdate){
					update dfContact;
				}else {
					insert dfContact;	
				}
							
			}else {
				errorClass = 'error';
				standardErrorMsg = STANDARD_ERROR_MSG;
				return null;
			}
			
			PageReference pr = WEBController.registerUser(title, firstName, lastName, telephone, emailAddress, postCode, password, password2, USER_TYPE_CHAMPION, newsletter);
			if (pr == null){
				if (WEBController.userAlreadyExists){
					//The user already exists so we need to flag that as an error
					emailAddressError = USER_ALREADY_EXISTS_MSG;
					isError = true;
				}
			}			
			
			if (!isError){
			
				if (test.isRunningTest()){
					return null;
				}else {
					return pr;
				}
				return null;
			}else {
				errorClass = 'error';
				standardErrorMsg = STANDARD_ERROR_MSG;
				return null;
			}
		}else {
			errorClass = 'error';
			standardErrorMsg = STANDARD_ERROR_MSG;
			return null;
		}		
	}

	public WEBRegisterChampion() {
		standardErrorMsg = '';
		firstNameError = '';
		lastNameError = '';

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