public with sharing class SObjectBuilder {
  private final Map<String, Object> fieldValues;
  private final SObjectType sObjectType;

  private SObjectBuilder(SObjectType sObjectType) {
    this.sObjectType = sObjectType;
    this.fieldValues = new Map<String, Object>();
  }

  public static SObjectBuilder of(SObjectType sObjectType) {
    return new SObjectBuilder(sObjectType);
  }

  public SObjectBuilder put(String field, Object value) {
    fieldValues.put(field, value);
    return this;
  }

  public SObjectBuilder putParent(
    String relationshipName,
    SObjectBuilder parentBuilder
  ) {
    SObject parent = parentBuilder.build();
    fieldValues.put(relationshipName, parent);
    return this;
  }

  public SObject build() {
    this.fieldValues.put(
      'attributes',
      new Map<String, Object>{ 'type' => sObjectType.getDescribe().getName() }
    );
    String serialized = JSON.serialize(fieldValues);
    Type type = Type.forName(sObjectType.getDescribe().getName());
    return (SObject) JSON.deserialize(serialized, type);
  }
}
