import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/notesData.dart';
import 'package:rxdart/rxdart.dart';

class NoteBloc{
  final _client = NotesClient();
  final _notesController = StreamController<String>();
  Sink<String> get getNotes => _notesController.sink;

  final _noteIdController = StreamController<int>();
  Sink<int> get noteId => _noteIdController.sink;

  final _noteEditController = StreamController<List<String>>();
  Sink<List<String>> get noteChange => _noteEditController.sink;

  late Stream<List<Note>?> allNotesStream;
  late Stream<Note?> noteDetailStream;
  late Stream<Note?> noteEditStream;
  late Stream<String?> noteDeleteStream;

  NoteBloc(SharedPreferences sp) {
    allNotesStream = _notesController.stream.switchMap(
            (bearer) => _client.fetchAllNotes(sp.getString("accessToken")!).asStream());

    noteDetailStream = _noteIdController.stream.switchMap(
            (noteId) => _client.fetchNoteDetails(noteId, sp.getString("accessToken")!).asStream());

    noteEditStream = _noteEditController.stream.switchMap(
            (noteChange) => _client.editNoteDetails(int.parse(noteChange[0]), sp.getString("accessToken")!, noteChange[1]).asStream());

    noteDeleteStream = _noteIdController.stream.switchMap(
            (noteId) => _client.deleteNote(noteId, sp.getString("accessToken")!).asStream());
  }


  void dispose() {
    _notesController.close();
    _noteIdController.close();
  }
}