public abstract class QDB {
    private static QDB instance;
    public static QDB getInstance() {
        if (instance != null) {
            return instance;
        }

        if (instance == null && Test.isRunningTest()) {
            instance = new InMemoryDB();
        } else {
            instance = new SystemDB();
        }

        return instance;
    }

    private class SystemDB extends QDB {
        public override void doInsert(SObject recordToInsert) {
            Database.insert(recordToInsert);
        }

        public override void doInsert(List<SObject> recordsToInsert) {
            Database.insert(recordsToInsert);
        }

        public override List<SObject> query(QueryBuilder queryBuilder) {
            String objectType = queryBuilder.getFrom();
            String fieldString = String.join(queryBuilder.getFields(), ',');

            String query = 'SELECT ' + fieldString + ' FROM ' + objectType;
            if (queryBuilder.getLimitAmount() != null) {
                query += ' LIMIT ' + queryBuilder.getLimitAmount();
            }

            return Database.query(query);
        }
    }

    private class InMemoryDB extends QDB {
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
            List<SObject> filteredRecords = new List<SObject>();
            String fromObject = queryBuilder.getFrom();
            for (SObject currentRecord : records) {
                SObjectType type = currentRecord.getSObjectType();
                if (type.getDescribe().getName().equalsIgnoreCase(fromObject)) {
                    SObjectBuilder builder = SObjectBuilder.of(type);

                    for (String queriedField : queryBuilder.getFields()) {
                        builder.put(queriedField, currentRecord.get(queriedField));
                    }

                    filteredRecords.add(builder.build());
                }
            }

            return filteredRecords;
        }
    }

    public abstract void doInsert(SObject recordToInsert);
    public abstract void doInsert(List<SObject> recordsToInsert);

    public abstract List<SObject> query(QueryBuilder queryBuilder);

    public static void useSystemDB() {
        instance = new SystemDB();
    }
}

