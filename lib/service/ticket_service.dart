// lib/service/ticket_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/ticket.dart';

class TicketService {
  final CollectionReference col = FirebaseFirestore.instance.collection('tickets');

  Future<String> create(Ticket t) async {
    final doc = await col.add({
      ...t.toJson(),
      'created_at': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> updateStatus(String id, String status) async {
    await col.doc(id).update({'status': status});
  }

  Future<void> delete(String id) async {
    await col.doc(id).delete();
  }

  Stream<List<Ticket>> streamByUser(String uid) {
    return col.where('user_id', isEqualTo: uid).orderBy('created_at', descending: true).snapshots().map(
      (snap) => snap.docs.map((d) => Ticket.fromJson(d.id, d.data() as Map<String, dynamic>)).toList(),
    );
  }

  Stream<List<Ticket>> streamAll() {
    return col.orderBy('created_at', descending: true).snapshots().map(
      (snap) => snap.docs.map((d) => Ticket.fromJson(d.id, d.data() as Map<String, dynamic>)).toList(),
    );
  }
}
