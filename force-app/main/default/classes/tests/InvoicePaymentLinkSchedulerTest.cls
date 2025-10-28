@isTest
private class InvoicePaymentLinkSchedulerTest {

    @isTest
    static void testSchedulerRunsBatch() {
        Test.startTest();
        String cron = '0 0 0 * * ?'; 
        System.schedule('Test Scheduler', cron, new InvoicePaymentLinkScheduler());
        Test.stopTest();

        List<CronTrigger> jobs = [SELECT Id, CronExpression, TimesTriggered 
                                  FROM CronTrigger WHERE CronJobDetail.Name = 'Test Scheduler'];
        System.assertEquals(1, jobs.size(), 'Job should be scheduled');
        System.assertEquals('0 0 0 * * ?', jobs[0].CronExpression, 'Cron expression should match');
    }
}
