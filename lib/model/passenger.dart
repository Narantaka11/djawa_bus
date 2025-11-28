// lib/model/passenger.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Passenger {
  String? id;
  String name;
  String phone;
  String address;
  DateTime? createdAt;

  Passenger({
    this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.createdAt,
  });

  factory Passenger.fromJson(String id, Map<String, dynamic> json) {
    DateTime? created;
    final ca = json['created_at'];
    if (ca is Timestamp) created = ca.toDate();
    else if (ca is String) created = DateTime.tryParse(ca);
    else if (ca is int) created = DateTime.fromMillisecondsSinceEpoch(ca);

    return Passenger(
      id: id,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      createdAt: created,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      // jangan kirim createdAt secara manual; service menambahkan serverTimestamp()
    };
  }
}
