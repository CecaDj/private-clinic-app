@isTest
public class StripeHttpMock implements HttpCalloutMock{

    private Boolean isSuccess;

    public StripeHttpMock(Boolean isSuccess) {
        this.isSuccess = isSuccess;
    }

    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();

        if (isSuccess) {
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"id":"cs_test_12345","url":"https://checkout.stripe.com/test_session"}');
            res.setStatusCode(200);
        } else {
            res.setBody('{"error":"Invalid request"}');
            res.setStatusCode(400);
        }

        return res;
    }
}