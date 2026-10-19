import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';

class FirestoreService {
  final CollectionReference _notes =
      FirebaseFirestore.instance.collection('notes');

  Stream<List<NoteModel>> streamNotes() {
    return _notes.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => NoteModel.fromFirestore(doc))
          .toList(),
    );
  }

  Future<List<NoteModel>> getNotesOnce() async {
    final snapshot = await _notes.get();
    return snapshot.docs
        .map((doc) => NoteModel.fromFirestore(doc))
        .toList();
  }

  Future<void> addNote(String title, String content) {
    return _notes.add({
      'title': title,
      'content': content,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> updateNote(
      String id, String title, String content) {
    return _notes.doc(id).update({
      'title': title,
      'content': content,
    });
  }

  Future<void> deleteNote(String id) {
    return _notes.doc(id).delete();
  }
}