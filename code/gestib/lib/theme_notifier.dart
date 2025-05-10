// File: lib/theme_notifier.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier with ChangeNotifier {
  static const String _themeModeKey = 'themeMode';
  static const String _primaryColorIndexKey = 'primaryColorIndex';
  static const String _textLowercaseKey = 'textLowercase'; // Nueva clave

  ThemeMode _themeMode = ThemeMode.dark; // <--- CAMBIO: Oscuro por defecto
  MaterialColor _primaryColor = Colors.deepPurple;
  bool _isTextLowercase = false; // <--- NUEVO: Opción de texto en minúsculas

  ThemeNotifier() {
    _loadPreferences();
  }

  ThemeMode get themeMode => _themeMode;
  MaterialColor get primaryColor => _primaryColor;
  bool get isTextLowercase => _isTextLowercase; // <--- NUEVO: Getter

  final List<MaterialColor> _availablePrimaryColors = [
    Colors.deepPurple, Colors.blue, Colors.green, Colors.pink, Colors.orange,
    Colors.teal, Colors.red, Colors.indigo, Colors.amber, Colors.cyan, Colors.lime,
  ];
  List<MaterialColor> get availablePrimaryColors => _availablePrimaryColors;

  final Map<MaterialColor, String> _colorNames = {
    Colors.deepPurple: 'Púrpura Profundo', Colors.blue: 'Azul', Colors.green: 'Verde',
    Colors.pink: 'Rosa', Colors.orange: 'Naranja', Colors.teal: 'Turquesa',
    Colors.red: 'Rojo', Colors.indigo: 'Índigo', Colors.amber: 'Ámbar',
    Colors.cyan: 'Cian', Colors.lime: 'Lima',
  };
  String getColorName(MaterialColor color) => _colorNames[color] ?? 'Color Desconocido';

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final themeModeString = prefs.getString(_themeModeKey);
    if (themeModeString != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == themeModeString,
        orElse: () => ThemeMode.dark, // Mantener oscuro si hay error al cargar
      );
    } // Si es null, se queda con ThemeMode.dark (definido arriba)

    final primaryColorIndex = prefs.getInt(_primaryColorIndexKey);
    if (primaryColorIndex != null && primaryColorIndex >= 0 && primaryColorIndex < _availablePrimaryColors.length) {
      _primaryColor = _availablePrimaryColors[primaryColorIndex];
    }

    _isTextLowercase = prefs.getBool(_textLowercaseKey) ?? false; // <--- NUEVO: Cargar preferencia

    notifyListeners();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, _themeMode.toString());
    await prefs.setInt(_primaryColorIndexKey, _availablePrimaryColors.indexOf(_primaryColor));
    await prefs.setBool(_textLowercaseKey, _isTextLowercase); // <--- NUEVO: Guardar preferencia
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    _savePreferences();
  }

  void setPrimaryColor(MaterialColor color) {
    if (_primaryColor == color) return;
    _primaryColor = color;
    notifyListeners();
    _savePreferences();
  }

  void setTextLowercase(bool value) { // <--- NUEVO: Setter
    if (_isTextLowercase == value) return;
    _isTextLowercase = value;
    notifyListeners();
    _savePreferences();
  }

  // Helper para aplicar transformación de texto si es necesario
  String transformText(String text) {
    return _isTextLowercase ? text.toLowerCase() : text;
  }
}
