public abstract class QDB {
    private static QDB instance;
    public static QDB getInstance() {
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
        public override void doInsert(SObject recordToInsert) {
        }

        public override List<SObject> query(QueryBuilder queryBuilder) {
            return null;
        }
    }


    public abstract void doInsert(SObject recordToInsert);

    public abstract List<SObject> query(QueryBuilder queryBuilder);

    public static void useSystemDB() {
        instance = new SystemDB();
    }
}

