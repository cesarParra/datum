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

  @IsTest
  static void canSetChildren() {
    SObjectBuilder child1 = SObjectBuilder.of(Contact.SObjectType)
      .put('LastName', 'Child Contact 1');
    SObjectBuilder child2 = SObjectBuilder.of(Contact.SObjectType)
      .put('LastName', 'Child Contact 2');

    SObjectBuilder parent = SObjectBuilder.of(Account.SObjectType)
      .put('Name', 'Parent Account')
      .putChildren('Contacts', new List<SObjectBuilder>{child1, child2});

    Account parentAccount = (Account) parent.build();
    System.assertEquals(2, parentAccount.Contacts.size());
  }
}
