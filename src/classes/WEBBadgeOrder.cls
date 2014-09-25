/******************************************************************************************
 *  Cloud Symphony
 *  
 *  Purpose : APEX controller class for VF Page WEBBadgeOrder.
 *  Author  : CSL
 *  Date    : 27-02-2014
 *  Version : 1.0
 *
 *  Description:    Apex Class that looks after the WEBBadgeOrder VF Page.
 *               
 *  Modification History
 *  Date            Who         Description 
 *                    
*******************************************************************************************/
public with sharing class WEBBadgeOrder extends WEBController {

    public final String EMPTY_FIELD_VALUE_MSG = 'Value is required and can\'t be empty';
    public final String STANDARD_ERROR_MSG = 'Please correct the mistakes highlighted below';

    public String lastName {get; set;}
    public String firstName {get; set;}
    public String addressStreet {get; set;}
    public String addressStreet2 {get; set;}
    public String addressCity {get; set;}
    public String addressCounty {get; set;}
    public String addressPostcode {get; set;}
    public String standardErrorMsg {get; set;}
    public String messageArea {get;set;}
    public String messageAreaClass {get;set;}
    public String firstNameErrorClass {get; set;}
    public String firstNameError {get; set;}
    public String lastNameErrorClass {get; set;}
    public String lastNameError {get; set;}
    public String addressStreetErrorClass {get; set;}
    public String addressStreetError {get; set;}
    public String addressCityErrorClass {get; set;}
    public String addressCityError {get; set;}
    public String addressCountyErrorClass {get; set;}
    public String addressCountyError {get; set;}
    public String addressPostcodeErrorClass {get; set;}
    public String addressPostcodeError {get; set;}
    public DF_Contact__c loggedInContact {get; set;}
    public List<BadgeClaimWrapper> badgeClaims {get; set;}
    public Badge_Claim__c badgeClaim {get; set;}
    public boolean isChampion {get; set;}
    public boolean isConverted {get; set;}
    
    public Page_Snippet__c totalFriendsSnippet {
        get {
            if (totalFriendsSnippet == null){
                totalFriendsSnippet = [select p.Body_Text__c, p.Unique_Name__c from Page_Snippet__c p where p.Unique_Name__c = 'DementiaFriendsTotalSnippet' LIMIT 1];
            }
            return totalFriendsSnippet;
        }
        set ;
    }
    
    //Constructor
    public WEBBadgeOrder(){
        if (WEBController.isLoggedIn){
            isChampion = WEBController.isChampion;
            isConverted = WEBController.isChampionConverted;            
            
            badgeClaims = new List<BadgeClaimWrapper>();
            badgeClaim = new Badge_Claim__c();
            
            User loggedInUser = [select u.Id, u.ContactId from User u where u.Id = :UserInfo.getUserId()];
            loggedInContact = [Select d.Street__c, d.Status__c, d.Postcode__c, d.Portal_Contact__c, d.Name__c, d.Name, d.Last_Name__c, d.First_Name__c, d.Email__c, d.County__c, d.Country__c, 
                                d.Contact_Number__c, d.City__c From DF_Contact__c d where d.Portal_Contact__c = :loggedInUser.ContactId LIMIT 1];
                                
            lastName = loggedInContact.Last_Name__c;
            firstName = loggedInContact.First_Name__c;
            addressStreet = loggedInContact.Street__c;
            addressCity = loggedInContact.City__c;
            addressCounty = loggedInContact.County__c;
            addressPostcode = loggedInContact.Postcode__c;
            
            for (Badge_Claim__c bc : [Select b.CreatedDate, b.Town_City__c, b.Street__c, b.Street_2__c, b.Postcode__c, b.Id, b.DF_Contact__c, b.County__c, b.Country__c, b.Contact_Ext_Id__c, b.Badge_Claimed__c, 
                                        b.BC_Ext_Id__c, b.DF_Contact__r.First_Name__c, b.DF_Contact__r.Last_Name__c From Badge_Claim__c b where b.DF_Contact__c = :loggedInContact.Id]){
                                            
                                            badgeClaims.add(new BadgeClaimWrapper(bc));
                                                                                        
                                        }
            }
    }
    
    //Method to validate page and submit Badge Claim
    public PageReference submitBadgeClaim(){
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

        if (addressStreet == null || addressStreet.trim().length() == 0){
            standardErrorMsg = STANDARD_ERROR_MSG;
            addressStreetError = EMPTY_FIELD_VALUE_MSG;
            addressStreetErrorClass = 'error';
            isError = true;
        }else {
            standardErrorMsg = null;
            addressStreetErrorClass = '';
            addressStreetError = '';    
        }
            
        if (addressCity == null || addressCity.trim().length() == 0){
            standardErrorMsg = STANDARD_ERROR_MSG;
            addressCityError = EMPTY_FIELD_VALUE_MSG;
            addressCityErrorClass = 'error';
            isError = true;
        }else {
            standardErrorMsg = null;
            addressCityErrorClass = '';
            addressCityError = '';  
        }
        
        if (addressCounty == null || addressCounty.trim().length() == 0){
            standardErrorMsg = STANDARD_ERROR_MSG;
            addressCountyError = EMPTY_FIELD_VALUE_MSG;
            addressCountyErrorClass = 'error';
            isError = true;
        }else {
            standardErrorMsg = null;
            addressCountyErrorClass = '';
            addressCountyError = '';    
        }
        
        if (addressPostcode == null || addressPostcode.trim().length() == 0){
            standardErrorMsg = STANDARD_ERROR_MSG;
            addressPostcodeError = EMPTY_FIELD_VALUE_MSG;
            addressPostcodeErrorClass = 'error';
            isError = true;
        }else {
            standardErrorMsg = null;
            addressPostcodeErrorClass = '';
            addressPostcodeError = '';  
        }
        
        if (isError){
            system.debug('*** -- Error in form -- ***');
            system.debug('*** -- lastNameErrorClass = ' + lastNameErrorClass + ' -- ***');
            system.debug('*** -- firstNameErrorClass = ' + firstNameErrorClass + ' -- ***');
            return null;
        }else {
            boolean saveContact = false;
            badgeClaim.DF_Contact__c = loggedInContact.Id;
            if (loggedInContact.First_Name__c != firstName){
                loggedInContact.First_Name__c = firstName;
                saveContact = true;
            }
            if (loggedInContact.Last_Name__c != lastName){
                loggedInContact.Last_Name__c = lastName;
                saveContact = true;
            }
            //2014-08-06 : CSL : Client wants to concatenate Street & Street 2 into the Street field on the Badge Order
            badgeClaim.Street__c = addressStreet + ', ' + addressStreet2;
            //badgeClaim.Street_2__c = addressStreet2;
            badgeClaim.Town_City__c = addressCity;
            badgeClaim.County__c = addressCounty;
            badgeClaim.Postcode__c = addressPostcode;
                                    
            if (saveContact){
                update loggedInContact;
            }           
            
            insert badgeClaim;
            
            return Page.WEBBadgeOrderThankyou;
            
        }
    }
    
    //Wrapper class to help with Badge Claim processing
    public class BadgeClaimWrapper {
        public Badge_Claim__c theClaim {get; set;}
        public String claimName {get; set;}
        public String claimAddress {get; set;}
        public String claimDate {get; set;}
        public String monthLabel {get; set;}
        
        public BadgeClaimWrapper(Badge_Claim__c bc){
            this.theClaim = bc;
            this.claimName = bc.DF_Contact__r.First_Name__c.substring(0,1) + ' ' + bc.DF_Contact__r.Last_Name__c;   
            this.claimAddress = bc.Street__c + ', ' + (bc.Street_2__c != null ? bc.Street_2__c + ', ' : ' ') + bc.Town_City__c + ', ' + bc.County__c + ', ' + bc.Postcode__c;
            if (bc.CreatedDate.month() == 1) monthLabel = 'January';
            if (bc.CreatedDate.month() == 2) monthLabel = 'February';
            if (bc.CreatedDate.month() == 3) monthLabel = 'March';
            if (bc.CreatedDate.month() == 4) monthLabel = 'April';
            if (bc.CreatedDate.month() == 5) monthLabel = 'May';
            if (bc.CreatedDate.month() == 6) monthLabel = 'June';
            if (bc.CreatedDate.month() == 7) monthLabel = 'July';
            if (bc.CreatedDate.month() == 8) monthLabel = 'August';
            if (bc.CreatedDate.month() == 9) monthLabel = 'September';
            if (bc.CreatedDate.month() == 10) monthLabel = 'October';
            if (bc.CreatedDate.month() == 11) monthLabel = 'November';
            if (bc.CreatedDate.month() == 12) monthLabel = 'December';
            
            this.claimDate = monthLabel + ' ' + bc.CreatedDate.day() + ', ' + bc.CreatedDate.year();    
            
        }
    }

}