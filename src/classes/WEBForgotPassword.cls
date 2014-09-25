public with sharing class WEBForgotPassword {
    public final String EMPTY_FIELD_VALUE_MSG = 'Value is required and can\'t be empty';
    public final String E_NEWSLETTER_RECORDTYPE = 'E_Newsletter_Subscriber';

    public boolean resetSent {get;set;}
    public boolean noUserFound {get; set;}
    public boolean userIsNewsletter {get; set;}

    public String emailAddress {get;set;}
    public String emailAddressError {get;set;}
    public RecordType eNewsletterRT {get; set;}

    public Page_Snippet__c forgotPasswordSnippet {
        get {
            if (forgotPasswordSnippet == null){
                forgotPasswordSnippet = [select p.Body_Text__c, p.Unique_Name__c from Page_Snippet__c p where p.Unique_Name__c = 'forgotpasswordsnippet' LIMIT 1];
            }
            return forgotPasswordSnippet;
        }
        set ;
    }

    public WEBForgotPassword() {
        emailAddress = '';
        emailAddressError = '';
        resetSent = FALSE;
        userIsNewsletter = FALSE;
        noUserFound = FALSE;
        
        eNewsletterRT = [select r.Id from RecordType r where r.DeveloperName = :E_NEWSLETTER_RECORDTYPE and sObjectType = 'DF_Contact__c' and IsActive = TRUE LIMIT 1];
    }
        
    public PageReference forgotPassword() {
        resetSent = FALSE;
        userIsNewsletter = FALSE;
        noUserFound = FALSE;
        
        if (emailAddress.length() == 0) {
            emailAddressError = EMPTY_FIELD_VALUE_MSG;
            return null;
        }
        
        emailAddress = emailAddress.toLowerCase();
        
        List<DF_Contact__c> dfContactList = new List<DF_Contact__c>();
        dfContactList = [select d.Id, d.Email__c, d.RecordTypeId from DF_Contact__c d where d.Email__c = :emailAddress LIMIT 1];
        
        if (dfContactList.size() == 0){
            noUserFound = TRUE;
            return null;
        }else {
            if (dfContactList[0].RecordTypeId == eNewsletterRT.Id){
                userIsNewsletter = TRUE;
                return null;
            }
        }
        
        system.debug('*** -- About to run Site.forgotPassword with ' + emailAddress + ' -- ***');
        boolean success = Site.forgotPassword(emailAddress);
        system.debug('*** -- forgotPassword success is ' + success + ' -- ***');
        if (success)
            resetSent = TRUE;

        return null;
    }
        
}