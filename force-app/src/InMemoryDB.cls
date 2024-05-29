public class InMemoryDB extends QDB {
    final List<SObject> records = new List<SObject>();
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
        Integer limitAmount = queryBuilder.getLimitAmount();
        List<SObject> filteredRecords = new List<SObject>();
        String fromObject = queryBuilder.getFrom();
        for (SObject currentRecord : records) {
            SObjectType type = currentRecord.getSObjectType();
            if (type.getDescribe().getName().equalsIgnoreCase(fromObject)) {
                SObjectBuilder builder = SObjectBuilder.of(type);

                for (String queriedField : queryBuilder.getFields()) {
                    builder.put(queriedField, currentRecord.get(queriedField));
                }

                if (limitAmount == null || filteredRecords.size() < limitAmount) {
                    filteredRecords.add(builder.build());
                }
            }
        }

        return filteredRecords;
    }
}
