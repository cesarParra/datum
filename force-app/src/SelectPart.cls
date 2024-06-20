public class SelectPart extends QueryBuilder.QueryPart {
    private final SObjectType objectType;
    public final Set<Field> fields { get; set; }

    public SelectPart(SObjectType objectType, Set<String> initialFields) {
        this.objectType = objectType;
        this.fields = new Set<Field>();
        for (String fieldAsString : initialFields) {
            this.add(fieldAsString);
        }
    }

    public void add(String field) {
        this.fields.add(new Field(this.objectType, field));
    }

    public override Object accept(QueryPartVisitor visitor) {
        return visitor.visit(this);
    }

    public Set<String> toSet() {
        Set<String> fieldNames = new Set<String>();
        for (Field field : this.fields) {
            fieldNames.add(field.getFullName());
        }
        return fieldNames;
    }

    public Map<String, List<Field>> getRelationshipFieldsByRelationshipName() {
        Map<String, List<Field>> relationshipFields = new Map<String, List<Field>>();
        for (Field field : this.fields) {
            if (field.isRelationship()) {
                String relationshipName = field.getRelationship().relationName;
                if (!relationshipFields.containsKey(relationshipName)) {
                    relationshipFields.put(relationshipName, new List<Field>());
                }
                relationshipFields.get(relationshipName).add(field);
            }
        }
        return relationshipFields;
    }

    public Set<Field> baseFields() {
        // return all non-relational fields
        Set<Field> baseFields = new Set<Field>();
        for (Field field : this.fields) {
            if (!field.isRelationship()) {
                baseFields.add(field);
            }
        }
        return baseFields;
    }
}
