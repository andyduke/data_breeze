import 'package:databreeze/databreeze.dart';
import 'package:databreeze_flutter/databreeze_flutter.dart';
import 'package:databreeze_flutter_example/models/folder.dart';
import 'package:databreeze_flutter_example/models/note.dart';
import 'package:databreeze_sqlite/databreeze_sqlite.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MultiViewDemoScreen extends StatefulWidget {
  const MultiViewDemoScreen({
    super.key,
  });

  @override
  State<MultiViewDemoScreen> createState() => _MultiViewDemoScreenState();
}

class _MultiViewDemoScreenState extends State<MultiViewDemoScreen> {
  late final store = context.read<BreezeSqliteStore>();

  late final foldersController = BreezeDataQueryController<List<Folder>>(
    source: store,
    query: BreezeQueryAll<Folder>(),
    onFilterData: (data, isReload) async {
      // Simulate latency
      await Future.delayed(const Duration(milliseconds: 700));

      return data;
    },
  );

  late final notesController = BreezeDataQueryController<List<Note>>(
    source: store,
    query: BreezeQueryAll<Note>(),
    onFilterData: (data, isReload) async {
      // Simulate latency
      await Future.delayed(const Duration(milliseconds: 700));

      return data;
    },
  );

  @override
  void dispose() {
    notesController.dispose();
    foldersController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Muti View Demo'),
      ),
      body: RefreshIndicator(
        onRefresh: () => [
          foldersController.reload(),
          notesController.reload(),
        ].wait,
        child: BreezeDataMultiView(
          controllers: [
            foldersController,
            notesController,
          ],
          builder: (context) => _NotesGridView(
            folders: foldersController.data!,
            notes: notesController.data!,
          ),
        ),
      ),
    );
  }
}

class _NotesGridView extends StatelessWidget {
  const _NotesGridView({
    required this.folders,
    required this.notes,
  });

  final List<Folder> folders;
  final List<Note> notes;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverMainAxisGroup(
            slivers: [
              SliverToBoxAdapter(
                child: Text('FOLDERS'),
              ),
              SliverList.builder(
                itemCount: folders.length,
                itemBuilder: (context, index) => ListTile(
                  leading: Icon(Icons.folder),
                  title: Text(folders[index].title),
                ),
              ),
            ],
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.only(top: 32),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverMainAxisGroup(
            slivers: [
              SliverToBoxAdapter(
                child: Text('NOTES'),
              ),
              SliverList.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) => ListTile(
                  leading: Icon(Icons.text_snippet_outlined),
                  title: Text(notes[index].title),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
