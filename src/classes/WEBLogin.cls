public with sharing class WEBLogin extends WEBController{
    public final String EMPTY_FIELD_VALUE_MSG = 'Value is required and can\'t be empty';
    public final String INVALID_EMAIL_ADDRESS = 'The email address you have provided is not valid';
    public final String LOGIN_FAILED = 'Login Failed : please check you email and password are correct';
    public final String DF_HVCP_PROFILE = 'DF HVCP';

    public String emailAddress {get; set;}
    public String password {get; set;}

    public String standardErrorMsg {get;set;}
    public String emailAddressError {get; set;}
    public String passwordError {get; set;}
    public Profile dfhvcp {get; set;}

    private Boolean isError = FALSE;

    public PageReference login() {
        emailAddressError = '';
        passwordError = ''; 
        standardErrorMsg = '';
        isError = FALSE;

        if (emailAddress.length() == 0) {
            emailAddressError = INVALID_EMAIL_ADDRESS;
            isError = TRUE;
        }

        if (password.length() == 0) {
            passwordError = EMPTY_FIELD_VALUE_MSG;
            isError = TRUE;
        }
        if (isError){
            return null;
        }
            
        // We need to Redirect based on the user characteristics - Friend or Champion
        PageReference pr = null;
		dfhvcp = [select p.Id from Profile p where p.Name = :DF_HVCP_PROFILE LIMIT 1];
        String url = '/WEBFriend';

        try {
            Id contactId = [SELECT Id, contactId FROM USER WHERE email = :emailAddress and ProfileId = :dfhvcp.Id LIMIT 1].contactId;
            
            if (contactId != null){
                if (WEBConversionClass.isChampion(contactId))
                    url = '/WEBChampion';
                else
                    url = '/WEBFriend';
            }

            pr = Site.login(emailAddress, password, url);   
        } catch (Exception e) {
            // DO SOMETHING
            standardErrorMsg = e.getMessage();
        }

        if (pr == null) {
            standardErrorMsg = LOGIN_FAILED;
            return null;
        }

        return Site.login(emailAddress, password, url);       
    }

    public WEBLogin() { 
        standardErrorMsg = '';
        emailAddressError = '';
        passwordError = ''; 
    }
}