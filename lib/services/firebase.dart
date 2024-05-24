import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mysocialmediaapp/firebase_options.dart';
import 'package:mysocialmediaapp/services/AuthExceptions.dart';

class AuthService {
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  User? getUser() {
    User? user = FirebaseAuth.instance.currentUser;
    return user;
  }

  Future<User> createUser(
      {required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = getUser();
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw WeakPasswordAuthException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  Future<User> login({required String email, required String password}) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final user = getUser();
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw UserNotFoundAuthException();
      } else if (e.code == 'auth/wrong-password') {
        throw WrongPasswordAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  Future<void> logout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }
}
