// File: lib/home_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import 'settings_screen.dart';
import 'theme_notifier.dart';
import 'notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _selectedLMPDate;
  DateTime? _estimatedDueDate;
  String? _zodiacSign;
  int? _gestationalWeeks;
  int? _gestationalDays;

  final NotificationService _notificationService = NotificationService();
  static const String _remindersEnabledKey = 'weeklyRemindersEnabled';

  final Map<int, Map<String, dynamic>> _weeklyData = {
    1: {'symptoms': ['Inicio del ciclo menstrual', 'Preparación del cuerpo'], 'bpd': 'N/A', 'weight': 'N/A', 'length': 'N/A', 'femur': 'N/A', 'notes': 'La "semana 1" comienza el primer día de tu último período menstrual, antes de la concepción.'},
    2: {'symptoms': ['Ovulación (posiblemente a final de semana)', 'Flujo vaginal más elástico'], 'bpd': 'N/A', 'weight': 'N/A', 'length': 'N/A', 'femur': 'N/A', 'notes': 'La concepción suele ocurrir al final de esta semana o inicio de la siguiente.'},
    3: {'symptoms': ['Fertilización e implantación', 'Algunas mujeres no notan nada', 'Posible ligero manchado (sangrado de implantación)'], 'bpd': 'N/A', 'weight': 'Microscópico', 'length': 'Microscópico', 'femur': 'N/A', 'notes': 'El óvulo fertilizado viaja y se implanta en el útero.'},
    4: {'symptoms': ['Retraso menstrual (primer signo común)', 'Pechos sensibles o hinchados', 'Fatiga leve', 'Prueba de embarazo positiva'], 'bpd': 'N/A', 'weight': '<1g', 'length': '<1mm (como una semilla de amapola)', 'femur': 'N/A', 'notes': 'El embrión es diminuto, pero ya se está desarrollando rápidamente.'},
    5: {'symptoms': ['Fatiga aumentada', 'Náuseas leves (pueden empezar)', 'Micción frecuente', 'Sensibilidad a olores'], 'bpd': 'N/A', 'weight': '~1g', 'length': '1-5mm (como una semilla de sésamo)', 'femur': 'N/A', 'notes': 'Se forma el tubo neural (futuro cerebro y médula espinal). El corazón empieza a latir.'},
    6: {'symptoms': ['Náuseas matutinas más evidentes', 'Cambios de humor', 'Aversión a ciertos alimentos', 'Antojos'], 'bpd': 'N/A', 'weight': '~1-2g', 'length': '4-6mm (como un guisante pequeño)', 'femur': 'N/A', 'notes': 'Se distinguen rasgos faciales básicos. Brotes de brazos y piernas.'},
    7: {'symptoms': ['Antojos y aversiones alimentarias intensificadas', 'Aumento de la sensibilidad olfativa', 'Salivación excesiva'], 'bpd': '~4mm', 'weight': '~2g', 'length': '~1cm (como un arándano)', 'femur': '~1mm', 'notes': 'Se forman manos y pies. El cerebro se desarrolla rápidamente.'},
    8: {'symptoms': ['Fatiga intensa', 'Mareos leves', 'Pechos más grandes y sensibles', 'Posible acné'], 'bpd': '~6-8mm', 'weight': '~3g', 'length': '~1.6cm (como una frambuesa)', 'femur': '~1.5-2mm', 'notes': 'Todos los órganos principales están comenzando a formarse. El embrión empieza a moverse, aunque no lo sientas.'},
    9: {'symptoms': ['Acidez estomacal leve', 'Estreñimiento', 'Venas más visibles (especialmente en pechos)', 'Ropa puede empezar a apretar'], 'bpd': '~9-11mm', 'weight': '~4g', 'length': '~2.3cm (como una uva)', 'femur': '~2-3mm', 'notes': 'Los párpados cubren los ojos. Se forman los dedos de manos y pies.'},
    10: {'symptoms': ['Náuseas pueden empezar a disminuir (para algunas)', 'Ligero aumento de flujo vaginal', 'Cambios emocionales'], 'bpd': '~1.4cm', 'weight': '~5-7g', 'length': '~3.1cm (como una ciruela pasa)', 'femur': '~3-4mm', 'notes': 'El embrión ahora se considera un feto. Órganos vitales casi completamente formados.'},
    11: {'symptoms': ['Aumento de energía (posible)', 'Ligero aumento de peso', 'Menor riesgo de aborto espontáneo'], 'bpd': '~1.8cm', 'weight': '~7-10g', 'length': '~4.1cm (como una lima)', 'femur': '~4-5mm', 'notes': 'El feto puede tragar y patear. Se desarrollan las uñas.'},
    12: {'symptoms': ['El útero crece por encima del hueso pélvico', 'Puede empezar a notarse una pequeña barriga', 'Náuseas suelen mejorar mucho'], 'bpd': '~2.1cm', 'weight': '~14g', 'length': '~5.4cm (como una ciruela grande)', 'femur': '~0.8cm', 'notes': 'Los reflejos del feto están activos. Los órganos sexuales comienzan a diferenciarse.'},
    13: {'symptoms': ['¡Comienzo del segundo trimestre!', 'Menos molestias comunes del primer trimestre', 'Aumento del apetito'], 'bpd': '~2.5cm', 'weight': '~23-25g', 'length': '~7.4cm (como una vaina de guisante)', 'femur': '~1.1cm', 'notes': 'Las huellas dactilares se están formando. El feto puede bostezar.'},
    14: {'symptoms': ['Aumento del apetito continua', 'Posible congestión nasal (rinitis del embarazo)', 'Piel puede verse más radiante'], 'bpd': '~2.8cm', 'weight': '~43-45g', 'length': '~8.7cm (como un limón)', 'femur': '~1.4cm', 'notes': 'El feto puede fruncir el ceño y hacer muecas. El lanugo (vello fino) cubre el cuerpo.'},
    15: {'symptoms': ['Podrías sentir los primeros movimientos fetales (especialmente si no es tu primer embarazo)', 'Aumento de energía'], 'bpd': '~3.2cm', 'weight': '~70g', 'length': '~10.1cm (como una manzana)', 'femur': '~1.7cm', 'notes': 'El esqueleto se endurece. El feto puede oír sonidos amortiguados.'},
    16: {'symptoms': ['Crecimiento notable del abdomen', 'Dolores de espalda leves', 'Posibles olvidos ("cerebro de embarazada")'], 'bpd': '~3.5cm', 'weight': '~100g', 'length': '~11.6cm (como un aguacate)', 'femur': '~2.0cm', 'notes': 'Los ojos pueden moverse lentamente. Las piernas son más largas que los brazos.'},
    17: {'symptoms': ['Aumento de peso más constante', 'Vértigo ocasional al levantarse rápido', 'Aumento del flujo sanguíneo'], 'bpd': '~3.8cm', 'weight': '~140g', 'length': '~13cm (como una granada)', 'femur': '~2.3cm', 'notes': 'Se forma el tejido adiposo (grasa). El feto practica la respiración.'},
    18: {'symptoms': ['Movimientos fetales más perceptibles', 'Dificultad para encontrar una postura cómoda para dormir', 'Hambre frecuente'], 'bpd': '~4.2cm', 'weight': '~190g', 'length': '~14.2cm (como un pimiento)', 'femur': '~2.6cm', 'notes': 'Se pueden identificar los genitales en una ecografía. Las cuerdas vocales se forman.'},
    19: {'symptoms': ['Dolor en el ligamento redondo (tirones en el bajo vientre)', 'Calambres en las piernas', 'Posible aparición de la línea alba'], 'bpd': '~4.5cm', 'weight': '~240g', 'length': '~15.3cm (como un mango grande)', 'femur': '~3.0cm', 'notes': 'Se desarrolla la vérnix caseosa (sustancia grasa que protege la piel). Los sentidos se agudizan.'},
    20: {'symptoms': ['Movimientos fetales claros y regulares', 'Ecografía morfológica (semana 18-22)', 'Acidez puede reaparecer o empeorar'], 'bpd': '~4.9cm', 'weight': '~300g', 'length': '~25.6cm (coronilla-talón, como un plátano pequeño)', 'femur': '~3.3cm', 'notes': 'El feto traga líquido amniótico. Se desarrollan las papilas gustativas.'},
    21: {'symptoms': ['Sensación de bienestar general para muchas', 'Aumento del apetito', 'Piel puede estar más grasa'], 'bpd': '~5.2cm', 'weight': '~360g', 'length': '~26.7cm', 'femur': '~3.6cm', 'notes': 'El feto es más activo. Las cejas y párpados están bien definidos.'},
    22: {'symptoms': ['Estrías pueden empezar a aparecer', 'Ombligo puede sobresalir', 'Pies y tobillos hinchados levemente'], 'bpd': '~5.5cm', 'weight': '~430g', 'length': '~27.8cm', 'femur': '~3.9cm', 'notes': 'El feto tiene aspecto de un recién nacido en miniatura. El lanugo cubre todo el cuerpo.'},
    23: {'symptoms': ['Mayor sensibilidad en las encías', 'Ronquidos al dormir', 'Contracciones de Braxton Hicks (leves e irregulares)'], 'bpd': '~5.8cm', 'weight': '~500g', 'length': '~28.9cm', 'femur': '~4.2cm', 'notes': 'Los pulmones continúan madurando. El feto puede tener hipo.'},
    24: {'symptoms': ['Prueba de tolerancia a la glucosa (entre semana 24-28)', 'Piel del abdomen puede picar', 'Dificultad para dormir'], 'bpd': '~6.0cm', 'weight': '~600g', 'length': '~30cm (como una mazorca de maíz)', 'femur': '~4.4cm', 'notes': 'El feto es viable (con cuidados intensivos). Los alvéolos pulmonares se desarrollan.'},
    25: {'symptoms': ['Dolor de espalda más común', 'Posible estreñimiento', 'Aumento de la frecuencia urinaria'], 'bpd': '~6.3cm', 'weight': '~660g', 'length': '~34.6cm', 'femur': '~4.7cm', 'notes': 'El feto responde a la voz y al tacto. Establece ciclos de sueño y vigilia.'},
    26: {'symptoms': ['Hinchazón en manos y pies más notoria', 'Calambres en las piernas por la noche', 'Fatiga puede regresar'], 'bpd': '~6.6cm', 'weight': '~760g', 'length': '~35.6cm', 'femur': '~5.0cm', 'notes': 'Los ojos se abren y cierran. Los pulmones producen surfactante.'},
    27: {'symptoms': ['¡Comienzo del tercer trimestre!', 'Presión en la pelvis', 'Dificultad para respirar profundamente a veces'], 'bpd': '~6.9cm', 'weight': '~875g', 'length': '~36.6cm', 'femur': '~5.2cm', 'notes': 'El cerebro crece rápidamente. El feto practica movimientos respiratorios.'},
    28: {'symptoms': ['Visitas prenatales más frecuentes', 'Acidez frecuente', 'Insomnio leve o moderado'], 'bpd': '~7.2cm', 'weight': '~1kg', 'length': '~37.6cm (como una berenjena grande)', 'femur': '~5.3cm', 'notes': 'El feto puede distinguir la luz. Buenas posibilidades de supervivencia si nace prematuramente.'},
    29: {'symptoms': ['Aumento de peso fetal considerable', 'Parestesias (hormigueo en manos)', 'Necesidad de orinar con frecuencia'], 'bpd': '~7.5cm', 'weight': '~1.15kg', 'length': '~38.6cm', 'femur': '~5.5cm', 'notes': 'Los huesos se endurecen (excepto el cráneo). La cabeza es proporcional al cuerpo.'},
    30: {'symptoms': ['Fatiga y dificultad para moverse', 'Cambios de humor más pronunciados', 'Pechos pueden empezar a gotear calostro'], 'bpd': '~7.8cm', 'weight': '~1.3kg', 'length': '~39.9cm', 'femur': '~5.7cm', 'notes': 'El lanugo comienza a desaparecer. La médula ósea produce glóbulos rojos.'},
    31: {'symptoms': ['Contracciones de Braxton Hicks más frecuentes', 'Dolor de espalda y pelvis', 'Dificultad para encontrar una postura cómoda'], 'bpd': '~8.0cm', 'weight': '~1.5kg', 'length': '~41.1cm', 'femur': '~6.0cm', 'notes': 'Todos los sentidos están funcionando. El feto acumula grasa.'},
    32: {'symptoms': ['Dificultad para respirar (útero presiona diafragma)', 'Hinchazón de pies y manos', 'Preparación del "nido"'], 'bpd': '~8.2cm', 'weight': '~1.7kg', 'length': '~42.4cm (como una col china)', 'femur': '~6.2cm', 'notes': 'Las uñas de los pies llegan a la punta de los dedos. El feto suele colocarse cabeza abajo.'},
    33: {'symptoms': ['Menor espacio para el bebé, movimientos pueden sentirse diferentes', 'Presión en la vejiga', 'Cansancio'], 'bpd': '~8.4cm', 'weight': '~1.9kg', 'length': '~43.7cm', 'femur': '~6.4cm', 'notes': 'El sistema inmunológico se fortalece. La piel se vuelve más lisa y rosada.'},
    34: {'symptoms': ['Fatiga extrema', 'Posible descenso del bebé (encajamiento)', 'Aumento de la presión pélvica'], 'bpd': '~8.6cm', 'weight': '~2.1kg', 'length': '~45cm', 'femur': '~6.6cm', 'notes': 'Los pulmones están casi maduros. La vérnix caseosa es más gruesa.'},
    35: {'symptoms': ['Visitas semanales al médico', 'Mayor frecuencia de micción', 'Dificultad para dormir'], 'bpd': '~8.8cm', 'weight': '~2.4kg', 'length': '~46.2cm', 'femur': '~6.8cm', 'notes': 'El feto gana peso rápidamente. El desarrollo cerebral es intenso.'},
    36: {'symptoms': ['El bebé desciende ("encajamiento"), facilitando la respiración pero aumentando presión pélvica', 'Aumento de flujo vaginal', 'Contracciones más notorias'], 'bpd': '~9.0cm', 'weight': '~2.6kg', 'length': '~47.4cm (como una papaya pequeña)', 'femur': '~7.0cm', 'notes': 'El feto se considera a término a partir de la semana 37. Práctica de succión y deglución.'},
    37: {'symptoms': ['Ansiedad y emoción por el parto', 'Posible expulsión del tapón mucoso', 'Sensación de "estar lista"'], 'bpd': '~9.1cm', 'weight': '~2.9kg', 'length': '~48.6cm', 'femur': '~7.2cm', 'notes': 'El feto está listo para nacer. El lanugo ha desaparecido casi por completo.'},
    38: {'symptoms': ['Presión pélvica intensa', 'Mayor torpeza', 'Falsas alarmas de parto'], 'bpd': '~9.2cm', 'weight': '~3.1kg', 'length': '~49.8cm', 'femur': '~7.4cm', 'notes': 'El feto sigue acumulando grasa. Los órganos están completamente maduros.'},
    39: {'symptoms': ['Impaciencia', 'Síntomas premonitorios de parto (contracciones, rotura de aguas)', 'Hinchazón puede ser significativa'], 'bpd': '~9.3cm', 'weight': '~3.3kg', 'length': '~50.7cm', 'femur': '~7.5cm', 'notes': 'El feto está completamente desarrollado y esperando el momento de nacer.'},
    40: {'symptoms': ['¡Fecha probable de parto!', 'Ansiedad/Excitación máxima', 'Contracciones más regulares y fuertes si el parto comienza', 'Cansancio extremo'], 'bpd': '~9.5cm', 'weight': '~3.4kg-3.5kg', 'length': '~51.2cm (como una sandía pequeña)', 'femur': '~7.6cm', 'notes': 'Solo un pequeño porcentaje de bebés nace en su FPP. El parto puede ocurrir entre la semana 38 y 42.'},
  };
  final DateFormat _dateFormatter = DateFormat.yMMMMd('es_ES');
  final Duration _gestationDurationFromLMP = const Duration(days: 280);

  Future<void> _handleNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final bool remindersEnabled = prefs.getBool(_remindersEnabledKey) ?? true;

    if (!remindersEnabled) {
      await _notificationService.cancelAllNotifications();
      return;
    }

    if (_selectedLMPDate != null && _gestationalWeeks != null) {
      int weekToNotify = _gestationalWeeks!;
      DateTime startOfWeekDate = _selectedLMPDate!.add(Duration(days: _gestationalWeeks! * 7));
      DateTime notificationTimeForCurrentWeek = DateTime(startOfWeekDate.year, startOfWeekDate.month, startOfWeekDate.day, 9, 0);

      if (DateTime.now().isAfter(notificationTimeForCurrentWeek)) {
        weekToNotify = _gestationalWeeks! + 1;
         if (kDebugMode) print("homescreen: Hora de notificación para semana actual ($_gestationalWeeks) ya pasó. Programando para semana $weekToNotify.");
      }

      if (weekToNotify < 42) {
        await _notificationService.scheduleWeeklyPregnancyNotification(
          lmpDate: _selectedLMPDate!,
          gestationalWeek: weekToNotify,
        );
      } else {
        await _notificationService.cancelAllNotifications();
         if (kDebugMode) print("homescreen: Semana $weekToNotify demasiado avanzada, cancelando notificaciones.");
      }
    } else {
      await _notificationService.cancelAllNotifications();
       if (kDebugMode) print("homescreen: Sin FUR o semanas gestacionales, cancelando notificaciones.");
    }
  }

  void _calculateDates() {
    if (_selectedLMPDate != null) {
      final now = DateTime.now();
      final todayNormalized = DateTime(now.year, now.month, now.day);
      final lmpNormalized = DateTime(_selectedLMPDate!.year, _selectedLMPDate!.month, _selectedLMPDate!.day);
      final differenceInDays = todayNormalized.difference(lmpNormalized).inDays;
      final dueDate = _selectedLMPDate!.add(_gestationDurationFromLMP);
      final zodiac = _getZodiacSign(dueDate);

      if (differenceInDays >= 0) {
        final weeks = differenceInDays ~/ 7;
        final days = differenceInDays % 7;
        setState(() {
          _gestationalWeeks = weeks;
          _gestationalDays = days;
          _estimatedDueDate = dueDate;
          _zodiacSign = zodiac;
        });
      } else {
         setState(() {
           _estimatedDueDate = dueDate;
           _zodiacSign = zodiac;
           _gestationalWeeks = null;
           _gestationalDays = null;
         });
      }
      _handleNotifications();
    } else {
      _resetCalculations();
    }
  }

  void _resetCalculations() {
     setState(() {
        _selectedLMPDate = null;
        _estimatedDueDate = null;
        _zodiacSign = null;
        _gestationalWeeks = null;
        _gestationalDays = null;
      });
     _notificationService.cancelAllNotifications();
  }

  String _getZodiacSign(DateTime date) {
    int day = date.day;
    int month = date.month;
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'Acuario ♒';
    if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) return 'Piscis ♓';
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Aries ♈';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Tauro ♉';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'Géminis ♊';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'Cáncer ♋';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Leo ♌';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Virgo ♍';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'Libra ♎';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return 'Escorpio ♏';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return 'Sagitario ♐';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return 'Capricornio ♑';
    return 'Error Zodíaco';
  }

  Future<void> _selectLMPDate(BuildContext context) async {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedLMPDate ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime.now().add(const Duration(days: 280)),
      locale: const Locale('es', 'ES'),
      helpText: themeNotifier.transformText('Fecha de Última Regla (FUR)'),
      cancelText: themeNotifier.transformText('CANCELAR'),
      confirmText: themeNotifier.transformText('ACEPTAR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: themeNotifier.primaryColor,
                  onPrimary: (Theme.of(context).brightness == Brightness.light && themeNotifier.primaryColor.computeLuminance() > 0.5) ||
                             (Theme.of(context).brightness == Brightness.dark && themeNotifier.primaryColor.computeLuminance() < 0.5)
                      ? Colors.black
                      : Colors.white,
                ),
            dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: themeNotifier.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedLMPDate) {
      setState(() {
        _selectedLMPDate = picked;
      });
      _calculateDates();
    }
  }

  String _formatGestationalAgeString(int? weeks, int? days) {
    if (weeks == null || days == null) return 'N/A';
    if (weeks < 0) return 'Fecha futura';
    final String weekText = weeks == 1 ? 'semana' : 'semanas';
    final String dayText = days == 1 ? 'día' : 'días';
    if (weeks == 0 && days == 0) return 'Menos de 1 semana';
    if (weeks > 0 && days > 0) return '$weeks $weekText + $days $dayText';
    if (weeks > 0 && days == 0) return '$weeks $weekText';
    if (weeks == 0 && days > 0) return '$days $dayText';
    return '$weeks $weekText + $days $dayText';
  }

  Widget _buildEmptyState(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.calendar_month_outlined,
          size: 80,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
        ),
        const SizedBox(height: 24),
        Text(
          themeNotifier.transformText('Selecciona la fecha de tu última regla (FUR)'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
              ),
        ),
        const SizedBox(height: 16),
        Text(
          themeNotifier.transformText('Calcularemos tu fecha probable de parto y te mostraremos información semanal.'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
        ),
        const SizedBox(height: 32),
        Center(
          child: FilledButton.icon(
            icon: const Icon(Icons.edit_calendar_outlined),
            label: Text(themeNotifier.transformText('Seleccionar Fecha FUR')),
            onPressed: () => _selectLMPDate(context),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelectionCard(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return Card(
      elevation: Theme.of(context).cardTheme.elevation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              themeNotifier.transformText('Fecha de Última Regla (FUR):'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12.0),
            Text(
              _selectedLMPDate != null
                ? themeNotifier.transformText(_dateFormatter.format(_selectedLMPDate!))
                : themeNotifier.transformText('No seleccionada'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12.0),
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.edit_calendar_outlined, size: 18),
                label: Text(themeNotifier.transformText(_selectedLMPDate == null ? 'Seleccionar Fecha' : 'Cambiar Fecha')),
                onPressed: () => _selectLMPDate(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildSummaryCard(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    if (_estimatedDueDate == null) return const SizedBox.shrink();
    return Card(
      elevation: Theme.of(context).cardTheme.elevation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          children: [
            Text(
              themeNotifier.transformText('Fecha Estimada de Parto (FEP)'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            Text(
              themeNotifier.transformText(_dateFormatter.format(_estimatedDueDate!)),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            Text(
              themeNotifier.transformText(_zodiacSign ?? 'N/A'),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            if (_gestationalWeeks != null && _gestationalDays != null && _gestationalWeeks! >= 0) ...[
              const Divider(height: 32.0, thickness: 0.5),
              Text(
                themeNotifier.transformText('Edad Gestacional Actual'),
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4.0),
              Text(
                themeNotifier.transformText(_formatGestationalAgeString(_gestationalWeeks, _gestationalDays)),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyInfoCard(BuildContext context, Map<String, dynamic>? weekData, int? weekNumber) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    if (weekData == null || weekNumber == null || weekNumber < 0 || _gestationalWeeks == null) {
      if (_selectedLMPDate != null && _estimatedDueDate != null) {
          final now = DateTime.now();
          final todayNormalized = DateTime(now.year, now.month, now.day);
          if (todayNormalized.isAfter(_estimatedDueDate!.add(const Duration(days: 14)))) {
             return Card(
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                        themeNotifier.transformText("La fecha probable de parto ya ha pasado. Si necesitas información, consulta con tu profesional de salud."),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium
                    )
                )
             );
          }
          if (_gestationalWeeks != null && _gestationalWeeks! < 0) {
            return Card(
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                        themeNotifier.transformText("Información semanal disponible a partir de la concepción."),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium
                    )
                )
             );
          }
      }
      return const SizedBox.shrink();
    }

    final symptoms = (weekData['symptoms'] as List<dynamic>? ?? []).map((s) => themeNotifier.transformText(s.toString())).toList();
    final notes = weekData['notes'] != null ? themeNotifier.transformText(weekData['notes'] as String) : null;
    final List<Widget> fetalMetricsWidgets = [];
    final Map<String, IconData> metricIcons = {
      'length': Icons.straighten_outlined, 'weight': Icons.monitor_weight_outlined,
      'bpd': Icons.aspect_ratio_outlined, 'femur': Icons.square_foot_outlined,
    };
    final Map<String, String> metricLabels = {
      'length': 'Talla:', 'weight': 'Peso:', 'bpd': 'DBP:', 'femur': 'Fémur:',
    };

    metricLabels.forEach((key, label) {
      final value = weekData[key]?.toString();
      if (value != null && value != 'N/A' && value.isNotEmpty) {
        fetalMetricsWidgets.add(_buildMetricRow(context, metricIcons[key]!, themeNotifier.transformText(label), themeNotifier.transformText(value)));
      }
    });

    return Card(
      elevation: Theme.of(context).cardTheme.elevation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
               themeNotifier.transformText('Información de la Semana $weekNumber'),
               style: Theme.of(context).textTheme.titleLarge?.copyWith(
                 color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold
               ),
             ),
             if (notes != null && notes.isNotEmpty) ...[
                const SizedBox(height: 8.0),
                Text(
                  notes, // Ya transformado
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
             ],
             if (fetalMetricsWidgets.isNotEmpty) ...[
               const SizedBox(height: 16.0),
               Text(themeNotifier.transformText('Desarrollo Fetal Estimado:'), style: Theme.of(context).textTheme.titleMedium),
               const SizedBox(height: 12.0),
               ...fetalMetricsWidgets,
             ],
             if (symptoms.isNotEmpty)...[
                const Divider(height: 24.0, thickness: 0.5),
                Text(themeNotifier.transformText('Síntomas Comunes Maternos:'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8.0),
                Wrap(
                  spacing: 8.0, runSpacing: 4.0,
                  children: symptoms.map((symptom) => Chip(label: Text(symptom))).toList(), // symptom ya transformado
                ),
             ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(BuildContext context, IconData icon, String label, String value) {
    // label y value ya vienen transformados desde _buildWeeklyInfoCard
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context); // listen: true para que el AppBar se reconstruya
    Map<String, dynamic>? currentWeekData;
    if (_gestationalWeeks != null && _gestationalWeeks! >= 0 && _weeklyData.containsKey(_gestationalWeeks!)) {
      currentWeekData = _weeklyData[_gestationalWeeks!];
    }

    return Scaffold(
      appBar: AppBar(
         title: Text('gestib', style: Theme.of(context).appBarTheme.titleTextStyle), // Siempre minúscula
         centerTitle: true,
         actions: [
           IconButton(
             icon: const Icon(Icons.settings_outlined),
             tooltip: themeNotifier.transformText('Configuración'),
             onPressed: () async {
               await Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => const SettingsScreen()),
               );
               _handleNotifications();
             },
           ),
         ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _selectedLMPDate == null
                ? Align(
                   alignment: Alignment.center,
                   key: const ValueKey('EmptyState'),
                   child: Padding(padding: const EdgeInsets.all(16.0), child: _buildEmptyState(context)),
                  )
                : SingleChildScrollView(
                    key: const ValueKey('ResultsState'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildDateSelectionCard(context),
                        const SizedBox(height: 24.0),
                        _buildSummaryCard(context),
                        const SizedBox(height: 24.0),
                        _buildWeeklyInfoCard(context, currentWeekData, _gestationalWeeks),
                        const SizedBox(height: 24.0),
                        if (_selectedLMPDate != null)
                          Center(
                            child: TextButton(
                              onPressed: _resetCalculations,
                              child: Text(themeNotifier.transformText('Calcular Nuevo Embarazo')),
                            ),
                          ),
                        const SizedBox(height: 16.0),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
