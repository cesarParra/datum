public with sharing class SubselectPart extends QueryPart {

    public final List<QueryBuilder> subqueries;

    public SubselectPart() {
        this.subqueries = new List<QueryBuilder>();
    }

    public void add(QueryBuilder subquery) {
        this.subqueries.add(subquery);
    }

    public override Object accept(QueryPartVisitor visitor, Object current) {
        return visitor.visit(this, current);
    }
}
