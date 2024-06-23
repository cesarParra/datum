
public with sharing class InMemoryDBVisitor implements QueryPartVisitor {
    private final InMemoryDB db;
    List<SObject> filteredRecords = null;

    public InMemoryDBVisitor(InMemoryDB db) {
        this.db = db;
    }

    public List<SObject> query(QueryBuilder queryBuilder) {
        this.filteredRecords = new List<SObject>();
        for (QueryBuilder.QueryPart part : queryBuilder) {
            part.accept(this, null); // TODO
        }

        return filteredRecords;
    }

    public Object visit(FromPart part, Object current) {
        String fromObject = part.objectType;
        for (SObject currentRecord : this.db.getRecordsById().values()) {
            SObjectType type = currentRecord.getSObjectType();
            if (type.getDescribe().getName().equalsIgnoreCase(fromObject)) {
                filteredRecords.add(currentRecord);
            }
        }

        return filteredRecords;
    }

    public Object visit(SelectPart part, Object current) {
        List<SObject> filteredRecords = new List<SObject>();
        for (SObject currentRecord : this.filteredRecords) {
            SObjectType type = currentRecord.getSObjectType();
            SObjectBuilder builder = SObjectBuilder.of(type);
            for (Field queriedField : part.baseFields()) {
                builder.put(queriedField.getName(), currentRecord.get(queriedField.getName()));
            }

            for (String relationshipName : part.getRelationshipFieldsByRelationshipName().keySet()) {
                List<Field> relationshipFields = part.getRelationshipFieldsByRelationshipName().get(relationshipName);
                SObject relatedRecord = this.db.getParent(currentRecord.Id, relationshipName);
                if (relatedRecord == null) {
                    continue;
                }
                SObjectBuilder relatedRecordBuilder = SObjectBuilder.of(relatedRecord.getSObjectType());
                for (Field relationshipField : relationshipFields) {
                    relatedRecordBuilder.put(relationshipField.getName(), relatedRecord.get(relationshipField.getName()));
                }
                builder.putParent(relationshipName, relatedRecordBuilder);
            }

            filteredRecords.add(builder.build());
        }

        this.filteredRecords = filteredRecords;
        return this.filteredRecords;
    }

    public Object visit(SubselectPart part, Object current) {
        throw new System.QueryException('Not implemented yet');
    }

    public Object visit(LimitPart part, Object current) {
        Integer limitAmount = part.limitAmount;
        for (Integer i = 0; i < filteredRecords.size(); i++) {
            if (i >= limitAmount) {
                filteredRecords.remove(i);
            }
        }

        return filteredRecords;
    }

    public Object visit(EmptyPart part, Object current) {
        return filteredRecords;
    }

    public Object visit(OffsetPart part, Object current) {
        Integer offsetAmount = part.offsetAmount;
        for (Integer i = 0; i < filteredRecords.size(); i++) {
            if (i < offsetAmount) {
                filteredRecords.remove(i);
            }
        }

        return filteredRecords;
    }
}
