import 'package:databreeze/databreeze.dart';
import 'package:databreeze_sqlite/databreeze_sqlite.dart';

class MUser extends BreezeModel<int> {
  static final blueprint = BreezeModelBlueprint.versioned(
    versions: {
      BreezeSqliteModelSchemaVersion(
        version: 1,
        name: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('name'),
        },
      ),
    },
    builder: MUser.fromRecord,
  );

  @override
  BreezeModelBlueprint get schema => blueprint;

  String name;

  MUser({
    required this.name,
  });

  factory MUser.fromRecord(BreezeDataRecord record) => MUser(
    name: record['name'],
  );

  @override
  Map<String, dynamic> toRecord() => {
    'name': name,
  };
}

class MUserRenamed extends BreezeModel<int> {
  static final blueprint = BreezeModelBlueprint.versioned(
    versions: {
      BreezeSqliteModelSchemaVersion(
        version: 1,
        name: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('name'),
        },
      ),

      BreezeSqliteModelSchemaVersion(
        version: 2,
        name: 'persons',
        prevName: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('name'),
        },
      ),
    },
    builder: MUserRenamed.fromRecord,
  );

  @override
  BreezeModelBlueprint get schema => blueprint;

  String name;

  MUserRenamed({
    required this.name,
  });

  factory MUserRenamed.fromRecord(BreezeDataRecord record) => MUserRenamed(
    name: record['name'],
  );

  @override
  Map<String, dynamic> toRecord() => {
    'name': name,
  };
}

class MUserDeleted extends BreezeModel<int> {
  static final blueprint = BreezeModelBlueprint.versioned(
    versions: {
      BreezeSqliteModelSchemaVersion(
        version: 1,
        name: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('name'),
        },
      ),

      BreezeSqliteModelSchemaVersion.deleted(
        version: 2,
        name: 'users',
      ),
    },
    builder: MUserDeleted.fromRecord,
  );

  @override
  BreezeModelBlueprint get schema => blueprint;

  String name;

  MUserDeleted({
    required this.name,
  });

  factory MUserDeleted.fromRecord(BreezeDataRecord record) => MUserDeleted(
    name: record['name'],
  );

  @override
  Map<String, dynamic> toRecord() => {
    'name': name,
  };
}

// ---

class MUserWithHooks extends BreezeModel<int> {
  static final blueprint = BreezeModelBlueprint.versioned(
    versions: {
      BreezeSqliteModelSchemaVersion(
        version: 1,
        name: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('name'),
        },
        onBeforeMigrate: (db) async => db.execute('PRAGMA user_version = 1'),
        onAfterMigrate: (db) async => db.execute('PRAGMA user_version = 2'),
      ),
    },
    builder: MUserWithHooks.fromRecord,
  );

  @override
  BreezeModelBlueprint get schema => blueprint;

  String name;

  MUserWithHooks({
    required this.name,
  });

  factory MUserWithHooks.fromRecord(BreezeDataRecord record) => MUserWithHooks(
    name: record['name'],
  );

  @override
  Map<String, dynamic> toRecord() => {
    'name': name,
  };
}

class MUserRenamedWithHooks extends BreezeModel<int> {
  static final blueprint = BreezeModelBlueprint.versioned(
    versions: {
      BreezeSqliteModelSchemaVersion(
        version: 1,
        name: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('name'),
        },
      ),

      BreezeSqliteModelSchemaVersion(
        version: 2,
        name: 'persons',
        prevName: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('name'),
        },
        onBeforeMigrate: (db) async => db.execute('PRAGMA user_version = 1'),
        onAfterMigrate: (db) async => db.execute('PRAGMA user_version = 2'),
      ),
    },
    builder: MUserRenamedWithHooks.fromRecord,
  );

  @override
  BreezeModelBlueprint get schema => blueprint;

  String name;

  MUserRenamedWithHooks({
    required this.name,
  });

  factory MUserRenamedWithHooks.fromRecord(BreezeDataRecord record) => MUserRenamedWithHooks(
    name: record['name'],
  );

  @override
  Map<String, dynamic> toRecord() => {
    'name': name,
  };
}

class MUserDeletedWithHooks extends BreezeModel<int> {
  static final blueprint = BreezeModelBlueprint.versioned(
    versions: {
      BreezeSqliteModelSchemaVersion(
        version: 1,
        name: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('name'),
        },
      ),

      BreezeSqliteModelSchemaVersion.deleted(
        version: 2,
        name: 'users',
        onBeforeMigrate: (db) async => db.execute('PRAGMA user_version = 1'),
        onAfterMigrate: (db) async => db.execute('PRAGMA user_version = 2'),
      ),
    },
    builder: MUserDeletedWithHooks.fromRecord,
  );

  @override
  BreezeModelBlueprint get schema => blueprint;

  String name;

  MUserDeletedWithHooks({
    required this.name,
  });

  factory MUserDeletedWithHooks.fromRecord(BreezeDataRecord record) => MUserDeletedWithHooks(
    name: record['name'],
  );

  @override
  Map<String, dynamic> toRecord() => {
    'name': name,
  };
}

// ---

class MUserAddColumn extends BreezeModel<int> {
  static final blueprint = BreezeModelBlueprint.versioned(
    versions: {
      BreezeSqliteModelSchemaVersion(
        version: 1,
        name: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('name'),
        },
      ),

      BreezeSqliteModelSchemaVersion(
        version: 2,
        name: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('name'),
          BreezeModelColumn<int>('age'),
        },
      ),
    },
    builder: MUserAddColumn.fromRecord,
  );

  @override
  BreezeModelBlueprint get schema => blueprint;

  String name;
  int age;

  MUserAddColumn({
    required this.name,
    required this.age,
  });

  factory MUserAddColumn.fromRecord(BreezeDataRecord record) => MUserAddColumn(
    name: record['name'],
    age: record['age'],
  );

  @override
  Map<String, dynamic> toRecord() => {
    'name': name,
    'age': age,
  };
}

class MUserDeleteColumn extends BreezeModel<int> {
  static final blueprint = BreezeModelBlueprint.versioned(
    versions: {
      BreezeSqliteModelSchemaVersion(
        version: 1,
        name: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('name'),
          BreezeModelColumn<int>('age'),
        },
      ),

      BreezeSqliteModelSchemaVersion(
        version: 2,
        name: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('name'),
        },
      ),
    },
    builder: MUserDeleteColumn.fromRecord,
  );

  @override
  BreezeModelBlueprint get schema => blueprint;

  String name;

  MUserDeleteColumn({
    required this.name,
  });

  factory MUserDeleteColumn.fromRecord(BreezeDataRecord record) => MUserDeleteColumn(
    name: record['name'],
  );

  @override
  Map<String, dynamic> toRecord() => {
    'name': name,
  };
}

class MUserRenameColumn extends BreezeModel<int> {
  static final blueprint = BreezeModelBlueprint.versioned(
    versions: {
      BreezeSqliteModelSchemaVersion(
        version: 1,
        name: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('firstName'),
        },
      ),

      BreezeSqliteModelSchemaVersion(
        version: 2,
        name: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('name'),
        },
      ),
    },
    builder: MUserRenameColumn.fromRecord,
  );

  @override
  BreezeModelBlueprint get schema => blueprint;

  String name;

  MUserRenameColumn({
    required this.name,
  });

  factory MUserRenameColumn.fromRecord(BreezeDataRecord record) => MUserRenameColumn(
    name: record['name'],
  );

  @override
  Map<String, dynamic> toRecord() => {
    'name': name,
  };
}

class MUserChangeColumnType extends BreezeModel<int> {
  static final blueprint = BreezeModelBlueprint.versioned(
    versions: {
      BreezeSqliteModelSchemaVersion(
        version: 1,
        name: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<int>('code'),
        },
      ),

      BreezeSqliteModelSchemaVersion(
        version: 2,
        name: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('code'),
        },
      ),
    },
    builder: MUserChangeColumnType.fromRecord,
  );

  @override
  BreezeModelBlueprint get schema => blueprint;

  String code;

  MUserChangeColumnType({
    required this.code,
  });

  factory MUserChangeColumnType.fromRecord(BreezeDataRecord record) => MUserChangeColumnType(
    code: record['code'],
  );

  @override
  Map<String, dynamic> toRecord() => {
    'code': code,
  };
}

class MUserRenameOneAndAddAnotherColumn extends BreezeModel<int> {
  static final blueprint = BreezeModelBlueprint.versioned(
    versions: {
      BreezeSqliteModelSchemaVersion(
        version: 1,
        name: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('name'),
        },
      ),

      BreezeSqliteModelSchemaVersion(
        version: 2,
        name: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('firstName', prevName: 'name'),
          BreezeModelColumn<String>('lastName'),
        },
      ),
    },
    builder: MUserRenameOneAndAddAnotherColumn.fromRecord,
  );

  @override
  BreezeModelBlueprint get schema => blueprint;

  String firstName;
  String lastName;

  MUserRenameOneAndAddAnotherColumn({
    required this.firstName,
    required this.lastName,
  });

  factory MUserRenameOneAndAddAnotherColumn.fromRecord(BreezeDataRecord record) => MUserRenameOneAndAddAnotherColumn(
    firstName: record['firstName'],
    lastName: record['lastName'],
  );

  @override
  Map<String, dynamic> toRecord() => {
    'firstName': firstName,
    'lastName': lastName,
  };
}

// ---

class MUserAddColumnWithHooks extends BreezeModel<int> {
  static final blueprint = BreezeModelBlueprint.versioned(
    versions: {
      BreezeSqliteModelSchemaVersion(
        version: 1,
        name: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('name'),
        },
      ),

      BreezeSqliteModelSchemaVersion(
        version: 2,
        name: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('name'),
          BreezeModelColumn<int>('age'),
        },
        onBeforeMigrate: (db) async => db.execute('PRAGMA user_version = 1'),
        onAfterMigrate: (db) async => db.execute('PRAGMA user_version = 2'),
      ),
    },
    builder: MUserAddColumnWithHooks.fromRecord,
  );

  @override
  BreezeModelBlueprint get schema => blueprint;

  String name;
  int age;

  MUserAddColumnWithHooks({
    required this.name,
    required this.age,
  });

  factory MUserAddColumnWithHooks.fromRecord(BreezeDataRecord record) => MUserAddColumnWithHooks(
    name: record['name'],
    age: record['age'],
  );

  @override
  Map<String, dynamic> toRecord() => {
    'name': name,
    'age': age,
  };
}

class MUserDeleteColumnWithHooks extends BreezeModel<int> {
  static final blueprint = BreezeModelBlueprint.versioned(
    versions: {
      BreezeSqliteModelSchemaVersion(
        version: 1,
        name: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('name'),
          BreezeModelColumn<int>('age'),
        },
      ),

      BreezeSqliteModelSchemaVersion(
        version: 2,
        name: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('name'),
        },
        onBeforeMigrate: (db) async => db.execute('PRAGMA user_version = 1'),
        onAfterMigrate: (db) async => db.execute('PRAGMA user_version = 2'),
      ),
    },
    builder: MUserDeleteColumnWithHooks.fromRecord,
  );

  @override
  BreezeModelBlueprint get schema => blueprint;

  String name;

  MUserDeleteColumnWithHooks({
    required this.name,
  });

  factory MUserDeleteColumnWithHooks.fromRecord(BreezeDataRecord record) => MUserDeleteColumnWithHooks(
    name: record['name'],
  );

  @override
  Map<String, dynamic> toRecord() => {
    'name': name,
  };
}

class MUserRenameColumnWithHooks extends BreezeModel<int> {
  static final blueprint = BreezeModelBlueprint.versioned(
    versions: {
      BreezeSqliteModelSchemaVersion(
        version: 1,
        name: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('firstName'),
        },
      ),

      BreezeSqliteModelSchemaVersion(
        version: 2,
        name: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('name'),
        },
        onBeforeMigrate: (db) async => db.execute('PRAGMA user_version = 1'),
        onAfterMigrate: (db) async => db.execute('PRAGMA user_version = 2'),
      ),
    },
    builder: MUserRenameColumnWithHooks.fromRecord,
  );

  @override
  BreezeModelBlueprint get schema => blueprint;

  String name;

  MUserRenameColumnWithHooks({
    required this.name,
  });

  factory MUserRenameColumnWithHooks.fromRecord(BreezeDataRecord record) => MUserRenameColumnWithHooks(
    name: record['name'],
  );

  @override
  Map<String, dynamic> toRecord() => {
    'name': name,
  };
}

// ---

class MProgressTemp extends BreezeModel<int> {
  static final blueprint = BreezeModelBlueprint.versioned(
    versions: {
      BreezeSqliteModelSchemaVersion(
        version: 1,
        name: 'progress',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<double>('progress'),
        },
        tags: {#temporary},
      ),

      BreezeSqliteModelSchemaVersion(
        version: 2,
        name: 'progress',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<double>('progress'),
          BreezeModelColumn<String?>('error'),
        },
        tags: {#temporary},
      ),
    },
    builder: MProgressTemp.fromRecord,
  );

  @override
  BreezeModelBlueprint get schema => blueprint;

  double progress;
  String? error;

  MProgressTemp({
    required this.progress,
    this.error,
  });

  factory MProgressTemp.fromRecord(BreezeDataRecord record) => MProgressTemp(
    progress: record['progress'],
    error: record['error'],
  );

  @override
  Map<String, dynamic> toRecord() => {
    'progress': progress,
    'error': error,
  };
}

class MProgressTempDeleteColumn extends BreezeModel<int> {
  static final blueprint = BreezeModelBlueprint.versioned(
    versions: {
      BreezeSqliteModelSchemaVersion(
        version: 1,
        name: 'progress',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<double>('progress'),
          BreezeModelColumn<String?>('error'),
        },
        tags: {#temporary},
      ),

      BreezeSqliteModelSchemaVersion(
        version: 2,
        name: 'progress',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<double>('progress'),
        },
        tags: {#temporary},
      ),
    },
    builder: MProgressTempDeleteColumn.fromRecord,
  );

  @override
  BreezeModelBlueprint get schema => blueprint;

  double progress;

  MProgressTempDeleteColumn({
    required this.progress,
  });

  factory MProgressTempDeleteColumn.fromRecord(BreezeDataRecord record) => MProgressTempDeleteColumn(
    progress: record['progress'],
  );

  @override
  Map<String, dynamic> toRecord() => {
    'progress': progress,
  };
}

class MProgressAddTemporaryTag extends BreezeModel<int> {
  static final blueprint = BreezeModelBlueprint.versioned(
    versions: {
      BreezeSqliteModelSchemaVersion(
        version: 1,
        name: 'progress',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<double>('progress'),
        },
      ),

      BreezeSqliteModelSchemaVersion(
        version: 2,
        name: 'progress',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<double>('progress'),
        },
        tags: {#temporary},
      ),
    },
    builder: MProgressAddTemporaryTag.fromRecord,
  );

  @override
  BreezeModelBlueprint get schema => blueprint;

  double progress;

  MProgressAddTemporaryTag({
    required this.progress,
  });

  factory MProgressAddTemporaryTag.fromRecord(BreezeDataRecord record) => MProgressAddTemporaryTag(
    progress: record['progress'],
  );

  @override
  Map<String, dynamic> toRecord() => {
    'progress': progress,
  };
}

class MProgressRemoveTemporaryTag extends BreezeModel<int> {
  static final blueprint = BreezeModelBlueprint.versioned(
    versions: {
      BreezeSqliteModelSchemaVersion(
        version: 1,
        name: 'progress',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<double>('progress'),
        },
        tags: {#temporary},
      ),

      BreezeSqliteModelSchemaVersion(
        version: 2,
        name: 'progress',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<double>('progress'),
        },
      ),
    },
    builder: MProgressRemoveTemporaryTag.fromRecord,
  );

  @override
  BreezeModelBlueprint get schema => blueprint;

  double progress;

  MProgressRemoveTemporaryTag({
    required this.progress,
  });

  factory MProgressRemoveTemporaryTag.fromRecord(BreezeDataRecord record) => MProgressRemoveTemporaryTag(
    progress: record['progress'],
  );

  @override
  Map<String, dynamic> toRecord() => {
    'progress': progress,
  };
}
