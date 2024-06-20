public with sharing class Field {
    private final SObjectType type;
    private final String name;
    private final Relationship relationship;

    public class Relationship {
        public String relationName;
        public SObjectType relationType;
        public String fieldName;

        public Relationship(String relationName, SObjectType relationType, String fieldName) {
            this.relationName = relationName;
            this.relationType = relationType;
            this.fieldName = fieldName;
        }
    }

    public Field(SObjectType type, String name) {
        this.type = type;
        if (name.contains('.')) {
            List<String> parts = name.split('\\.');
            Relationship relationship = new Relationship(parts[0], SObjectDescribeUtil.getSObjectTypeByRelationshipName(type, parts[0]), parts[1]);
            this.relationship = relationship;
            this.name = parts[1];
        } else {
            this.name = name;
            this.relationship = null;
        }
    }

    public String getName() {
        return name;
    }

    public Boolean isRelationship() {
        return relationship != null;
    }

    public Relationship getRelationship() {
        return relationship;
    }

    public String getFullName() {
        return isRelationship() ? relationship.relationName + '.' + name : name;
    }
}
