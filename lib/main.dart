import 'package:flutter/material.dart';
import 'screens/add_edit_note_screen.dart';
import 'screens/note_detail_screen.dart';
import 'models/note.dart';
import 'services/db_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Note> _notes = [];
  final DBService _dbService = DBService();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await _dbService.getNotes();
    setState(() {
      _notes = notes;
    });
  }

  void _deleteNote(Note note) async {
    await _dbService.deleteNote(note.id!);
    _loadNotes();
  }

  void _navigateToAddEditNoteScreen([Note? note]) async {
    final result = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AddEditNoteScreen(note: note),
    ));
    if (result != null && result == true) {
      _loadNotes();
    }
  }

  void _navigateToNoteDetailScreen(Note note) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => NoteDetailScreen(note: note),
    ));
  }

  // ignore: unused_element
  void _searchNotes(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = _notes.where((note) {
      return note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.content.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: NoteSearchDelegate(_notes, _navigateToNoteDetailScreen),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredNotes.length,
        itemBuilder: (context, index) {
          final note = filteredNotes[index];
          return ListTile(
            title: Text(note.title),
            subtitle: Text(note.date.toLocal().toString()),
            onTap: () => _navigateToNoteDetailScreen(note),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _navigateToAddEditNoteScreen(note),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteNote(note),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditNoteScreen(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NoteSearchDelegate extends SearchDelegate {
  final List<Note> notes;
  final Function(Note) onSelected;

  NoteSearchDelegate(this.notes, this.onSelected);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = notes.where((note) {
      return note.title.toLowerCase().contains(query.toLowerCase()) ||
          note.content.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final note = results[index];
        return ListTile(
          title: Text(note.title),
          subtitle: Text(note.date.toLocal().toString()),
          onTap: () {
            close(context, null);
            onSelected(note);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = notes.where((note) {
      return note.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final note = suggestions[index];
        return ListTile(
          title: Text(note.title),
          subtitle: Text(note.date.toLocal().toString()),
          onTap: () {
            query = note.title;
            showResults(context);
          },
        );
      },
    );
  }
}
