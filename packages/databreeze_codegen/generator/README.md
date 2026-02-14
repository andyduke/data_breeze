# DataBreeze code generator

```dart
@BzModel(
  name: 'note_entries',
  schemaVersion: [
    BzSchemaVersion(1, [
      .append(#name),
      .append(#content),
      .append(#createdAt),
      .append(#flag),
    ]),
    BzSchemaVersion(2, [
      .rename(#name, to: #title),
      .append(#updatedAt),
      .delete(#flag),
    ]),
  ],
)
class Note extends BreezeModel<int> {
  String title;

  @BzColumn(name: 'note_text')
  String content;

  DateTime createdAt;

  DateTime updatedAt;
}
```
