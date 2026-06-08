import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/constants.dart';

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
  AuthCubit() : super(AuthInitial()) {
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
      final savedMobile = prefs.getString(AppConstants.keyLoggedInMobile);

      if (isLoggedIn && savedMobile != null) {
        emit(AuthSuccess(savedMobile));
      } else {
        emit(AuthInitial());
      }
    } catch (_) {
      emit(AuthInitial());
    }
  }

  Future<void> sendOtp(String mobile) async {
    emit(AuthLoading());
    // Simulate network latency for a polished user experience
    await Future.delayed(const Duration(milliseconds: 800));

    if (mobile.trim() != AppConstants.demoMobile) {
      emit(AuthFailure('Please use the demo mobile number: ${AppConstants.demoMobile}'));
      return;
    }

    emit(AuthCodeSent(mobile.trim()));
  }

  Future<void> verifyOtp(String mobile, String otp) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 800));

    if (otp.trim() != AppConstants.demoOtp) {
      emit(AuthFailure('Invalid OTP. Please use the demo OTP: ${AppConstants.demoOtp}'));
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsLoggedIn, true);
      await prefs.setString(AppConstants.keyLoggedInMobile, mobile);
      
      emit(AuthSuccess(mobile));
    } catch (e) {
      emit(AuthFailure('Failed to save session. Please try again.'));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyIsLoggedIn);
      await prefs.remove(AppConstants.keyLoggedInMobile);
      
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure('Failed to logout. Please try again.'));
    }
  }
}
