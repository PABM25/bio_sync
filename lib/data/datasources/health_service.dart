import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthService {
  // Instancia de Health
  final Health _health = Health();

  // Tipos de datos que queremos leer
  final _types = [HealthDataType.STEPS, HealthDataType.ACTIVE_ENERGY_BURNED];

  // Solicitar permisos
  Future<bool> requestPermissions() async {
    // Permiso de actividad física (Android 10+)
    await Permission.activityRecognition.request();

    // Configurar Health Connect para Android
    await _health.configure();

    // Solicitar acceso a los tipos de datos
    bool requested = await _health.requestAuthorization(_types);
    return requested;
  }

  // Obtener Pasos de HOY
  Future<int> getTodaySteps() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      // Pedir permisos si no se tienen
      bool authorized = await requestPermissions();

      if (authorized) {
        int? steps = await _health.getTotalStepsInInterval(midnight, now);
        return steps ?? 0;
      }
      return 0;
    } catch (e) {
      print("Error obteniendo pasos: $e");
      return 0;
    }
  }

  // Obtener Calorías Activas de HOY
  Future<double> getTodayCalories() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      bool authorized = await requestPermissions();

      if (authorized) {
        // Health package devuelve una lista de puntos de datos
        List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
          startTime: midnight,
          endTime: now,
          types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        );

        // Sumar todas las calorías
        double totalCalories = 0;
        for (var point in healthData) {
          if (point.value is NumericHealthValue) {
            totalCalories += (point.value as NumericHealthValue).numericValue;
          }
        }
        return totalCalories;
      }
      return 0.0;
    } catch (e) {
      print("Error obteniendo calorías: $e");
      return 0.0;
    }
  }
}
