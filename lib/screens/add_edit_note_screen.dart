import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/note.dart';
import '../services/db_service.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  // ignore: library_private_types_in_public_api
  _AddEditNoteScreenState createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _imagePath;
  final DBService _dbService = DBService();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _imagePath = widget.note!.imagePath;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _submitData() async {
    final enteredTitle = _titleController.text;
    final enteredContent = _contentController.text;

    if (enteredTitle.isEmpty || enteredContent.isEmpty) {
      return;
    }

    final newNote = Note(
      id: widget.note?.id,
      title: enteredTitle,
      content: enteredContent,
      date: DateTime.now(),
      imagePath: _imagePath,
    );

    if (widget.note == null) {
      await _dbService.insertNote(newNote);
    } else {
      await _dbService.updateNote(newNote);
    }

    // ignore: use_build_context_synchronously
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Add Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _submitData,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 10,
            ),
            const SizedBox(height: 10),
            if (_imagePath != null)
              Image.file(
                File(_imagePath!),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            TextButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Add Image'),
              onPressed: _pickImage,
            ),
          ],
        ),
      ),
    );
  }
}
