import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider {
  static Future<String?> getRole(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!doc.exists) {
        print('[UserProvider] users/$uid tidak ditemukan');
        return null;
      }
      final data = doc.data();
      print('[UserProvider] users/$uid => $data');
      return data?['role'] as String?;
    } catch (e, st) {
      print('[UserProvider] getRole error: $e\n$st');
      return null;
    }
  }

  static Future<void> createUserDocument(String uid, String name, String email, String role) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'role': role,
        'created_at': FieldValue.serverTimestamp()
      });
      print('[UserProvider] createUserDocument success for $uid');
    } catch (e, st) {
      print('[UserProvider] createUserDocument ERROR: $e\n$st');
      // fallback: coba set tanpa serverTimestamp
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': name,
          'email': email,
          'role': role
        }, SetOptions(merge: true));
        print('[UserProvider] createUserDocument fallback success for $uid');
      } catch (e2, st2) {
        print('[UserProvider] fallback also failed: $e2\n$st2');
        rethrow;
      }
    }
  }
}
