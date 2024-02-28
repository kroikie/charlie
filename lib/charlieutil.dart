import 'package:firebase_auth/firebase_auth.dart';

class CharlieUtil {
  static Future<bool> isAdmin() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return false;
    } else {
      final customClaims = (await currentUser.getIdTokenResult()).claims;
      if (customClaims != null && customClaims['user-type'] == 'admin') {
        return true;
      }
    }
    return false;
  }
}
