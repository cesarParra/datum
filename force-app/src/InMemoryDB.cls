public class InMemoryDB extends QDB {
  final Map<Id, SObject> recordsById = new Map<Id, SObject>();

  public class QdbException extends Exception {
  }

  public override void doInsert(SObject recordToInsert) {
    recordToInsert.Id = IdGenerator.generate(recordToInsert.getSObjectType());

    Map<String, Object> populatedFields = recordToInsert.getPopulatedFieldsAsMap();
    SObjectType type = recordToInsert.getSObjectType();
    Map<String, SObjectField> fieldsMap = type.getDescribe().fields.getMap();
    for (String currentlyPopulatedField : populatedFields.keySet()) {
      if (currentlyPopulatedField.toLowerCase() != 'id') {
        if (
          fieldsMap.get(currentlyPopulatedField).getDescribe().getType() ==
          DisplayType.REFERENCE
        ) {
          if (
            !recordsById.containsKey(
              (Id) populatedFields.get(currentlyPopulatedField)
            )
          ) {
            throw new DmlException('The parent does not exist');
          }
        }
      }
    }

    recordsById.put(recordToInsert.Id, recordToInsert);
  }

  public override void doInsert(List<SObject> recordsToInsert) {
    for (SObject record : recordsToInsert) {
      doInsert(record);
    }
  }

  public override List<SObject> query(QueryBuilder queryBuilder) {
    InMemoryDBVisitor visitor = new InMemoryDBVisitor(this);
    return visitor.query(queryBuilder);
  }

  public Map<Id, SObject> getRecordsById() {
    return recordsById;
  }
}
