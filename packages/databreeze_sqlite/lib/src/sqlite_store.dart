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
import 'package:path/path.dart' as p;

class BreezeSqliteRequest extends BreezeAbstractFetchRequest {
  final String sql;
  final List<Object?> params;

  const BreezeSqliteRequest(
    this.sql, [
    this.params = const [],
  ]);

  @override
  String toString() =>
      '''BreezeSqliteRequest(
  sql: $sql,
  params: $params
)''';
}

typedef BreezeSqliteDatabaseLocation = Future<String> Function();

class BreezeSqliteStore extends BreezeStore
    with BreezeStoreFetch, BreezeStoreRelations /*, BreezeStoreHasManyThoughRelations*/ {
  final Logger? log;

  /// The database file name, or `null` for an in-memory database.
  final String? databaseFile;

  /// It should return the path to the database file if [databaseFile] is not null.
  final BreezeSqliteDatabaseLocation? databaseLocation;

  /// This is called immediately after the database is
  /// opened (before migrations, etc.).
  ///
  /// It can be used to set database operating parameters,
  /// such as `PRAGMA`.
  final Future<void> Function(SqliteConnection db)? onInit;

  BreezeSqliteStore({
    this.log,
    super.models,
    required String this.databaseFile,
    required BreezeSqliteDatabaseLocation this.databaseLocation,
    this.onInit,
    super.migrationStrategy,
    super.typeConverters,
    super.onError,
  }) {
    initializeDatabase();
  }

  BreezeSqliteStore.inMemory({
    this.log,
    super.models,
    this.onInit,
    super.migrationStrategy,
    super.typeConverters,
    super.onError,
  }) : databaseFile = null,
       databaseLocation = null {
    initializeDatabase();
  }

  @override
  final Set<BreezeBaseTypeConverter> defaultTypeConverters = {
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
    late final String? path;
    if (databaseFile != null) {
      if (databaseLocation == null) {
        throw ArgumentError.notNull('databaseLocation');
      }
      final dbLocation = await databaseLocation!();
      path = p.join(dbLocation, databaseFile);
    } else {
      path = null;
    }

    final db = SqliteDatabase.withFactory(
      (path != null)
          ? SqliteFileOpenFactory(
              path: path,
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

    // Calling custom initializations, such as PRAGMA or
    // setting database session parameters
    await onInit?.call(db);

    // Apply migrations
    if (migrationStrategy != null) {
      await migrationStrategy?.migrate(this, db);
    }

    // Complete database initialization
    _dbCompleter.complete(db);
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
    required BreezeAbstractFetchRequest request,
    BreezeModelBlueprint? blueprint,
    Set<BreezeBaseTypeConverter> typeConverters = const {},
  }) async {
    List<Map<String, dynamic>>? result;
    Map<String, dynamic>? record;

    switch (request) {
      case BreezeFetchRequest(filter: final filter, sortBy: final sortBy):
        /*
        final joins = (blueprint != null)
            ? createJoinsForNested(table, blueprint.nestedModelColumns)
            : const <SqlJoin>[];
        */

        final (:sql, :params) = buildSql(
          table,
          filter: filter,
          // joins: joins,
          sortBy: sortBy,
          limit: 1,
        );
        result = await executeSql(sql, params, typeConverters);

        /*
        if (blueprint != null) {
          result = expandJoinsToNested(result, blueprint.nestedModelColumns);
        }
        */

        break;

      case BreezeSqliteRequest(sql: final sql, params: final params):
        result = await executeSql(sql, params, typeConverters);
        break;
    }

    if (result != null) {
      record = result.isNotEmpty ? Map.from(result.first).cast<String, dynamic>() : null;
    }

    log?.finest('Fetch $request: $record');

    return record;
  }

  @override
  Future<List<BreezeDataRecord>> fetchAllRecords({
    required String table,
    BreezeAbstractFetchRequest? request,
    BreezeModelBlueprint? blueprint,
    Set<BreezeBaseTypeConverter> typeConverters = const {},
  }) async {
    List<Map<String, dynamic>>? result;
    List<Map<String, dynamic>>? records;

    switch (request) {
      case BreezeFetchRequest(filter: final filter, sortBy: final sortBy):
        final (:sql, :params) = buildSql(table, filter: filter, sortBy: sortBy);
        result = await executeSql(sql, params, typeConverters);

        /*
        if (blueprint != null) {
          result = await loadNested(result, blueprint.nestedModelColumns);
        }
        */

        break;

      case BreezeSqliteRequest(sql: final sql, params: final params):
        result = await executeSql(sql, params, typeConverters);
        break;

      case Null _:
        final (:sql, :params) = buildSql(table);
        result = await executeSql(sql, params, typeConverters);
        break;

      default:
        throw Exception('Request type "${request.runtimeType}" is not supported in store "$runtimeType".');
    }

    // if (result != null) {
    records = result.map((r) => Map.from(r).cast<String, dynamic>()).toList(growable: false);
    // } else {
    //   records = [];
    // }

    // --

    log?.finest('FetchAll $request: $records');

    return records;
  }

  @override
  Future<dynamic> fetchColumnWithRequest({
    required String table,
    required String column,
    required BreezeAbstractFetchRequest request,
    Set<BreezeBaseTypeConverter<dynamic, dynamic>> typeConverters = const {},
  }) async {
    ResultSet? result;
    dynamic columnValue;

    switch (request) {
      case BreezeFetchRequest(filter: final filter, sortBy: final sortBy):
        final (:sql, :params) = buildSql(table, columns: column, filter: filter, sortBy: sortBy, limit: 1);
        result = await executeSql(sql, params, typeConverters);
        break;

      case BreezeSqliteRequest(sql: final sql, params: final params):
        result = await executeSql(sql, params, typeConverters);
        break;
    }

    if (result != null) {
      columnValue = result.isNotEmpty ? result.first.values.first : null;
    }

    log?.finest('Fetch column $request: $columnValue');

    return columnValue;
  }

  @override
  Future<List<dynamic>> fetchColumnAllWithRequest({
    required String table,
    required String column,
    required BreezeAbstractFetchRequest request,
    Set<BreezeBaseTypeConverter<dynamic, dynamic>> typeConverters = const {},
  }) async {
    ResultSet? result;
    List<dynamic>? values;

    switch (request) {
      case BreezeFetchRequest(filter: final filter, sortBy: final sortBy):
        final (:sql, :params) = buildSql(table, columns: column, filter: filter, sortBy: sortBy);
        result = await executeSql(sql, params, typeConverters);
        break;

      case BreezeSqliteRequest(sql: final sql, params: final params):
        result = await executeSql(sql, params, typeConverters);
        break;
    }

    if (result != null) {
      values = result.map((r) => r.values.first).toList(growable: false);
    } else {
      values = [];
    }

    // --

    log?.finest('FetchAll column $request: $values');

    return values;
  }

  @override
  Future<dynamic> addRecord({
    required String name,
    String? key,
    required Map<String, dynamic> record,
  }) async {
    final hasPrimaryKey = (key != null) && record.containsKey(key) && (record[key] != null);
    final rawRecord = hasPrimaryKey ? record : ({...record}..remove(key));
    final columns = rawRecord.keys;
    final columnsPlaceholders = List.filled(columns.length, '?').join(', ');
    final values = rawRecord.values;

    final returning = (key != null) ? ' RETURNING $key' : '';
    final result = await executeSql(
      'INSERT INTO $name (${columns.join(', ')}) VALUES ($columnsPlaceholders)$returning',
      values.toList(growable: false),
    );

    final lastInsertId = result.isNotEmpty ? result.first.values.first : null;

    if (lastInsertId != null) {
      log?.finest('Added #$lastInsertId: $record');
    } else {
      log?.finest('Added: $record');
    }

    return lastInsertId;
  }

  @override
  Future<void> updateRecord({
    required String name,
    required String key,
    required dynamic keyValue,
    // TODO: Add uniqueKeys
    required Map<String, dynamic> record,
  }) async {
    final hasPrimaryKey = record.containsKey(key) && (record[key] != null);
    final rawRecord = hasPrimaryKey ? record : ({...record}..remove(key));
    final columns = rawRecord.keys;
    final columnsPlaceholders = List.filled(columns.length, '?').join(', ');
    final values = rawRecord.values;
    final updateColumns = columns.where((c) => (c != key));

    await executeSql(
      'INSERT INTO $name (${columns.join(', ')}) VALUES ($columnsPlaceholders) '
      'ON CONFLICT($key) DO UPDATE SET ${updateColumns.map((k) => '$k = excluded.$k').join(', ')}',
      values.toList(growable: false),
    );

    // await executeSql(
    //   'UPDATE $name SET ${record.keys.map((k) => '$k = ?').join(', ')} WHERE $key = ?',
    //   [...record.values, keyValue],
    // );

    log?.finest('Updated #$keyValue: $record');
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

    log?.finest('Deleted #$keyValue: $record');
  }

  @override
  Future<void> deleteWhereRecords({
    required String name,
    required BreezeFilterExpression filter,
  }) async {
    final (whereSql, whereParams) = _buildWhere(name, filter);
    final whereClause = 'WHERE $whereSql';

    // Skip and do not delete anything if the condition is empty.
    if (whereSql.isEmpty) {
      return;
    }

    await executeSql(
      'DELETE FROM $name $whereClause',
      whereParams,
    );

    log?.finest('Deleted from "$name" where $filter');
  }

  @override
  Future<T?> aggregate<T extends num>(
    String name,
    BreezeAggregationOp op,
    String column, [
    BreezeAbstractFetchRequest? request,
  ]) async {
    final operator = switch (op) {
      BreezeAggregationOp.count => 'COUNT($column)',
      BreezeAggregationOp.sum => 'TOTAL($column)',
      BreezeAggregationOp.avg => 'AVG($column)',
      BreezeAggregationOp.min => 'MIN($column)',
      BreezeAggregationOp.max => 'MAX($column)',
    };

    ResultSet? result;

    switch (request) {
      case BreezeFetchRequest(filter: final filter, sortBy: final sortBy):
        final (:sql, :params) = buildSql(
          name,
          addPrefixToSelect: false,
          columns: operator,
          filter: filter,
          sortBy: sortBy,
        );
        result = await executeSql(sql, params, typeConverters);
        break;

      case BreezeSqliteRequest(sql: final sql, params: final params):
        result = await executeSql(sql, params, typeConverters);
        break;

      default:
        final (:sql, :params) = buildSql(name, columns: operator);
        result = await executeSql(sql, params, typeConverters);
        break;
    }

    final rawValue = result.isNotEmpty ? (result.first.values.first as num?) : null;

    late final num? value;
    if (T == int) {
      value = rawValue?.toInt();
    } else if (T == double) {
      value = rawValue?.toDouble();
    } else {
      value = rawValue;
    }

    log?.finest('Aggregate "$name" $operator${(request != null) ? ' $request' : ''} = $value');

    return value as T?;
  }

  // @override
  // Future<void> fetchHasManyThrough(
  //   BreezeModelResolvedHasManyThroughRelation<BreezeBaseModel> relation,
  //   List<Map<String, dynamic>> records,
  //   BreezeModelBlueprint<BreezeBaseModel> relationBlueprint,
  // ) async {
  //   throw UnimplementedError();
  // }

  // ---

  ({String sql, List<dynamic> params}) sqlWhereOf(
    String table,
    BreezeFilterExpression? filter, {
    String prefix = 'WHERE',
    String suffix = '',
  }) {
    final (whereSql, whereParams) = _buildWhere(table, filter);
    final whereClause = whereSql.isNotEmpty ? '$prefix ($whereSql) $suffix'.trim() : '';

    return (
      sql: whereClause,
      params: whereParams,
    );
  }

  // ---

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
      log?.finer('$sql; -> ${_convertJsonParams(params)}');
    } else {
      log?.finer(sql);
    }
  }

  Future<ResultSet> executeSql(
    String sql, [
    List<Object?> parameters = const [],
    Set<BreezeBaseTypeConverter> typeConverters = const {},
  ]) async {
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

      final paramValue = toStorageValue(
        param,
        dartType: param.runtimeType,
        converters: typeConverters,
      );

      params.add(paramValue);
    }

    _logQuery(sql, params);

    try {
      final result = await database.then(
        (db) => db.execute(
          sql,
          params,
        ),
      );

      return result;
    } catch (error) {
      onError?.call(error, StackTrace.current);

      // Rethrow the exception with a new stack trace pointing to where the request was called
      // ignore: use_rethrow_when_possible
      throw error;
    }
  }

  @Deprecated('Remove this')
  @protected
  List<SqlJoin> createJoinsForNested(String table, List<BreezeModelColumn> columns) {
    final result = <SqlJoin>[];

    for (final column in columns) {
      /*
      final type = switch (column) {
        BreezeModelColumn<List<BreezeBaseModel>> _ => column.listType,
        BreezeModelColumn<BreezeBaseModel> _ => column.type,
        _ => null,
      };
      */

      print('{!} ${column.baseType}');

      /*
      final type = column.genericType
      /*(column is BreezeModelColumn<List<BreezeBaseModel>>) //
          ? column.listType
          : column.type*/
      ;
      */

      // final type = column.isSubtype<List<BreezeBaseModel>>() ? column.genericType : column.type;

      // final type =
      //     (column is BreezeModelColumn<List>) //
      //     ? column.listType
      //     : column.type;

      final type = column.type;

      final columnBlueprint = blueprintOf(type /* ! */);
      // TODO: Recursive buildJoins(columnBlueprint.nestedModelColumns)

      result.add(
        SqlJoin(
          parentTable: table,
          table: columnBlueprint.name,
          columns: columnBlueprint.columns.values
              .map(
                (c) => SqlColumn(
                  table: columnBlueprint.name,
                  name: c.name,
                  alias: '__${column.name}__${c.name}',
                ),
              )
              .toList(growable: false),
          constraint: '$table.${column.name} = ${columnBlueprint.name}.id',
        ),
      );
    }

    return result;
  }

  @Deprecated('Remove this')
  @protected
  List<Map<String, dynamic>> expandJoinsToNested(List<Map<String, dynamic>> rows, List<BreezeModelColumn> columns) {
    final result = <Map<String, dynamic>>[];

    for (final column in columns) {
      // final columnBlueprint = blueprintOf(column.type /* ! */);
      // TODO: Recursive expandJoinsToNested('_${rows[column.name]}', columnBlueprint.nestedModelColumns)

      for (final row in rows) {
        final nestedRow = {...row};
        final Map<String, dynamic> nestedRecord = {};

        final nestedKeys = nestedRow.keys.where((k) => k.startsWith('__${column.name}__'));
        for (final nestedKey in nestedKeys) {
          final key = nestedKey.substring('__${column.name}__'.length);
          nestedRecord[key] = nestedRow[nestedKey];
        }

        nestedRow.removeWhere((key, _) => nestedKeys.contains(key));

        if (nestedRecord.isNotEmpty) {
          nestedRow[column.name] = nestedRecord;
        }

        result.add(nestedRow);
      }
    }

    return result;
  }

  @Deprecated('Remove this')
  @protected
  Future<List<Map<String, dynamic>>> loadNested(
    List<Map<String, dynamic>> rows,
    List<BreezeModelColumn> columns,
  ) async {
    final resultRows = rows
        .map(
          (row) => Map<String, dynamic>.from(row),
        )
        .toList();

    for (final column in columns) {
      final columnBlueprint = blueprintOf(column.type /* ! */);
      if (columnBlueprint.key != null) {
        final ids = {
          for (final row in resultRows)
            if (row.containsKey(column.name)) row[column.name],
        }.toList(growable: false);
        final nestedRows = Map.fromIterable(
          await fetchAllRecords(
            table: columnBlueprint.name,
            request: BreezeFetchRequest(
              filter: BreezeField(columnBlueprint.key!).inside(ids),
            ),
            blueprint: columnBlueprint,
          ),
          key: (row) => row[columnBlueprint.key!],
        );

        for (final row in resultRows) {
          final rowFk = row[column.name];
          if (rowFk != null) {
            final nested = nestedRows[rowFk];
            if (nested != null) {
              row[column.name] = Map<String, dynamic>.from(nested);
            }
          }
        }
      }
    }

    return resultRows;
  }

  @protected
  ({String sql, List<dynamic> params}) buildSql(
    String table, {
    String columns = '*',
    BreezeFilterExpression? filter,
    List<SqlJoin> joins = const [],
    List<BreezeSortBy> sortBy = const [],
    int? limit,
    int? offset,
    bool addPrefixToSelect = true,
  }) {
    final (joinsColumns, joinsTables) = _buildJoins(joins);

    final (whereSql, whereParams) = _buildWhere(table, filter);
    final whereClause = whereSql.isNotEmpty ? ' WHERE $whereSql' : '';

    final (orderSql, orderParams) = _buildOrderBy(table, sortBy);
    final orderClause = orderSql.isNotEmpty ? ' ORDER BY $orderSql' : '';

    final limitClause = _buildLimit(limit, offset);

    final selectColumns = addPrefixToSelect ? '$table.$columns' : columns;

    return (
      sql: 'SELECT $selectColumns$joinsColumns FROM $table$joinsTables$whereClause$orderClause$limitClause',
      params: [...whereParams, ...orderParams],
    );
  }

  (String columns, String tables) _buildJoins(List<SqlJoin> joins) {
    final columns = <String>[];
    final tables = <String>[];

    for (final join in joins) {
      columns.addAll(join.columns.map((c) => c.fullName));
      tables.add(
        'LEFT JOIN ${join.table} ON ${join.constraint}',
      );
    }

    return (
      columns.isNotEmpty ? ', ${columns.join(', ')}' : '',
      tables.isNotEmpty ? ' ${tables.join(', ')}' : '',
    );
  }

  (String, List<dynamic>) _buildWhere(String table, BreezeFilterExpression? filter) {
    return switch (filter) {
      BreezeComparisonFilter f => _buildComparison(table, f),
      BreezeBetweenFilter f => _buildBetween(table, f),
      BreezeInFilter f => _buildIn(table, f),
      BreezeAndFilter f => _combineFilter(table, 'AND', f.left, f.right),
      BreezeOrFilter f => _combineFilter(table, 'OR', f.left, f.right),
      BreezeNotFilter f => _buildNot(table, f.expression),
      _ => ('', []),
    };
  }

  (String, List<dynamic>) _buildComparison(String table, BreezeComparisonFilter f) {
    // Convert comparison with NULL to IS NULL/IS NOT NULL expression.
    if ((f.operator == '==' || f.operator == '!=') && (f.value == null)) {
      final op = switch (f.operator) {
        '==' => 'IS',
        '!=' => 'IS NOT',
        _ => throw UnsupportedError('Invalid operator: ${f.operator}'),
      };
      return (
        '$table.${f.field} $op NULL',
        [],
      );
    }

    final op = switch (f.operator) {
      '==' => '=',
      '!=' => '!=',
      '<' => '<',
      '<=' => '<=',
      '>' => '>',
      '>=' => '>=',
      _ => throw UnsupportedError('Invalid operator: ${f.operator}'),
    };

    if (f.value is BreezeExpressionValue) {
      return (
        '$table.${f.field} $op ${f.value.expr}',
        [],
      );
    } else {
      return (
        '$table.${f.field} $op ?',
        [f.value],
      );
    }
  }

  (String, List<dynamic>) _buildBetween(String table, BreezeBetweenFilter f) {
    return (
      '$table.${f.field} BETWEEN ? AND ?',
      [f.min, f.max],
    );
  }

  (String, List<dynamic>) _buildIn(String table, BreezeInFilter f) {
    if (f.values.isEmpty) return ('0', []);
    final placeholders = List.filled(f.values.length, '?').join(', ');
    final op = !f.inverse ? 'IN' : 'NOT IN';
    return (
      '$table.${f.field} $op ($placeholders)',
      f.values.toList(growable: false),
    );
  }

  (String, List<dynamic>) _combineFilter(
    String table,
    String op,
    BreezeFilterExpression left,
    BreezeFilterExpression right,
  ) {
    final (leftSql, leftArgs) = _buildWhere(table, left);
    final (rightSql, rightArgs) = _buildWhere(table, right);

    if (left is BreezeNoneFilter && right is BreezeNoneFilter) {
      return ('', []);
    }
    if (right is BreezeNoneFilter) {
      return (
        leftSql,
        [...leftArgs],
      );
    }
    if (left is BreezeNoneFilter) {
      return (
        rightSql,
        [...rightArgs],
      );
    } else {
      return (
        '($leftSql $op $rightSql)',
        [...leftArgs, ...rightArgs],
      );
    }
  }

  (String, List<dynamic>) _buildNot(String table, BreezeFilterExpression expression) {
    final (notSql, notArgs) = _buildWhere(table, expression);
    final sql = (notSql.startsWith('(') && notSql.endsWith(')')) ? notSql : '($notSql)';
    return (
      'NOT $sql',
      [...notArgs],
    );
  }

  (String, List<dynamic>) _buildOrderBy(String table, List<BreezeSortBy> orderBy) {
    final result = orderBy
        .map((order) => '$table.${order.column} ${_orderDirections[order.direction]}')
        .join(
          ', ',
        );
    return (result, []);
  }

  String _buildLimit(int? limit, int? offset) {
    final result = StringBuffer();

    if (limit != null) {
      result.write(' LIMIT $limit');
    }

    if (limit != null && offset != null) {
      result.write(' OFFSET $offset');
    }

    return result.toString();
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
        () => DynamicLibrary.open(p.join(sqliteLibPath, lib)),
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
          () => DynamicLibrary.open(p.join(sqliteLibPath!, lib)),
        );
      }
    }

    final db = super.open(options);
    return db;
  }
}

class SqlColumn {
  final String? table;
  final String name;
  final String? alias;

  String get fullName {
    final result = StringBuffer();

    if (table != null) {
      result.write('$table.');
    }

    result.write(name);

    if (alias != null) {
      result.write(' AS $alias');
    }

    return result.toString();
  }

  const SqlColumn({
    this.table,
    required this.name,
    this.alias,
  });
}

class SqlJoin {
  final String parentTable;
  final String table;
  final List<SqlColumn> columns;
  final String constraint;

  const SqlJoin({
    required this.parentTable,
    required this.table,
    required this.columns,
    required this.constraint,
  });
}
