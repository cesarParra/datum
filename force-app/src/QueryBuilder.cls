public with sharing class QueryBuilder implements Iterable<QueryPart> {
  private final SObjectType targetType;
  private final List<QueryPart> partsList;

  public abstract class QueryPart {
    public abstract Object accept(QueryPartVisitor visitor);
  }

  private QueryBuilder(String objectType) {
    this.targetType = Schema.getGlobalDescribe().get(objectType);
    this.partsList = new List<QueryPart>{
      new FromPart(objectType), // 0
      new SelectPart(targetType, new Set<String>{ 'Id' }), // 1
      new EmptyPart(Parts.WHERE_PART), // WHERE CLAUSE // 2
      new EmptyPart(Parts.ORDER_BY_PART), // ORDER BY // 3
      new LimitPart(null), // LIMIT // 4
      new EmptyPart(Parts.OFFSET_PART) // OFFSET // 5
    };
  }

  public static QueryBuilder of(String objectType) {
    return new QueryBuilder(objectType);
  }

  public QueryBuilder selectFields(Set<String> fields) {
    if (fields == null) {
      return this;
    }
    for (String field : fields) {
      this.selectField(field);
    }
    return this;
  }

  public QueryBuilder selectField(String fieldName) {
    if (fieldName == null) {
      return this;
    }
    SelectPart selectPart = (SelectPart) this.partsList[1];
    selectPart.add(fieldName);
    return this;
  }

  public QueryBuilder withLimitAmount(Integer limitAmount) {
    LimitPart part = new LimitPart(limitAmount);
    this.partsList[4] = part;
    return this;
  }

  public QueryBuilder withOffsetAmount(Integer offsetAmount) {
    OffsetPart part = new OffsetPart(offsetAmount);
    this.partsList[5] = part;
    return this;
  }

  public Iterator<QueryBuilder.QueryPart> iterator() {
    return this.partsList.iterator();
  }
}
