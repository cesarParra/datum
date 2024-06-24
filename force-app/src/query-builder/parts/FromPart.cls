public class FromPart extends QueryPart {
  public SObjectType targetType { get; private set; }
  public final String fromIdentifier { get; set; }

  public FromPart(String fromIdentifier) {
    this.fromIdentifier = fromIdentifier;
  }

  public override Object accept(QueryPartVisitor visitor, Object current) {
    return visitor.visit(this, current);
  }

  public void setTargetType(SObjectType targetType) {
    this.targetType = targetType;
  }

  public String getTargetSObjectTypeName() {
    if (this.targetType == null) {
      return fromIdentifier;
    }
    return this.targetType.getDescribe().getName();
  }
}
