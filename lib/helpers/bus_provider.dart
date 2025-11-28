import 'package:cloud_firestore/cloud_firestore.dart';

class BusProvider {
  static Stream<QuerySnapshot> getBusStream() {
    return FirebaseFirestore.instance
        .collection("bus")
        .orderBy("created_at", descending: false)
        .snapshots();
  }
}
