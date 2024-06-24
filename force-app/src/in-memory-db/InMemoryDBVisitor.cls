public with sharing class InMemoryDBVisitor implements QueryPartVisitor {
    private final InMemoryDB db;

    public InMemoryDBVisitor(InMemoryDB db) {
        this.db = db;
    }

    public List<SObject> query(QueryBuilder queryBuilder) {
        List<SObject> filteredRecords = new List<SObject>();
        for (QueryPart part : queryBuilder) {
            filteredRecords = (List<SObject>)part.accept(this, filteredRecords);
        }

        return filteredRecords;
    }

    private static List<SObject> toList(Object current) {
        return (List<SObject>)current;
    }

    public Object visit(FromPart part, Object ignored) {
        List<SObject> filtered = new List<SObject>();
        String fromObject = part.objectType;
        for (SObject currentRecord : this.db.getRecordsById().values()) {
            SObjectType type = currentRecord.getSObjectType();
            if (type.getDescribe().getName().equalsIgnoreCase(fromObject)) {
                filtered.add(currentRecord);
            }
        }

        return filtered;
    }

    public Object visit(SelectPart part, Object current) {
        List<SObject> filteredRecords = new List<SObject>();
        for (SObject currentRecord : toList(current)) {
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

        return filteredRecords;
    }

    public Object visit(SubselectPart part, Object current) {
        throw new System.QueryException('Not implemented yet');
    }

    public Object visit(LimitPart part, Object current) {
        List<SObject> filtered = toList(current).clone();
        Integer limitAmount = part.limitAmount;
        for (Integer i = 0; i < filtered.size(); i++) {
            if (i >= limitAmount) {
                filtered.remove(i);
            }
        }

        return filtered;
    }

    public Object visit(EmptyPart part, Object current) {
        return toList(current).clone();
    }

    public Object visit(OffsetPart part, Object current) {
        List<SObject> filteredRecords = toList(current).clone();
        Integer offsetAmount = part.offsetAmount;
        for (Integer i = 0; i < filteredRecords.size(); i++) {
            if (i < offsetAmount) {
                filteredRecords.remove(i);
            }
        }

        return filteredRecords;
    }
}
