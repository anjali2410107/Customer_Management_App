import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/constants.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(AppConstants.keyThemeMode);
      if (themeIndex != null) {
        emit(ThemeMode.values[themeIndex]);
      }
    } catch (_) {
      emit(ThemeMode.light);
    }
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    emit(newMode);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppConstants.keyThemeMode, newMode.index);
    } catch (_) {}
  }
}
