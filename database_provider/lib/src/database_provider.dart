import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'column_info.dart';
import 'database_error_parser.dart';
import 'database_item.dart';

enum DatabaseError {
  columnNameAlreadyExists,
  failedToCreateColumn,
}

abstract class DatabaseProvider<T extends DatabaseItem> {
  final String databaseName;
  final int databaseVersion;
  final String tableName;

  Database _database;

  Directory _documentsDirectory;
  String _databasePath = "";

  DatabaseProvider({
    @required this.databaseName,
    @required this.databaseVersion,
    @required this.tableName,
  })  : assert(tableName != null),
        assert(databaseName != null),
        assert(databaseVersion != null);

  Future<Database> getDatabase() async {
    if ((_database == null) || (!_database.isOpen)) {
      _database = await _initialize();
    }

    return _database;
  }

  /// Initialises the database. On first call, the [_documentsDirectory] and
  /// [_databasePath] are created.
  Future<Database> _initialize() async {
    if (_documentsDirectory == null || _databasePath.isEmpty) {
      _documentsDirectory = await getApplicationDocumentsDirectory();
      _databasePath = join(_documentsDirectory.path, databaseName);
    }
    return await openDatabase(
      _databasePath,
      version: databaseVersion,
      onOpen: onOpen,
      onCreate: onCreate,
      onUpgrade: onUpgrade,
      onDowngrade: onDowngrade,
      singleInstance: false,
    );
  }

  void onOpen(Database openedDatabase) {}

  void onCreate(Database database, int version);

  Future<void> onUpgrade(Database database, int oldVersion, int newVersion);

  Future<void> onDowngrade(Database database, int oldVersion, int newVersion);

  /// Gets table information. Returns a list of `ColumnInfo` objects.
  Future<List<ColumnInfo>> getTableInfoAsync() async {
    final tableInfo = await (await getDatabase()).rawQuery("PRAGMA table_info(\"$tableName\")");
    return tableInfo.map<ColumnInfo>((mapItem) => ColumnInfo.fromMap(mapItem)).toList();
  }

  /// Inserts a new column with the specified [columnName] and of specified
  /// [type]. The [type] can be simply (for example) `INTEGER`, or it can
  /// contain multiple constraints, like `INTEGER NOT NULL DEFAULT 0`. An error
  /// is thrown if:
  /// - The column name already exists,
  /// - The SQL command fails,
  /// - The new column was not created.
  Future<void> insertColumnAsync({@required String columnName, @required String type}) async {
    // If the column name already exists, this will throw.
    await _checkColumnExistsAsync(columnName);

    // Column does not exist, so it must be added.
    await (await getDatabase())
        .rawQuery("ALTER TABLE $tableName ADD COLUMN $columnName ${type.toUpperCase()}");

    // Check the column has indeed been added.
    if (!await _tryCheckColumnExistsAsync(columnName)) {
      throw DatabaseError.failedToCreateColumn;
    }
  }

  /// Inserts a new column with the specified [columnName] and of specified
  /// [type]. The [type] can be simply (for example) `INTEGER`, or it can
  /// contain multiple constraints, like `INTEGER NOT NULL DEFAULT 0`. Returns
  /// `true` when the table contains the new column, otherwise `false`.
  Future<bool> tryInsertColumnAsync({@required String columnName, @required String type}) async {
    try {
      await insertColumnAsync(columnName: columnName, type: type);
      return true;
    } catch (_) {
      // We are not interested in the exception generated, as this is a "try..."
      // method. Just return a failure.
      return false;
    }
  }

  /// Checks that the database has a column with the [columnName] specified. If
  /// it does not, a `DatabaseError.columnNameAlreadyExists` is **thrown**.
  Future<void> _checkColumnExistsAsync(String columnName) async {
    final tableInfo = await getTableInfoAsync();
    // Check to see if the column exists. If not, create it.
    final existingColumn = tableInfo.singleWhere(
      (item) => item.name.toLowerCase() == columnName.toLowerCase(),
      orElse: () => null,
    );

    if (existingColumn != null) {
      throw DatabaseError.columnNameAlreadyExists;
    }
  }

  /// Checks that the database has a column with the [columnName] specified.
  /// Returns `true` for the column exists, otherwise `false`.
  Future<bool> _tryCheckColumnExistsAsync(String columnName) async {
    try {
      await _checkColumnExistsAsync(columnName);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Inserts an object in the table. If the item already exists, it is
  /// automatically replaced with the new one.
  ///
  /// `object` - The data object to be inserted.
  Future<int> insert({@required T object}) async {
    try {
      final db = await getDatabase();
      return await db.insert(tableName, object.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw DatabaseErrorParser.parseException(e);
    }
  }

  /// Inserts a list of items in the table. If any items are already in the
  /// table, they will be replaced with the new ones.
  ///
  /// `objects` - The list of data object to be inserted in the table.
  Future<List<int>> batchInsert({@required List<DatabaseItem> objects}) async {
    List<dynamic> results;
    final db = await getDatabase();
    await db.transaction((transaction) async {
      final batch = transaction.batch();
      objects.forEach((t) {
        batch.insert(tableName, t.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      });
      results = await batch.commit(continueOnError: true);
    });

    // batc.commit() returns a List<dynamic>. This needs to be casted to a
    // List<int> by using cast<int>(). See comment from library author:
    // https://github.com/tekartik/sqflite/issues/221#issuecomment-499058722
    return DatabaseErrorParser.parseList(results).cast<int>();
  }

  /// Gets one row item that match a given criteria. If no data is found, it
  /// returns a null object, otherwise it returns a row item that matches the
  /// given criteria.
  ///
  /// `where` - A filter declaring which rows to return, formatted as an SQL
  /// WHERE clause (excluding the WHERE itself). Passing `null` will return all
  /// rows for the table. You may include ?s in the where clause, which will be
  /// replaced by the values from `whereArgs`.
  /// `whereArgs` - The list of arguments to be included in the `where` clause.
  /// If the `where` declaration contains question marks (?) for argument
  /// placement, they will be replaced by `whereArgs` in the order in which they
  /// appear. For example, the first ? will be replaced with `whereArgs[0]`, the
  /// second with `whereArgs[1]` etc.
  /// `converter` - The converter function for converting `Map<String, dynamic>`
  /// to `DatabaseItem`.
  Future<T> get(
      {String where,
      List<dynamic> whereArgs,
      @required DatabaseItem converter(Map<String, dynamic> map)}) async {
    try {
      final db = await getDatabase();
      final results = await db.query(
        tableName,
        where: where,
        whereArgs: whereArgs,
        limit: 1,
      );
      return results.isNotEmpty ? converter(results.first) : null;
    } catch (e) {
      throw DatabaseErrorParser.parseException(e);
    }
  }

  /// Gets all the items that match a given criteria. If no data is found, it
  /// returns an empty list, otherwise it returns the row items that matches the
  /// given criteria.
  ///
  /// `where` - A filter declaring which rows to return, formatted as an SQL
  /// WHERE clause (excluding the WHERE itself). Passing `null` will return all
  /// rows for the table. You may include ?s in the where clause, which will be
  /// replaced by the values from `whereArgs`.
  /// `whereArgs` - The list of arguments to be included in the `where` clause.
  /// If the `where` declaration contains question marks (?) for argument
  /// placement, they will be replaced by `whereArgs` in the order in which they
  /// appear. For example, the first ? will be replaced with `whereArgs[0]`, the
  /// second with `whereArgs[1]` etc.
  /// `converter` - The converter function for converting `Map<String, dynamic>`
  /// to `DatabaseItem`.
  Future<List<T>> getAll(
      {String where,
      List<dynamic> whereArgs,
      @required DatabaseItem converter(Map<String, dynamic> map)}) async {
    List<Map<String, dynamic>> results;
    try {
      final db = await getDatabase();
      results = await db.query(tableName, where: where, whereArgs: whereArgs);
    } catch (e) {
      throw DatabaseErrorParser.parseException(e);
    }
    final list = List<DatabaseItem>();
    results?.forEach((t) => list.add(converter(t)));
    return list.cast<T>();
  }

  /// Updates a row item in the table.
  ///
  /// `item` - The row item to update.
  Future<int> update(DatabaseItem item) async {
    try {
      final db = await getDatabase();
      return await db.update(
        tableName,
        item.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw DatabaseErrorParser.parseException(e);
    }
  }

  /// Updates all the row items from the given list in the table.
  ///
  /// `list` - The list of row items to update.
  /// `conflictAlgorithm` - The algorithm to use in case an error is
  /// encountered. This is defaulted to `.ignore`.
  Future<List<int>> updateAll(
    List<DatabaseItem> list, {
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.ignore,
  }) async {
    final db = await getDatabase();
    final batch = db.batch();
    list.forEach((item) async {
      batch.update(
        tableName,
        item.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
        conflictAlgorithm: conflictAlgorithm,
      );
    });

    // batch.commit() returns a List<dynamic>. This needs to be casted to a
    // List<int> by using cast<int>(). See comment from library author:
    // https://github.com/tekartik/sqflite/issues/221#issuecomment-499058722
    final results = (await batch.commit(continueOnError: true));
    return DatabaseErrorParser.parseList(results).cast<int>();
  }

  /// Deletes a row in the table.
  ///
  /// `item` - The database item to delete.
  Future<int> delete(DatabaseItem item) async {
    try {
      final db = await getDatabase();
      return await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [item.id],
      );
    } catch (e) {
      throw DatabaseErrorParser.parseException(e);
    }
  }

  /// Deletes rows with clause from the table.
  ///
  /// `where` - A filter declaring which rows to return, formatted as an SQL
  /// WHERE clause (excluding the WHERE itself). Passing `null` will return all
  /// rows for the table. You may include ?s in the where clause, which will be
  /// replaced by the values from `whereArgs`.
  /// `whereArgs` - The list of arguments to be included in the `where` clause.
  /// If the `where` declaration contains question marks (?) for argument
  /// placement, they will be replaced by `whereArgs` in the order in which they
  /// appear. For example, the first ? will be replaced with `whereArgs[0]`, the
  /// second with `whereArgs[1]` etc.
  Future<int> deleteWhere({
    @required String where,
    @required List<dynamic> whereArgs,
  }) async {
    try {
      final db = await getDatabase();
      return await db.delete(
        tableName,
        where: where,
        whereArgs: whereArgs,
      );
    } catch (e) {
      throw DatabaseErrorParser.parseException(e);
    }
  }

  /// Deletes all data in the table. Returns a list of IDs that have been
  /// deleted.
  Future<int> deleteAll() async {
    try {
      final db = await getDatabase();
      return await db.rawDelete('DELETE FROM $tableName');
    } catch (e) {
      throw DatabaseErrorParser.parseException(e);
    }
  }

  void close() {
    _database?.close();
    _database = null;
  }
}
