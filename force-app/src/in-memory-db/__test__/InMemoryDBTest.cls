@IsTest
private class InMemoryDBTest {
    @IsTest
    static void autoGeneratesIdsDuringInsert() {
        Contact someContact = new Contact(LastName = 'Test Contact');
        QDB.getInstance().doInsert(someContact);

        QueryBuilder builder = QueryBuilder.of('Contact');

        List<Contact> contacts = QDB.getInstance().query(builder);

        Assert.isNotNull(contacts[0].Id);
    }

    @IsTest
    static void validatesTheParentExistsWhenInsertingARelationship() {
        Account childAccount = new Account(
            Name = 'Child Account',
            ParentId = '001000000000000AAA'
        );
        try {
            QDB.getInstance().doInsert(childAccount);
            Assert.fail('An exception should have been thrown');
        } catch (DmlException e) {
            Assert.isTrue(true, 'The expected exception was thrown');
        } catch (Exception e) {
            Assert.fail('An unexpected exception was thrown');
        }
    }

    @IsTest
    static void canReturnAllChildRecordsGivenAParentIdAndASubRelationshipName() {
        InMemoryDB db = new InMemoryDB();
        Account parentAccount = new Account(Name = 'Parent Account');
        db.doInsert(parentAccount);

        Contact childContact1 = new Contact(LastName = 'Child Contact 1', AccountId = parentAccount.Id);
        db.doInsert(childContact1);

        Contact childContact2 = new Contact(LastName = 'Child Contact 2', AccountId = parentAccount.Id);
        db.doInsert(childContact2);

        List<SObject> childContacts = db.getChildren(parentAccount.Id, 'Contacts');

        Assert.areEqual(2, childContacts.size());
    }
}
