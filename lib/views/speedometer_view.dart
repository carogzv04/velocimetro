import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/speedometer_viewmodel.dart';
import '../services/location_service.dart';

/// Vista principal del velocímetro.
/// Muestra velocidad actual, distancia, tiempo y permite iniciar/reiniciar el rastreo GPS.
class SpeedometerView extends StatelessWidget {
  const SpeedometerView({super.key});

  static const Color backgroundColor = Color(0xFFCECFCF);

  @override
  Widget build(BuildContext context) {
    // Obtiene el ViewModel que gestiona el estado del velocímetro
    final viewModel = Provider.of<SpeedometerViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        actions: [
          // Indicador de estado del GPS con accesibilidad
          Semantics(
            label: viewModel.currentSpeed > 0
                ? "GPS activo"
                : "GPS inactivo",
            child: Icon(
              viewModel.currentSpeed > 0
                  ? Icons.gps_fixed
                  : Icons.gps_off,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Container(
        color: backgroundColor,
        padding: const EdgeInsets.all(24.1),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Velocidad actual",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),

              // Valor animado de la velocidad con etiqueta para lectores de pantalla
              Semantics(
                label: "Velocidad actual: ${viewModel.formattedSpeed}",
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    viewModel.formattedSpeed,
                    key: ValueKey(viewModel.formattedSpeed),
                    style: const TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 70),

              // Métricas adicionales: distancia y tiempo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _MetricTile(
                    icon: Icons.route,
                    label: "Distancia",
                    value: viewModel.formattedDistance,
                    semanticsLabel:
                    "Distancia recorrida: ${viewModel.formattedDistance}",
                  ),
                  _MetricTile(
                    icon: Icons.timer,
                    label: "Tiempo",
                    value: viewModel.elapsedTime,
                    semanticsLabel:
                    "Tiempo de desplazamiento: ${viewModel.elapsedTime}",
                  ),
                ],
              ),

              const SizedBox(height: 60),

              // Botón para iniciar el rastreo GPS con soporte accesible
              if (!viewModel.isTracking) // Condición para mostrar "Iniciar rastreamiento"
                Semantics(
                  button: true,
                  label: "Iniciar rastreamiento por GPS",
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      bool gpsEnabled = await LocationService.checkAndRequestPermission();
                      if (!gpsEnabled) {
                        // Muestra alerta si el GPS está desactivado
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("GPS desactivado"),
                            content: const Text(
                                "Por favor, active el GPS para usar el velocímetro."
                            ),
                            actions: [
                              TextButton(
                                child: const Text("OK"),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        );
                        return;
                      }
                      await viewModel.startTracking();
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Iniciar rastreamiento"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Botón para detener el rastreo GPS, solo visible si `isTracking` es `true`
              if (viewModel.isTracking) // Condición para mostrar "Detener rastreamiento"
                Semantics(
                  button: true,
                  label: "Detener rastreamiento",
                  child: ElevatedButton.icon(
                    onPressed: () => viewModel.stopTracking(),
                    icon: const Icon(Icons.stop),
                    label: const Text("Detener rastreamiento"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ),
                ),
              const SizedBox(height: 16),


              // Botón para reiniciar los datos, también accesible
              Semantics(
                button: true,
                label: "Reiniciar datos",
                child: ElevatedButton.icon(
                  onPressed: () => viewModel.reset(),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Reiniciar datos"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
      ),
    );
  }
}

/// Widget reutilizable para mostrar una métrica (como distancia o tiempo).
/// Incluye soporte para Semantics para mejorar accesibilidad.
class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? semanticsLabel;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel ?? "$label: $value",
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.4,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 36, color: Colors.blueAccent),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
