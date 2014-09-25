/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class WEBNewsLetterSignupTest {

    static testMethod void testNewsLetterSignup() {
    	String NEWSLETTER_CONTACT_RT = 'E_Newsletter_Subscriber';
    	RecordType newsletterContactRT = [select r.Id from RecordType r where r.SObjectType = 'Contact' and r.DeveloperName = :NEWSLETTER_CONTACT_RT LIMIT 1];
		RecordType newsletterDFContactRT = [select r.Id from RecordType r where r.SObjectType = 'DF_Contact__c' and r.DeveloperName = :NEWSLETTER_CONTACT_RT LIMIT 1];
		
        PageReference newsLetter = Page.WEBNewsLetterSignup;
       	newsLetter.getParameters().put('recaptcha_challenge_field','test values');
       	newsLetter.getParameters().put('recaptcha_response_field','test values');
       	test.setCurrentPage(newsLetter);
       	
       
        WEBNewsLetterSignup wns = new WEBNewsLetterSignup();
        
        //Test with no values;
        
        wns.signupForNewsletter();
        
        //Test with bad values
        
        wns.firstName = 'Test';
        wns.lastName = 'Contact';
        wns.email = 'test';
        
        wns.signupForNewsletter();
        
        //Test with good values
        
		wns.firstName = 'Test';
        wns.lastName = 'Contact';
        wns.email = 'test.contact@myemail.com';
        
        wns.signupForNewsletter();
        
        //Test with an already existing contact
        DF_Contact__c newContact = new DF_Contact__c(RecordTypeId = newsletterDFContactRT.Id);
        newContact.First_Name__c = 'Old';
        newContact.Last_Name__c = 'Contact';
        newContact.Email__c = 'old.contact@myemail.com';
        insert newContact;
        
        wns.firstName = 'Old';
        wns.lastName = 'Contact';
        wns.email = 'old.contact@myemail.com';
        
        wns.signupForNewsletter();
        
    }
}