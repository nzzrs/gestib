// File: lib/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/foundation.dart'; // No se usa kDebugMode aquí

import 'theme_notifier.dart';
import 'notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _remindersEnabledKey = 'weeklyRemindersEnabled';
  bool _weeklyRemindersEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadReminderPreference();
  }

  Future<void> _loadReminderPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _weeklyRemindersEnabled = prefs.getBool(_remindersEnabledKey) ?? true;
    });
  }

  Future<void> _saveReminderPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_remindersEnabledKey, value);
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Text(
        themeNotifier.transformText(title),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final currentYear = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(
        title: Text(themeNotifier.transformText('Configuración')),
      ),
      body: ListView(
        children: <Widget>[
          _buildSectionTitle(context, 'Apariencia'),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: Text(themeNotifier.transformText('Tema de la aplicación')),
            trailing: DropdownButton<ThemeMode>(
              value: themeNotifier.themeMode,
              elevation: 2,
              underline: const SizedBox.shrink(),
              icon: Icon(Icons.arrow_drop_down_rounded, color: Theme.of(context).colorScheme.primary),
              items: [
                DropdownMenuItem(value: ThemeMode.system, child: Text(themeNotifier.transformText('Automático (Sistema)'))),
                DropdownMenuItem(value: ThemeMode.light, child: Text(themeNotifier.transformText('Claro'))),
                DropdownMenuItem(value: ThemeMode.dark, child: Text(themeNotifier.transformText('Oscuro'))),
              ],
              onChanged: (ThemeMode? newValue) {
                if (newValue != null) {
                  themeNotifier.setThemeMode(newValue);
                }
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: Text(themeNotifier.transformText('Color primario')),
            trailing: DropdownButton<MaterialColor>(
              value: themeNotifier.primaryColor,
              elevation: 2,
              underline: const SizedBox.shrink(),
              icon: Icon(Icons.arrow_drop_down_rounded, color: Theme.of(context).colorScheme.primary),
              items: themeNotifier.availablePrimaryColors.map((MaterialColor color) {
                return DropdownMenuItem<MaterialColor>(
                  value: color,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          color: color, shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withOpacity(0.3)
                                : Colors.black.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(themeNotifier.transformText(themeNotifier.getColorName(color))),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (MaterialColor? newValue) {
                if (newValue != null) {
                  themeNotifier.setPrimaryColor(newValue);
                }
              },
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.text_fields_outlined),
            title: Text(themeNotifier.transformText('Todo el texto en minúsculas')),
            value: themeNotifier.isTextLowercase,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (bool value) {
              themeNotifier.setTextLowercase(value);
            },
          ),

          const Divider(height: 32),
          _buildSectionTitle(context, 'Recordatorios'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: Text(themeNotifier.transformText('Recordatorios semanales')),
            subtitle: Text(themeNotifier.transformText('Notificar al inicio de cada nueva semana gestacional.')),
            value: _weeklyRemindersEnabled,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (bool value) async {
              setState(() {
                _weeklyRemindersEnabled = value;
              });
              await _saveReminderPreference(value);
              if (value) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                    content: Text(themeNotifier.transformText('Recordatorios activados. Se programarán con una FUR válida.')),
                    duration: const Duration(seconds: 3),
                  ),
                );
              } else {
                await NotificationService().cancelAllNotifications();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(themeNotifier.transformText('Recordatorios desactivados. Notificaciones existentes canceladas.')),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
          ),

          const Divider(height: 32),
          _buildSectionTitle(context, 'Información'),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(themeNotifier.transformText('Versión de la App')),
            subtitle: Text(themeNotifier.transformText('0.9.0 (gestib)')), // VERSIÓN ACTUALIZADA Y NOMBRE EN MINÚSCULA
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(themeNotifier.transformText('Descargo de Responsabilidad')),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(themeNotifier.transformText("Descargo de Responsabilidad")),
                  content: SingleChildScrollView(
                    child: Text(
                        themeNotifier.transformText("La información proporcionada por gestib es solo para fines informativos generales y no constituye asesoramiento médico. Siempre busque el consejo de su médico u otro proveedor de salud calificado con cualquier pregunta que pueda tener sobre una condición médica o embarazo.\n\nNo confíe en la información de esta aplicación como una alternativa al consejo médico de su doctor u otro proveedor de atención médica profesional.")),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(themeNotifier.transformText("Entendido")),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              // CAMBIO A CRÉDITOS
              themeNotifier.transformText('Créditos:\n$currentYear nzrs & gemini 2.5 pro preview 05-06.\nTodos los derechos reservados.'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
