import 'package:databreeze/databreeze.dart';
import 'package:databreeze_sqlite/src/sqlite_store.dart';
import 'package:sqlite_async/sqlite_async.dart';

class BreezeSqliteMigrations extends BreezeMigrationStrategy<SqliteConnection> {
  final SqliteMigrations migrations;

  const BreezeSqliteMigrations(this.migrations);

  @override
  Future<void> migrate(covariant BreezeSqliteStore store, [SqliteConnection? db]) async {
    if (db != null) {
      await migrations.migrate(db);
    }
  }
}
