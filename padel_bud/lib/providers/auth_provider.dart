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
    state = state.copyWith(isLoading: true, error: null);

    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (credential) async {
        await _auth.signInWithCredential(credential);
        await _createUserIfNew(_auth.currentUser);
        state = state.copyWith(isLoading: false, user: _auth.currentUser);
      },
      verificationFailed: (e) {
        state = state.copyWith(isLoading: false, error: e.message);
      },
      codeSent: (verificationId, _) {
        state = state.copyWith(
          isLoading: false,
          codeSent: true,
          verificationId: verificationId,
        );
      },
      codeAutoRetrievalTimeout: (_) {},
    );
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
      await _createUserIfNew(_auth.currentUser);
      state = state.copyWith(isLoading: false, user: _auth.currentUser);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
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
