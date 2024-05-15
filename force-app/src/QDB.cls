public abstract class QDB {
    public static QDB getInstance() {
        return new SystemDB();
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


    public abstract void doInsert(SObject recordToInsert);

    public abstract List<SObject> query(QueryBuilder queryBuilder);
}
