public with sharing class QueryBuilder implements Iterable<QueryPart> {
  private final List<QueryPart> parts;

  public abstract class QueryPart {
    public abstract Object accept(QueryPartVisitor visitor);
  }

  private QueryBuilder(String objectType) {
    this.parts = new List<QueryPart>{
      new FromPart(objectType), // 0
      new SelectPart(new Set<String>{ 'Id' }), // 1
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
    Set<String> fieldsToAdd = fields ?? new Set<String>();
    SelectPart selectPart = (SelectPart) this.parts[1];
    selectPart.fields.addAll(fieldsToAdd);
    return this;
  }

  public QueryBuilder selectField(String fieldName) {
    SelectPart selectPart = (SelectPart) this.parts[1];
    selectPart.fields.add(fieldName);
    return this;
  }

  public QueryBuilder withLimitAmount(Integer limitAmount) {
    LimitPart part = new LimitPart(limitAmount);
    this.parts[4] = part;
    return this;
  }

  public QueryBuilder withOffsetAmount(Integer offsetAmount) {
    OffsetPart part = new OffsetPart(offsetAmount);
    this.parts[5] = part;
    return this;
  }

  public Iterator<QueryBuilder.QueryPart> iterator() {
    return this.parts.iterator();
  }
}
