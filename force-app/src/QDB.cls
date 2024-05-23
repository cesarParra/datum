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

        public override List<SObject> query(QueryBuilder queryBuilder) {
            String objectType = queryBuilder.getFrom();
            return Database.query('SELECT Id FROM ' + objectType);
        }
    }

    private class InMemoryDB extends QDB {
        final List<SObject> records = new List<SObject>();
        public override void doInsert(SObject recordToInsert) {
            records.add(recordToInsert);
        }

        public override List<SObject> query(QueryBuilder queryBuilder) {
           List<SObject> filteredRecords = new List<SObject>();
            // filter based on SObjectType

            String fromObject = queryBuilder.getFrom();
            for (SObject currentRecord : records) {
                if (currentRecord.getSObjectType().getDescribe().getName().equalsIgnoreCase(fromObject)) {
                    filteredRecords.add(currentRecord);
                }
            }

            return filteredRecords;
        }
    }


    public abstract void doInsert(SObject recordToInsert);

    public abstract List<SObject> query(QueryBuilder queryBuilder);

    public static void useSystemDB() {
        instance = new SystemDB();
    }
}

