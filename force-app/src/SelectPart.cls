public class SelectPart extends QueryBuilder.QueryPart {
    public final Set<Field> fields { get; set; }

    public SelectPart(SObjectType parentType, Set<String> fields) {
        this.fields = new Set<Field>();
        for (String fieldAsString : fields) {
            this.fields.add(new Field(parentType, fieldAsString));
        }
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

    public Map<SObjectType, List<Field>> relationshipFields() {
        Map<SObjectType, List<Field>> relationshipFields = new Map<SObjectType, List<Field>>();
        for (Field field : this.fields) {
            if (field.isRelationship()) {
                if (!relationshipFields.containsKey(field.getRelationshipType())) {
                    relationshipFields.put(field.getRelationshipType(), new List<Field>());
                }
                relationshipFields.get(field.getRelationshipType()).add(field);
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
