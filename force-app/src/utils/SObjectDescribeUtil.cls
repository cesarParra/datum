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

  public static SObjectType getFromName(String fromName) {
    return Schema.getGlobalDescribe().get(fromName);
  }
}
