/******************************************************************************************
 *  Cloud Symphony
 *  
 *  Purpose : APEX controller class for VF Page WEBChampionSessionResources.
 *  Author  : CSL
 *  Date    : 27-02-2014
 *  Version : 1.0
 *
 *  Description:    Apex Class controller for the WEBChampionSessionResources class.
 *          Will return a list of Session Resources to the Session Resources page
 *               
 *  Modification History
 *  Date            Who         Description 
 *            
*******************************************************************************************/
public with sharing class WEBChampionSessionResources extends WEBController {
    
    public Boolean isChampion {get;set;}
    public Boolean isConverted {get; set;}

    public String messageArea {get;set;}
    public String messageAreaClass {get;set;}

    public List<sessionResourceCategory> sessionCategories {
        get {
            if (sessionCategories == null) 
                sessionCategories = new List<sessionResourceCategory>();
            return sessionCategories;
        }
        set;
    }

    public Map<Integer, List<Session_Resource__c>> sessionResources {
        get {
            if (sessionResources == null)
                sessionResources = new Map<Integer, List<Session_Resource__c>>();

            return sessionResources;
        }
        set;
    }

    public Map<Id, Attachment> att {
        get {
            if (att == null)
                att = new Map<Id, Attachment>();
            return att;
        }
        set;
    }

  //Constructor  
    public WEBChampionSessionResources() {
        isChampion = WEBController.isChampion;
        isConverted = WEBController.isChampionConverted;

        List<Session_Category__c> sessCats = [SELECT Id, Name, Description__c FROM Session_Category__c ORDER BY Name DESC];        

        if (sessCats != null) {
            Integer r = 0;
            for (Session_Category__c s : sessCats) {
                sessionResourceCategory src = new sessionResourceCategory();
                src.theId = s.Id;
                src.name = s.Name;
                src.description = s.Description__c;
                src.rowNum = r;

                sessionCategories.add(src);

                List<Session_Resource__c> resources = [SELECT Id, Name__c, Type__c, (Select Id, Name, BodyLength, ContentType From Attachments LIMIT 1) FROM Session_Resource__c WHERE Session_Resource_Category__r.Id = :s.Id ORDER BY Name__c];

                if (resources == null) {
                    resources = new List<Session_Resource__c>();
                    sessionResources.put(r,resources);
                }
                else {
                    // Grab the 1st (and hopefully only) attachement
                    Integer i = 0;
                    List<Integer> removeTheseResources = new List<Integer>();

                    for (Session_Resource__c sess : resources) {

                        if (sess.Attachments != null && sess.Attachments.size() > 0) {
                            att.put(sess.Id,sess.Attachments[0]);
                            System.debug('*** Found Attachment - ' + sess.Attachments[0].Name);
                        }
                        else {
                            // Remove it from the list
                            removeTheseResources.add(i);
                            System.debug('*** Removing Resource - ' + i + ' ' + sess.Name__c);
                        }
                        i++;
                    }

                    /* OLD buggy code. We have to remove resources without attachment in reverse order
                    for (Integer j : removeTheseResources)
                        try {
                            resources.remove(j);
                        }catch (Exception e){
                            system.debug('*** -- Error in Session Resources class ' + e + ' at line number ' + e.getLineNumber() + ' -- ***');
                            continue;
                        }
                    */
                    for (Integer j=removeTheseResources.size()-1; j>=0; j--) {
                        resources.remove(removeTheseResources[j]);
                    }

                    if (resources.size() == 0)
                        resources = new List<Session_Resource__c>();
                }

                sessionResources.put(r,resources);

                r += 1;
            }
        }
    }

  //Internal class representing a Session Resource Category
    public class sessionResourceCategory {
        public Id theId {get;set;}
        public String name {get;set;}
        public String description {get;set;}
        public Integer rowNum {get;set;}
    }
    
    //Test method
    public testmethod static void testWEBChampionSessionResources()
    {
     // List<Session_Category__c> sessCats = [SELECT Id, Name, Description__c FROM Session_Category__c]; 
      Session_Category__c scat = new Session_Category__c(name='testname',Description__c='testDescription');
       insert scat;
       
      Session_Resource__c sRes = new Session_Resource__c(Name__c ='testresorce',Type__c='Post',Session_Resource_Category__c = scat.id); 
       insert sRes;
      
      Blob b = Blob.valueOf('Test Data');  
      
    Attachment attachment = new Attachment();  
    attachment.ParentId = sRes.id;  
    attachment.Name = 'Test Attachment for Parent';  
    attachment.Body = b;  
      
    insert(attachment);   
         
       WEBChampionSessionResources webResource = new WEBChampionSessionResources(); 
      
    }
}