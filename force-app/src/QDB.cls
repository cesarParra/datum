public with sharing class QDB {
    public static void doInsert(SObject recordToInsert) {
        insert recordToInsert;
    }

    public static List<SObject> query(QueryBuilder queryBuilder) {
//        String objectType = queryBuilder.getFrom();
        return [SELECT Id FROM Account];
    }
}
