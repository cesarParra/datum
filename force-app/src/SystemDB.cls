public class SystemDB extends QDB {
    public override void doInsert(SObject recordToInsert) {
        Database.insert(recordToInsert);
    }

    public override void doInsert(List<SObject> recordsToInsert) {
        Database.insert(recordsToInsert);
    }

    public override List<SObject> query(QueryBuilder queryBuilder) {
        String objectType = ((QueryBuilder.FromPart)queryBuilder.getFrom()).objectType;
        String fieldString = String.join(((QueryBuilder.SelectPart)queryBuilder.getSelectPart()).fields, ',');

        String query = 'SELECT ' + fieldString + ' FROM ' + objectType;
        Integer limitAmount = ((QueryBuilder.LimitPart)queryBuilder.getLimitAmount()).limitAmount;
        if (limitAmount != null) {
            query += ' LIMIT ' + limitAmount;
        }

        return Database.query(query);
    }
}
