public with sharing class InMemoryDBVisitor implements QueryPartVisitor {
  private final InMemoryDB db;

  public InMemoryDBVisitor(InMemoryDB db) {
    this.db = db;
  }

  public List<SObject> query(QueryBuilder queryBuilder) {
    List<SObject> builtRecords = new List<SObject>();
    for (SObjectBuilder record : buildSObjectBuilders(queryBuilder)) {
      builtRecords.add(record.build());
    }

    return builtRecords;
  }

  private List<SObjectBuilder> buildSObjectBuilders(QueryBuilder queryBuilder) {
    List<SObjectBuilder> filteredRecords = new List<SObjectBuilder>();
    for (QueryPart part : queryBuilder) {
      filteredRecords = (List<SObjectBuilder>) part.accept(
        this,
        filteredRecords
      );
    }
    return filteredRecords;
  }

  private static List<SObjectBuilder> toList(Object current) {
    return (List<SObjectBuilder>) current;
  }

  public Object visit(FromPart part, Object ignored) {
    List<SObjectBuilder> filtered = new List<SObjectBuilder>();
    String fromObject = part.getTargetSObjectTypeName();
    for (SObject currentRecord : this.db.getRecordsById().values()) {
      SObjectType type = currentRecord.getSObjectType();
      if (type.getDescribe().getName().equalsIgnoreCase(fromObject)) {
        SObjectBuilder builder = SObjectBuilder.of(type);
        builder.RecordId = currentRecord.Id;
        filtered.add(builder);
      }
    }

    return filtered;
  }

  public Object visit(SelectPart part, Object current) {
    List<SObjectBuilder> filteredRecords = new List<SObjectBuilder>();
    for (SObjectBuilder currentBuilder : toList(current)) {
      SObject recordInDatabase = this.db.getRecordsById()
        .get(currentBuilder.RecordId);
      for (Field queriedField : part.baseFields()) {
        currentBuilder.put(
          queriedField.getName(),
          recordInDatabase.get(queriedField.getName())
        );
      }

      for (
        String relationshipName : part.getRelationshipFieldsByRelationshipName()
          .keySet()
      ) {
        SObjectBuilder relatedRecordBuilder = getParentSObjectBuilder(
          part,
          relationshipName,
          currentBuilder
        );
        if (relatedRecordBuilder != null) {
          currentBuilder.putParent(relationshipName, relatedRecordBuilder);
        }
      }

      filteredRecords.add(currentBuilder);
    }

    return filteredRecords;
  }

  private SObjectBuilder getParentSObjectBuilder(
    SelectPart part,
    String relationshipName,
    SObjectBuilder currentBuilder
  ) {
    List<Field> relationshipFields = part.getRelationshipFieldsByRelationshipName()
      .get(relationshipName);
    SObject relatedRecord = this.db.getParent(
      currentBuilder.RecordId,
      relationshipName
    );
    if (relatedRecord == null) {
      return null;
    }
    SObjectBuilder relatedRecordBuilder = SObjectBuilder.of(
      relatedRecord.getSObjectType()
    );
    for (Field relationshipField : relationshipFields) {
      relatedRecordBuilder.put(
        relationshipField.getName(),
        relatedRecord.get(relationshipField.getName())
      );
    }
    return relatedRecordBuilder;
  }

  public Object visit(SubselectPart part, Object current) {
    List<SObjectBuilder> filteredRecords = toList(current).clone();
    for (QueryBuilder subSelectBuilder : part.subqueries) {
      List<SObjectBuilder> subRecordBuilders = buildSObjectBuilders(
        subSelectBuilder
      );
      for (SObjectBuilder currentBuilder : filteredRecords) {
        Id currentParentId = currentBuilder.RecordId;
        List<SObjectBuilder> buildersThatAreChildren = new List<SObjectBuilder>();
        for (SObjectBuilder subRecordBuilder : subRecordBuilders) {
          if (this.db.isChild(currentParentId, subRecordBuilder.RecordId)) {
            buildersThatAreChildren.add(subRecordBuilder);
          }
        }
        currentBuilder.putChildren(
          subSelectBuilder.getFrom(),
          buildersThatAreChildren
        );
      }
    }
    return filteredRecords;
  }

  public Object visit(LimitPart part, Object current) {
    List<SObjectBuilder> filtered = toList(current).clone();
    Integer limitAmount = part.limitAmount;
    for (Integer i = 0; i < filtered.size(); i++) {
      if (i >= limitAmount) {
        filtered.remove(i);
      }
    }

    return filtered;
  }

  public Object visit(EmptyPart part, Object current) {
    return toList(current).clone();
  }

  public Object visit(OffsetPart part, Object current) {
    List<SObjectBuilder> filteredRecords = toList(current).clone();
    Integer offsetAmount = part.offsetAmount;
    for (Integer i = 0; i < filteredRecords.size(); i++) {
      if (i < offsetAmount) {
        filteredRecords.remove(i);
      }
    }

    return filteredRecords;
  }
}
