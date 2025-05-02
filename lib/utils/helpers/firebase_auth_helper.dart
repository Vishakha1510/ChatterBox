import 'package:chatterbox/utils/helpers/firestore_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthHelper {
  FirebaseAuthHelper._();

  static final FirebaseAuthHelper firebaseAuthHelper = FirebaseAuthHelper._();

  static final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  static final GoogleSignIn googleSignIn = GoogleSignIn();

  //Sign in Anonymously

  Future<Map<String, dynamic>> signInAsGuestUser() async {
    Map<String, dynamic> response = {};

    try {
      UserCredential userCredential = await firebaseAuth.signInAnonymously();

      User? user = userCredential.user;

      response['user'] = user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "admin-restricted-operation":
          response['error'] = "Admin disabled this feature. Contact to admin.";
          break;
        case "operation-not-allowed":
          response['error'] =
              "Anonymous sign-in has been disabled for this project. Enable it in the Firebase console.";

          break;
        case "too-many-requests":
          response['error'] =
              "Access to this account has been temporarily disabled due to many failed requests. Try again later.";

          break;
        case "auth/internal-error":
          response['error'] =
              "Firebase Authentication service error. Please try again later.";
          break;
        default:
          response['error'] = "Not possible due to ${e.code}";
      }
    }
    return response;
  }

  //Sign out user

  signOutUser() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();
  }

  // Sign up user

  Future<Map<String, dynamic>> signUpUser({
    required String email,
    required String password,
  }) async {
    Map<String, dynamic> response = {};

    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      response['user'] = user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "weak-password":
          response['error'] = "The password provided is too weak.";
          break;
        case "email-already-in-use":
          response['error'] = "The account already exists for that email.";
          break;
        case "invalid-email":
          response['error'] = "The email provided is not valid.";
          break;
        case "admin-restricted-operation":
          response['error'] =
              "Email/password accounts are not enabled. Enable it in the Firebase console.";
          break;
        case "too-many-requests":
          response['error'] =
              "Access to this account has been temporarily disabled due to many failed requests. Try again later.";
          break;
        case "user-disabled":
          response['error'] =
              "This account has been disabled. Please contact support.";
          break;
        case "invalid-credential":
          response['error'] = "The email or password is not valid.";
          break;
        default:
          response['error'] = "Not possible due to ${e.code}";
      }
    }
    return response;
  }

  // Sign in user

  Future<Map<String, dynamic>> signInUser({
    required String email,
    required String password,
  }) async {
    Map<String, dynamic> response = {};

    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      //call insertuser() from firebaseFirestore helper class

      await FirestoreHelper.firestoreHelper.insertUser(email: user!.email!);

      response['user'] = user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "user-not-found":
          response['error'] =
              "There is no user record corresponding to this identifier. The user may have been deleted.";
          break;
        case "wrong-password":
          response['error'] =
              "The password is not valid or the user does not have a password.";
          break;
        case "invalid-email":
          response['error'] = "The email address is badly formatted.";
          break;
        case "user-disabled":
          response['error'] =
              "The user account has been disabled by an administrator.";
          break;
        case "admin-restricted-operation":
          response['error'] = "Sign in with email and password is not enabled.";
          break;
        case "too-many-requests":
          response['error'] =
              "Access to this account has been temporarily disabled due to many failed login attempts. Try again later.";
          break;
        case "invalid-credential":
          response['error'] = "The email or password is not valid.";
          break;
        default:
          response['error'] = "Not possible due to ${e.code}";
      }
    }
    return response;
  }

  // Sign in with Google

  Future<Map<String, dynamic>> signInWithGoogle() async {
    Map<String, dynamic> response = {};

    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );
      User? user = userCredential.user;
      //call insertuser() from firebaseFirestore helper class

      await FirestoreHelper.firestoreHelper.insertUser(email: user!.email!);
      response['user'] = user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "invalid-credential":
          response['error'] =
              "The credential received from Google is malformed or has expired.";
          break;
        case "admin-restricted-operation":
          response['error'] =
              "Sign in with Google is not enabled in this project.";
          break;
        case "user-disabled":
          response['error'] = "The user account has been disabled.";
          break;
        case "account-exists-with-different-credential":
          response['error'] =
              "An account already exists with the same email address but different sign-in credentials. Sign in using that provider instead.";
          break;
        case "invalid-verification-code":
          response['error'] =
              "The verification code received from Google is invalid.";
          break;
        case "network-request-failed":
          response['error'] =
              "A network error occurred while trying to authenticate with Google.";
          break;
        case "too-many-requests":
          response['error'] =
              "Access to this account has been temporarily disabled due to many failed requests. Try again later.";
          break;
        default:
          response['error'] = "Not possible due to ${e.code}";
      }
    }
    return response;
  }
}
//keytool -list -v -alias androiddebugkey -keystore C:\Users\hp\.android\debug.keystore