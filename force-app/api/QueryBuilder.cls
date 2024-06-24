/**
 * @description A class for building SOQL queries in Apex.
 * @example
 * QueryBuilder query = QueryBuilder.of('Account')
 *   .selectFields(new Set<String>{ 'Name', 'Id' })
 *   .subselect(
 *     QueryBuilder.of('Contacts')
 *     .selectFields(new Set<String>{ 'Name', 'Id' })
 *     .withLimitAmount(10)
 *   )
 */
public with sharing class QueryBuilder implements Iterable<QueryPart> {
  private final SObjectType targetType;
  private final Map<Parts, QueryPart> partsList;

  private QueryBuilder(String fromIdentifier) {
    this.targetType = Schema.getGlobalDescribe().get(fromIdentifier);
    this.partsList = new Map<Parts, QueryPart>{
      Parts.FROM_PART => new FromPart(fromIdentifier),
      Parts.SELECT_PART => new SelectPart(targetType, new Set<String>{ 'Id' }),
      Parts.SUBSELECT_PART => new EmptyPart(Parts.SUBSELECT_PART),
      Parts.WHERE_PART => new EmptyPart(Parts.WHERE_PART),
      Parts.ORDER_BY_PART => new EmptyPart(Parts.ORDER_BY_PART),
      Parts.LIMIT_PART => new LimitPart(null),
      Parts.OFFSET_PART => new EmptyPart(Parts.OFFSET_PART)
    };
  }

  /**
   * @description Creates a new QueryBuilder object with the specified object type.
   * @param objectType The object type to query.
   *                   When querying a child object, use the relationship name.
   * @return A new QueryBuilder object.
   */
  public static QueryBuilder of(String objectType) {
    return new QueryBuilder(objectType);
  }

  /**
   * @description Adds a set of fields to the SELECT clause of the query.
   * @param fields A set of field names to add to the SELECT clause.
   * @return The QueryBuilder object.
   */
  public QueryBuilder selectFields(Set<String> fields) {
    if (fields == null) {
      return this;
    }
    for (String field : fields) {
      this.selectField(field);
    }
    return this;
  }

  /**
   * @description Adds a field to the SELECT clause of the query.
   * @param fieldName The field name to add to the SELECT clause.
   * @return The QueryBuilder object.
   */
  public QueryBuilder selectField(String fieldName) {
    if (fieldName == null) {
      return this;
    }
    SelectPart selectPart = (SelectPart) this.partsList.get(Parts.SELECT_PART);
    selectPart.add(fieldName);
    return this;
  }

  /**
   * @description Adds a subquery to the query.
   * @param subquery The subquery to add to the query.
   * @return The QueryBuilder object.
   */
  public QueryBuilder subselect(QueryBuilder subquery) {
    QueryPart subselectPart = this.partsList.get(Parts.SUBSELECT_PART);
    SubselectPart part;
    if (subselectPart instanceof EmptyPart) {
      part = new SubselectPart();
    } else {
      part = (SubselectPart) subselectPart;
    }

    ChildRelationship relationship = SObjectDescribeUtil.getRelationship(
      this.targetType,
      subquery.getFrom()
    );
    FromPart subQueryFrom = (FromPart) subquery.partsList.get(Parts.FROM_PART);
    subQueryFrom.setTargetType(relationship.getChildSObject());

    part.add(subquery);
    this.partsList.put(Parts.SUBSELECT_PART, part);
    return this;
  }

  /**
   * @description Sets the maximum number of records to return.
   * @param limitAmount The maximum number of records to return.
   * @return The QueryBuilder object.
   */
  public QueryBuilder withLimitAmount(Integer limitAmount) {
    LimitPart part = new LimitPart(limitAmount);
    this.partsList.put(Parts.LIMIT_PART, part);
    return this;
  }

  /**
   * @description Sets the offset amount for the query.
   * @param offsetAmount The offset amount for the query.
   * @return The QueryBuilder object.
   */
  public QueryBuilder withOffsetAmount(Integer offsetAmount) {
    OffsetPart part = new OffsetPart(offsetAmount);
    this.partsList.put(Parts.OFFSET_PART, part);
    return this;
  }

  /**
   * @return The FROM part of the query.
   * @ignore
   */
  public String getFrom() {
    return ((FromPart) this.partsList.get(Parts.FROM_PART)).fromIdentifier;
  }

  /**
   * @description Returns an iterator over the QueryParts in this QueryBuilder.
   * @return Iterator<QueryPart>
   * @ignore
   */
  public Iterator<QueryPart> iterator() {
    return this.partsList.values().iterator();
  }
}
