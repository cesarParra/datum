public class OffsetPart extends QueryBuilder.QueryPart {
  public final Integer offsetAmount { get; set; }

  public OffsetPart(Integer offsetAmount) {
    this.offsetAmount = offsetAmount;
  }

  public override Object accept(QueryPartVisitor visitor) {
    return visitor.visit(this);
  }
}
