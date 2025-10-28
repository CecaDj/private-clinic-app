/* Creates Stripe Checkout sessions for a list of invoices
 * - For each invoice, a callout is made to Stripe’s /checkout/sessions endpoint
 * - Response contains a checkout URL
 * - The map result is later used to update invoices with their payment link
 */
public class StripePaymentService {

    public static Map<Id, String> createCheckoutSessions(List<Invoice__c> invoices) {
        Map<Id, String> invoiceToUrl = new Map<Id, String>();

        for (Invoice__c inv : invoices) {
            try {
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:Stripe/v1/checkout/sessions'); 
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

                // Construct Stripe request body with invoice details
                String body =
                    'payment_method_types[]=card' +
                    '&mode=payment' +
                    '&success_url=https://your-heroku-app.herokuapp.com/success?invoiceId=' + inv.Id +
                    '&cancel_url=https://your-heroku-app.herokuapp.com/cancel?invoiceId=' + inv.Id +
                    '&line_items[0][price_data][currency]=usd' +   
                    '&line_items[0][price_data][product_data][name]=Invoice ' + inv.Name +
                    '&line_items[0][price_data][unit_amount]=' + Integer.valueOf(inv.Total_Amount__c * 100) +
                    '&line_items[0][quantity]=1' +
                    '&metadata[invoiceId]=' + inv.Id;

                req.setBody(body);

                Http http = new Http();
                HttpResponse res = http.send(req);

                // On success, extract the checkout URL and map it to the invoice
                if (res.getStatusCode() == 200) {
                    Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    String url = (String) result.get('url');
                    invoiceToUrl.put(inv.Id, url);
                } else {
                    System.debug('Stripe error for Invoice ' + inv.Id + ': ' + res.getBody());
                }
            } catch (Exception e) {
                System.debug('Exception for Invoice ' + inv.Id + ': ' + e.getMessage());
            }
        }

        return invoiceToUrl;
    }
}
