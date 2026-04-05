import 'package:databreeze/src/model.dart';
import 'package:databreeze/src/model_column.dart';
import 'package:databreeze/src/model_schema.dart';
import 'package:databreeze/src/relations/model_relation.dart';
import 'package:databreeze/src/type_converters.dart';
import 'package:databreeze/src/types.dart';

typedef BreezeModelBlueprintBuilder<M extends BreezeBaseModel> = M Function(BreezeDataRecord record);

class BreezeModelBlueprint<M extends BreezeBaseModel> extends BreezeModelVersionedSchema
    with BreezeRelationalModelSchema {
  final BreezeModelBlueprintBuilder<M> builder;

  @override
  final Set<BreezeBaseTypeConverter> typeConverters;

  @override
  final Set<BreezeModelRelation> relations;

  BreezeModelBlueprint({
    required String name,
    required Set<BreezeModelColumn> columns,
    Set<Object?> tags = const {},
    required BreezeModelBlueprintBuilder<M> builder,
    Set<BreezeBaseTypeConverter> typeConverters = const {},
    Set<BreezeModelRelation> relations = const {},
  }) : this.versioned(
         versions: {
           BreezeModelSchemaVersion(
             name: name,
             columns: columns,
             tags: tags,
           ),
         },
         builder: builder,
         typeConverters: typeConverters,
         relations: relations,
       );

  BreezeModelBlueprint.versioned({
    required Set<BreezeModelSchemaVersion> versions,
    required this.builder,
    this.typeConverters = const {},
    this.relations = const {},
  }) : super(versions) {
    // TODO: Validate [columns] for the presence of columns for [relations].
  }

  Type get type => M;

  /// Creates a copy of the model blueprint, changes the model type,
  /// and also allows you to modify other blueprint parameters.
  ///
  /// Note: Allows copying only for inherited models.
  BreezeModelBlueprint<T> extend<T extends M>({
    String? name,
    Set<BreezeModelColumn>? columns,
    required T Function(Map<String, dynamic> raw) builder,
    Set<BreezeBaseTypeConverter>? typeConverters,
    Set<BreezeModelRelation> relations = const {},
  }) {
    return BreezeModelBlueprint<T>(
      name: name ?? this.name,
      columns: columns ?? this.columns.values.toSet(),
      builder: builder,
      typeConverters: typeConverters ?? this.typeConverters,
      relations: relations,
    );
  }

  @Deprecated('Remove this')
  List<BreezeModelColumn> get nestedModelColumns => columns.values
      .where(
        // (column) => column.isSubtype<BreezeBaseModel>() || column.isSubtype<List<BreezeBaseModel>>(),
        // (column) => column is BreezeModelColumn<BreezeBaseModel> || column is BreezeModelColumn<List<BreezeBaseModel>>,
        (column) {
          print('{???} ${column.type} ${column.genericType} ${column.baseType}');
          return column is BreezeModelColumn<BreezeBaseModel> || column is BreezeModelColumn<List<BreezeBaseModel>>;
        },
      )
      .toList(growable: false);

  @Deprecated('Remove this')
  Set<BreezeBaseTypeConverter> relationsConverters(
    BreezeStorageTypeConverters converters,
    BreezeBlueprintLookup blueprintOf,
  ) {
    final Set<BreezeBaseTypeConverter> result = {};

    for (final relation in relations) {
      final relationBlueprint = blueprintOf(relation.type);
      result.add(
        _RelationModelTypeConverter(
          relation.type,
          relationBlueprint,
          converters,
          blueprintOf,
        ),
      );
    }

    return result;
  }

  /// Create a model instance from a raw record
  M fromRecord(
    Map<String, dynamic> record,
    BreezeStorageTypeConverters converters,
    BreezeBlueprintLookup blueprintOf,
  ) {
    final typedRecord = fromRaw(record, converters, blueprintOf);
    final result = builder(typedRecord);

    if ((result is BreezeModel) && (key != null)) {
      result.id = typedRecord[key];
    }

    return result;
  }

  List<M> fromRecordsList(
    Iterable<Map<String, dynamic>> records,
    BreezeStorageTypeConverters converters,
    BreezeBlueprintLookup blueprintOf,
  ) {
    final blueprint = blueprintOf(M) as BreezeModelBlueprint<M>;
    final result = records.map((r) => blueprint.fromRecord(r, converters, blueprintOf)).toList();
    return result;
  }

  /// Convert db's data types to schema column types
  Map<String, dynamic> fromRaw(
    Map<String, dynamic> raw,
    BreezeStorageTypeConverters converters,
    BreezeBlueprintLookup blueprintOf,
  ) {
    final extendedTypeConverters = {
      ...typeConverters,
      // ...relationsConverters(converters, blueprintOf),
    };

    // Convert relations
    final relMaps = Map<String, BreezeModelRelation>.fromIterable(relations, key: (r) => r.name);
    for (final MapEntry(key: relName, value: rel) in relMaps.entries) {
      if (raw.containsKey(relName)) {
        final relBlueprint = blueprintOf(rel.type);
        final rawRelValue = raw[relName];
        if (rawRelValue is Iterable<Map<String, dynamic>>) {
          raw[relName] = relBlueprint.fromRecordsList(rawRelValue, converters, blueprintOf);
        } else {
          raw[relName] = relBlueprint.fromRecord(rawRelValue, converters, blueprintOf);
        }
      }
    }

    return raw.map(
      (k, v) => MapEntry(
        k,
        valueFromStorage(
          k,
          v,
          converters,
          extendedTypeConverters,
          blueprintOf,
        ),
      ),
    );
  }

  /// Convert schema column types into db's data types
  Map<String, dynamic> toRaw(
    Map<String, dynamic> raw,
    BreezeStorageTypeConverters converters,
    BreezeBlueprintLookup blueprintOf,
  ) {
    final extendedTypeConverters = {
      ...typeConverters,
      // ...relationsConverters(converters, blueprintOf),
    };

    /*
    for (final relation in relations) {
      final relationInfo = relation.resolve(this);

      if (raw.containsKey(relationInfo.name)) {
        raw[relationInfo.foreignKey] = raw[relationInfo.name];
        raw.remove(relationInfo.name);
      }
    }
    */

    /*
    return raw.map(
      (k, v) => MapEntry(
        k,
        valueToStorage(
          k,
          v,
          converters,
          extendedTypeConverters,
          blueprintOf,
        ),
      ),
    );
    */

    final relationNames = relations.map((rel) => rel.name);
    final result = {
      for (final MapEntry(key: key, value: value) in raw.entries)
        key: (relationNames.contains(key))
            ? value
            : valueToStorage(
                key,
                value,
                converters,
                extendedTypeConverters,
                blueprintOf,
              ),
    };
    return result;
  }

  dynamic valueFromStorage(
    String name,
    dynamic value,
    BreezeStorageTypeConverters converters,
    Set<BreezeBaseTypeConverter> typeConverters,
    BreezeBlueprintLookup blueprintOf,
  ) {
    final column = columns[name];

    if (column == null) {
      return value;
    }

    if (!column.isNullable && value == null) {
      if (column.defaultValue != null) {
        return column.defaultValue;
      } else {
        throw Exception('[valueFromStorage] The value for column "$name" cannot be null.');
      }
    }

    if (value == null) {
      return null;
    } else {
      final result = converters.toDartValue(
        value,
        dartType: column.type,
        converters: typeConverters,
      );
      return result ?? value;
    }
  }

  dynamic valueToStorage(
    String name,
    dynamic value,
    BreezeStorageTypeConverters converters,
    Set<BreezeBaseTypeConverter> typeConverters,
    BreezeBlueprintLookup blueprintOf,
  ) {
    final column = columns[name]!;

    if (!column.isAutoGenerate && !column.isNullable && value == null) {
      throw Exception('[valueToStorage] The value for column "$name" cannot be null.');
    }

    if (value == null) {
      return null;
    } else {
      final result = converters.toStorageValue(
        value,
        dartType: column.type,
        converters: typeConverters,
      );
      return result ?? value;
    }
  }
}

@Deprecated('Remove this')
class _RelationModelTypeConverter<M extends BreezeBaseModel> extends BreezeBaseTypeConverter<M, Map<String, dynamic>> {
  final Type modelType;
  final BreezeModelBlueprint<M> blueprint;
  final BreezeStorageTypeConverters converters;
  final BreezeBlueprintLookup blueprintOf;

  const _RelationModelTypeConverter(this.modelType, this.blueprint, this.converters, this.blueprintOf);

  @override
  bool isDartType(Type type) {
    final result = (modelType == type);
    return result;
  }

  @override
  bool isStorageType(Type type) {
    final result = (type == <String, dynamic>{}.runtimeType);
    return result;
  }

  @override
  bool canConvertToStorage(Type dartType) {
    /*
    if (blueprint is BreezeModelBlueprint<BreezeModel>) {
      return super.canConvertToStorage(dartType);
    } else {
      return false;
    }
    */
    return false;
  }

  @override
  M toDart(Map<String, dynamic> value) => blueprint.fromRecord(value, converters, blueprintOf);

  /*
  @override
  Map<String, dynamic> toStorage(M value) =>
      blueprint.toRaw((value as BreezeModel).toRawRecord(), converters, blueprintOf);
  */

  @override
  Map<String, dynamic> toStorage(M value) => {};
}
