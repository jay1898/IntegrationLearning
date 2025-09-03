@isTest
public class RewardsCalloutServiceTest {
    
    // Fake callout response
    private class RewardsCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Validate request basics
            System.assertEquals('POST', req.getMethod(), 'Method must be POST');
            System.assertEquals('application/json', req.getHeader('Content-Type'));

            // Create fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"message":"success","rewardId":"12345"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testSubmitUsersForRewardCallout_Success() {
        // Register mock
        Test.setMock(HttpCalloutMock.class, new RewardsCalloutMock());

        // Prepare dummy JSON body
        String jsonBody = '{"userId":"005xx0000012345","fullName":"Test User"}';

        Test.startTest();
        Integer statusCode = RewardsCalloutService.submitUsersForRewardCallout(jsonBody);
        Test.stopTest();

        // Assert
        System.assertEquals(200, statusCode, 'Expected success status code 200');
    }

    @isTest
    static void testSubmitUsersForRewardCallout_Failure() {

        Test.startTest();
        Integer statusCode = RewardsCalloutService.submitUsersForRewardCallout('');
        Test.stopTest();

        // Should fallback to 500
        System.assertEquals(500, statusCode, 'Expected error status code 500');
    }
}