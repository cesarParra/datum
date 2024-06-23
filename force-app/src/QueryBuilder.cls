public with sharing class QueryBuilder implements Iterable<QueryPart> {
  private final SObjectType targetType;
  private final Map<Parts, QueryPart> partsList;

  public abstract class QueryPart {
    public abstract Object accept(QueryPartVisitor visitor, Object current);
  }

  private QueryBuilder(String objectType) {
    this.targetType = Schema.getGlobalDescribe().get(objectType);
    this.partsList = new Map<Parts, QueryPart>{
      Parts.FROM_PART => new FromPart(objectType),
      Parts.SELECT_PART => new SelectPart(targetType, new Set<String>{ 'Id' }),
      Parts.SUBSELECT_PART => new EmptyPart(Parts.SUBSELECT_PART),
      Parts.WHERE_PART => new EmptyPart(Parts.WHERE_PART),
      Parts.ORDER_BY_PART => new EmptyPart(Parts.ORDER_BY_PART),
      Parts.LIMIT_PART => new LimitPart(null),
      Parts.OFFSET_PART => new EmptyPart(Parts.OFFSET_PART)
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
    SelectPart selectPart = (SelectPart) this.partsList.get(Parts.SELECT_PART);
    selectPart.add(fieldName);
    return this;
  }

  public QueryBuilder subselect(QueryBuilder subquery) {
    QueryPart subselectPart = this.partsList.get(Parts.SUBSELECT_PART);
    SubselectPart part;
    if (subselectPart instanceof EmptyPart) {
       part = new SubselectPart();
    } else {
      part = (SubselectPart) subselectPart;
    }
    part.add(subquery);
    this.partsList.put(Parts.SUBSELECT_PART, part);
    return this;
  }

  public QueryBuilder withLimitAmount(Integer limitAmount) {
    LimitPart part = new LimitPart(limitAmount);
    this.partsList.put(Parts.LIMIT_PART, part);
    return this;
  }

  public QueryBuilder withOffsetAmount(Integer offsetAmount) {
    OffsetPart part = new OffsetPart(offsetAmount);
    this.partsList.put(Parts.OFFSET_PART, part);
    return this;
  }

  public Iterator<QueryBuilder.QueryPart> iterator() {
    return this.partsList.values().iterator();
  }
}
