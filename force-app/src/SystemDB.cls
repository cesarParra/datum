public class SystemDB extends QDB {
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
