// File: lib/home_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // Para kDebugMode

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
    1: {
      'symptoms': ['Inicio del ciclo menstrual', 'Preparación del cuerpo'],
      // 'bpd': 'N/A', 'weight': 'N/A', 'length': 'N/A', 'femur': 'N/A', // Omitidos si no aplican
      'notes': 'La "semana 1" comienza el primer día de tu último período menstrual, antes de la concepción.',
      'recommendations': ['Mantén un estilo de vida saludable.', 'Considera registrar tus ciclos si buscas concebir.'],
      'image_month_id': 1
    },
    2: {
      'symptoms': ['Ovulación (posiblemente a final de semana)', 'Flujo vaginal más elástico'],
      'notes': 'La concepción suele ocurrir al final de esta semana o inicio de la siguiente.',
      'recommendations': ['Si intentas concebir, este es un buen momento para la actividad sexual.', 'Sigue con hábitos saludables.'],
      'image_month_id': 1
    },
    3: {
      'symptoms': ['Fertilización e implantación', 'Posible ligero manchado (sangrado de implantación)'],
      'weight': 'Microscópico', 'length': 'Microscópico',
      'notes': 'El óvulo fertilizado viaja y se implanta en el útero.',
      'recommendations': ['Evita el alcohol, tabaco y drogas.', 'Descansa adecuadamente.'],
      'image_month_id': 1
    },
    4: {
      'symptoms': ['Retraso menstrual', 'Pechos sensibles', 'Fatiga leve', 'Prueba de embarazo positiva'],
      'weight': '<1g', 'length': '<1mm (como una semilla de amapola)',
      'notes': 'El embrión es diminuto. El corazón podría empezar a latir.',
      'recommendations': ['Confirma el embarazo con una prueba.', 'Comienza a tomar ácido fólico (400-800 mcg/día).', 'Programa tu primera cita prenatal.', 'Mantén una dieta equilibrada e hidratación.'],
      'image_month_id': 1
    },
    5: {
      'symptoms': ['Fatiga aumentada', 'Náuseas leves', 'Micción frecuente', 'Sensibilidad a olores'],
      'weight': '~1g', 'length': '1-5mm (como una semilla de sésamo)',
      'notes': 'Se forma el tubo neural. El corazón late con regularidad.',
      'recommendations': ['Para las náuseas: come pequeñas porciones frecuentes, evita olores fuertes, prueba galletas saladas.', 'Descansa cuando lo necesites.', 'Continúa con el ácido fólico.'],
      'image_month_id': 2
    },
    6: {
      'symptoms': ['Náuseas matutinas más evidentes', 'Cambios de humor', 'Aversión a ciertos alimentos'],
      'weight': '~1-2g', 'length': '4-6mm (como un guisante pequeño)',
      'notes': 'Se distinguen rasgos faciales básicos. Brotes de brazos y piernas.',
      'recommendations': ['Vístete con ropa cómoda.', 'Habla sobre tus sentimientos con tu pareja o alguien de confianza.', 'Jengibre puede ayudar con las náuseas (consulta a tu médico).'],
      'image_month_id': 2
    },
    7: {
      'symptoms': ['Antojos y aversiones alimentarias', 'Aumento de la sensibilidad olfativa', 'Salivación excesiva'],
      'bpd': '~4mm', 'weight': '~2g', 'length': '~1cm (como un arándano)', 'femur': '~1mm',
      'notes': 'Se forman manos y pies. El cerebro se desarrolla rápidamente.',
      'recommendations': ['Mantén una buena higiene bucal.', 'Bebe mucha agua.', 'Evita alimentos crudos o poco cocidos.'],
      'image_month_id': 2
    },
    8: {
      'symptoms': ['Fatiga intensa', 'Mareos leves', 'Pechos más grandes y sensibles', 'Posible acné'],
      'bpd': '~6-8mm', 'weight': '~3g', 'length': '~1.6cm (como una frambuesa)', 'femur': '~1.5-2mm',
      'notes': 'Todos los órganos principales están comenzando a formarse. El embrión empieza a moverse.',
      'recommendations': ['Usa un sujetador de buen soporte.', 'Levántate despacio para evitar mareos.', 'Consulta sobre tu primera ecografía.'],
      'image_month_id': 2
    },
    9: {
      'symptoms': ['Acidez estomacal leve', 'Estreñimiento', 'Venas más visibles'],
      'bpd': '~9-11mm', 'weight': '~4g', 'length': '~2.3cm (como una uva)', 'femur': '~2-3mm',
      'notes': 'Los párpados cubren los ojos. Se forman los dedos.',
      'recommendations': ['Para la acidez: come porciones pequeñas, evita acostarte justo después de comer.', 'Para el estreñimiento: consume fibra y líquidos, haz ejercicio ligero.'],
      'image_month_id': 3
    },
    10: {
      'symptoms': ['Náuseas pueden empezar a disminuir', 'Ligero aumento de flujo vaginal', 'Cambios emocionales'],
      'bpd': '~1.4cm', 'weight': '~5-7g', 'length': '~3.1cm (como una ciruela pasa)', 'femur': '~3-4mm',
      'notes': 'El embrión ahora se considera un feto. Órganos vitales casi formados.',
      'recommendations': ['Considera compartir la noticia con familiares y amigos cercanos si te sientes cómoda.', 'Realiza ejercicios de Kegel.'],
      'image_month_id': 3
    },
    11: {
      'symptoms': ['Aumento de energía (posible)', 'Ligero aumento de peso', 'Menor riesgo de aborto'],
      'bpd': '~1.8cm', 'weight': '~7-10g', 'length': '~4.1cm (como una lima)', 'femur': '~4-5mm',
      'notes': 'El feto puede tragar y patear. Se desarrollan las uñas.',
      'recommendations': ['Aprovecha el aumento de energía para hacer ejercicio moderado (aprobado por tu médico).', 'Empieza a pensar en ropa de maternidad.'],
      'image_month_id': 3
    },
    12: {
      'symptoms': ['El útero crece por encima del hueso pélvico', 'Puede empezar a notarse la barriga', 'Náuseas suelen mejorar'],
      'bpd': '~2.1cm', 'weight': '~14g', 'length': '~5.4cm (como una ciruela grande)', 'femur': '~0.8cm',
      'notes': 'Los reflejos del feto están activos. Órganos sexuales comienzan a diferenciarse.',
      'recommendations': ['Es un buen momento para pruebas de detección prenatal si no las has hecho (ej. translucencia nucal).', 'Mantén una buena postura.'],
      'image_month_id': 3
    },
    13: {
      'symptoms': ['¡Comienzo del segundo trimestre!', 'Menos molestias comunes', 'Aumento del apetito'],
      'bpd': '~2.5cm', 'weight': '~23-25g', 'length': '~7.4cm (como una vaina de guisante)', 'femur': '~1.1cm',
      'notes': 'Las huellas dactilares se están formando. El feto puede bostezar.',
      'recommendations': ['Disfruta esta etapa, a menudo la más cómoda.', 'Asegúrate de una nutrición rica en calcio y hierro.', 'Considera clases de preparación para el parto.'],
      'image_month_id': 3
    },
     14: {
      'symptoms': ['Aumento del apetito continua', 'Posible congestión nasal', 'Piel puede verse más radiante'],
      'bpd': '~2.8cm', 'weight': '~43-45g', 'length': '~8.7cm (como un limón)', 'femur': '~1.4cm',
      'notes': 'El feto puede fruncir el ceño y hacer muecas. El lanugo (vello fino) cubre el cuerpo.',
      'recommendations': ['Usa un humidificador para la congestión nasal.', 'Bebe suficiente agua.', 'Cuida tu piel con hidratantes suaves.'],
      'image_month_id': 4
    },
    15: {
      'symptoms': ['Podrías sentir los primeros movimientos fetales', 'Aumento de energía'],
      'bpd': '~3.2cm', 'weight': '~70g', 'length': '~10.1cm (como una manzana)', 'femur': '~1.7cm',
      'notes': 'El esqueleto se endurece. El feto puede oír sonidos amortiguados.',
      'recommendations': ['Presta atención a los movimientos del bebé, ¡es emocionante!', 'Habla o canta a tu bebé.'],
      'image_month_id': 4
    },
    16: {
      'symptoms': ['Crecimiento notable del abdomen', 'Dolores de espalda leves', 'Posibles olvidos'],
      'bpd': '~3.5cm', 'weight': '~100g', 'length': '~11.6cm (como un aguacate)', 'femur': '~2.0cm',
      'notes': 'Los ojos pueden moverse lentamente. Las piernas son más largas que los brazos.',
      'recommendations': ['Duerme de lado (preferiblemente izquierdo) con almohadas de apoyo.', 'Usa zapatos cómodos.', 'Anota cosas importantes si tienes olvidos.'],
      'image_month_id': 4
    },
    17: {
      'symptoms': ['Aumento de peso más constante', 'Vértigo ocasional', 'Aumento del flujo sanguíneo'],
      'bpd': '~3.8cm', 'weight': '~140g', 'length': '~13cm (como una granada)', 'femur': '~2.3cm',
      'notes': 'Se forma el tejido adiposo (grasa). El feto practica la respiración.',
      'recommendations': ['Evita cambios bruscos de posición.', 'Continúa con una dieta saludable para controlar el aumento de peso.'],
      'image_month_id': 4
    },
    18: {
      'symptoms': ['Movimientos fetales más perceptibles', 'Dificultad para encontrar una postura cómoda para dormir', 'Hambre frecuente'],
      'bpd': '~4.2cm', 'weight': '~190g', 'length': '~14.2cm (como un pimiento)', 'femur': '~2.6cm',
      'notes': 'Se pueden identificar los genitales en una ecografía. Las cuerdas vocales se forman.',
      'recommendations': ['Programa tu ecografía morfológica (generalmente entre las semanas 18-22).', 'Considera comprar una almohada de embarazo.'],
      'image_month_id': 5
    },
    19: {
      'symptoms': ['Dolor en el ligamento redondo', 'Calambres en las piernas', 'Posible aparición de la línea alba'],
      'bpd': '~4.5cm', 'weight': '~240g', 'length': '~15.3cm (como un mango grande)', 'femur': '~3.0cm',
      'notes': 'Se desarrolla la vérnix caseosa. Los sentidos se agudizan.',
      'recommendations': ['Para el dolor del ligamento redondo: muévete con cuidado, evita movimientos bruscos.', 'Para los calambres: estira los músculos, asegúrate de consumir suficiente calcio y magnesio.'],
      'image_month_id': 5
    },
    20: {
      'symptoms': ['Movimientos fetales claros y regulares', 'Ecografía morfológica', 'Acidez puede reaparecer'],
      'bpd': '~4.9cm', 'weight': '~300g', 'length': '~25.6cm (coronilla-talón, como un plátano pequeño)', 'femur': '~3.3cm',
      'notes': 'El feto traga líquido amniótico. Se desarrollan las papilas gustativas.',
      'recommendations': ['Disfruta viendo a tu bebé en la ecografía.', 'Si la acidez es un problema, evita comidas picantes, grasosas y no te acuestes inmediatamente después de comer.'],
      'image_month_id': 5
    },
    21: {
      'symptoms': ['Sensación de bienestar general', 'Aumento del apetito', 'Piel puede estar más grasa'],
      'bpd': '~5.2cm', 'weight': '~360g', 'length': '~26.7cm', 'femur': '~3.6cm',
      'notes': 'El feto es más activo. Las cejas y párpados están bien definidos.',
      'recommendations': ['Mantén una rutina de cuidado de la piel adecuada.', 'Sigue una dieta balanceada y rica en nutrientes.'],
      'image_month_id': 5
    },
    22: {
      'symptoms': ['Estrías pueden empezar a aparecer', 'Ombligo puede sobresalir', 'Pies y tobillos hinchados levemente'],
      'bpd': '~5.5cm', 'weight': '~430g', 'length': '~27.8cm', 'femur': '~3.9cm',
      'notes': 'El feto tiene aspecto de un recién nacido en miniatura. El lanugo cubre todo el cuerpo.',
      'recommendations': ['Hidrata tu piel para ayudar con las estrías (aunque son en gran parte genéticas).', 'Eleva los pies para reducir la hinchazón.', 'Usa ropa y calzado cómodos.'],
      'image_month_id': 5
    },
    23: {
      'symptoms': ['Mayor sensibilidad en las encías', 'Ronquidos al dormir', 'Contracciones de Braxton Hicks leves'],
      'bpd': '~5.8cm', 'weight': '~500g', 'length': '~28.9cm', 'femur': '~4.2cm',
      'notes': 'Los pulmones continúan madurando. El feto puede tener hipo.',
      'recommendations': ['Usa un cepillo de dientes suave y visita al dentista si es necesario.', 'Si tienes Braxton Hicks, cambia de posición o descansa; deben ser irregulares y no dolorosas.'],
      'image_month_id': 6
    },
    24: {
      'symptoms': ['Prueba de tolerancia a la glucosa (semana 24-28)', 'Piel del abdomen puede picar', 'Dificultad para dormir'],
      'bpd': '~6.0cm', 'weight': '~600g', 'length': '~30cm (como una mazorca de maíz)', 'femur': '~4.4cm',
      'notes': 'El feto es viable (con cuidados intensivos). Los alvéolos pulmonares se desarrollan.',
      'recommendations': ['Realiza la prueba de detección de diabetes gestacional.', 'Evita rascarte la piel; usa lociones calmantes.', 'Establece una rutina relajante antes de dormir.'],
      'image_month_id': 6
    },
    25: {
      'symptoms': ['Dolor de espalda más común', 'Posible estreñimiento', 'Aumento de la frecuencia urinaria'],
      'bpd': '~6.3cm', 'weight': '~660g', 'length': '~34.6cm', 'femur': '~4.7cm',
      'notes': 'El feto responde a la voz y al tacto. Establece ciclos de sueño y vigilia.',
      'recommendations': ['Practica una buena postura y considera ejercicios para fortalecer la espalda.', 'Sigue consumiendo fibra y líquidos para el estreñimiento.'],
      'image_month_id': 6
    },
    26: {
      'symptoms': ['Hinchazón en manos y pies más notoria', 'Calambres en las piernas por la noche', 'Fatiga puede regresar'],
      'bpd': '~6.6cm', 'weight': '~760g', 'length': '~35.6cm', 'femur': '~5.0cm',
      'notes': 'Los ojos se abren y cierran. Los pulmones producen surfactante.',
      'recommendations': ['Evita estar de pie o sentada por períodos prolongados.', 'Quítate los anillos si te aprietan.', 'Consulta a tu médico si la hinchazón es súbita o severa.'],
      'image_month_id': 6
    },
    27: {
      'symptoms': ['¡Comienzo del tercer trimestre!', 'Presión en la pelvis', 'Dificultad para respirar profundamente a veces'],
      'bpd': '~6.9cm', 'weight': '~875g', 'length': '~36.6cm', 'femur': '~5.2cm',
      'notes': 'El cerebro crece rapidamente. El feto practica movimientos respiratorios.',
      'recommendations': ['Infórmate sobre los signos de parto prematuro.', 'Empieza a planificar la logística para la llegada del bebé (maleta del hospital, etc.).'],
      'image_month_id': 6
    },
    28: {
      'symptoms': ['Visitas prenatales más frecuentes', 'Acidez frecuente', 'Insomnio leve o moderado'],
      'bpd': '~7.2cm', 'weight': '~1kg', 'length': '~37.6cm (como una berenjena grande)', 'femur': '~5.3cm',
      'notes': 'El feto puede distinguir la luz. Buenas posibilidades de supervivencia si nace prematuramente.',
      'recommendations': ['Duerme semisentada si la acidez es fuerte por la noche.', 'Mantén un horario de sueño regular en la medida de lo posible.', 'Pregunta sobre la vacuna Tdap (tos ferina).'],
      'image_month_id': 7
    },
    29: {
      'symptoms': ['Aumento de peso fetal considerable', 'Parestesias (hormigueo en manos)', 'Necesidad de orinar con frecuencia'],
      'bpd': '~7.5cm', 'weight': '~1.15kg', 'length': '~38.6cm', 'femur': '~5.5cm',
      'notes': 'Los huesos se endurecen (excepto el cráneo). La cabeza es proporcional al cuerpo.',
      'recommendations': ['Si tienes hormigueo en las manos, podría ser síndrome del túnel carpiano; habla con tu médico.', 'Sigue haciendo ejercicios de Kegel.'],
      'image_month_id': 7
    },
    30: {
      'symptoms': ['Fatiga y dificultad para moverse', 'Cambios de humor más pronunciados', 'Pechos pueden empezar a gotear calostro'],
      'bpd': '~7.8cm', 'weight': '~1.3kg', 'length': '~39.9cm', 'femur': '~5.7cm',
      'notes': 'El lanugo comienza a desaparecer. La médula ósea produce glóbulos rojos.',
      'recommendations': ['Pide ayuda con tareas pesadas.', 'Considera usar protectores de lactancia si tienes pérdidas de calostro.'],
      'image_month_id': 7
    },
    31: {
      'symptoms': ['Contracciones de Braxton Hicks más frecuentes', 'Dolor de espalda y pelvis', 'Dificultad para encontrar una postura cómoda'],
      'bpd': '~8.0cm', 'weight': '~1.5kg', 'length': '~41.1cm', 'femur': '~6.0cm',
      'notes': 'Todos los sentidos están funcionando. El feto acumula grasa.',
      'recommendations': ['Aprende a distinguir Braxton Hicks del trabajo de parto real.', 'Usa almohadas para encontrar una postura cómoda para dormir.'],
      'image_month_id': 7
    },
    32: {
      'symptoms': ['Dificultad para respirar (útero presiona diafragma)', 'Hinchazón de pies y manos', 'Preparación del "nido"'],
      'bpd': '~8.2cm', 'weight': '~1.7kg', 'length': '~42.4cm (como una col china)', 'femur': '~6.2cm',
      'notes': 'Las uñas de los pies llegan a la punta de los dedos. El feto suele colocarse cabeza abajo.',
      'recommendations': ['Come porciones más pequeñas y frecuentes para ayudar con la respiración y la acidez.', 'Empieza a finalizar los preparativos para el bebé.'],
      'image_month_id': 8
    },
    33: {
      'symptoms': ['Menor espacio para el bebé, movimientos pueden sentirse diferentes', 'Presión en la vejiga', 'Cansancio'],
      'bpd': '~8.4cm', 'weight': '~1.9kg', 'length': '~43.7cm', 'femur': '~6.4cm',
      'notes': 'El sistema inmunológico se fortalece. La piel se vuelve más lisa y rosada.',
      'recommendations': ['Sigue contando los movimientos fetales diariamente.', 'Descansa siempre que puedas.'],
      'image_month_id': 8
    },
    34: {
      'symptoms': ['Fatiga extrema', 'Posible descenso del bebé (encajamiento)', 'Aumento de la presión pélvica'],
      'bpd': '~8.6cm', 'weight': '~2.1kg', 'length': '~45cm', 'femur': '~6.6cm',
      'notes': 'Los pulmones están casi maduros. La vérnix caseosa es más gruesa.',
      'recommendations': ['Si el bebé desciende, podrías respirar más fácil pero tener más presión pélvica.', 'Ten lista tu maleta para el hospital.'],
      'image_month_id': 8
    },
    35: {
      'symptoms': ['Visitas semanales al médico', 'Mayor frecuencia de micción', 'Dificultad para dormir'],
      'bpd': '~8.8cm', 'weight': '~2.4kg', 'length': '~46.2cm', 'femur': '~6.8cm',
      'notes': 'El feto gana peso rápidamente. El desarrollo cerebral es intenso.',
      'recommendations': ['Asiste a todas tus citas prenatales.', 'Repasa tu plan de parto si tienes uno.', 'Asegúrate de tener todo listo para el bebé.'],
      'image_month_id': 8
    },
    36: {
      'symptoms': ['El bebé desciende ("encajamiento"), facilitando la respiración', 'Aumento de flujo vaginal', 'Contracciones más notorias'],
      'bpd': '~9.0cm', 'weight': '~2.6kg', 'length': '~47.4cm (como una papaya pequeña)', 'femur': '~7.0cm',
      'notes': 'El feto se considera a término a partir de la semana 37. Práctica de succión y deglución.',
      'recommendations': ['Reconoce los signos del trabajo de parto: contracciones regulares y progresivas, rotura de aguas, expulsión del tapón mucoso.', 'Descansa y conserva energía.'],
      'image_month_id': 9
    },
    37: {
      'symptoms': ['Ansiedad y emoción por el parto', 'Posible expulsión del tapón mucoso', 'Sensación de "estar lista"'],
      'bpd': '~9.1cm', 'weight': '~2.9kg', 'length': '~48.6cm', 'femur': '~7.2cm',
      'notes': 'El feto está listo para nacer. El lanugo ha desaparecido casi por completo.',
      'recommendations': ['Confirma con tu médico cuándo debes ir al hospital.', 'Intenta relajarte y mantener la calma.'],
      'image_month_id': 9
    },
    38: {
      'symptoms': ['Presión pélvica intensa', 'Mayor torpeza', 'Falsas alarmas de parto'],
      'bpd': '~9.2cm', 'weight': '~3.1kg', 'length': '~49.8cm', 'femur': '~7.4cm',
      'notes': 'El feto sigue acumulando grasa. Los órganos están completamente maduros.',
      'recommendations': ['Sigue descansando y manteniéndote hidratada.', 'Ten a mano los números de contacto importantes.'],
      'image_month_id': 9
    },
    39: {
      'symptoms': ['Impaciencia', 'Síntomas premonitorios de parto', 'Hinchazón puede ser significativa'],
      'bpd': '~9.3cm', 'weight': '~3.3kg', 'length': '~50.7cm', 'femur': '~7.5cm',
      'notes': 'El feto está completamente desarrollado y esperando el momento de nacer.',
      'recommendations': ['Intenta mantenerte ocupada para manejar la ansiedad.', 'Camina si te sientes cómoda, puede ayudar a inducir el parto.'],
      'image_month_id': 9
    },
    40: {
      'symptoms': ['¡Fecha probable de parto!', 'Ansiedad/Excitación máxima', 'Contracciones más regulares y fuertes si el parto comienza'],
      'bpd': '~9.5cm', 'weight': '~3.4kg-3.5kg', 'length': '~51.2cm (como una sandía pequeña)', 'femur': '~7.6cm',
      'notes': 'Solo un pequeño porcentaje de bebés nace en su FPP. El parto puede ocurrir entre la semana 38 y 42.',
      'recommendations': ['Mantén la calma, tu bebé llegará pronto.', 'Contacta a tu médico si tienes dudas o si el parto comienza.', 'Si pasas tu FPP, tu médico discutirá los próximos pasos.'],
      'image_month_id': 9
    },
     41: {
      'symptoms': ['Posible inducción del parto', 'Monitoreo fetal más frecuente', 'Ansiedad por la espera'],
      'bpd': '~9.6cm', 'weight': '~3.5kg+', 'length': '~51.5cm+', 'femur': '~7.7cm+',
      'notes': 'Muchos bebés sanos nacen esta semana. Tu médico te guiará.',
      'recommendations': ['Habla con tu médico sobre las opciones si el parto no ha comenzado.', 'Mantén la calma y confía en el proceso y en tu equipo médico.'],
      'image_month_id': 9
    },
    42: { // Aunque notificamos hasta la semana 41, la información de la 42 puede ser útil si se llega.
      'symptoms': ['Inducción del parto es muy probable', 'Mayor monitoreo'],
      'bpd': '~9.7cm', 'weight': '~3.6kg+', 'length': '~52cm+', 'femur': '~7.8cm+',
      'notes': 'Es importante el monitoreo cercano para asegurar el bienestar del bebé.',
      'recommendations': ['Sigue las indicaciones de tu médico para la inducción o monitoreo.', 'Prepárate para conocer a tu bebé muy pronto.'],
      'image_month_id': 9
    },
  };

  final DateFormat _dateFormatter = DateFormat.yMMMMd('es_ES');
  final Duration _gestationDurationFromLMP = const Duration(days: 280); // 40 semanas

  Future<void> _handleNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final bool remindersEnabled = prefs.getBool(_remindersEnabledKey) ?? true;

    if (!remindersEnabled) {
      await _notificationService.cancelAllNotifications();
      return;
    }

    if (_selectedLMPDate != null && _gestationalWeeks != null && _gestationalWeeks! >= 0) { // Solo si FUR es válida y no futura
      int weekToNotifyFor = _gestationalWeeks!;
      DateTime startOfCurrentWeek = _selectedLMPDate!.add(Duration(days: _gestationalWeeks! * 7));
      DateTime notificationTimeForThisWeek = DateTime(startOfCurrentWeek.year, startOfCurrentWeek.month, startOfCurrentWeek.day, 9, 0);

      if (DateTime.now().isAfter(notificationTimeForThisWeek)) {
        if (kDebugMode) print("homescreen: Hora de notificación para semana actual ($_gestationalWeeks) ya pasó. Programando para semana ${_gestationalWeeks! + 1}.");
        weekToNotifyFor = _gestationalWeeks! + 1;
      }

      // No programar notificaciones para la semana 42 o más allá, ya que la información es hasta la semana 41/42.
      if (weekToNotifyFor < 42) {
        await _notificationService.scheduleWeeklyPregnancyNotification(
          lmpDate: _selectedLMPDate!,
          gestationalWeek: weekToNotifyFor,
        );
      } else {
        await _notificationService.cancelAllNotifications();
        if (kDebugMode) print("homescreen: Semana $weekToNotifyFor es >= 42, cancelando/no programando notificaciones.");
      }
    } else {
      await _notificationService.cancelAllNotifications(); // Cancelar si no hay FUR válida o es futura
      if (kDebugMode) print("homescreen: Sin FUR válida o FUR es futura, cancelando notificaciones.");
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

      // Si la FUR es en el futuro, differenceInDays será negativo.
      if (differenceInDays >= 0) {
        final weeks = differenceInDays ~/ 7;
        final days = differenceInDays % 7;
        setState(() {
          _gestationalWeeks = weeks;
          _gestationalDays = days;
          _estimatedDueDate = dueDate;
          _zodiacSign = zodiac;
        });
      } else { // FUR es en el futuro
         setState(() {
           _estimatedDueDate = dueDate;
           _zodiacSign = zodiac;
           _gestationalWeeks = -1; // Indicador especial para FUR futura
           _gestationalDays = differenceInDays; // Guardar días negativos para posible referencia
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
      // CORRECCIÓN: Permitir cualquier fecha pasada o futura
      firstDate: DateTime(1900), // Un año razonablemente lejano en el pasado
      lastDate: DateTime(2200),   // Un año razonablemente lejano en el futuro
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
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    if (weeks == null || days == null) return themeNotifier.transformText('N/A');
    
    // CORRECCIÓN: Manejo de FUR futura
    if (weeks < 0) {
        // Calcula cuántos días faltan para la FUR
        int daysUntilLMP = days!.abs(); // `days` será negativo
        String dayText = daysUntilLMP == 1 ? themeNotifier.transformText('día') : themeNotifier.transformText('días');
        return themeNotifier.transformText('Faltan $daysUntilLMP $dayText para la FUR');
    }

    final String weekText = weeks == 1 ? themeNotifier.transformText('semana') : themeNotifier.transformText('semanas');
    final String dayText = days == 1 ? themeNotifier.transformText('día') : themeNotifier.transformText('días');

    if (weeks == 0 && days == 0) return themeNotifier.transformText('Comienzo de la gestación (FUR hoy)');
    if (weeks > 0 && days > 0) return '$weeks $weekText + $days $dayText';
    if (weeks > 0 && days == 0) return '$weeks $weekText';
    if (weeks == 0 && days > 0) return '$days $dayText'; // Ej. FUR hace 3 días -> "3 días"

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
    if (_estimatedDueDate == null) return const SizedBox.shrink(); // Si no hay FUR, no mostrar FEP
    
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
              themeNotifier.transformText(_zodiacSign ?? 'N/A'), // El zodíaco se calcula a partir de la FEP
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            // Mostrar edad gestacional solo si _gestationalWeeks es no nulo
            if (_gestationalWeeks != null && _gestationalDays != null) ...[
              const Divider(height: 32.0, thickness: 0.5),
              Text(
                themeNotifier.transformText('Edad Gestacional'), // Título más genérico
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4.0),
              Text(
                // La función _formatGestationalAgeString ya maneja el caso de FUR futura
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
    
    if (_selectedLMPDate == null) return const SizedBox.shrink();

    if (weekNumber != null && weekNumber < 0) {
        return Card(
            elevation: Theme.of(context).cardTheme.elevation,
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                    themeNotifier.transformText("La información semanal detallada estará disponible una vez que la fecha de última regla (FUR) haya pasado y comience la gestación."),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium
                )
            )
        );
    }
    
    if (weekData == null || weekNumber == null) {
      if (_gestationalWeeks != null && _gestationalWeeks! > 41 && _estimatedDueDate != null && DateTime.now().isAfter(_estimatedDueDate!)) {
          return Card(
              elevation: Theme.of(context).cardTheme.elevation,
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                      themeNotifier.transformText("Has superado la semana 41. Consulta con tu profesional de salud para seguimiento."),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium
                  )
              )
          );
      }
      return const SizedBox.shrink();
    }
    
    if (_estimatedDueDate != null && DateTime.now().isAfter(_estimatedDueDate!.add(const Duration(days: 2 * 7 + 1)))) { // Un día después de la semana 42
        return Card(
            elevation: Theme.of(context).cardTheme.elevation,
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                    themeNotifier.transformText("La fecha probable de parto ya ha pasado considerablemente. Para un nuevo cálculo, selecciona 'Calcular Nuevo Embarazo'."),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium
                )
            )
        );
    }

    final symptoms = (weekData['symptoms'] as List<dynamic>? ?? []).map((s) => themeNotifier.transformText(s.toString())).toList();
    final notes = weekData['notes'] != null ? themeNotifier.transformText(weekData['notes'] as String) : null;
    final recommendations = (weekData['recommendations'] as List<dynamic>? ?? []).map((r) => themeNotifier.transformText(r.toString())).toList();
    final imageMonthId = weekData['image_month_id'] as int?;
    final String? imageName = imageMonthId != null ? 'assets/fetal_development/month_$imageMonthId.png' : null;

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
      // CORRECCIÓN: No mostrar si el valor es nulo, vacío o "N/A" (case-insensitive)
      if (value != null && value.isNotEmpty && value.toLowerCase() != 'n/a') {
        fetalMetricsWidgets.add(_buildMetricRow(
            context,
            metricIcons[key]!,
            themeNotifier.transformText(label),
            themeNotifier.transformText(value) // El valor ya no debería ser N/A aquí
        ));
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
                  notes,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
             ],
             if (imageName != null) ...[
                const SizedBox(height: 16.0),
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 200,
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    child: Image.asset(
                      imageName,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        if (kDebugMode) {
                          print("DEBUG: Error cargando imagen '$imageName': $error");
                        }
                        return Container(
                          height: 100,
                          width: MediaQuery.of(context).size.width * 0.8,
                          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image_outlined, size: 40, color: Theme.of(context).colorScheme.onSurfaceVariant),
                              const SizedBox(height: 4),
                              Text(
                                themeNotifier.transformText('Imagen referencial no disponible'),
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                textAlign: TextAlign.center,
                              ),
                              if (kDebugMode) 
                                Text(
                                  imageName.split('/').last, 
                                  style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7)), 
                                  textAlign: TextAlign.center,
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
             ],
             // CORRECCIÓN: Solo mostrar la sección de Métricas si hay al menos una métrica con valor.
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
                  children: symptoms.map((symptom) => Chip(label: Text(symptom))).toList(),
                ),
             ],
             if (recommendations.isNotEmpty)...[
                const Divider(height: 24.0, thickness: 0.5),
                Text(themeNotifier.transformText('Recomendaciones:'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8.0),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recommendations.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_outline, size: 18, color: Theme.of(context).colorScheme.tertiary),
                          const SizedBox(width: 8),
                          Expanded(child: Text(recommendations[index], style: Theme.of(context).textTheme.bodyMedium)),
                        ],
                      ),
                    );
                  },
                )
             ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value, // Ya viene transformado y sin "N/A"
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditsWidget(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
      child: Text(
        themeNotifier.transformText('Gestib App v0.9.0\nDesarrollado con fines informativos.\nConsulta siempre a tu profesional de salud.'),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    Map<String, dynamic>? currentWeekData;

    if (_gestationalWeeks != null && _gestationalWeeks! >= 0 && _weeklyData.containsKey(_gestationalWeeks!)) {
      currentWeekData = _weeklyData[_gestationalWeeks!];
    }

    return Scaffold(
      appBar: AppBar(
         title: Text(themeNotifier.transformText('gestib'), style: Theme.of(context).appBarTheme.titleTextStyle),
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
                        if (_selectedLMPDate != null) ...[
                          const SizedBox(height: 16.0),
                          Center(
                            child: TextButton(
                              onPressed: _resetCalculations,
                              child: Text(themeNotifier.transformText('Calcular Nuevo Embarazo')),
                            ),
                          ),
                        ],
                        _buildCreditsWidget(context),
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
