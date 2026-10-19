import 'dart:async';

import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/firestore_service.dart';

enum ViewState { initial, loading, loaded, empty, error }

class NotesProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  StreamSubscription? _subscription;

  ViewState _state = ViewState.initial;
  List<NoteModel> _notes = [];
  String _errorMessage = '';

  ViewState get state => _state;
  List<NoteModel> get notes => _notes;
  String get errorMessage => _errorMessage;

  void startListening() {
    _state = ViewState.loading;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _service.streamNotes().listen(
      (notes) {
        _notes = notes;
        _state =
            notes.isEmpty ? ViewState.empty : ViewState.loaded;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        _state = ViewState.error;
        notifyListeners();
      },
    );
  }

  Future<void> refreshOnce() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      final notes = await _service.getNotesOnce();
      _notes = notes;
      _state =
          notes.isEmpty ? ViewState.empty : ViewState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ViewState.error;
    }

    notifyListeners();
  }

  Future<void> addNote(String title, String content) {
    return _service.addNote(title, content);
  }

  Future<void> updateNote(
      String id, String title, String content) {
    return _service.updateNote(id, title, content);
  }

  Future<void> deleteNote(String id) {
    return _service.deleteNote(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
