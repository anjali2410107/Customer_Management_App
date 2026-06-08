import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/constants.dart';

// Authentication States
abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthCodeSent extends AuthState {
  final String mobile;
  AuthCodeSent(this.mobile);
}

class AuthSuccess extends AuthState {
  final String mobile;
  AuthSuccess(this.mobile);
}

class AuthFailure extends AuthState {
  final String errorMessage;
  AuthFailure(this.errorMessage);
}

class AuthCubit extends Cubit<AuthState> {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  String? _verificationId;

  AuthCubit() : super(AuthInitial()) {
    checkLoginStatus();
  }

  // Check SharedPreferences and Firebase Auth to see if the session is active
  Future<void> checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
      final savedMobile = prefs.getString(AppConstants.keyLoggedInMobile);

      // Check both Firebase current user and SharedPreferences session states
      if (Firebase.apps.isNotEmpty && _auth.currentUser != null) {
        final phone = _auth.currentUser!.phoneNumber ?? savedMobile ?? '';
        // Standardize displaying phone number (removing country code for simpler view)
        final formattedPhone = phone.replaceAll('+91', '').trim();
        emit(AuthSuccess(formattedPhone.isNotEmpty ? formattedPhone : 'Firebase User'));
      } else if (isLoggedIn && savedMobile != null) {
        emit(AuthSuccess(savedMobile));
      } else {
        emit(AuthInitial());
      }
    } catch (_) {
      emit(AuthInitial());
    }
  }

  // Trigger Phone Verification - sends real SMS or bypasses for demo credentials
  Future<void> sendOtp(String mobile) async {
    emit(AuthLoading());

    // 1. Local Fallback Mode Check (If Firebase configuration is missing)
    if (Firebase.apps.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate delay
      if (mobile.trim() != AppConstants.demoMobile) {
        emit(AuthFailure('App running in offline mode. Please use demo number: ${AppConstants.demoMobile}'));
        return;
      }
      emit(AuthCodeSent(mobile.trim()));
      return;
    }

    // 2. Demo bypass (bypass real SMS gateway for developer/review testing)
    if (mobile.trim() == AppConstants.demoMobile) {
      await Future.delayed(const Duration(milliseconds: 800));
      emit(AuthCodeSent(mobile.trim()));
      return;
    }

    // 3. Real Firebase Phone Auth SMS sequence
    try {
      final formattedPhone = '+91$mobile';
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Automatic SMS code interception (Android only)
          await _auth.signInWithCredential(credential);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(AppConstants.keyIsLoggedIn, true);
          await prefs.setString(AppConstants.keyLoggedInMobile, mobile);
          emit(AuthSuccess(mobile));
        },
        verificationFailed: (FirebaseAuthException e) {
          emit(AuthFailure(e.message ?? 'Verification failed. Please try again.'));
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          emit(AuthCodeSent(mobile));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      emit(AuthFailure('Failed to send OTP: ${e.toString()}'));
    }
  }

  // Verify OTP - Validate locally against demo OTP or submit to Firebase
  Future<void> verifyOtp(String mobile, String otp) async {
    emit(AuthLoading());

    // 1. Local Fallback Mode Check (Firebase offline)
    if (Firebase.apps.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (otp.trim() != AppConstants.demoOtp) {
        emit(AuthFailure('Invalid OTP. Use demo OTP: ${AppConstants.demoOtp}'));
        return;
      }
      await _saveLocalSession(mobile);
      return;
    }

    // 2. Demo credential verification bypass
    if (mobile.trim() == AppConstants.demoMobile && otp.trim() == AppConstants.demoOtp) {
      await Future.delayed(const Duration(milliseconds: 800));
      await _saveLocalSession(mobile);
      return;
    }

    // 3. Real Firebase SMS OTP credential verification
    if (_verificationId == null) {
      emit(AuthFailure('Session expired. Please request a new OTP code.'));
      return;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);
      await _saveLocalSession(mobile);
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(e.message ?? 'Invalid OTP code. Please verify and retry.'));
    } catch (e) {
      emit(AuthFailure('Authentication error: ${e.toString()}'));
    }
  }

  // Utility to write user details to SharedPreferences on successful authentication
  Future<void> _saveLocalSession(String mobile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsLoggedIn, true);
      await prefs.setString(AppConstants.keyLoggedInMobile, mobile);
      emit(AuthSuccess(mobile));
    } catch (e) {
      emit(AuthFailure('Failed to save session, but login succeeded.'));
    }
  }

  // Clear Session, Sign Out from Firebase and SharedPreferences
  Future<void> logout() async {
    emit(AuthLoading());
    try {
      if (Firebase.apps.isNotEmpty) {
        await _auth.signOut();
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyIsLoggedIn);
      await prefs.remove(AppConstants.keyLoggedInMobile);
      
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure('Failed to logout. Please try again.'));
    }
  }
}
