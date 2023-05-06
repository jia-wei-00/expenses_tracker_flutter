import 'package:firebase_auth/firebase_auth.dart';
import 'package:bloc/bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> checkSignin() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      emit(AuthSuccess(user: user));
    }
  }

  Future<void> googleSignIn() async {
    emit(AuthLoading());

    try {
      final googleAccount = await _googleSignIn.signIn();

      print("PASS 1");

      if (googleAccount == null) {
        emit(AuthFailed(error: "Please login again!"));
        return;
      }

      print("PASS 2");

      final googleAuth = await googleAccount.authentication;

      print("PASS 3");
      if (googleAuth.accessToken != null && googleAuth.idToken != null) {
        print("PASS 4");
        final authResult = await _auth.signInWithCredential(
          GoogleAuthProvider.credential(
              idToken: googleAuth.idToken, accessToken: googleAuth.accessToken),
        );

        emit(AuthSuccess(user: authResult.user!));
        print("PASS 5");
      }
    } on FirebaseAuthException catch (error) {
      emit(AuthFailed(error: error.message.toString()));
    } catch (error) {
      emit(AuthFailed(error: error.toString()));
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      emit(AuthSuccess(user: user.user!));
      print(user);
    } on FirebaseAuthException catch (e) {
      emit(AuthFailed(error: e.message.toString()));
    } catch (error) {
      emit(AuthFailed(error: error.toString()));
    }
  }

  Future<void> logOut() async {
    emit(AuthLoading());
    try {
      //Sign out firebase
      await FirebaseAuth.instance.signOut();

      //Revoke Google access token
      await _googleSignIn.signOut();

      emit(AuthInitial());
    } catch (error) {
      emit(AuthFailed(error: error.toString()));
    }
  }
}
