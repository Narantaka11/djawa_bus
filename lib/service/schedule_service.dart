// lib/service/schedule_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/schedule.dart';

class ScheduleService {
  final CollectionReference col = FirebaseFirestore.instance.collection('schedule');

  Stream<List<Schedule>> streamAll() {
    return col.orderBy('created_at', descending: true).snapshots().map(
      (snap) => snap.docs.map((d) => Schedule.fromJson(d.id, d.data() as Map<String, dynamic>)).toList(),
    );
  }

  Future<List<Schedule>> listOnce() async {
    final snap = await col.orderBy('created_at', descending: true).get();
    return snap.docs.map((d) => Schedule.fromJson(d.id, d.data() as Map<String, dynamic>)).toList();
  }

  Future<String> create(Schedule s) async {
    final doc = await col.add({
      ...s.toJson(),
      'created_at': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> update(Schedule s) async {
    if (s.id == null) throw Exception('Schedule id null');
    await col.doc(s.id).update(s.toJson());
  }

  Future<void> delete(String id) async {
    await col.doc(id).delete();
  }

  Future<Schedule?> getById(String id) async {
    final doc = await col.doc(id).get();
    if (!doc.exists) return null;
    return Schedule.fromJson(doc.id, doc.data() as Map<String, dynamic>);
  }

  // Optional: get schedules by bus id
  Stream<List<Schedule>> streamByBus(String busId) {
    return col.where('bus_id', isEqualTo: busId).snapshots().map(
      (snap) => snap.docs.map((d) => Schedule.fromJson(d.id, d.data() as Map<String, dynamic>)).toList(),
    );
  }
}
