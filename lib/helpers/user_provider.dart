import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserProvider {
  static final _usersCol = FirebaseFirestore.instance.collection('users');
  static Future<String?> getRole(String uid) async {
    try {
      final doc = await _usersCol.doc(uid).get();
      if (!doc.exists) {
        debugPrint('[UserProvider] users/$uid tidak ditemukan');
        return null;
      }
      final data = doc.data();
      debugPrint('[UserProvider] users/$uid => $data');
      return data?['role'] as String?;
    } catch (e, st) {
      debugPrint('[UserProvider] getRole error: $e\n$st');
      return null;
    }
  }

  static Stream<String?> roleStream(String uid) {
    return _usersCol.doc(uid).snapshots().map((doc) {
      if (!doc.exists) {
        debugPrint('[UserProvider] roleStream: users/$uid tidak ditemukan');
        return null;
      }
      final data = doc.data();
      final r = (data?['role'] ?? null) as String?;
      debugPrint('[UserProvider] roleStream: users/$uid => $r');
      return r;
    }).handleError((e, st) {
      debugPrint('[UserProvider] roleStream error: $e\n$st');
    });
  }

  static Future<void> createUserDocument(String uid, String name, String email, String role) async {
    try {
      await _usersCol.doc(uid).set({
        'name': name,
        'email': email,
        'role': role,
        'created_at': FieldValue.serverTimestamp()
      });
      debugPrint('[UserProvider] createUserDocument success for $uid');
    } catch (e, st) {
      debugPrint('[UserProvider] createUserDocument ERROR: $e\n$st');
      try {
        await _usersCol.doc(uid).set({
          'name': name,
          'email': email,
          'role': role
        }, SetOptions(merge: true));
        debugPrint('[UserProvider] createUserDocument fallback success for $uid');
      } catch (e2, st2) {
        debugPrint('[UserProvider] fallback also failed: $e2\n$st2');
        rethrow;
      }
    }
  }
}
