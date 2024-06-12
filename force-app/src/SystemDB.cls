public class SystemDB extends QDB implements QueryBuilder.QueryPartVisitor {
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
            if(result != null) {
                query = result;
            }
        }

        return Database.query(query);
    }

    private String currentQuery = 'SELECT {1} FROM {0}{4}{5}';

    public Object visit(QueryBuilder.SelectPart part) {
        this.currentQuery = currentQuery.replace('{1}', String.join(part.fields, ','));
        return this.currentQuery;
    }

    public Object visit(QueryBuilder.LimitPart part) {
        String result = part.limitAmount != null ? ' LIMIT ' + part.limitAmount : '';
        this.currentQuery = currentQuery.replace('{4}', result);
        return this.currentQuery;
    }

    public Object visit(QueryBuilder.FromPart part) {
        this.currentQuery = currentQuery.replace('{0}', part.objectType);
        return this.currentQuery;
    }

    public Object visit(QueryBuilder.EmptyPart part) {
        this.currentQuery = currentQuery.replace(part.replacer, '');
        return this.currentQuery;
    }

    public Object visit(QueryBuilder.OffsetPart part) {
        String result = part.offsetAmount != null ? ' OFFSET ' + part.offsetAmount : '';
        this.currentQuery = currentQuery.replace('{5}', result);
        return this.currentQuery;
    }
}
