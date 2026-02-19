abstract class BzSchemaChange {
  const BzSchemaChange();

  const factory BzSchemaChange.column(String name, Type type, {bool isNullable /* TODO: bool isUnique = false */}) =
      BzAppendField;

  const factory BzSchemaChange.rename(String name, {required String to}) = BzRenameField;

  const factory BzSchemaChange.delete(String name) = BzDeleteField;
}

class BzAppendField extends BzSchemaChange {
  final String name;
  final Type type;
  final bool isNullable;

  const BzAppendField(
    this.name,
    this.type, {
    this.isNullable = false,
    /* TODO: bool isUnique = false */
  }) /* : assert(
         // TODO: Allow any type, due to TypeConverter
         type == String || type == num || type == int || type == double || type == bool,
         'Invalid type "$type", only simple data types such as String, Number, Boolean are allowed.',
       ) */;
}

class BzRenameField extends BzSchemaChange {
  final String from;
  final String to;

  const BzRenameField(this.from, {required this.to});
}

class BzDeleteField extends BzSchemaChange {
  final String name;

  const BzDeleteField(this.name);
}
