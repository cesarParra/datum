public abstract class QueryPart {
    public abstract Object accept(QueryPartVisitor visitor, Object current);
}
