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
            query += (String)part.accept(this);
        }

        return Database.query(query);
    }

    public Object visit(QueryBuilder.SelectPart part) {
        return 'SELECT ' + String.join(part.fields, ',');
    }

    public Object visit(QueryBuilder.LimitPart part) {
        return part.limitAmount != null ? ' LIMIT ' + part.limitAmount : '';
    }

    public Object visit(QueryBuilder.FromPart part) {
        return ' FROM ' + part.objectType;
    }

    public Object visit(QueryBuilder.EmptyPart part) {
        return '';
    }
}
