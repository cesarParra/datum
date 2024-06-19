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
}
