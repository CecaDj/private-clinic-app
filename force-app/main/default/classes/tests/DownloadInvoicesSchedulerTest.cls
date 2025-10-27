@IsTest
private class DownloadInvoicesSchedulerTest {
    @IsTest
    static void testDownloadScheduler() {
        Test.startTest();
        String CRON_EXP = '0 30 2 * * ?';
        String jobId = System.schedule('TestDownloadInvoicesJob', CRON_EXP, new DownloadInvoicesScheduler());
        Test.stopTest();

        CronTrigger ct = [SELECT Id, CronExpression FROM CronTrigger WHERE Id = :jobId LIMIT 1];
        System.assertEquals('0 30 2 * * ?', ct.CronExpression, 'Cron expression should match');
    }
}
