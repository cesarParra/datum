public class InMemoryDB extends QDB {
    final Map<Id, SObject> recordsById = new Map<Id, SObject>();
    final List<Relationship> relationships = new List<Relationship>();

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
                    this.relationships.add(
                        new Relationship(
                            parentId,
                            recordToInsert.Id,
                            fieldsMap.get(currentlyPopulatedField)
                        )
                    );
                } else {
                    throw new DmlException('The parent does not exist');
                }
            }
        }
    }

    public SObject getParent(Id childId, String relationshipName) {
        for (Relationship relationship : relationships) {
            if (relationship.childId == childId && relationship.childToParentRelationshipName == relationshipName) {
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

    public List<SObject> getChildren(Id parentId, String subRelationshipName) {
        List<SObject> children = new List<SObject>();
        for (Relationship relationship : relationships) {
            if (relationship.parentId == parentId &&
                relationship.parentToChildRelationshipName.equalsIgnoreCase(subRelationshipName)) {
                children.add(recordsById.get(relationship.childId));
            }
        }
        return children;
    }

    public Boolean isChild(Id parentId, Id childId) {
        for (Relationship relationship : relationships) {
            if (relationship.parentId == parentId && relationship.childId == childId) {
                return true;
            }
        }
        return false;
    }

    public class QdbException extends Exception {
    }
}
