public class Relationship {
    public final Id parentId;
    public final Id childId;
    public final String childToParentRelationshipName;
    public final String parentToChildRelationshipName;

    public Relationship(Id parentId, Id childId, SObjectField field) {
        this.parentId = parentId;
        this.childId = childId;
        this.childToParentRelationshipName = field.getDescribe().getRelationshipName();
        this.parentToChildRelationshipName = parentToChildRelationshipName(field);
    }

    private static String parentToChildRelationshipName(SObjectField field) {
        SObjectType referenceTo = field.getDescribe().getReferenceTo()[0];
        for (ChildRelationship childRel : referenceTo.getDescribe().getChildRelationships()) {
            if (childRel.getField() == field) {
                return childRel.getRelationshipName();
            }
        }
        return '';
    }
}
