trigger ContactSupportTrigger on Contact (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        Set<Id> toCreateIds = new Set<Id>();
        for (Contact c : Trigger.new) {
            Contact oldC = Trigger.oldMap.get(c.Id);
            if (oldC != null && oldC.Needs_Support__c == false && c.Needs_Support__c == true) {
                toCreateIds.add(c.Id);
            }
        }
        if (toCreateIds.isEmpty()) {
            return;
        }
        List<Contact> contacts = [
            SELECT Id, Name
            FROM Contact
            WHERE Id IN :toCreateIds
        ];

        RecordType rt = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Case' AND Name = 'IT Request'
            LIMIT 1
        ];

        List<Case> casesToInsert = new List<Case>();
        for (Contact c : contacts) {
            Case cs = new Case(
                ContactId = c.Id,
                RecordTypeId = rt != null ? rt.Id : null,
                Subject = 'Support Needed for ' + c.Name
            );
            casesToInsert.add(cs);
        }
        if (!casesToInsert.isEmpty()) {
            insert casesToInsert;
        }
    }
}
