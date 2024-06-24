public with sharing class SObjectDescribeUtil {
  public static SObjectType getSObjectTypeByRelationshipName(
    SObjectType childType,
    String relationshipName
  ) {
    Map<String, SObjectField> fieldMap = childType.getDescribe()
      .fields.getMap();
    for (String key : fieldMap.keySet()) {
      String relName = fieldMap.get(key.toLowerCase())
        ?.getDescribe()
        ?.getRelationshipName();
      if (relName == null) {
        continue;
      }
      if (relName.equalsIgnoreCase(relationshipName)) {
        return fieldMap.get(key).getDescribe().getSObjectType();
      }
    }

    return null;
  }

  public static ChildRelationship getRelationship(SObjectType parentType, String relationshipName) {
    for (ChildRelationship childRel : parentType.getDescribe().getChildRelationships()) {
      if (childRel.getRelationshipName() != null &&
          childRel.getRelationshipName().equalsIgnoreCase(relationshipName)) {
        return childRel;
      }
    }

    return null;
  }
}
