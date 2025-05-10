// File: lib/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:flutter/foundation.dart'; // Para kDebugMode
// import 'package:flutter_native_timezone_updated_gradle/flutter_native_timezone.dart'; // Opción para zona horaria

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();
    // Determinar la zona horaria local de forma segura.
    // Si usas flutter_native_timezone, descomenta y ajusta:
    // try {
    //   final String? currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    //   if (currentTimeZone != null && currentTimeZone.isNotEmpty) {
    //     tz.setLocalLocation(tz.getLocation(currentTimeZone));
    //      if (kDebugMode) print('Zona horaria establecida a: $currentTimeZone');
    //   } else {
    //      if (kDebugMode) print('No se pudo obtener la zona horaria, usando Etc/UTC como fallback.');
    //      tz.setLocalLocation(tz.getLocation('Etc/UTC')); // Fallback
    //   }
    // } catch (e) {
    //   if (kDebugMode) print('Error obteniendo zona horaria local: $e. Usando Etc/UTC.');
    //   tz.setLocalLocation(tz.getLocation('Etc/UTC')); // Fallback en caso de error
    // }


    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/ic_launcher'); // Asegúrate que 'ic_launcher' exista en mipmap

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
      // No solicitaremos el permiso SCHEDULE_EXACT_ALARM por ahora para simplificar.
      // Si se necesitara exactitud crítica, se habilitaría esta parte y se manejaría el permiso:
      // final bool? exactAlarmGranted = await androidImplementation.requestExactAlarmsPermission();
      // if (kDebugMode) {
      //   print("Permiso de alarma exacta Android: $exactAlarmGranted");
      // }
    }
  }


  static void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    if (kDebugMode) {
      print('iOS < 10 onDidReceiveLocalNotification: id $id, title $title, body $body, payload $payload');
    }
  }

  static void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) {
    if (kDebugMode) {
      print('onDidReceiveNotificationResponse: payload ${notificationResponse.payload}');
    }
  }

  Future<void> scheduleWeeklyPregnancyNotification({
    required DateTime lmpDate,
    required int gestationalWeek, // La semana que está comenzando para la cual se notifica
  }) async {
    await cancelAllNotifications();

    if (gestationalWeek >= 42) { // No programar más allá de la semana 41 (info hasta la 42)
        if (kDebugMode) print("Semana gestacional ($gestationalWeek) demasiado avanzada para notificar.");
        return;
    }

    // La notificación es PARA la semana `gestationalWeek`, se dispara al inicio de esa semana.
    DateTime notificationFireDate = lmpDate.add(Duration(days: gestationalWeek * 7));

    // Configurar la hora de la notificación (ej. 9 AM)
    DateTime scheduledFireDateTime = DateTime(
      notificationFireDate.year,
      notificationFireDate.month,
      notificationFireDate.day,
      9, // 9 AM
      0, // 00 minutes
    );

    final now = DateTime.now();
    int targetWeekForNotificationMessage = gestationalWeek; // Semana para el mensaje

    // Si la fecha calculada ya pasó para esta semana, o es hoy pero la hora ya pasó,
    // programar para el inicio de la siguiente semana gestacional.
    if (scheduledFireDateTime.isBefore(now)) {
        if (kDebugMode) print("Fecha de notificación para semana $targetWeekForNotificationMessage ($scheduledFireDateTime) ya pasó. Intentando semana ${targetWeekForNotificationMessage + 1}.");
        
        targetWeekForNotificationMessage++; // Avanzamos la semana para el mensaje y el cálculo
        
        if (targetWeekForNotificationMessage >= 42) {
           if (kDebugMode) print("Semana gestacional para próxima notificación ($targetWeekForNotificationMessage) demasiado avanzada.");
           return;
        }

        notificationFireDate = lmpDate.add(Duration(days: targetWeekForNotificationMessage * 7));
        scheduledFireDateTime = DateTime(
            notificationFireDate.year,
            notificationFireDate.month,
            notificationFireDate.day,
            9,0
        );
        
        // Doble chequeo por si acaso el cálculo nos lleva de nuevo al pasado (improbable con lógica correcta)
        if (scheduledFireDateTime.isBefore(now)){
            if (kDebugMode) print("Siguiente fecha de notificación para semana $targetWeekForNotificationMessage ($scheduledFireDateTime) también en el pasado. No se programará.");
            return;
        }
    }

    // Es crucial que tz.local se haya configurado correctamente en init() si se depende de la zona horaria local.
    // Si no, puede que UTC sea usado por defecto por la librería.
    // Por simplicidad, asumimos que tz.local está configurado o que la conversión es manejada por la librería si no se especifica tz.local.
    tz.Location location;
    try {
        // Si usas flutter_native_timezone, asegúrate que esta lógica esté sincronizada con init.
        // final String? currentTimeZoneName = await FlutterNativeTimezone.getLocalTimezone();
        // location = tz.getLocation(currentTimeZoneName ?? 'Etc/UTC');
        location = tz.local; // Asume que tz.local fue configurado en init() o usa la configuración por defecto de la librería
    } catch (e) {
        if (kDebugMode) print("Error obteniendo tz.local, usando 'Etc/UTC': $e");
        location = tz.getLocation('Etc/UTC');
    }

    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(scheduledFireDateTime, location);

    if (kDebugMode) {
      print('Programando notificación para semana $targetWeekForNotificationMessage en: $tzScheduledDate (Zona Horaria: ${tzScheduledDate.location.name})');
    }

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0, // ID de la notificación
        '¡Nueva Semana de Embarazo!',
        'Has entrado en la semana $targetWeekForNotificationMessage de tu embarazo. ¡Descubre las novedades!',
        tzScheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'gestib_pregnancy_channel', // ID del canal
            'Actualizaciones Semanales de Embarazo', // Nombre del canal
            channelDescription: 'Notificaciones sobre el progreso semanal del embarazo.',
            importance: Importance.high,
            priority: Priority.high,
            icon: 'mipmap/ic_launcher', // CAMBIAR si tienes un icono específico para notificaciones
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, // CAMBIO A INEXACTO
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // Repetir semanalmente
        payload: 'semana_$targetWeekForNotificationMessage',
      );
      if (kDebugMode) {
          print("Notificación programada para la semana $targetWeekForNotificationMessage el $tzScheduledDate");
      }
    } catch (e) {
        if (kDebugMode) {
            print("Error al programar la notificación: $e");
            // Si el error es por permisos de alarma exacta, este cambio a inexacto debería prevenirlo.
            // Si persiste, podría ser otro problema de configuración o permisos.
        }
    }
  }


  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    if (kDebugMode) {
      print('Todas las notificaciones han sido canceladas.');
    }
  }
}
