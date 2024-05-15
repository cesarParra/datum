public with sharing class QueryBuilder {
    public static QueryBuilder of(String objectType) {
        return new QueryBuilder();
    }

    public List<Account> query(QueryBuilder queryBuilder) {
        return [SELECT Id FROM Account];
    }
}
