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

    public abstract void doInsert(SObject recordToInsert);
    public abstract void doInsert(List<SObject> recordsToInsert);

    public abstract List<SObject> query(QueryBuilder queryBuilder);

    public static void useSystemDB() {
        instance = new SystemDB();
    }
}

