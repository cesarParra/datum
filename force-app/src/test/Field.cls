public with sharing class Field {
  private final String fullName;
  private final SObjectType type;
  private final SObjectType relationshipType;
  private final String name;

  public Field(SObjectType type, String name) {
    this.fullName = name;
    this.type = type;
    if (name.contains('.')) {
      List<String> parts = name.split('\\.');
      String relationshipName = parts[0];
      // Get the relationship type
      this.relationshipType = SObjectDescribeUtil.getSObjectTypeByRelationshipName(
        type,
        relationshipName
      );
      this.name = parts[1];
    } else {
      this.name = name;
    }
  }

  public String getName() {
    return name;
  }

  public Boolean isRelationship() {
    return relationshipType != null;
  }

  public SObjectType getRelationshipType() {
    return relationshipType;
  }

  public String getFullName() {
    return fullName;
  }
}
