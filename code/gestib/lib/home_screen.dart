import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  // Datos de ejemplo - ¡REEMPLAZAR CON DATOS MÉDICOS REALES!
  final Map<int, Map<String, dynamic>> _weeklyData = {
    // (Datos omitidos por brevedad, usar los de la versión anterior)
    4: {'symptoms': ['Retraso menstrual', 'Pechos sensibles'], 'bpd': 'N/A', 'weight': '<1g', 'length': '<1mm', 'femur': 'N/A'},
    5: {'symptoms': ['Fatiga', 'Náuseas leves', 'Micción frecuente'], 'bpd': 'N/A', 'weight': '1g', 'length': '1-5mm', 'femur': 'N/A'},
    6: {'symptoms': ['Náuseas matutinas', 'Cambios de humor', 'Aversión a olores'], 'bpd': 'N/A', 'weight': '1-2g', 'length': '4-6mm', 'femur': 'N/A'},
    7: {'symptoms': ['Antojos/Aversiones', 'Aumento sensibilidad olfato'], 'bpd': '~4mm', 'weight': '2g', 'length': '1cm', 'femur': '~1mm'},
    8: {'symptoms': ['Fatiga intensa', 'Mareos leves'], 'bpd': '~6mm', 'weight': '3g', 'length': '1.6cm', 'femur': '~1.5mm'},
    9: {'symptoms': ['Acidez estomacal leve', 'Estreñimiento'], 'bpd': '~9mm', 'weight': '4g', 'length': '2.3cm', 'femur': '~2mm'},
    10: {'symptoms': ['Menos náuseas (en algunos casos)', 'Venas visibles'], 'bpd': '~1.4cm', 'weight': '5g', 'length': '3.1cm', 'femur': '~3mm'},
    11: {'symptoms': ['Aumento de energía (posible)', 'Ligero aumento de peso'], 'bpd': '~1.8cm', 'weight': '7g', 'length': '4.1cm', 'femur': '~4mm'},
    12: {'symptoms': ['Riesgo de aborto disminuye', 'Puede empezar a notarse la barriga'], 'bpd': '~2.1cm', 'weight': '14g', 'length': '5.4cm', 'femur': '~8mm'},
    13: {'symptoms': ['Comienzo del 2º trimestre', 'Menos molestias'], 'bpd': '~2.5cm', 'weight': '23g', 'length': '7.4cm', 'femur': '~1.1cm'},
    14: {'symptoms': ['Aumento del apetito', 'Posible congestión nasal'], 'bpd': '~2.8cm', 'weight': '43g', 'length': '8.7cm', 'femur': '~1.4cm'},
    15: {'symptoms': ['Puede sentir los primeros movimientos (segundigestas)'], 'bpd': '~3.2cm', 'weight': '70g', 'length': '10.1cm', 'femur': '~1.7cm'},
    16: {'symptoms': ['Crecimiento notable del abdomen', 'Piel radiante (algunas)'], 'bpd': '~3.5cm', 'weight': '100g', 'length': '11.6cm', 'femur': '~2.0cm'},
    20: {'symptoms': ['Movimientos fetales claros', 'Dolor de espalda leve'], 'bpd': '~4.9cm', 'weight': '300g', 'length': '25.6cm (coronilla-talón)', 'femur': '~3.3cm'},
    24: {'symptoms': ['Posibles estrías', 'Práctica de respiración (contracciones Braxton Hicks leves)'], 'bpd': '~6.0cm', 'weight': '600g', 'length': '30cm', 'femur': '~4.4cm'},
    28: {'symptoms': ['Acidez frecuente', 'Insomnio leve'], 'bpd': '~7.2cm', 'weight': '1kg', 'length': '37.6cm', 'femur': '~5.3cm'},
    32: {'symptoms': ['Dificultad para respirar a veces', 'Hinchazón pies/manos'], 'bpd': '~8.2cm', 'weight': '1.7kg', 'length': '42.4cm', 'femur': '~6.2cm'},
    36: {'symptoms': ['Descenso del bebé (encajamiento)', 'Aumento presión pélvica'], 'bpd': '~9.0cm', 'weight': '2.6kg', 'length': '47.4cm', 'femur': '~7.0cm'},
    40: {'symptoms': ['Listo para el parto', 'Ansiedad/Excitación', 'Contracciones más regulares'], 'bpd': '~9.5cm', 'weight': '~3.4kg', 'length': '~51.2cm', 'femur': '~7.6cm'},
  };

  final DateFormat _dateFormatter = DateFormat.yMMMMd('es_ES');
  final Duration _gestationDurationFromLMP = const Duration(days: 280);

  // --- Lógica de Cálculo (sin cambios) ---
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
    } else {
      _resetCalculations();
    }
  }

  void _resetCalculations() {
     setState(() {
        _estimatedDueDate = null;
        _zodiacSign = null;
        _gestationalWeeks = null;
        _gestationalDays = null;
      });
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
    return 'Capricornio ♑';
  }

  // --- Selección de Fecha (sin cambios en lógica) ---
  Future<void> _selectLMPDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedLMPDate ?? DateTime.now(),
      firstDate: DateTime(1),
      lastDate: DateTime(3000),
      locale: const Locale('es', 'ES'),
      helpText: 'Fecha de última regla (FUR)',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (picked != null && picked != _selectedLMPDate) {
      setState(() {
        _selectedLMPDate = picked;
      });
      _calculateDates();
    }
  }

  // --- Helper de Formato Edad Gestacional ---
  String _formatGestationalAgeString(int? weeks, int? days) {
    if (weeks == null || days == null) return 'N/A';
    final String weekText = weeks == 1 ? 'semana' : 'semanas';
    final String dayText = days == 1 ? 'día' : 'días';
    return '$weeks $weekText + $days $dayText';
  }

  // --- Helpers de UI Refinados ---

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.calendar_month_outlined,
          size: 80,
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
        ),
        const SizedBox(height: 24),
        Text(
          'Selecciona la fecha de tu última regla (FUR)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Calcularemos tu fecha probable de parto y te mostraremos información semanal.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 32),
        Center(
          child: FilledButton.icon(
            icon: const Icon(Icons.edit_calendar),
            label: const Text('Seleccionar fecha FUR'),
            onPressed: () => _selectLMPDate(context),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelectionCard(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
             Text(
              'Fecha de última regla (FUR)',
               style: Theme.of(context).textTheme.titleMedium?.copyWith(
                 color: Theme.of(context).colorScheme.primary
               ),
            ),
            const SizedBox(height: 12.0),
            Text(
              _dateFormatter.format(_selectedLMPDate!),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12.0),
            TextButton.icon(
              icon: const Icon(Icons.edit_calendar, size: 18),
              label: const Text('Cambiar fecha'),
              style: TextButton.styleFrom(
                 textStyle: Theme.of(context).textTheme.labelMedium,
                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
              ),
              onPressed: () => _selectLMPDate(context),
            ),
          ],
        ),
      ),
    );
  }

 // --- Widget "Hero" ---
 Widget _buildSummaryCard(BuildContext context) {
  if (_estimatedDueDate == null) return const SizedBox.shrink();

  return Card(
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        children: [
          Text(
            'Fecha estimada de parto (FEP)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          Text(
            _dateFormatter.format(_estimatedDueDate!),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith( // Bajado de displaySmall a headlineMedium
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            _zodiacSign ?? 'N/A',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
               color: Theme.of(context).colorScheme.onSurfaceVariant
            ),
            textAlign: TextAlign.center,
          ),

          if (_gestationalWeeks != null && _gestationalDays != null) ...[
            const Divider(height: 32.0, thickness: 0.5),
            Text(
              'Edad gestacional actual',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4.0),
            Text(
              _formatGestationalAgeString(_gestationalWeeks, _gestationalDays),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith( // Bajado de headlineMedium a headlineSmall
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
    if (weekData == null || weekNumber == null) return const SizedBox.shrink();
    final symptoms = weekData['symptoms'] as List<dynamic>? ?? [];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
               'Información de la semana $weekNumber',
               style: Theme.of(context).textTheme.titleLarge?.copyWith(
                 color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold
               ),
             ),
             const SizedBox(height: 16.0),
             Text(
              'Desarrollo fetal estimado:',
              style: Theme.of(context).textTheme.titleMedium,
             ),
             const SizedBox(height: 12.0),
             _buildMetricRow(context, Icons.straighten, 'Talla:', weekData['length']?.toString() ?? 'N/A'),
             _buildMetricRow(context, Icons.monitor_weight_outlined, 'Peso:', weekData['weight']?.toString() ?? 'N/A'),
             _buildMetricRow(context, Icons.aspect_ratio, 'DBP:', weekData['bpd']?.toString() ?? 'N/A'),
             _buildMetricRow(context, Icons.square_foot_outlined, 'Fémur:', weekData['femur']?.toString() ?? 'N/A'),
             if (symptoms.isNotEmpty)...[
                const Divider(height: 24.0, thickness: 0.5),
                Text(
                  'Síntomas comunes maternos:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8.0),
                Wrap(
                  spacing: 8.0, runSpacing: 4.0,
                  children: symptoms.map((symptom) => Chip(
                    label: Text(symptom.toString()),
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    labelStyle: Theme.of(context).textTheme.bodySmall,
                    visualDensity: VisualDensity.compact,
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.4),
                    side: BorderSide.none,
                  )).toList(),
                ),
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
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // --- Método Build Principal ---
  @override
  Widget build(BuildContext context) {
    final currentWeekData = (_gestationalWeeks != null && _weeklyData.containsKey(_gestationalWeeks!))
        ? _weeklyData[_gestationalWeeks!]
        : null;
    return Scaffold(
      appBar: AppBar(
         title: Text(
              'gestib',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.8)
              )
         ),
         centerTitle: true,
         backgroundColor: Colors.transparent,
         elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _selectedLMPDate == null
                ? Align(
                   alignment: Alignment.center,
                   key: const ValueKey('EmptyState'),
                   child: _buildEmptyState(context),
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
