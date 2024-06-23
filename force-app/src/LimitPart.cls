public class LimitPart extends QueryBuilder.QueryPart {
  public final Integer limitAmount { get; set; }

  public LimitPart(Integer limitAmount) {
    this.limitAmount = limitAmount;
  }

  public override Object accept(QueryPartVisitor visitor, Object current) {
    return visitor.visit(this, current);
  }
}
