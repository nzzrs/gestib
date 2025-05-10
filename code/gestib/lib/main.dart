// File: lib/main.dart

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
// import 'package:timezone/timezone.dart' as tz; // No se usa tz directamente aquí
// import 'dart:io' show Platform; // No se usa Platform aquí

import 'home_screen.dart';
import 'theme_notifier.dart';
import 'notification_service.dart';

Future<void> _configureLocalTimeZone() async {
  tz_data.initializeTimeZones();
  // La configuración de la zona horaria local (tz.setLocalLocation)
  // se maneja mejor dentro del NotificationService si es específico para él,
  // o si se necesita globalmente, asegurarse de que la librería que obtiene
  // la zona horaria (como flutter_native_timezone) se inicialice correctamente.
  // Por ahora, solo inicializamos los datos de zona horaria.
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  await _configureLocalTimeZone();
  await NotificationService().init(); // Inicializar servicio de notificaciones

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(), // Cargar ThemeNotifier
      child: const GestogramaApp(),
    ),
  );
}

class GestogramaApp extends StatelessWidget {
  const GestogramaApp({super.key});

  TextTheme _applyTextTransform(TextTheme baseTextTheme, ThemeNotifier themeNotifier) {
    // Esta función es más conceptual. La transformación real del texto
    // se hace en cada widget Text usando themeNotifier.transformText().
    if (!themeNotifier.isTextLowercase) {
      return baseTextTheme;
    }
    return baseTextTheme.copyWith(
        // Ejemplo de cómo podrías intentar aplicar globalmente, aunque no es efectivo para todo.
        // bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontFamily: 'lowercase_if_needed'),
        // displayLarge: baseTextTheme.displayLarge?.copyWith(fontFamily: 'lowercase_if_needed'),
        );
  }

  ThemeData _buildTheme(Brightness brightness, MaterialColor primaryColor, ThemeNotifier themeNotifier) {
    Color seed = primaryColor;
    Color primary = brightness == Brightness.light ? primaryColor.shade600 : primaryColor.shade300;
    Color secondary = brightness == Brightness.light ? primaryColor.shade400 : primaryColor.shade200;
    Color tertiary = brightness == Brightness.light ? primaryColor.shade800 : primaryColor.shade100;
    Color surfaceVariantColor = brightness == Brightness.light
        ? primaryColor.shade50.withOpacity(0.6)
        : primaryColor.shade800.withOpacity(0.6);
    Color appBarTextColor = brightness == Brightness.light ? primaryColor.shade900 : primaryColor.shade50;
    Color chipBgColor = brightness == Brightness.light ? primaryColor.withOpacity(0.12) : primaryColor.withOpacity(0.25);
    Color chipLabelColor = brightness == Brightness.light ? primaryColor.shade700 : primaryColor.shade200;

    var colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      primary: primary,
      onPrimary: brightness == Brightness.light ? Colors.white : Colors.black, // Ajustar para mejor contraste
      secondary: secondary,
      onSecondary: brightness == Brightness.light ? Colors.white : Colors.black, // Ajustar
      tertiary: tertiary,
      onTertiary: brightness == Brightness.light ? Colors.white : Colors.black, // Ajustar
      error: Colors.red.shade400,
      onError: Colors.white,
      surface: brightness == Brightness.light ? const Color(0xFFFDFDFD) : const Color(0xFF121212),
      onSurface: brightness == Brightness.light ? Colors.black87 : Colors.white.withOpacity(0.87),
      surfaceVariant: surfaceVariantColor,
      onSurfaceVariant: brightness == Brightness.light ? Colors.black54 : Colors.white.withOpacity(0.60),
    );

    TextTheme baseTextTheme = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;

    TextTheme themedTextTheme = _applyTextTransform(baseTextTheme, themeNotifier).apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface.withOpacity(0.87),
    );


    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primaryColor: primary, // Usado para algunos componentes que no se actualizan con colorScheme.primary
      textTheme: themedTextTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent, // AppBar transparente para que tome el color del scaffold
        titleTextStyle: themedTextTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: appBarTextColor,
        ),
        iconTheme: IconThemeData(color: appBarTextColor),
      ),
      cardTheme: CardTheme(
          elevation: brightness == Brightness.light ? 1 : 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0)
      ),
      inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: primary, width: 2)
          )
      ),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              textStyle: themedTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)
            )
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: themedTextTheme.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w600)
        )
      ),
      chipTheme: ChipThemeData(
        backgroundColor: chipBgColor,
        labelStyle: themedTextTheme.bodySmall?.copyWith(color: chipLabelColor, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        iconTheme: IconThemeData(color: chipLabelColor, size: 16),
        elevation: 0,
        pressElevation: 0,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'gestib',
      debugShowCheckedModeBanner: false,

      theme: _buildTheme(Brightness.light, themeNotifier.primaryColor, themeNotifier),
      darkTheme: _buildTheme(Brightness.dark, themeNotifier.primaryColor, themeNotifier),
      themeMode: themeNotifier.themeMode,

      locale: const Locale('es', 'ES'),
      supportedLocales: const [Locale('es', 'ES')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeScreen(),
    );
  }
}
