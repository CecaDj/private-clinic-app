@IsTest
private class ShareEventTriggerTest {

    @IsTest
    static void testShareEventProcessing() {
        User portalUser = TestDataFactory.createPortalUser();
        Patient__c patient = [SELECT Id FROM Patient__c WHERE User__c = :portalUser.Id];

        ShareEvent__e evt = new ShareEvent__e(
            RecordId__c = patient.Id,
            ObjectName__c = 'Patient__c'
        );

        Test.startTest();
        Database.SaveResult result = EventBus.publish(evt);
        Test.stopTest();

        System.assert(result.isSuccess(), 'Event should be published successfully');

        List<Patient__Share> shares = [
            SELECT Id, ParentId, UserOrGroupId, AccessLevel
            FROM Patient__Share
            WHERE ParentId = :patient.Id AND UserOrGroupId = :portalUser.Id
        ];
        System.assertEquals(1, shares.size(), 'Patient share should exist after event processing');
    }
}
