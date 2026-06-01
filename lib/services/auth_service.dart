import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '121198675863-dcjrjddd32dmoepke9djb163s28kn55k.apps.googleusercontent.com',
  );

  FirebaseAuth? get _authOrNull {
    if (Firebase.apps.isEmpty) {
      debugPrint('Firebase is not initialized. Auth features are unavailable.');
      return null;
    }

    return FirebaseAuth.instance;
  }

  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      final auth = _authOrNull;
      if (auth == null) {
        return null;
      }

      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (error) {
      debugPrint('Login error: $error');
      return null;
    }
  }

  Future<User?> registerWithEmailPassword(String email, String password) async {
    try {
      final auth = _authOrNull;
      if (auth == null) {
        return null;
      }

      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (error) {
      debugPrint('Registration error: $error');
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final auth = _authOrNull;
      if (auth == null) return null;

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        debugPrint('Google Sign-In canceled by the user.');
        return null; 
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await auth.signInWithCredential(credential);
      return userCredential.user;

    } catch (error) {
      debugPrint('Google Sign-In error: $error');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      final auth = _authOrNull;
      if (auth == null) {
        return;
      }

      await _googleSignIn.signOut(); 
      await auth.signOut();
    } catch (error) {
      debugPrint('Sign out error: $error');
    }
  }
}