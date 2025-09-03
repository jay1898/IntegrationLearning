public class RewardsCalloutService{
    
    public static Integer submitUsersForRewardCallout(String jsonBody) {
        HttpRequest req = new HttpRequest();
        //Set Endpoint from Named Credential
        req.setEndpoint('callout:BalancedLiving/rewards');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(jsonBody);
        
        //Make HTTP Callout
        Http http = new Http();
        HttpResponse res;
        Integer statusCode;
        
        try{
            res = http.send(req);
            statusCode = res.getStatusCode();
            system.debug('Response Body : '+res.getBody());
            system.debug('Response Status : '+statusCode);
        }catch(Exception e){
            system.debug('Error: '+e.getMessage());
            statusCode = 500;
        }
        return statusCode;
    }
}