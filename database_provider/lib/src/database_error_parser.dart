import 'package:sqflite/sqflite.dart';

enum DatabaseParseResult {
  success,
  // Database-related errors.
  exceptionNull,
  noSuchTable,
  syntaxError,
  failedToOpen,
  databaseIsClosed,
  readOnly,
  uniqueConstraint,
  unknownDatabaseError,
  // Non-database related errors.
  resultNull,
}

class DatabaseErrorParser {
  DatabaseErrorParser._();

  static DatabaseException parseException(DatabaseException exception) {
    if (exception == null) {
      throw DatabaseParseResult.resultNull;
    } else if (exception.isDatabaseClosedError()) {
      throw DatabaseParseResult.databaseIsClosed;
    } else if (exception.isNoSuchTableError()) {
      throw DatabaseParseResult.noSuchTable;
    } else if (exception.isOpenFailedError()) {
      throw DatabaseParseResult.failedToOpen;
    } else if (exception.isReadOnlyError()) {
      throw DatabaseParseResult.readOnly;
    } else if (exception.isSyntaxError()) {
      throw DatabaseParseResult.syntaxError;
    } else if (exception.isUniqueConstraintError()) {
      throw DatabaseParseResult.uniqueConstraint;
    }

    return exception;
  }

  static List<dynamic> parseList(List<dynamic> list) {
    if (list == null) {
      throw DatabaseParseResult.resultNull;
    }

    list.forEach((item) {
      if (item is DatabaseException) {
        parseException(item);
      }
    });

    return list;
  }
}
