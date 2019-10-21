import 'package:flutter_test/flutter_test.dart';

import 'package:database_provider/database_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

class _TestDatabaseItem extends DatabaseItem {
  final int id;
  final String title;
  static const String titleColumnName = "title";

  _TestDatabaseItem(this.id, this.title) : super(id);

  @override
  List<Object> get props => [id];

  @override
  Map<String, dynamic> toMap() {
    return {
      DatabaseItem.idColumnName: id,
      titleColumnName: title,
    };
  }
}

class _TestDatabaseProvider extends Mock implements DatabaseProvider<_TestDatabaseItem> {
  final String _createTableSQLScript;

  final String _databaseName;
  final String _tableName;
  final int _databaseVersion;

  String get databaseName => _databaseName;
  String get tableName => _tableName;
  int get databaseVersion => _databaseVersion;

  _TestDatabaseProvider(this._databaseVersion, this._databaseName, this._tableName)
      : _createTableSQLScript = 'CREATE TABLE $_tableName ('
            '${DatabaseItem.idColumnName} INTEGER PRIMARY KEY AUTOINCREMENT,'
            '${_TestDatabaseItem.titleColumnName} TEXT'
            ')';

  @override
  void onCreate(Database database, int version) async {
    await database.execute(_createTableSQLScript);
  }
}

void main() {
  final _testDatabaseVersion = 1;
  final _testDatabaseName = "TestDatabase";
  final _testTableName = "TestItems";

  _TestDatabaseProvider _testDatabaseProvider;

  /// *** IMPORTANT ***
  /// Running unit tests on the SQLite package seems to fail due to the `sqflite`
  /// package not handling unit tests very well. Until this is done by the
  /// authors of the `sqflite` package, this is a no-go area. You just have to
  /// assume and trust that the package works :)

  // setUp(() {
  //   _testDatabaseProvider =
  //       _TestDatabaseProvider(_testDatabaseVersion, _testDatabaseName, _testTableName);
  // });

  // test("Database is created with correct table info", () async {
  //   final database = await _testDatabaseProvider.getDatabase();
  //   expect(database, isNotNull); // This fails!

  //   final databaseVersion = await database.getVersion();
  //   expect(databaseVersion, isNotNull);
  //   expect(databaseVersion, _testDatabaseVersion);

  //   final tableInfo = await _testDatabaseProvider.getTableInfoAsync();

  //   expect(tableInfo, isNotNull);
  //   expect(tableInfo.length, 2);

  //   expect(tableInfo[0].name, DatabaseItem.idColumnName);
  //   expect(tableInfo[0].isPrimaryKey, true);
  //   expect(tableInfo[1].name, _TestDatabaseItem.titleColumnName);
  //   expect(tableInfo[1].isPrimaryKey, false);
  //   expect(tableInfo[1].type, isNotNull);
  //   expect(tableInfo[1].type.toLowerCase(), "text");
  // });
}
