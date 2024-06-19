public class SystemDB extends QDB implements QueryPartVisitor {
  private static final Map<Parts, String> REPLACER_BY_PART = new Map<Parts, String>{
    Parts.FROM_PART => '{0}',
    Parts.SELECT_PART => '{1}',
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

  public override List<SObject> query(QueryBuilder queryBuilder) {
    String query = '';

    for (QueryBuilder.QueryPart part : queryBuilder) {
      String result = (String) part.accept(this);
      if (result != null) {
        query = result;
      }
    }

    return Database.query(query);
  }

  private String currentQuery = 'SELECT {1} FROM {0}{4}{5}';

  public Object visit(SelectPart part) {
    this.currentQuery = currentQuery.replace(
      '{1}',
      String.join(part.toSet(), ',')
    );
    return this.currentQuery;
  }

  public Object visit(LimitPart part) {
    String result = part.limitAmount != null
      ? ' LIMIT ' + part.limitAmount
      : '';
    this.currentQuery = currentQuery.replace('{4}', result);
    return this.currentQuery;
  }

  public Object visit(FromPart part) {
    this.currentQuery = currentQuery.replace('{0}', part.objectType);
    return this.currentQuery;
  }

  public Object visit(EmptyPart part) {
    this.currentQuery = currentQuery.replace(
      REPLACER_BY_PART.get(part.partType),
      ''
    );
    return this.currentQuery;
  }

  public Object visit(OffsetPart part) {
    String result = part.offsetAmount != null
      ? ' OFFSET ' + part.offsetAmount
      : '';
    this.currentQuery = currentQuery.replace('{5}', result);
    return this.currentQuery;
  }
}
