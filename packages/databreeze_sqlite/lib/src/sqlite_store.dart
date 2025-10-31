import 'dart:async';
import 'dart:ffi';
import 'package:databreeze/databreeze.dart';
import 'package:databreeze_sqlite/src/sqlite_json_type.dart';
import 'package:databreeze_sqlite/src/sqlite_type_converters.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:sqlite_async/sqlite3_common.dart';
import 'package:sqlite_async/sqlite3.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:sqlite3/open.dart' as sqlite_open;
import 'package:path/path.dart' as path;

class BreezeSqliteStore extends BreezeStore {
  final Logger? log;
  final Future<String?> Function() onPath;
  final SqliteMigrations? migrations;

  BreezeSqliteStore({
    this.log,
    required this.onPath,
    this.migrations,
    super.typeConverters,
  }) {
    initializeDatabase();
  }

  @override
  final Set<BreezeTypeConverter> defaultTypeConverters = {
    BreezeSqliteBoolIntConverter(),
    BreezeSqliteDurationIntConverter(),
    // BreezeSqliteDateTimeIntConverter(),
    BreezeSqliteDateTimeStringConverter(),
  };

  final _orderDirections = {
    BreezeSortDir.asc: 'ASC',
    BreezeSortDir.desc: 'DESC',
  };

  Future<SqliteConnection> createDatabase() async {
    final location = await onPath();
    final db = SqliteDatabase.withFactory(
      (location != null)
          ? SqliteFileOpenFactory(
              path: location,
            )
          : SqliteInMemoryOpenFactory(
              sqliteOptions: SqliteOptions(
                journalMode: SqliteJournalMode.memory,
                journalSizeLimit: 6 * 1024 * 1024, // 1.5x the default checkpoint size
                synchronous: SqliteSynchronous.normal,
                lockTimeout: const Duration(seconds: 30),
              ),
            ),
    );
    return db;
  }

  @protected
  Future<void> initializeDatabase() async {
    // Create database
    final db = await createDatabase();

    // Apply migrations
    final m = migrations;
    if (m != null) {
      m.migrate(db).then((_) async {
        _dbCompleter.complete(db);
      });
    } else {
      _dbCompleter.complete(db);
    }
  }

  @override
  Future<void> close() async {
    if (_dbCompleter.isCompleted) {
      final db = await database;
      if (!db.closed) {
        await db.close();
      }
    }
  }

  @protected
  @visibleForTesting
  Future<SqliteConnection> get database => _dbCompleter.future;

  late final _dbCompleter = Completer<SqliteConnection>();

  // Database API

  @override
  Future<BreezeDataRecord?> fetchRecord({
    required String table,
    BreezeModelBlueprint? blueprint,
    required BreezeFilterExpression filter,
    BreezeSortBy? sortBy,
  }) async {
    final (:sql, :params) = buildSql(table, filter, sortBy);
    final result = await executeSql(sql, params);

    final record = result.isNotEmpty ? Map.from(result.first).cast<String, dynamic>() : null;

    log?.finest('Fetch $filter: $record');

    return record;
  }

  @override
  Future<List<BreezeDataRecord>> fetchAllRecords({
    required String table,
    BreezeModelBlueprint? blueprint,
    BreezeFilterExpression? filter,
    BreezeSortBy? sortBy,
  }) async {
    final (:sql, :params) = buildSql(table, filter, sortBy);
    final result = await executeSql(sql, params);

    final records = result.map((r) => Map.from(r).cast<String, dynamic>()).toList(growable: false);

    log?.finest('Fetch All $filter: $records');

    return records;
  }

  @override
  Future<dynamic> addRecord({
    required String name,
    required String key,
    required Map<String, dynamic> record,
  }) async {
    final hasPrimaryKey = record.containsKey(key) && (record[key] != null);
    final rawRecord = hasPrimaryKey ? record : ({...record}..remove(key));
    final columns = rawRecord.keys;
    final columnsPlaceholders = List.filled(columns.length, '?').join(', ');
    final values = rawRecord.values;

    final result = await executeSql(
      'INSERT INTO $name (${columns.join(', ')}) VALUES ($columnsPlaceholders) RETURNING $key',
      values.toList(growable: false),
    );

    final lastInsertId = result.isNotEmpty ? result.first.values.first : null;

    log?.finest('Add #$lastInsertId: $record');

    return lastInsertId;
  }

  @override
  Future<void> updateRecord({
    required String name,
    required String key,
    required dynamic keyValue,
    required Map<String, dynamic> record,
  }) async {
    await executeSql(
      'UPDATE $name SET ${record.keys.map((k) => '$k = ?').join(', ')} WHERE $key = ?',
      [...record.values, keyValue],
    );

    log?.finest('Update #$keyValue: $record');
  }

  @override
  Future<void> deleteRecord({
    required String name,
    required String key,
    required dynamic keyValue,
    required Map<String, dynamic> record,
  }) async {
    await executeSql(
      'DELETE FROM $name WHERE $key = ?',
      [keyValue],
    );

    log?.finest('Delete #$keyValue: $record');
  }

  @override
  Future<T?> aggregate<T>(
    String entity,
    BreezeAggregationOp op,
    String column, [
    BreezeFetchOptions? options,
    BreezeSortBy? sortBy,
  ]) {
    // TODO: implement aggregate
    throw UnimplementedError();
  }

  dynamic _tryCastJson(BreezeSqliteJsonB value) {
    try {
      return jsonb.decode(value);
    } catch (_) {
      return value;
    }
  }

  List<dynamic> _convertJsonParams(List<Object?> params) {
    final result = [
      for (final param in params) (param is BreezeSqliteJsonB) ? _tryCastJson(param) : param,
    ];
    return result;
  }

  void _logQuery(String sql, [List<Object?> params = const []]) {
    // TODO: Make logging level configurable
    if (params.isNotEmpty) {
      log?.finer('$sql -> ${_convertJsonParams(params)}');
    } else {
      log?.finer(sql);
    }
  }

  Future<ResultSet> executeSql(String sql, [List<Object?> parameters = const []]) async {
    final List<Object?> params = [];
    for (final param in parameters) {
      /*
      if (param is DsStorageType) {
        final val = toStorageType(param.value, storageType: param.storageType);
        params.add(val);
      } else {
        params.add(param);
      }
      */

      params.add(param);
    }

    _logQuery(sql, params);

    final result = await database.then(
      (db) => db.execute(
        sql,
        params,
      ),
    );
    return result;
  }

  @protected
  ({String sql, List<dynamic> params}) buildSql(
    String table, [
    BreezeFilterExpression? filter,
    BreezeSortBy? sortBy,
  ]) {
    final (whereSql, whereParams) = _buildWhere(filter);
    final whereClause = whereSql.isNotEmpty ? ' WHERE $whereSql' : '';

    final (orderSql, orderParams) = _buildOrderBy(sortBy);
    final orderClause = orderSql.isNotEmpty ? ' ORDER BY $orderSql' : '';

    return (
      sql: 'SELECT * FROM $table$whereClause$orderClause',
      params: [...whereParams, ...orderParams],
    );
  }

  (String, List<dynamic>) _buildWhere(BreezeFilterExpression? filter) {
    return switch (filter) {
      BreezeComparisonFilter f => _buildComparison(f),
      BreezeBetweenFilter f => _buildBetween(f),
      BreezeInFilter f => _buildIn(f),
      BreezeAndFilter f => _combineFilter('AND', f.left, f.right),
      BreezeOrFilter f => _combineFilter('OR', f.left, f.right),
      _ => ('', []),
    };
  }

  (String, List<dynamic>) _buildComparison(BreezeComparisonFilter f) {
    final op = switch (f.operator) {
      '==' => '=',
      '!=' => '!=',
      '<' => '<',
      '<=' => '<=',
      '>' => '>',
      '>=' => '>=',
      _ => throw UnsupportedError('Invalid operator: ${f.operator}'),
    };
    return (
      '${f.field} $op ?',
      [f.value],
    );
  }

  (String, List<dynamic>) _buildBetween(BreezeBetweenFilter f) {
    return (
      '${f.field} BETWEEN ? AND ?',
      [f.min, f.max],
    );
  }

  (String, List<dynamic>) _buildIn(BreezeInFilter f) {
    if (f.values.isEmpty) return ('0', []);
    final placeholders = List.filled(f.values.length, '?').join(', ');
    final op = !f.inverse ? 'IN' : 'NOT IN';
    return (
      '${f.field} $op ($placeholders)',
      f.values,
    );
  }

  (String, List<dynamic>) _combineFilter(String op, BreezeFilterExpression left, BreezeFilterExpression right) {
    final (leftSql, leftArgs) = _buildWhere(left);
    final (rightSql, rightArgs) = _buildWhere(right);
    return (
      '($leftSql $op $rightSql)',
      [...leftArgs, ...rightArgs],
    );
  }

  (String, List<dynamic>) _buildOrderBy(BreezeSortBy? orderBy) {
    final result = orderBy?.orders
        .map((order) => '${order.column} ${_orderDirections[order.direction]}')
        .join(
          ', ',
        );
    return (result ?? '', []);
  }
}

class SqliteInMemoryOpenFactory extends DefaultSqliteOpenFactory {
  static const defaultInMemoryName = ':memory:';

  final String sqliteLibPath;

  SqliteInMemoryOpenFactory({
    String? name,
    super.sqliteOptions,
    this.sqliteLibPath = '',
  }) : super(path: name ?? defaultInMemoryName);

  final Map<sqlite_open.OperatingSystem, String> sqliteLib = {
    sqlite_open.OperatingSystem.linux: 'libsqlite3.so',
    sqlite_open.OperatingSystem.windows: 'sqlite3.dll',
  };

  @override
  Database open(SqliteOpenOptions options) {
    for (var MapEntry(key: os, value: lib) in sqliteLib.entries) {
      sqlite_open.open.overrideFor(
        os,
        () => DynamicLibrary.open(path.join(sqliteLibPath, lib)),
      );
    }

    final db = sqlite3.open(
      super.path,
      uri: true,
    );

    // Pragma statements don't have the same BUSY_TIMEOUT behavior as normal statements.
    // We add a manual retry loop for those.
    for (var statement in pragmaStatements(options)) {
      for (var tries = 0; tries < 30; tries++) {
        try {
          db.execute(statement);
          break;
        } on SqliteException catch (e) {
          if (e.resultCode == SqlError.SQLITE_BUSY && tries < 29) {
            continue;
          } else {
            rethrow;
          }
        }
      }
    }

    return db;
  }
}

class SqliteFileOpenFactory extends DefaultSqliteOpenFactory {
  final String? sqliteLibPath;

  SqliteFileOpenFactory({
    required super.path,
    super.sqliteOptions,
    this.sqliteLibPath,
  });

  final Map<sqlite_open.OperatingSystem, String> sqliteLib = {
    sqlite_open.OperatingSystem.linux: 'libsqlite3.so',
    sqlite_open.OperatingSystem.windows: 'sqlite3.dll',
    // sqlite_open.OperatingSystem.macOS: 'libsqlite3.so',
  };

  @override
  CommonDatabase open(SqliteOpenOptions options) {
    if (sqliteLibPath != null) {
      for (var MapEntry(key: os, value: lib) in sqliteLib.entries) {
        sqlite_open.open.overrideFor(
          os,
          () => DynamicLibrary.open(path.join(sqliteLibPath!, lib)),
        );
      }
    }

    final db = super.open(options);
    return db;
  }
}
