@IsTest
private class GenerateInvoicesSchedulerTest {
    @IsTest
    static void testGenerateScheduler() {
        Test.startTest();
        String CRON_EXP = '0 0 2 * * ?';
        String jobId = System.schedule('TestGenerateInvoicesJob', CRON_EXP, new GenerateInvoicesScheduler());
        Test.stopTest();

        CronTrigger ct = [SELECT Id, CronExpression FROM CronTrigger WHERE Id = :jobId LIMIT 1];
        System.assertEquals('0 0 2 * * ?', ct.CronExpression, 'Cron expression should match');
    }
}
