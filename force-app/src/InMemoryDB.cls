public class InMemoryDB extends QDB implements QueryBuilder.QueryPartVisitor {
    final List<SObject> records = new List<SObject>();
    List<SObject> filteredRecords = null;

    public override void doInsert(SObject recordToInsert) {
        recordToInsert.Id = IdGenerator.generate(recordToInsert.getSObjectType());
        records.add(recordToInsert);
    }

    public override void doInsert(List<SObject> recordsToInsert) {
        for (SObject record : recordsToInsert) {
            doInsert(record);
        }
    }

    public override List<SObject> query(QueryBuilder queryBuilder) {
        this.filteredRecords = new List<SObject>();
        for (QueryBuilder.QueryPart part : queryBuilder) {
            part.accept(this);
        }

        return filteredRecords;
    }

    public Object visit(QueryBuilder.FromPart part) {
        String fromObject = part.objectType;
        for (SObject currentRecord : records) {
            SObjectType type = currentRecord.getSObjectType();
            if (type.getDescribe().getName().equalsIgnoreCase(fromObject)) {
                filteredRecords.add(currentRecord);
            }
        }

        return filteredRecords;
    }

    public Object visit(QueryBuilder.SelectPart part) {
        List<SObject> filteredRecords = new List<SObject>();
        for (SObject currentRecord : this.filteredRecords) {
            SObjectType type = currentRecord.getSObjectType();
            SObjectBuilder builder = SObjectBuilder.of(type);
            for (String queriedField : part.fields) {
                builder.put(queriedField, currentRecord.get(queriedField));
            }

            filteredRecords.add(builder.build());
        }

        this.filteredRecords = filteredRecords;
        return this.filteredRecords;
    }

    public Object visit(QueryBuilder.LimitPart part) {
        Integer limitAmount = part.limitAmount;
        for (Integer i = 0; i < filteredRecords.size(); i++) {
            if (i >= limitAmount) {
                filteredRecords.remove(i);
            }
        }

        return filteredRecords;
    }

    public Object visit(QueryBuilder.EmptyPart part) {
        return filteredRecords;
    }

    public Object visit(QueryBuilder.OffsetPart part) {
        Integer offsetAmount = part.offsetAmount;
        for (Integer i = 0; i < filteredRecords.size(); i++) {
            if (i < offsetAmount) {
                filteredRecords.remove(i);
            }
        }

        return filteredRecords;
    }
}
