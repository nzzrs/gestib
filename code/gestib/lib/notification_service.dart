// File: lib/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:flutter/foundation.dart'; // Para kDebugMode

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Inicializar datos de zona horaria
    tz_data.initializeTimeZones();
    // Obtener la zona horaria local
    // tz.setLocalLocation(tz.getLocation(await FlutterNativeTimezone.getLocalTimezone())); // Alternativa si es necesario

    // Configuración para Android
    // IMPORTANTE: Cambia 'mipmap/ic_launcher' por el nombre de tu icono de notificación en res/drawable
    // Por ejemplo, si tu icono es 'ic_stat_notification.png', usa 'ic_stat_notification'
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/ic_launcher'); // <--- CAMBIA ESTO

    // Configuración para iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    // Solicitar permisos en Android 13+
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _requestAndroidPermissions();
    }
  }

  Future<void> _requestAndroidPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final bool? granted = await androidImplementation.requestNotificationsPermission();
      if (kDebugMode) {
        print("Permiso de notificación Android: $granted");
      }
      // Considerar solicitar permiso de alarma exacta si es necesario en el futuro
      // final bool? exactAlarmGranted = await androidImplementation.requestExactAlarmsPermission();
      // print("Permiso de alarma exacta Android: $exactAlarmGranted");
    }
  }


  static void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // Manejar notificación recibida mientras la app está en primer plano en iOS < 10
    if (kDebugMode) {
      print('iOS < 10 onDidReceiveLocalNotification: id $id, title $title, body $body, payload $payload');
    }
  }

  static void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) {
    // Manejar cuando el usuario toca la notificación
    if (kDebugMode) {
      print('onDidReceiveNotificationResponse: payload ${notificationResponse.payload}');
    }
    // Aquí podrías navegar a una pantalla específica si el payload lo indica
  }

  Future<void> scheduleWeeklyPregnancyNotification({
    required DateTime lmpDate,
    required int gestationalWeek, // La semana que está comenzando
  }) async {
    await cancelAllNotifications(); // Cancelar anteriores antes de programar nuevas

    if (gestationalWeek >= 42) { // No programar más allá de la semana 42 (o un límite razonable)
        if (kDebugMode) print("Semana gestacional ($gestationalWeek) demasiado avanzada para notificar.");
        return;
    }

    // Calcular la fecha de inicio de la próxima semana gestacional
    // LMP + (semana_actual * 7 días) = inicio de la semana actual
    // Próxima notificación: LMP + (semana_objetivo_notificacion * 7 días)
    // La notificación es PARA la semana `gestationalWeek`, entonces se dispara al inicio de esa semana.
    // Si la semana actual es `currentCalculatedWeek`, y queremos notificar para `gestationalWeek`,
    // la fecha de disparo es LMP + (gestationalWeek * 7) días.

    DateTime notificationDateTime = lmpDate.add(Duration(days: gestationalWeek * 7));

    // Configurar la hora de la notificación (ej. 9 AM)
    DateTime scheduledFireDateTime = DateTime(
      notificationDateTime.year,
      notificationDateTime.month,
      notificationDateTime.day,
      9, // 9 AM
      0, // 00 minutes
    );

    // Si la fecha calculada ya pasó para esta semana, programar para la siguiente semana que cumpla.
    final now = DateTime.now();
    if (scheduledFireDateTime.isBefore(now)) {
        if (kDebugMode) print("Fecha de notificación para semana $gestationalWeek ($scheduledFireDateTime) ya pasó. Intentando semana ${gestationalWeek + 1}.");
        // Intentamos para la siguiente semana si la actual ya pasó o es hoy pero la hora ya pasó.
        // Esto es para asegurar que si el usuario abre la app a mitad de semana,
        // la notificación se programe para el inicio de la *próxima* nueva semana.
        scheduledFireDateTime = lmpDate.add(Duration(days: (gestationalWeek + 1) * 7));
        scheduledFireDateTime = DateTime(
            scheduledFireDateTime.year,
            scheduledFireDateTime.month,
            scheduledFireDateTime.day,
            9,0
        );
        // Si incluso la siguiente semana está en el pasado (caso improbable si se calcula bien)
        if (scheduledFireDateTime.isBefore(now)){
            if (kDebugMode) print("Siguiente fecha de notificación ($scheduledFireDateTime) también en el pasado. No se programará.");
            return;
        }
         gestationalWeek++; // Ajustar la semana para el mensaje
         if (gestationalWeek >= 42) {
            if (kDebugMode) print("Semana gestacional para próxima notificación ($gestationalWeek) demasiado avanzada.");
            return;
         }
    }


    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(scheduledFireDateTime, tz.local);

    if (kDebugMode) {
      print('Programando notificación para semana $gestationalWeek en: $tzScheduledDate');
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // ID de la notificación (puedes usar uno por tipo o incremental)
      '¡Nueva Semana de Embarazo!',
      'Has entrado en la semana $gestationalWeek de tu embarazo. ¡Descubre las novedades!',
      tzScheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'gestib_pregnancy_channel', // ID del canal
          'Actualizaciones Semanales de Embarazo', // Nombre del canal
          channelDescription: 'Notificaciones sobre el progreso semanal del embarazo.',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'mipmap/ic_launcher', // <--- CAMBIA ESTO por tu icono real
          // sound: RawResourceAndroidNotificationSound('notification_sound'), // Si tienes sonido personalizado
        ),
        iOS: DarwinNotificationDetails(
          // sound: 'notification_sound.aiff', // Si tienes sonido personalizado
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Tratar de ser exacto
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // Repetir semanalmente a esa hora y día de la semana
      payload: 'semana_$gestationalWeek',
    );
     if (kDebugMode) {
        print("Notificación programada para la semana $gestationalWeek el $tzScheduledDate");
     }
  }


  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    if (kDebugMode) {
      print('Todas las notificaciones han sido canceladas.');
    }
  }
}
