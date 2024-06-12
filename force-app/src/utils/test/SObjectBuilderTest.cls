@IsTest
private class SObjectBuilderTest {
    @IsTest
    static void canSetParent() {
        SObjectBuilder parentBuilder = SObjectBuilder.of(Account.SObjectType)
            .put('Name', 'Parent Account');

        Account child = (Account) SObjectBuilder.of(Account.SObjectType)
            .put('Name', 'Child Account')
            .putParent('Parent', parentBuilder)
            .build();

        System.assertEquals(child.Parent.Name, 'Parent Account');
    }
}
