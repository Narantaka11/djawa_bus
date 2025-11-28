// lib/service/passenger_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/passenger.dart';

class PassengerService {
  final CollectionReference col = FirebaseFirestore.instance.collection('passengers');

  Future<String> create(Passenger p) async {
    final doc = await col.add({
      ...p.toJson(),
      'created_at': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> update(Passenger p) async {
    if (p.id == null) throw Exception('Passenger id null');
    await col.doc(p.id).update(p.toJson());
  }

  Future<void> delete(String id) async {
    await col.doc(id).delete();
  }

  Stream<List<Passenger>> streamAll() {
    return col.orderBy('created_at', descending: true).snapshots().map(
      (snap) => snap.docs.map((d) => Passenger.fromJson(d.id, d.data() as Map<String, dynamic>)).toList(),
    );
  }

  Future<Passenger?> getById(String id) async {
    final doc = await col.doc(id).get();
    if (!doc.exists) return null;
    return Passenger.fromJson(doc.id, doc.data() as Map<String, dynamic>);
  }
}
