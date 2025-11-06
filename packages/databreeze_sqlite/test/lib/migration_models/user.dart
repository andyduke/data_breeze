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
      BreezeModelSchemaVersion(
        version: 1,
        name: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('name'),
        },
      ),

      BreezeModelSchemaVersion(
        version: 2,
        name: 'persons',
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
      BreezeModelSchemaVersion(
        version: 1,
        name: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('name'),
        },
      ),

      BreezeModelSchemaVersion.deleted(
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

class MUserAddColumn extends BreezeModel<int> {
  static final blueprint = BreezeModelBlueprint.versioned(
    versions: {
      BreezeModelSchemaVersion(
        version: 1,
        name: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('name'),
        },
      ),

      BreezeModelSchemaVersion(
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
      BreezeModelSchemaVersion(
        version: 1,
        name: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('name'),
          BreezeModelColumn<int>('age'),
        },
      ),

      BreezeModelSchemaVersion(
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
      BreezeModelSchemaVersion(
        version: 1,
        name: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('firstName'),
        },
      ),

      BreezeModelSchemaVersion(
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
      BreezeModelSchemaVersion(
        version: 1,
        name: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<int>('code'),
        },
      ),

      BreezeModelSchemaVersion(
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
      BreezeModelSchemaVersion(
        version: 1,
        name: 'users',
        columns: {
          BreezeModelColumn<int>('id', isPrimaryKey: true),
          BreezeModelColumn<String>('name'),
        },
      ),

      BreezeModelSchemaVersion(
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
