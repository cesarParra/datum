@IsTest
private class WhenQueryingTheInMemoryDatabase {
    @IsTest
    static void canSelectFromAnObject() {
        Account account = new Account(Name = 'Test Account');
        QDB.getInstance().doInsert(account);

        QueryBuilder builder = QueryBuilder.of('Account');

        List<Account> accounts = QDB.getInstance().query(builder);

        Assert.areEqual(1, accounts.size());
        Assert.areEqual(account.Id, accounts[0].Id);
    }

    @IsTest
    static void canSelectFromAnyObject() {
        Contact someContact = new Contact(LastName = 'Test Contact');
        Account someAccount = new Account(Name = 'Test Account');
        QDB.getInstance().doInsert(new List<SObject>{someContact, someAccount});

        QueryBuilder builder = QueryBuilder.of('Contact');

        List<Contact> contacts = QDB.getInstance().query(builder);

        Assert.areEqual(1, contacts.size());
    }


    @IsTest
    static void canSelectSpecificFieldsFromAnObject() {
        Account account = new Account(Name = 'Test Account');
        QDB.getInstance().doInsert(account);

        QueryBuilder builder = QueryBuilder.of('Account');

        List<Account> accounts = QDB.getInstance().query(builder);

        Assert.areEqual(1, accounts.size());
        Assert.areEqual(account.Id, accounts[0].Id);
        Assert.isNull(accounts[0].Name);
    }

    @IsTest
    static void canSelectSpecificFieldsFromAnObject_canInsertWithNonWritableFieldsIntoTheDatabase() {
        Account account = (Account) SObjectBuilder.of(Account.SObjectType)
            .put('Name', 'Test Account')
            .put('CreatedDate', Datetime.now())
            .build();
        QDB.getInstance().doInsert(account);

        QueryBuilder builder = QueryBuilder.of('Account')
            .selectFields(new Set<String>{'Name', 'CreatedDate'});

        List<Account> accounts = QDB.getInstance().query(builder);

        Assert.areEqual(1, accounts.size());
        Assert.areEqual(account.Id, accounts[0].Id);
        Assert.areEqual(account.Name, accounts[0].Name);
    }

    @IsTest
    static void canSelectOneFieldAtATime() {
        Account account = (Account) SObjectBuilder.of(Account.SObjectType)
            .put('Name', 'Test Account')
            .put('CreatedDate', Datetime.now())
            .build();
        QDB.getInstance().doInsert(account);

        QueryBuilder builder = QueryBuilder.of('Account')
            .selectField('Name')
            .selectField('CreatedDate');

        List<Account> accounts = QDB.getInstance().query(builder);

        Assert.areEqual(1, accounts.size());
        Assert.areEqual(account.Id, accounts[0].Id);
        Assert.areEqual(account.Name, accounts[0].Name);
    }

    @IsTest
    static void canSelectUsingLimit() {
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
        Account parentAccount = new Account(Name = 'Parent Account');
        QDB.getInstance().doInsert(parentAccount);

        Account childAccount = new Account(Name = 'Child Account', ParentId = parentAccount.Id);
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
    static void canSubselect() {
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
        for (Account currentAccountRecord : accounts) {
            if (currentAccountRecord.Name == 'Parent Account') {
                Assert.areEqual(1, currentAccountRecord.ChildAccounts.size());
                Assert.areEqual('Child Account', currentAccountRecord.ChildAccounts[0].Name);
                return;
            }
        }

        Assert.fail('Parent Account not found');
    }
}
