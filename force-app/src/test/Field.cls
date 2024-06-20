public with sharing class Field {
    private final String relationshipName;
    private final SObjectType type;
    private final SObjectType relationshipType;
    private final String name;

    public class Relationship {
        public String relationName;
        public SObjectType relationType;
        public String fieldName;
    }

    public Field(SObjectType type, String name) {
        this.type = type;
        if (name.contains('.')) {
            List<String> parts = name.split('\\.');
            this.relationshipName = parts[0];
            // Get the relationship type
            this.relationshipType = SObjectDescribeUtil.getSObjectTypeByRelationshipName(
                type,
                this.relationshipName
            );
            this.name = parts[1];
        } else {
            this.name = name;
            this.relationshipType = null;
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
        return isRelationship() ? relationshipName + '.' + name : name;
    }
}
