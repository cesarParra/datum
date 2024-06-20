public class InMemoryDB extends QDB {
    final Map<Id, SObject> recordsById = new Map<Id, SObject>();
    final List<Relationship> relationships = new List<Relationship>();

    public class Relationship {
        public Id parentId;
        public Id childId;
        public String relationshipName;

        public Relationship(Id parentId, Id childId, String relationshipName) {
            this.parentId = parentId;
            this.childId = childId;
            this.relationshipName = relationshipName;
        }
    }

    public class QdbException extends Exception {
    }

    public override void doInsert(SObject recordToInsert) {
        recordToInsert.Id = IdGenerator.generate(recordToInsert.getSObjectType());
        handleRelationships(recordToInsert);
        recordsById.put(recordToInsert.Id, recordToInsert);
    }

    private void handleRelationships(SObject recordToInsert) {
        Map<String, Object> populatedFields = recordToInsert.getPopulatedFieldsAsMap();
        SObjectType type = recordToInsert.getSObjectType();
        Map<String, SObjectField> fieldsMap = type.getDescribe().fields.getMap();
        for (String currentlyPopulatedField : populatedFields.keySet()) {
            if (currentlyPopulatedField.toLowerCase() == 'id') {
                continue;
            }
            DescribeFieldResult fieldDescribe = fieldsMap.get(currentlyPopulatedField).getDescribe();
            if (fieldDescribe.getType() == DisplayType.REFERENCE) {
                Id parentId = (Id) populatedFields.get(currentlyPopulatedField);
                if (recordsById.containsKey(parentId)) {
                    this.relationships.add(new Relationship(parentId, recordToInsert.Id, fieldDescribe.getRelationshipName()));
                } else {
                    throw new DmlException('The parent does not exist');
                }
            }
        }
    }

    public SObject getParent(Id childId, String relationshipName) {
        System.debug('Received childId: ' + childId + ' and relationshipName: ' + relationshipName);
        for (Relationship relationship : relationships) {
            System.debug('Looking at relationship: ' + relationship);
            if (relationship.childId == childId && relationship.relationshipName == relationshipName) {
                return recordsById.get(relationship.parentId);
            }
        }
        return null;
    }

    public override void doInsert(List<SObject> recordsToInsert) {
        for (SObject record : recordsToInsert) {
            doInsert(record);
        }
    }

    public override List<SObject> query(QueryBuilder queryBuilder) {
        InMemoryDBVisitor visitor = new InMemoryDBVisitor(this);
        return visitor.query(queryBuilder);
    }

    public Map<Id, SObject> getRecordsById() {
        return recordsById;
    }
}
