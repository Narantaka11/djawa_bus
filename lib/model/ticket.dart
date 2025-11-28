// lib/model/ticket.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Ticket {
  String? id;
  String userId;
  String scheduleId;
  String passengerId;
  String seat;
  int total;
  String status; // pending, paid, cancelled, dll
  DateTime? createdAt;

  Ticket({
    this.id,
    required this.userId,
    required this.scheduleId,
    required this.passengerId,
    required this.seat,
    required this.total,
    required this.status,
    this.createdAt,
  });

  factory Ticket.fromJson(String id, Map<String, dynamic> json) {
    DateTime? created;
    final ca = json['created_at'];
    if (ca is Timestamp) created = ca.toDate();
    else if (ca is String) created = DateTime.tryParse(ca);
    else if (ca is int) created = DateTime.fromMillisecondsSinceEpoch(ca);

    return Ticket(
      id: id,
      userId: json['user_id'] ?? '',
      scheduleId: json['schedule_id'] ?? '',
      passengerId: json['passenger_id'] ?? '',
      seat: json['seat'] ?? '',
      total: (json['total'] is int) ? json['total'] : int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? 'pending',
      createdAt: created,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'schedule_id': scheduleId,
      'passenger_id': passengerId,
      'seat': seat,
      'total': total,
      'status': status,
      // created_at ditambahkan oleh service (FieldValue.serverTimestamp())
    };
  }
}
