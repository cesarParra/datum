@IsTest
private class FieldTest {
  @IsTest
  static void canHoldRegularFields() {
    SObjectType type = Account.SObjectType;
    String fieldName = 'Name';

    Field field = new Field(type, fieldName);

    Assert.areEqual('Name', field.getName());
  }

  @IsTest
  static void regularFieldsAreNotRelationship() {
    SObjectType type = Account.SObjectType;
    String fieldName = 'Name';

    Field field = new Field(type, fieldName);

    Assert.isFalse(field.isRelationship());
  }

  @IsTest
  static void canHoldRelationships() {
    SObjectType type = Account.SObjectType;
    String fieldName = 'Parent.Name';

    Field field = new Field(type, fieldName);

    Assert.areEqual('Name', field.getName());
  }

  @IsTest
  static void canHoldRelationships_relationshipIsTrue() {
    SObjectType type = Account.SObjectType;
    String fieldName = 'Parent.Name';

    Field field = new Field(type, fieldName);

    Assert.isTrue(field.isRelationship());
  }

  @IsTest
  static void canGetRelationshipTypes() {
    SObjectType type = Account.SObjectType;
    String fieldName = 'Parent.Name';

    Field field = new Field(type, fieldName);

    Assert.isTrue(field.isRelationship());
    Assert.areEqual(Account.SObjectType, field.getRelationship().relationType);
  }
}
