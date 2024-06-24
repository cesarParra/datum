public class EmptyPart extends QueryPart {
  public Parts partType { get; set; }

  public EmptyPart(Parts partType) {
    this.partType = partType;
  }

  public override Object accept(QueryPartVisitor visitor, Object current) {
    return visitor.visit(this, current);
  }
}
