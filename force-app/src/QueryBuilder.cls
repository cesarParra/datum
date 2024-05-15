public with sharing class QueryBuilder {
    private final String objectType;

    private QueryBuilder(String objectType) {
        this.objectType = objectType;
    }

    public static QueryBuilder of(String objectType) {
        return new QueryBuilder(objectType);
    }

    public String getFrom() {
        return objectType;
    }
}
