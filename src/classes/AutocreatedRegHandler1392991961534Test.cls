@isTest(SeeAllData=true) 
public class AutocreatedRegHandler1392991961534Test{
	
  	static testMethod void AutocreatedRegHandler1(){
    	User u;
        Account a;
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
       	// Insert account as current user
        system.runAs (thisUser) {
        	Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
            UserRole r = [SELECT Id FROM UserRole WHERE Name='CEO'];
            
            u = new User(alias = 'jsmith1', email='jsmith1@acme.com', 
            	emailencodingkey='UTF-8', lastname='Smith12', 
                languagelocalekey='en_US', 
                localesidkey='en_US', profileid = p.Id, userroleid = r.Id,
                timezonesidkey='America/Los_Angeles', 
                username='jsmith12@acme.com');
            insert u;
            
            a = new Account(name='Acme');
            insert a;
        }
        
    	AutocreatedRegHandler1392991961534 handler = new AutocreatedRegHandler1392991961534();
      	Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast','testFirst testLast', 'testuser@example.org', null, 
      								'testAdvalong', 'en_US', 'facebook',null, new Map<String, String>{'language' => 'en_US'});  
            
		Account aa = new Account(name='Acme');  
        insert aa; 
        
        handler.canCreateUser(sampleData );
        handler.createUser(null,sampleData );
        // user u2=new user(id=u.id);
        handler.updateUser(u.id,null,sampleData );  
  } 

}