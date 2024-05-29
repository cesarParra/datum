public with sharing class QueryBuilder {
    private final List<QueryPart> parts;

    public abstract class QueryPart {}

    public class SelectPart extends QueryPart {
        public final Set<String> fields { get; set; }

        public SelectPart(Set<String> fields) {
            this.fields = fields;
        }
    }

    public class LimitPart extends QueryPart {
        public final Integer limitAmount { get; set; }

        public LimitPart(Integer limitAmount) {
            this.limitAmount = limitAmount;
        }
    }

    public class FromPart extends QueryPart {
        public final String objectType { get; set; }

        public FromPart(String objectType) {
            this.objectType = objectType;
        }
    }

    public class EmptyPart extends QueryPart {}

    private QueryBuilder(String objectType) {
        this.parts = new List<QueryPart> {
            new FromPart(objectType), // 0
            new SelectPart(new Set<String>{ 'Id' }), // 1
            new EmptyPart(), // WHERE CLAUSE // 2
            new EmptyPart(), // ORDER BY // 3
            new LimitPart(null), // LIMIT // 4
            new EmptyPart() // OFFSET // 5
        };
    }

    public static QueryBuilder of(String objectType) {
        return new QueryBuilder(objectType);
    }

    public QueryBuilder selectFields(Set<String> fields) {
        Set<String> fieldsToAdd = fields ?? new Set<String>();
        SelectPart selectPart = (SelectPart)this.parts[1];
        selectPart.fields.addAll(fieldsToAdd);
        return this;
    }

    public QueryBuilder selectField(String fieldName) {
        SelectPart selectPart = (SelectPart)this.parts[1];
        selectPart.fields.add(fieldName);
        return this;
    }

    public QueryBuilder withLimitAmount(Integer limitAmount) {
        LimitPart part = new LimitPart(limitAmount);
        this.parts[4] = part;
        return this;
    }

    // Getters

    public FromPart getFrom() {
        return (FromPart)this.parts[0];
    }

    public SelectPart getSelectPart() {
        return (SelectPart)this.parts[1];
    }

    public LimitPart getLimitAmount() {
        return (LimitPart)this.parts[4];
    }
}
