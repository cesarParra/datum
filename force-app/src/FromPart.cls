public class FromPart extends QueryBuilder.QueryPart {
  public final String objectType { get; set; }

  public FromPart(String objectType) {
    this.objectType = objectType;
  }

  public override Object accept(QueryPartVisitor visitor) {
    return visitor.visit(this);
  }
}
