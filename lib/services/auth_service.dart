import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authServiceProvider = Provider((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Mevcut kullanıcıyı al
  User? get currentUser => _auth.currentUser;

  // 1. Anonim Giriş (Uygulama ilk açıldığında sessizce çalışacak)
  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      debugPrint("Anonim giriş hatası: $e");
      return null;
    }
  }

  // 2. Google ile Hesap Bağlama (Mevcut anonim verileri korur)
  Future<UserCredential?> linkWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Mevcut anonim kullanıcıyı Google hesabına bağla
      if (_auth.currentUser != null) {
        return await _auth.currentUser!.linkWithCredential(credential);
      } else {
        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      debugPrint("Google bağlama hatası: $e");
      return null;
    }
  }

  // 3. Çıkış Yap
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
