import 'package:databreeze_flutter_example/models/folder.dart';
import 'package:databreeze_flutter_example/models/model_types.dart';
import 'package:databreeze_flutter_example/models/note.dart';
import 'package:databreeze_flutter_example/models/task.dart';
import 'package:databreeze_flutter_example/models/task_stats.dart';
import 'package:databreeze_sqlite/databreeze_sqlite.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:sqlite_async/sqlite_async.dart';

class DbDemoStore extends BreezeSqliteStore {
  DbDemoStore({
    required Logger log,
  }) : super.inMemory(
         models: {
           Task.blueprint,
           TaskStatsModel.blueprint,
           FolderModel.blueprint,
           NoteModel.blueprint,
         },
         log: log,
         migrationStrategy: BreezeSqliteAutomaticSchemaBasedMigration(
           log: log,
           onAfterMigration: afterNotesMigration,
         ),
         typeConverters: modelTypeConverters,
       );

  static Future<void> afterNotesMigration(SqliteWriteContext db) async {
    await Future.wait([
      db.executeBatch(
        r'''
INSERT INTO folders(id, title, color) VALUES(?, ?, ?)
''',
        [
          [1, 'Folder 1', Colors.amber.toARGB32()],
          [2, 'Folder 2', Colors.lightBlue.toARGB32()],
        ],
      ),

      db.executeBatch(
        r'''
INSERT INTO notes(id, title, text, updated_at) VALUES(?, ?, ?, ?)
''',
        [
          [1, 'Note 1', 'First note', DateTime.now().toIso8601String()],
          [2, 'Note 2', 'Second note', DateTime.now().toIso8601String()],
        ],
      ),
    ]);
  }
}
