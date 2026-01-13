import 'package:amateur_arena/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AmateurArenaUser? _userFromFirebaseUser(User? user) {
    return user != null
        ? AmateurArenaUser(uid: user.uid, email: user.email!)
        : null;
  }

  AmateurArenaUser? get currentUser {
    return _userFromFirebaseUser(_auth.currentUser);
  }

  Stream<AmateurArenaUser?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _userFromFirebaseUser(result.user);
    } catch (e) {
      return null;
    }
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _userFromFirebaseUser(result.user);
    } catch (e) {
      return null;
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      return null;
    }
  }
}
