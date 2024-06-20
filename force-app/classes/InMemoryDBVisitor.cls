
public with sharing class InMemoryDBVisitor implements QueryPartVisitor {
    private final InMemoryDB db;
    List<SObject> filteredRecords = null;

    public InMemoryDBVisitor(InMemoryDB db) {
        this.db = db;
    }

    public List<SObject> query(QueryBuilder queryBuilder) {
        this.filteredRecords = new List<SObject>();
        for (QueryBuilder.QueryPart part : queryBuilder) {
            part.accept(this);
        }

        return filteredRecords;
    }

    public Object visit(FromPart part) {
        String fromObject = part.objectType;
        for (SObject currentRecord : this.db.getRecordsById().values()) {
            SObjectType type = currentRecord.getSObjectType();
            if (type.getDescribe().getName().equalsIgnoreCase(fromObject)) {
                filteredRecords.add(currentRecord);
            }
        }

        return filteredRecords;
    }

    public Object visit(SelectPart part) {
        List<SObject> filteredRecords = new List<SObject>();
        for (SObject currentRecord : this.filteredRecords) {
            SObjectType type = currentRecord.getSObjectType();
            SObjectBuilder builder = SObjectBuilder.of(type);
            for (SObjectType relationshipType : part.relationshipFields().keySet()) {
                SObjectBuilder parentBuilder = SObjectBuilder.of(relationshipType);
                // TODO: Add relationships.
                builder.putParent('Parent', parentBuilder);
            }

            for (Field queriedField : part.baseFields()) {
                builder.put(queriedField.getName(), currentRecord.get(queriedField.getName()));
            }

            filteredRecords.add(builder.build());
        }

        this.filteredRecords = filteredRecords;
        return this.filteredRecords;
    }

    public Object visit(LimitPart part) {
        Integer limitAmount = part.limitAmount;
        for (Integer i = 0; i < filteredRecords.size(); i++) {
            if (i >= limitAmount) {
                filteredRecords.remove(i);
            }
        }

        return filteredRecords;
    }

    public Object visit(EmptyPart part) {
        return filteredRecords;
    }

    public Object visit(OffsetPart part) {
        Integer offsetAmount = part.offsetAmount;
        for (Integer i = 0; i < filteredRecords.size(); i++) {
            if (i < offsetAmount) {
                filteredRecords.remove(i);
            }
        }

        return filteredRecords;
    }
}