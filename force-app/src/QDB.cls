public with sharing class QDB {
    public static void doInsert(SObject recordToInsert) {
        Database.insert(recordToInsert);
    }

    public static List<SObject> query(QueryBuilder queryBuilder) {
        String objectType = queryBuilder.getFrom();
        return Database.query('SELECT Id FROM ' + objectType);
    }
}
