import 'package:amateur_arena/models/event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Event> _eventFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;

      return EventMapper.fromMap(data);
    }).toList();
  }

  // Events Collection Reference
  CollectionReference get _eventsCollection => _firestore.collection('events');

  // Read all events
  Stream<List<Event>> get events {
    return _eventsCollection.snapshots().map(_eventFromSnapshot);
  }

  // Create an event
  Future<void> addEvent(Event event) async {
    await _eventsCollection.add(event.toMap());
  }

  // Update an event
  Future<void> updateEvent(Event event) async {
    if (event.id != null) {
      await _eventsCollection.doc(event.id).set(event.toMap());
    }
  }

  // Delete an event
  Future<void> deleteEvent(String id) async {
    await _eventsCollection.doc(id).delete();
  }
}
