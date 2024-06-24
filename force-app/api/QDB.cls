/**
 * @description Represents a Database that supports storing data both in-memory as well as in the Salesforce
 * database.
 * @example
 * QDB db = QDB.getInstance();
 * db.doInsert(new Account(Name = 'Test Account'));
 */
public abstract class QDB {
  private static QDB instance;

  /**
   * @description Returns an instance of the QDB class.
   *              By default the Salesforce database is used, but if the code is running in a test context
   *              then an in-memory database is used.
   * @return An instance of the QDB class.
   */
  public static QDB getInstance() {
    if (instance != null) {
      return instance;
    }

    if (instance == null && Test.isRunningTest()) {
      instance = new InMemoryDB();
    } else {
      instance = new SystemDB();
    }

    return instance;
  }

  /**
   * @description Inserts a single record into the database.
   * @param recordToInsert The record to insert into the database.
   * @example
   * QDB db = QDB.getInstance();
   * db.doInsert(new Account(Name = 'Test Account'));
   */
  public abstract void doInsert(SObject recordToInsert);

  /**
   * @description Inserts multiple records into the database.
   * @param recordsToInsert The records to insert into the database.
   * @example
   * QDB db = QDB.getInstance();
   * db.doInsert(new List<Account>{new Account(Name = 'Test Account 1'), new Account(Name = 'Test Account 2')});
   */
  public abstract void doInsert(List<SObject> recordsToInsert);

  /**
   * @description Queries for records in the database.
   * @param queryBuilder A {@link QueryBuilder} object that represents the query to run.
   * @return A list of records that match the query.
   * @example
   * QDB db = QDB.getInstance();
   * List<SObject> accounts = db.query(QueryBuilder.of('Account').selectField('Name'));
   * // Returns a list of Account records with only the Name field populated.
   */
  public abstract List<SObject> query(QueryBuilder queryBuilder);

  /**
   * @description Forces the QDB class to use the Salesforce database, regardless of the context.
   */
  public static void useSystemDB() {
    instance = new SystemDB();
  }
}
