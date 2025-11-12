import 'package:databreeze/src/migration/migration_manager.dart';
import 'package:databreeze/src/model.dart';
import 'package:databreeze/src/model_blueprint.dart';
import 'package:databreeze/src/model_schema.dart';
import 'package:databreeze/src/store.dart';
import 'package:databreeze/src/type_converters.dart';

abstract class BreezeMigrationStrategy<D> {
  const BreezeMigrationStrategy();

  Future<void> migrate(BreezeStore store, [D? extra]);
}

abstract class BreezeSchemaMigrationStrategy<D> extends BreezeMigrationStrategy<D> {
  final bool Function(BreezeBaseModelSchema schema)? filter;
  final BreezeMigrationCallback<D>? onBeforeMigration;
  final BreezeMigrationCallback<D>? onAfterMigration;
  final BreezeMigrationBeforeVersionCallback<D>? onBeforeVersion;
  final BreezeMigrationAfterVersionCallback<D>? onAfterVersion;

  const BreezeSchemaMigrationStrategy({
    this.filter,
    this.onBeforeMigration,
    this.onAfterMigration,
    this.onBeforeVersion,
    this.onAfterVersion,
  });

  @override
  Future<void> migrate(BreezeStore store, [D? db]) async {
    // Filter only models with a primary key (ignore view models).
    Iterable<BreezeBaseModelSchema> schemes = store.blueprints.values.whereType<BreezeModelBlueprint<BreezeModel>>();

    if (filter != null) {
      schemes = schemes.where((blueprint) => filter!(blueprint));
    }

    await migrateSchemas(schemes, db, store.typeConverters);
  }

  // @protected
  Future<void> migrateSchemas(
    Iterable<BreezeBaseModelSchema> schemas, [
    D? db,
    Set<BreezeBaseTypeConverter> typeConverters = const {},
  ]);
}
