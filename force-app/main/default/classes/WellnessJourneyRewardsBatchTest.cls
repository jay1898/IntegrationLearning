@isTest
public class WellnessJourneyRewardsBatchTest {
    //Last Change 5 commit
    @testSetup
    static void setupTestData() {
        // Create a test user to own the records
        User user = new User();
        user.Alias = 'testu';
        user.Email = 'testuser@test.com';
        user.EmailEncodingKey = 'UTF-8';
        user.LastName = 'Test';
        user.LanguageLocaleKey = 'en_US';
        user.LocaleSidKey = 'en_US';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1].Id;
        user.Username = 'testuser' + DateTime.now().getTime() + '@test.com';
        insert user;
        
        // Create 12 completed journeys for the previous quarter
        Date startDate = getTestStartDate();
        
        List<Wellness_Journey__c> journeys = new List<Wellness_Journey__c>();
        for (Integer i = 0; i < 12; i++) {
            Wellness_Journey__c WJ = new Wellness_Journey__c();
            WJ.Name = 'Journey ' + i;
            WJ.OwnerId = user.Id;
            WJ.Status__c = 'Complete';
            WJ.Completion_Date__c = startDate.addDays(i);
            journeys.add(WJ);
        }
        insert journeys;
    }
    
    @isTest
    static void testBatchExecution() {
        // Setup mock callout
        Test.setMock(HttpCalloutMock.class, new RewardsCalloutMock());
        
        Test.startTest();
        Database.executeBatch(new WellnessJourneyRewardsBatch(), 12); 
        Test.stopTest();
        
        // Validate journeys exist
        List<Wellness_Journey__c> journeys = [
            SELECT Id, OwnerId FROM Wellness_Journey__c
        ];
        System.assertEquals(12, journeys.size(), 'Should have 12 journeys');
    }
    
    @isTest
    static void testBatchWithNoRecords() {
        // Delete all journeys
        delete [SELECT Id FROM Wellness_Journey__c];
        
        // Setup mock
        Test.setMock(HttpCalloutMock.class, new RewardsCalloutMock());
        
        Test.startTest();
        Database.executeBatch(new WellnessJourneyRewardsBatch(), 5);
        Test.stopTest();
        
        System.assertEquals(0, [SELECT COUNT() FROM Wellness_Journey__c], 'Should be no journeys');
    }
    
        
    // Utility methods to get previous quarter start and end dates
    private static Date getTestStartDate() {
        Date today = Date.today();
        Integer currentYear = today.year();
        Integer currentMonth = today.month();

        Integer previousQuarterStartMonth = ((currentMonth - 1) / 3) * 3 + 1 - 3;
        if (previousQuarterStartMonth <= 0) {
            previousQuarterStartMonth += 12;
            currentYear--;
        }
        return Date.newInstance(currentYear, previousQuarterStartMonth, 1);
    }

    private static Date getTestEndDate() {
        Date startDate = getTestStartDate();
        return startDate.addMonths(3).addDays(-1);
    }
    
        
    // Mock class for HTTP Callout
    private class RewardsCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.assertNotEquals(null, req.getBody(), 'Request body should not be null');
            
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"success": true}');
            return res;
        }
    }

}