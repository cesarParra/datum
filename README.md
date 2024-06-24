# Datum

## API

# QDB Class

`abstract`

Represents a Database that supports storing data both in-memory as well as in the Salesforce

database.

## Example

```apex
QDB db = QDB.getInstance();
db.doInsert(new Account(Name = 'Test Account'));
```

## Methods

### `getInstance()`

Returns an instance of the QDB class.

By default the Salesforce database is used, but if the code is running in a test context

then an in-memory database is used.

### Signature

```apex
public static QDB getInstance()
```

### Returns

**[QDB](./QDB.md)**

An instance of the QDB class.

---

### `doInsert(recordToInsert)`

Inserts a single record into the database.

### Signature

```apex
public abstract void doInsert(SObject recordToInsert)
```

### Parameters

| Name           | Type    | Description                             |
| -------------- | ------- | --------------------------------------- |
| recordToInsert | SObject | The record to insert into the database. |

### Returns

**void**

### Example

```apex
QDB db = QDB.getInstance();
db.doInsert(new Account(Name = 'Test Account'));
```

---

### `doInsert(recordsToInsert)`

Inserts multiple records into the database.

### Signature

```apex
public abstract void doInsert(List&lt;SObject&gt; recordsToInsert)
```

### Parameters

| Name            | Type                | Description                              |
| --------------- | ------------------- | ---------------------------------------- |
| recordsToInsert | List&lt;SObject&gt; | The records to insert into the database. |

### Returns

**void**

### Example

```apex
QDB db = QDB.getInstance();
db.doInsert(new List&lt;Account&gt;{new Account(Name = 'Test Account 1'), new Account(Name = 'Test Account 2')});
```

---

### `query(queryBuilder)`

Queries for records in the database.

### Signature

```apex
public abstract List&lt;SObject&gt; query(QueryBuilder queryBuilder)
```

### Parameters

| Name         | Type                              | Description                                                                  |
| ------------ | --------------------------------- | ---------------------------------------------------------------------------- |
| queryBuilder | [QueryBuilder](./QueryBuilder.md) | A [QueryBuilder](./QueryBuilder.md) object that represents the query to run. |

### Returns

**List&lt;SObject&gt;**

A list of records that match the query.

### Example

```apex
QDB db = QDB.getInstance();
List&lt;SObject&gt; accounts = db.query(QueryBuilder.of('Account').selectField('Name'));
// Returns a list of Account records with only the Name field populated.
```

---

### `useSystemDB()`

Forces the QDB class to use the Salesforce database, regardless of the context.

### Signature

```apex
public static void useSystemDB()
```

### Returns

**void**

---

# QueryBuilder Class

A class for building SOQL queries in Apex.

## Example

```apex
QueryBuilder query = QueryBuilder.of('Account')
  .selectFields(new Set&lt;String&gt;{ 'Name', 'Id' })
  .subselect(
    QueryBuilder.of('Contacts')
    .selectFields(new Set&lt;String&gt;{ 'Name', 'Id' })
    .withLimitAmount(10)
  )
```

**Implements**
Iterable&lt;QueryPart&gt;

## Methods

### `of(objectType)`

Creates a new QueryBuilder object with the specified object type.

### Signature

```apex
public static QueryBuilder of(String objectType)
```

### Parameters

| Name       | Type   | Description               |
| ---------- | ------ | ------------------------- |
| objectType | String | The object type to query. |

When querying a child object, use the relationship name. |

### Returns

**[QueryBuilder](./QueryBuilder.md)**

A new QueryBuilder object.

---

### `selectFields(fields)`

Adds a set of fields to the SELECT clause of the query.

### Signature

```apex
public QueryBuilder selectFields(Set&lt;String&gt; fields)
```

### Parameters

| Name   | Type              | Description                                       |
| ------ | ----------------- | ------------------------------------------------- |
| fields | Set&lt;String&gt; | A set of field names to add to the SELECT clause. |

### Returns

**[QueryBuilder](./QueryBuilder.md)**

The QueryBuilder object.

---

### `selectField(fieldName)`

Adds a field to the SELECT clause of the query.

### Signature

```apex
public QueryBuilder selectField(String fieldName)
```

### Parameters

| Name      | Type   | Description                                 |
| --------- | ------ | ------------------------------------------- |
| fieldName | String | The field name to add to the SELECT clause. |

### Returns

**[QueryBuilder](./QueryBuilder.md)**

The QueryBuilder object.

---

### `subselect(subquery)`

Adds a subquery to the query.

### Signature

```apex
public QueryBuilder subselect(QueryBuilder subquery)
```

### Parameters

| Name     | Type                              | Description                       |
| -------- | --------------------------------- | --------------------------------- |
| subquery | [QueryBuilder](./QueryBuilder.md) | The subquery to add to the query. |

### Returns

**[QueryBuilder](./QueryBuilder.md)**

The QueryBuilder object.

---

### `withLimitAmount(limitAmount)`

Sets the maximum number of records to return.

### Signature

```apex
public QueryBuilder withLimitAmount(Integer limitAmount)
```

### Parameters

| Name        | Type    | Description                              |
| ----------- | ------- | ---------------------------------------- |
| limitAmount | Integer | The maximum number of records to return. |

### Returns

**[QueryBuilder](./QueryBuilder.md)**

The QueryBuilder object.

---

### `withOffsetAmount(offsetAmount)`

Sets the offset amount for the query.

### Signature

```apex
public QueryBuilder withOffsetAmount(Integer offsetAmount)
```

### Parameters

| Name         | Type    | Description                      |
| ------------ | ------- | -------------------------------- |
| offsetAmount | Integer | The offset amount for the query. |

### Returns

**[QueryBuilder](./QueryBuilder.md)**

The QueryBuilder object.
