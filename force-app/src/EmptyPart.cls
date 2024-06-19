public class EmptyPart extends QueryBuilder.QueryPart {
  public Parts partType { get; set; }

  public EmptyPart(Parts partType) {
    this.partType = partType;
  }

  public override Object accept(QueryPartVisitor visitor) {
    return visitor.visit(this);
  }
}
