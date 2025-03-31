import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  runApp(const GestogramaApp());
}

class GestogramaApp extends StatelessWidget {
  const GestogramaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestograma App',
      debugShowCheckedModeBanner: false,

      // --- Temas ---
      theme: ThemeData( // Tema Claro (definido por completitud, aunque no se use)
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
        cardTheme: CardTheme(elevation: 1, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0)),
        inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0))),
        textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))))
      ),
      darkTheme: ThemeData( // Tema Oscuro
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark, // Asegura que sea modo oscuro
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
        cardTheme: CardTheme(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0)),
        inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0))),
        textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))))
      ),
      themeMode: ThemeMode.dark, // Forza el modo oscuro

      // --- Localización ---
      locale: const Locale('es', 'ES'),
      supportedLocales: const [ Locale('es', 'ES') ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: const HomeScreen(),
    );
  }
}
