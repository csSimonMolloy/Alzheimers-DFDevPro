@isTest(seeAllData=false)
public with sharing class WEBChampionSessionPrintAttendeesTest {
    static testMethod void printAttendeesTest() {
        WEBChampionSessionPrintAttendees controller;
        
        Test.startTest();

        ApexPages.currentPage().getParameters().put('eventId', '****');
    
        controller = new WEBChampionSessionPrintAttendees();

        System.assertNotEquals(null, controller.isChampion);
        System.assertNotEquals(null, controller.attendees);
        System.assertNotEquals(null, controller.noOfAttendees);
        
        Test.stoptest();
    }
}