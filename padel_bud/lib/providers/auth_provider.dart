import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class AuthState {
  final bool isLoading;
  final bool codeSent;
  final String? verificationId;
  final User? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.codeSent = false,
    this.verificationId,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? codeSent,
    String? verificationId,
    User? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      codeSent: codeSent ?? this.codeSent,
      verificationId: verificationId ?? this.verificationId,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  AuthState build() {
    return const AuthState();
  }

  Future<void> sendPhoneVerification(String phone) async {
    print('[Auth] sendPhoneVerification called with phone: $phone');
    state = state.copyWith(isLoading: true, error: null, codeSent: false, verificationId: null);

    try {
      print('[Auth] Calling verifyPhoneNumber...');
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (credential) async {
          print('[Auth] Verification completed automatically');
          await _auth.signInWithCredential(credential);
          await _createUserIfNew(_auth.currentUser);
          state = state.copyWith(isLoading: false, user: _auth.currentUser);
        },
        verificationFailed: (e) {
          print('[Auth] Verification failed: ${e.message}');
          state = state.copyWith(isLoading: false, error: e.message, codeSent: false, verificationId: null);
        },
        codeSent: (verificationId, _) {
          print('[Auth] Code sent successfully with verificationId: $verificationId');
          state = state.copyWith(
            isLoading: false,
            codeSent: true,
            verificationId: verificationId,
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {
          print('[Auth] Code auto-retrieval timed out with verificationId: $verificationId');
          state = state.copyWith(
            isLoading: false,
            codeSent: true,
            verificationId: verificationId,
          );
        },
      );
    } catch (e) {
      print('[Auth] Exception in verifyPhoneNumber: $e');
      state = state.copyWith(isLoading: false, error: e.toString(), codeSent: false, verificationId: null);
    }
  }

  Future<void> verifySmsCode(String smsCode) async {
    if (state.verificationId == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: state.verificationId!,
        smsCode: smsCode,
      );

      await _auth.signInWithCredential(credential);
      
      // Create user without blocking the UI - do it in background
      _createUserIfNew(_auth.currentUser);
      
      state = state.copyWith(isLoading: false, user: _auth.currentUser);
    } catch (e) {
      print('[Auth] Error in verifySmsCode: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void resetVerification() {
    state = state.copyWith(codeSent: false, verificationId: null, error: null);
  }

  Future<void> _createUserIfNew(User? user) async {
    if (user == null) return;

    try {
      final userRepository = UserRepository();
      final existingUser = await userRepository.getUser(user.uid);

      if (existingUser == null) {
        final newUser = UserModel(
          id: user.uid,
          firstName: '',
          lastName: '',
          email: user.email ?? '',
          phoneNumber: user.phoneNumber ?? '',
        );
        await userRepository.createUser(newUser);
      }
    } catch (e) {
      print('Error creating user: $e');
    }
  }

  Future<void> signInWithGoogle() async {
    throw UnimplementedError();
  }
}
