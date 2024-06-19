public class SelectPart extends QueryBuilder.QueryPart {
  public final Set<String> fields { get; set; }

  public SelectPart(Set<String> fields) {
    this.fields = fields;
  }

  public override Object accept(QueryPartVisitor visitor) {
    return visitor.visit(this);
  }
}
