public with sharing class SObjectBuilder {
  private final Map<String, Object> fieldValues;
  private final SObjectType sObjectType;

  public Id RecordId { get; set; }

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

  public SObjectBuilder putChildren(String relationshipName, List<SObjectBuilder> childBuilders) {
    List<SObject> children = new List<SObject>();
    for (SObjectBuilder childBuilder : childBuilders) {
      children.add(childBuilder.build());
    }
    fieldValues.put(relationshipName, new ChildRecords(children));
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

  private class ChildRecords {
    public Integer totalSize;
    public Boolean done;
    public List<SObject> records;

    public ChildRecords(List<SObject> records) {
      this.totalSize = records.size();
      this.done = true;
      this.records = records;
    }
  }
}
