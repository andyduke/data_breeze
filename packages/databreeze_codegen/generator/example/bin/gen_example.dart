import 'package:gen_example/models/note.dart';

void main(List<String> arguments) {
  final note = NoteModel.blueprint.builder({
    NoteModel.id: 1,
    NoteModel.title: 'Note 1',
    NoteModel.content: 'note body',
  });

  print('#${note.id}: ${note.title}');
}
