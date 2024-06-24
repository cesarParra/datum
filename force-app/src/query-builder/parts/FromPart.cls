public class FromPart extends QueryPart {
  public final String objectType { get; set; }

  public FromPart(String objectType) {
    this.objectType = objectType;
  }

  public override Object accept(QueryPartVisitor visitor, Object current) {
    return visitor.visit(this, current);
  }
}
