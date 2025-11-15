import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';

enum AppThemeMode { light, dark }

class ThemeState extends Equatable {
  final AppThemeMode themeMode;

  const ThemeState({this.themeMode = AppThemeMode.light});

  ThemeState copyWith({AppThemeMode? themeMode}) {
    return ThemeState(themeMode: themeMode ?? this.themeMode);
  }

  @override
  List<Object?> get props => [themeMode];
}

class ThemeCubit extends Cubit<ThemeState> {
  final Box _themeBox;

  ThemeCubit(this._themeBox) : super(_loadTheme()) {
    _themeBox.watch(key: 'theme').listen((_) {
      emit(_loadTheme());
    });
  }

  static ThemeState _loadTheme() {
    try {
      final box = Hive.box(AppConstants.themeBoxName);
      final themeString = box.get('theme', defaultValue: 'light') as String;
      final themeMode = themeString == 'dark' ? AppThemeMode.dark : AppThemeMode.light;
      return ThemeState(themeMode: themeMode);
    } catch (e) {
      return const ThemeState();
    }
  }

  void toggleTheme() {
    final newMode = state.themeMode == AppThemeMode.light
        ? AppThemeMode.dark
        : AppThemeMode.light;
    _themeBox.put('theme', newMode == AppThemeMode.dark ? 'dark' : 'light');
    emit(state.copyWith(themeMode: newMode));
  }

  void setTheme(AppThemeMode mode) {
    _themeBox.put('theme', mode == AppThemeMode.dark ? 'dark' : 'light');
    emit(state.copyWith(themeMode: mode));
  }
}

