public with sharing class QueryBuilder {
    private final String objectType;
    private final Set<String> fields;

    private QueryBuilder(String objectType) {
        this.objectType = objectType;
        fields = new Set<String>{'Id'};
    }

    public static QueryBuilder of(String objectType) {
        return new QueryBuilder(objectType);
    }

    public QueryBuilder selectFields(Set<String> fields) {
        Set<String> fieldsToAdd = fields ?? new Set<String>();
        this.fields.addAll(fieldsToAdd);
        return this;
    }

    public String getFrom() {
        return objectType;
    }

    public Set<String> getFields() {
        return fields;
    }
}
