import 'package:meta/meta.dart';

/// On calling `table_info("tableName")`, a list of column information for the
/// table is returned. This column information is returned in the format:
/// `cid: 0, name: id, type: INTEGER, notnull: 0, dflt_value: null, pk: 1`
/// To facilitate reading and stuff, this class holds that information as a Dart
/// object.
class ColumnInfo {
  final int columnId;
  final String name;
  final String type;
  final bool nullable;
  final dynamic defaultValue;
  final bool isPrimaryKey;

  ColumnInfo._({
    @required this.columnId,
    @required this.name,
    @required this.type,
    @required this.nullable,
    @required this.defaultValue,
    @required this.isPrimaryKey,
  })  : assert(columnId != null),
        assert(name != null && name.isNotEmpty),
        assert(type != null && type.isNotEmpty),
        assert(nullable != null),
        // Ideally, we don't want the default value to be "null" if the column
        // is defined as "not nullable". The default value is set in the CREATE
        // command (ex: `$columnName INTEGER DEFAULT 0`, or to be explicit:
        // `$columnName INTEGER NOT NULL DEFAULT 0`). Ironically, if the CREATE
        // command has not been given any default value, it will default to
        // `null` even if it is not nullable (bonkers!). For now, don't carry
        // out this assert.
        // assert(nullable ? true : defaultValue != null),
        assert(isPrimaryKey != null);

  factory ColumnInfo.fromMap(Map<String, dynamic> columnInfoMap) {
    assert(columnInfoMap != null);
    final nullable = (columnInfoMap["notnull"] as int);
    final primaryKey = (columnInfoMap["pk"] as int);
    return ColumnInfo._(
      columnId: columnInfoMap["cid"] as int,
      name: columnInfoMap["name"] as String,
      type: columnInfoMap["type"] as String,
      nullable: nullable == null ? null : nullable > 0,
      defaultValue: columnInfoMap["dflt_value"],
      isPrimaryKey: primaryKey == null ? null : primaryKey > 0,
    );
  }
}
