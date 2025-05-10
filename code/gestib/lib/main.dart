// File: lib/main.dart

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io' show Platform;

import 'home_screen.dart';
import 'theme_notifier.dart';
import 'notification_service.dart';

Future<void> _configureLocalTimeZone() async {
  tz_data.initializeTimeZones();
  // String timeZoneName;
  // try {
  //   timeZoneName = await FlutterNativeTimezone.getLocalTimezone(); // Paquete opcional
  // } catch (e) {
  //   timeZoneName = 'Etc/UTC'; // Fallback
  // }
  // tz.setLocalLocation(tz.getLocation(timeZoneName));
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  await _configureLocalTimeZone();
  await NotificationService().init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const GestogramaApp(),
    ),
  );
}

class GestogramaApp extends StatelessWidget {
  const GestogramaApp({super.key});

  // Helper para aplicar la transformación de texto globalmente si está activada
  TextTheme _applyTextTransform(TextTheme baseTextTheme, ThemeNotifier themeNotifier) {
    if (!themeNotifier.isTextLowercase) {
      return baseTextTheme;
    }
    // Esta es una forma simplificada. Para una transformación completa,
    // necesitarías recrear cada TextStyle aplicando .toLowerCase() a ejemplos de texto
    // y luego asignarlo. Aquí solo mostramos la idea, pero su efecto será limitado
    // sin recrear cada estilo individualmente con el texto transformado.
    // Flutter no tiene una propiedad global para forzar minúsculas en todos los Text widgets.
    // La transformación se debe aplicar en cada Text widget individualmente o
    // crear un Text widget personalizado.
    // Por ahora, el ThemeNotifier.transformText se usará explícitamente en los widgets.
    return baseTextTheme;
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
      onPrimary: brightness == Brightness.light ? Colors.white : Colors.black,
      secondary: secondary,
      onSecondary: brightness == Brightness.light ? Colors.white : Colors.black,
      tertiary: tertiary,
      onTertiary: brightness == Brightness.light ? Colors.white : Colors.black,
      error: Colors.red.shade400,
      onError: Colors.white,
      surface: brightness == Brightness.light ? const Color(0xFFFDFDFD) : const Color(0xFF121212),
      onSurface: brightness == Brightness.light ? Colors.black87 : Colors.white.withOpacity(0.87),
      surfaceVariant: surfaceVariantColor,
      onSurfaceVariant: brightness == Brightness.light ? Colors.black54 : Colors.white.withOpacity(0.60),
    );

    // Obtener el TextTheme base
    TextTheme baseTextTheme = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;

    // Aplicar la transformación de texto si es necesario (esto es más conceptual aquí)
    TextTheme themedTextTheme = _applyTextTransform(baseTextTheme, themeNotifier).apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface.withOpacity(0.87),
    );


    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primaryColor: primary,
      textTheme: themedTextTheme, // Aplicar el TextTheme modificado
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: themedTextTheme.headlineSmall?.copyWith( // Usar estilos del TextTheme
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
              textStyle: themedTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600) // Usar estilos del TextTheme
            )
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: themedTextTheme.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w600) // Usar estilos del TextTheme
        )
      ),
      chipTheme: ChipThemeData(
        backgroundColor: chipBgColor,
        labelStyle: themedTextTheme.bodySmall?.copyWith(color: chipLabelColor, fontWeight: FontWeight.w500), // Usar estilos del TextTheme
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
      title: 'gestib', // Siempre en minúscula
      debugShowCheckedModeBanner: false,

      theme: _buildTheme(Brightness.light, themeNotifier.primaryColor, themeNotifier),
      darkTheme: _buildTheme(Brightness.dark, themeNotifier.primaryColor, themeNotifier),
      themeMode: themeNotifier.themeMode, // Esto tomará el ThemeMode.dark por defecto de ThemeNotifier

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
