// lib/service/bus_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/bus.dart';

class BusService {
  final CollectionReference col = FirebaseFirestore.instance.collection('bus');

  Stream<List<Bus>> streamAll() {
    return col.orderBy('created_at', descending: true).snapshots().map(
      (snap) => snap.docs.map((d) {
        final data = d.data() as Map<String, dynamic>;
        return Bus.fromJson(d.id, data);
      }).toList(),
    );
  }

  Future<List<Bus>> listOnce() async {
    final snap = await col.orderBy('created_at', descending: true).get();
    return snap.docs.map((d) => Bus.fromJson(d.id, d.data() as Map<String, dynamic>)).toList();
  }

  Future<String> create(Bus b) async {
    final doc = await col.add({
      ...b.toJson(),
      'created_at': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> update(Bus b) async {
    if (b.id == null) throw Exception('Bus id null');
    await col.doc(b.id).update(b.toJson());
  }

  Future<void> delete(String id) async {
    await col.doc(id).delete();
  }

  Future<Bus?> getById(String id) async {
    final doc = await col.doc(id).get();
    if (!doc.exists) return null;
    return Bus.fromJson(doc.id, doc.data() as Map<String, dynamic>);
  }
}
