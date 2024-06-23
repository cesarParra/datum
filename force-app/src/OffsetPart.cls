public class OffsetPart extends QueryBuilder.QueryPart {
  public final Integer offsetAmount { get; set; }

  public OffsetPart(Integer offsetAmount) {
    this.offsetAmount = offsetAmount;
  }

  public override Object accept(QueryPartVisitor visitor, Object current) {
    return visitor.visit(this, current);
  }
}
