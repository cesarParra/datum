public class InMemoryDB extends QDB implements QueryBuilder.QueryPartVisitor {
    final Map<Id, SObject> recordsById = new Map<Id, SObject>();
    List<SObject> filteredRecords = null;

    public class QdbException extends Exception {}

    public override void doInsert(SObject recordToInsert) {
        recordToInsert.Id = IdGenerator.generate(recordToInsert.getSObjectType());

        Map<String, Object> populatedFields = recordToInsert.getPopulatedFieldsAsMap();
        SObjectType type = recordToInsert.getSObjectType();
        Map<String, SObjectField> fieldsMap = type.getDescribe().fields.getMap();
        for (String currentlyPopulatedField : populatedFields.keySet()) {
            if (currentlyPopulatedField.toLowerCase() != 'id') {
                if (fieldsMap.get(currentlyPopulatedField).getDescribe().getType() == DisplayType.REFERENCE) {
                    if (!recordsById.containsKey((Id)populatedFields.get(currentlyPopulatedField))) {
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
        this.filteredRecords = new List<SObject>();
        for (QueryBuilder.QueryPart part : queryBuilder) {
            part.accept(this);
        }

        return filteredRecords;
    }

    public Object visit(QueryBuilder.FromPart part) {
        String fromObject = part.objectType;
        for (SObject currentRecord : recordsById.values()) {
            SObjectType type = currentRecord.getSObjectType();
            if (type.getDescribe().getName().equalsIgnoreCase(fromObject)) {
                filteredRecords.add(currentRecord);
            }
        }

        return filteredRecords;
    }

    public Object visit(QueryBuilder.SelectPart part) {
        List<SObject> filteredRecords = new List<SObject>();
        for (SObject currentRecord : this.filteredRecords) {
            SObjectType type = currentRecord.getSObjectType();
            SObjectBuilder builder = SObjectBuilder.of(type);
            for (String queriedField : part.fields) {
                builder.put(queriedField, currentRecord.get(queriedField));
            }

            filteredRecords.add(builder.build());
        }

        this.filteredRecords = filteredRecords;
        return this.filteredRecords;
    }

    public Object visit(QueryBuilder.LimitPart part) {
        Integer limitAmount = part.limitAmount;
        for (Integer i = 0; i < filteredRecords.size(); i++) {
            if (i >= limitAmount) {
                filteredRecords.remove(i);
            }
        }

        return filteredRecords;
    }

    public Object visit(QueryBuilder.EmptyPart part) {
        return filteredRecords;
    }

    public Object visit(QueryBuilder.OffsetPart part) {
        Integer offsetAmount = part.offsetAmount;
        for (Integer i = 0; i < filteredRecords.size(); i++) {
            if (i < offsetAmount) {
                filteredRecords.remove(i);
            }
        }

        return filteredRecords;
    }
}
