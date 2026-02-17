import 'package:databreeze/src/model_blueprint.dart';
import 'package:meta/meta.dart';

/// The base class of the model is the interface of a family of model classes.
///
/// {@template breeze.model.description}
/// To define a model, you need to create a class inheriting from
/// [BreezeModel] or [BreezeViewModel] and define a model "blueprint."
///
/// For convenience, the model "blueprint" can be defined in a mixin,
/// which also specifies a list of model field constants for use in
/// the "blueprint," JSON encoding/decoding, and conditional
/// expressions in Query.
///
/// ```dart
/// mixin NoteModel {
///   static final blueprint = BreezeModelBlueprint<Note>(
///     name: 'notes',
///     columns: {
///       BreezeModelColumn<String>(title),
///       BreezeModelColumn<String?>(text),
///     },
///     builder: fromRecord,
///   );
///
///   static Note fromRecord(Map<String, dynamic> map) => Note(
///     title: map[title],
///     text: map[text],
///   );
///
///   static const title = BreezeField('title');
///   static const text = BreezeField('text');
/// }
///
/// class Note extends BreezeModel<int> with NoteModel {
///   String title;
///
///   String? text;
///
///   Note({
///     required this.title,
///     required this.text,
///   });
///
///   BreezeModelBlueprint get schema => NoteModel.blueprint;
///
///   @override
///   Map<String, dynamic> toRecord() => {
///     NoteModel.title: title,
///     NoteModel.text: text,
///   };
/// }
/// ```
///
/// ---
///
/// Field constants can be used in filters and queries as follows:
///
/// ```dart
/// // Filter
/// final notes = await store.fetchAll<Note>(
///   filter: NoteModel.title.contains('tasks'),
/// );
///
/// // Query
/// final query = BreezeQueryAll<Note>(
///   filter: NoteModel.title.contains('tasks'),
/// );
/// final notes = query.fetch(store);
/// ```
///
/// #### Configuring a Model in a Store
///
/// For a model to be available in a store, its "blueprint" must be
/// specified when instantiating the store:
/// ```dart
/// final store = BreezeSqliteStore.inMemory(
///   models: {
///     NoteModel.blueprint,
///   },
/// );
/// ```
/// {@endtemplate}
///
/// See also:
/// - [BreezeModel]
/// - [BreezeViewModel]
abstract class BreezeBaseModel {}

/// A view model is a class that maps immutable data from a database
/// (such as a View)  or external API.
///
/// For mutable data, see the [BreezeModel] class.
///
/// ### Model definition
///
/// {@macro breeze.model.description}
@immutable
abstract mixin class BreezeViewModel implements BreezeBaseModel {}

/// A model is a class that maps data from a database or external API.
///
/// [BreezeModel] is a model for mutable data for which the store
/// supports CRUD operations.
///
/// For immutable data, such as a `View` in a database,
/// see the [BreezeViewModel] class.
///
/// ### Unique identifier
///
/// A mutable model must have a unique identifier (primary key or
/// primary column), the type of which must be specified in the
/// generic parameter `K` during inheritance.
///
/// This identifier will be available as the [id] model property.
///
/// ### Equality
///
/// The mutable model implements model equality by default based on
/// a unique identifier.
///
/// To achieve model equality based on field values, you must
/// override the `==` operator and the `hashCode` property.
///
/// ### Model definition
///
/// {@macro breeze.model.description}
abstract mixin class BreezeModel<K> implements BreezeBaseModel {
  /// A value that uniquely identifies the model with
  /// a record in the store.
  K? id;

  /// Is the model "frozen"?
  ///
  /// Typically true for deleted records.
  @internal
  bool isFrozen = false;

  /// Is the model new, i.e., not yet added to the store?
  ///
  /// Such a model does not yet have a unique identifier.
  bool get isNew => (id == null);

  /// It should return the "blueprint" of the model.
  ///
  /// See:
  /// - [BreezeModelBlueprint]
  BreezeModelBlueprint get schema;

  /// Returns a map of the "fields" in the store for a single
  /// record, containing the values ​​from the corresponding
  /// model properties.
  ///
  /// The values ​​must be Dart scalar types or types for which
  /// type converters are specified in the
  /// store or model "blueprint."
  Map<String, dynamic> toRecord();

  /// Converts model field values ​​into a record for transfer
  /// to the store.
  ///
  /// Uses the result of the [toRecord] method, adding a
  /// unique identifier to it.
  @internal
  Map<String, dynamic> toRawRecord() => {
    ...toRecord(),
    if (schema.key != null) schema.key!: id,
  };

  /// Callback called after a model has been added to the store.
  Future<void> afterAdd() async {}

  /// Callback called before the model is saved to the store.
  ///
  /// See also:
  /// - [afterUpdate]
  Future<void> beforeUpdate() async {}

  /// Callback called after the model is saved to the store.
  ///
  /// See also:
  /// - [beforeUpdate]
  Future<void> afterUpdate() async {}

  /// Callback called before a model is removed from the store.
  ///
  /// See also:
  /// - [afterDelete]
  Future<void> beforeDelete() async {}

  /// Callback called after a model is removed from the store.
  ///
  /// See also:
  /// - [beforeDelete]
  Future<void> afterDelete() async {}

  @override
  bool operator ==(covariant BreezeModel<K> other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
