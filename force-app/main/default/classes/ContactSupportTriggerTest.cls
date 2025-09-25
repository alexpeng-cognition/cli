@IsTest
private class ContactSupportTriggerTest {
    @IsTest
    static void createsCaseWhenFlagFlipsTrue() {
        Contact c = new Contact(LastName = 'Flow Test', Email = 'flow.test@example.com', Needs_Support__c = false);
        insert c;

        Test.startTest();
        c.Needs_Support__c = true;
        update c;
        Test.stopTest();

        List<Case> cases = [
            SELECT Id, Subject, ContactId
            FROM Case
            WHERE ContactId = :c.Id
        ];
        System.assertEquals(1, cases.size(), 'One case should be created');
        System.assert(cases[0].Subject.startsWith('Support Needed for '), 'Subject should start with template');
        System.assertEquals(c.Id, cases[0].ContactId, 'Contact should be linked');

        // Edit without changing flag should not create duplicates
        c.FirstName = 'Edited';
        update c;

        Integer countAfter = [SELECT COUNT() FROM Case WHERE ContactId = :c.Id];
        System.assertEquals(1, countAfter, 'No duplicate cases should be created');
    }

    @IsTest
    static void bulkUpdateCreatesCasesOnceEach() {
        List<Contact> cs = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            cs.add(new Contact(LastName = 'Bulk'+i, Email = 'bulk'+i+'@example.com', Needs_Support__c = false));
        }
        insert cs;

        for (Contact c : cs) {
            c.Needs_Support__c = true;
        }

        Test.startTest();
        update cs;
        Test.stopTest();

        Integer total = [SELECT COUNT() FROM Case WHERE ContactId IN :cs];
        System.assertEquals(5, total, 'One case per contact in bulk update');
    }
}
