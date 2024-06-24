@IsTest
private class WhenQueryingTheSalesforceDatabase {
    @IsTest
    static void canSelectFromAnObject() {
        QDB.useSystemDB();
        Account account = new Account(Name = 'Test Account');
        QDB.getInstance().doInsert(account);

        QueryBuilder builder = QueryBuilder.of('Account');

        List<Account> accounts = QDB.getInstance().query(builder);

        Assert.areEqual(1, accounts.size());
        Assert.areEqual(account.Id, accounts[0].Id);
    }

    @IsTest
    static void canSelectFromAnyObject() {
        QDB.useSystemDB();
        Contact someContact = new Contact(LastName = 'Test Contact');
        QDB.getInstance().doInsert(someContact);

        QueryBuilder builder = QueryBuilder.of('Contact');

        List<Contact> contacts = QDB.getInstance().query(builder);

        Assert.areEqual(1, contacts.size());
        Assert.areEqual(someContact.Id, contacts[0].Id);
    }

    @IsTest
    static void canSelectSpecificFieldsFromAnObject() {
        QDB.useSystemDB();
        Account account = new Account(Name = 'Test Account');
        QDB.getInstance().doInsert(account);

        QueryBuilder builder = QueryBuilder.of('Account')
            .selectFields(new Set<String>{'Name'});

        List<Account> accounts = QDB.getInstance().query(builder);

        Assert.areEqual(1, accounts.size());
        Assert.areEqual(account.Id, accounts[0].Id);
        Assert.areEqual(account.Name, accounts[0].Name);
    }

    @IsTest
    static void canSelectSpecificFieldsFromAnObject_whenANullSetOfFieldsIsPassed_noExceptionsAreThrown() {
        QDB.useSystemDB();
        Account account = new Account(Name = 'Test Account');
        QDB.getInstance().doInsert(account);

        QueryBuilder builder = QueryBuilder.of('Account').selectFields(null);

        try {
            QDB.getInstance().query(builder);
            Assert.isTrue(true);
        } catch (Exception e) {
            Assert.fail('An exception was thrown');
        }
    }

    @IsTest
    static void canSelectUsingLimit_salesforceDatabase() {
        QDB.useSystemDB();
        QDB.getInstance()
            .doInsert(
                new List<SObject>{
                    new Account(Name = 'Test Account 1'),
                    new Account(Name = 'Test Account 2')
                }
            );

        QueryBuilder builder = QueryBuilder.of('Account')
            .selectFields(new Set<String>{'Name'})
            .withLimitAmount(1);

        List<Account> accounts = QDB.getInstance().query(builder);

        Assert.areEqual(1, accounts.size());
    }

    @IsTest
    static void canSelectUsingOffset() {
        QDB.useSystemDB();
        QDB.getInstance()
            .doInsert(
                new List<SObject>{
                    new Account(Name = 'Test Account 1'),
                    new Account(Name = 'Test Account 2')
                }
            );

        QueryBuilder builder = QueryBuilder.of('Account')
            .selectFields(new Set<String>{'Name'})
            .withOffsetAmount(1);

        List<Account> accounts = QDB.getInstance().query(builder);

        Assert.areEqual(1, accounts.size());
    }

    @IsTest
    static void canSelectParentFields() {
        QDB.useSystemDB();
        Account parentAccount = new Account(Name = 'Parent Account');
        QDB.getInstance().doInsert(parentAccount);

        Account childAccount = new Account(
            Name = 'Child Account',
            ParentId = parentAccount.Id
        );
        QDB.getInstance().doInsert(childAccount);

        QueryBuilder builder = QueryBuilder.of('Account')
            .selectField('Name')
            .selectField('Parent.Name');

        List<Account> accounts = QDB.getInstance().query(builder);

        Assert.areEqual(2, accounts.size());
        for (Account account : accounts) {
            if (account.Name == 'Child Account') {
                Assert.areEqual('Parent Account', account.Parent.Name);
                return;
            }
        }

        Assert.fail('Child Account not found');
    }

    @IsTest
    static void whenInsertingARelationshipTheDatabaseValidatesThatTheParentExists() {
        QDB.useSystemDB();
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
            Assert.fail('An exception was thrown');
        }
    }

    @IsTest
    static void canSubselect() {
        QDB.useSystemDB();
        Account parentAccount = new Account(Name = 'Parent Account');
        QDB.getInstance().doInsert(parentAccount);

        Account childAccount = new Account(
            Name = 'Child Account',
            ParentId = parentAccount.Id
        );
        QDB.getInstance().doInsert(childAccount);

        QueryBuilder builder = QueryBuilder.of('Account')
            .selectField('Name')
            .selectField('Parent.Name')
            .subselect(
                QueryBuilder.of('ChildAccounts')
                    .selectField('Name')
            );

        List<Account> accounts = QDB.getInstance().query(builder);

        Assert.areEqual(2, accounts.size());
        for (Account account : accounts) {
            if (account.Name == 'Parent Account') {
                Assert.areEqual(1, account.ChildAccounts.size());
                Assert.areEqual('Child Account', account.ChildAccounts[0].Name);
                return;
            }
        }

        Assert.fail('Parent Account not found');
    }

    @IsTest
    static void canQueryUsingMultipleSubselects() {
        QDB.useSystemDB();
        Account parentAccount = new Account(Name = 'Parent Account');
        QDB.getInstance().doInsert(parentAccount);

        Account childAccount = new Account(
            Name = 'Child Account',
            ParentId = parentAccount.Id
        );
        QDB.getInstance().doInsert(childAccount);

        Contact contact = new Contact(
            LastName = 'Test Contact',
            AccountId = parentAccount.Id
        );
        QDB.getInstance().doInsert(contact);

        QueryBuilder builder = QueryBuilder.of('Account')
            .selectField('Name')
            .subselect(
                QueryBuilder.of('ChildAccounts')
                    .selectField('Name')
            )
            .subselect(
                QueryBuilder.of('Contacts')
                    .selectField('LastName')
            );

        List<Account> accounts = QDB.getInstance().query(builder);

        Assert.areEqual(2, accounts.size());
        for (Account account : accounts) {
            if (account.Name == 'Parent Account') {
                Assert.areEqual(1, account.ChildAccounts.size());
                Assert.areEqual('Child Account', account.ChildAccounts[0].Name);
                Assert.areEqual(1, account.Contacts.size());
                Assert.areEqual('Test Contact', account.Contacts[0].LastName);
                return;
            }
        }
    }
}
