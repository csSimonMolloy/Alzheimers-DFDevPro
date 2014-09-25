public with sharing class WEBNews extends WEBController {
    
    public List<News__c> newsStories {
        get {
            if (newsStories == null) {
                newsStories = new List<News__c>();
            }

            return newsStories;
        }
        private set;
    }

    public News__c selectedStory {
        get {
            if (selectedStory == null) {
                selectedStory = new News__c();
            }

            return selectedStory;
        }
        private set;
    }

	public String imageId {get; set;}

    public WEBNews() {

        String storyId = ApexPages.currentPage().getParameters().get('storyId');

        //System.debug('*** WEBNews storyId : ' + storyId);

        if ((storyId != null) && (storyId.length() > 0))
            newsStories = [SELECT Body_Text__c,Id,Promote_On_Homepage__c,Publish_Date__c,Title__c,Unique_Text__c, (Select Id, Name, BodyLength From Attachments) FROM News__c WHERE Id = :storyId];
        else
            newsStories = [SELECT Body_Text__c,Id,Promote_On_Homepage__c,Publish_Date__c,Title__c,Unique_Text__c FROM News__c WHERE Publish_Date__c <= today ORDER BY Publish_Date__c DESC LIMIT 10];
        
        if (newsStories.size() > 0)
            selectedStory = newsStories[0];
            if (selectedStory.Attachments.size() > 0){
	            imageId = selectedStory.Attachments[0].Id;
            }
    }
}