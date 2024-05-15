@IsTest
private class QueryBuilderTest {
    // RED, GREEN, REFACTOR

    @IsTest
    static void canSelectFromAnObject_systemDb() {
        // Given an account in the DB
        Account account = new Account(Name = 'Test Account');
        QDB.doInsert(account);

        // By default when you don't specify any fields, it is going to select the Id
        QueryBuilder builder = QueryBuilder.of('Account');

        // When I run the query
        List<Account> accounts = builder.query(builder);

        Assert.areEqual(1, accounts.size());
        Assert.areEqual(account.Id, accounts[0].Id);
    }

    // TODO: Can query an object
    // TODO: Can query specific fields out of an object
    // TODO: Support bulk insert
}
