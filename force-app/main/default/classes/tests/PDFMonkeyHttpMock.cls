@IsTest
public class PDFMonkeyHttpMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();

        if (req.getMethod() == 'POST') {
            res.setStatusCode(201);
            res.setBody('{"document": {"id": "fakeDocId123"}}');
        } else if (req.getMethod() == 'GET' && req.getEndpoint().contains('PDFMonkey')) {
            res.setStatusCode(200);
            res.setBody('{"document": {"status": "success", "download_url": "https://fakeUrl.com/invoice.pdf"}}');
        } else if (req.getMethod() == 'GET' && req.getEndpoint().contains('fakeUrl.com')) {
            res.setStatusCode(200);
            res.setBodyAsBlob(Blob.valueOf('Fake PDF Data'));
        } else {
            res.setStatusCode(400);
            res.setBody('{"error": "Unsupported request"}');
        }
        return res;
    }
}
