public class SystemDB extends QDB implements QueryPartVisitor {
  private static final Map<Parts, String> REPLACER_BY_PART = new Map<Parts, String>{
    Parts.FROM_PART => '{0}',
    Parts.SELECT_PART => '{1}',
    Parts.SUBSELECT_PART => '{6}',
    Parts.WHERE_PART => '{2}',
    Parts.ORDER_BY_PART => '{3}',
    Parts.LIMIT_PART => '{4}',
    Parts.OFFSET_PART => '{5}'
  };

  public override void doInsert(SObject recordToInsert) {
    Database.insert(recordToInsert);
  }

  public override void doInsert(List<SObject> recordsToInsert) {
    Database.insert(recordsToInsert);
  }

  private String buildQuery(QueryBuilder queryBuilder) {
    String query = 'SELECT {1}{6} FROM {0}{4}{5}';
    for (QueryBuilder.QueryPart part : queryBuilder) {
      query = (String) part.accept(this, query);
    }
    return query;
  }

  public override List<SObject> query(QueryBuilder queryBuilder) {
    return Database.query(buildQuery(queryBuilder));
  }

  public Object visit(SelectPart part, Object current) {
    return currentToString(current).replace(
      '{1}',
      String.join(part.toSet(), ',')
    );
  }

  public Object visit(SubselectPart part, Object current) {
    String result = ',';
    for (QueryBuilder subquery : part.subqueries) {
      result += '(' + this.buildQuery(subquery) + '),';
    }
    // remove trailing comma
    result = result.substring(0, result.length() - 1);
    return currentToString(current).replace('{6}', result);
  }

  public Object visit(LimitPart part, Object current) {
    String result = part.limitAmount != null
      ? ' LIMIT ' + part.limitAmount
      : '';
    return currentToString(current).replace('{4}', result);
  }

  public Object visit(FromPart part, Object current) {
    return currentToString(current).replace('{0}', part.objectType);
  }

  public Object visit(EmptyPart part, Object current) {
    return currentToString(current).replace(
      REPLACER_BY_PART.get(part.partType),
      ''
    );
  }

  public Object visit(OffsetPart part, Object current) {
    String result = part.offsetAmount != null
      ? ' OFFSET ' + part.offsetAmount
      : '';
    return currentToString(current).replace('{5}', result);
  }

  private static String currentToString(Object current) {
    return (String) current;
  }
}
