import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../services/location_service.dart';

/// ViewModel que gestiona la lógica del velocímetro,
/// incluyendo la velocidad, distancia, tiempo y permisos de GPS.
class SpeedometerViewModel extends ChangeNotifier {
  double _currentSpeed = 0.0; // Velocidad actual en km/h
  double _totalDistance = 0.0; // Distancia total recorrida en km
  Stopwatch _stopwatch = Stopwatch(); // Cronómetro para medir el tiempo transcurrido
  Position? _lastPosition; // Última posición conocida para calcular distancia
  StreamSubscription<Position>? _positionStream; // Suscripción al stream de posición

  // Formateador para mostrar los números con 2 decimales, usando formato español
  final NumberFormat _formatter = NumberFormat("##0.00", "es");

  // Getters para acceder a los valores desde la UI
  double get currentSpeed => _currentSpeed;
  double get totalDistance => _totalDistance;
  String get formattedSpeed => "${_formatter.format(_currentSpeed)} km/h";
  String get formattedDistance => "${_formatter.format(_totalDistance)} km";
  String get elapsedTime => _formatDuration(_stopwatch.elapsed);
  bool get isTracking => _stopwatch.isRunning;

  /// Inicia el rastreo de ubicación y comienza a calcular velocidad y distancia.
  Future<void> startTracking() async {
    // Evita que la pantalla se apague mientras se rastrea.
    WakelockPlus.enable();

    // Verifica y solicita permisos de ubicación.
    bool hasPermission = await LocationService.checkAndRequestPermission();
    if (!hasPermission) return;

    // Inicia el cronómetro para medir el tiempo transcurrido.
    _stopwatch.start();

    // Escucha las actualizaciones de posición.
    _positionStream = LocationService.getPositionStream().listen((position) {
      if (_lastPosition != null) {
        // Calcula la distancia entre la posición anterior y la nueva.
        double distance = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        _totalDistance += distance / 1000; // Convierte metros a kilómetros.
      }

      // Calcula la velocidad en km/h (el valor original está en m/s).
      _currentSpeed = position.speed * 3.6;

      // Guarda la posición actual como la última.
      _lastPosition = position;

      // Notifica a los widgets escuchando que deben reconstruirse.
      notifyListeners();
    });
  }

  /// Reinicia todos los valores a cero.
  void reset() {
    _currentSpeed = 0.0;
    _totalDistance = 0.0;
    _lastPosition = null;
    _stopwatch.reset();
    notifyListeners();
  }

  /// Cancela el rastreo de posición y desactiva el wakelock.
  void disposeModel() {
    _positionStream?.cancel();
    WakelockPlus.disable();
  }

  /// Formatea la duración en formato HH:MM:SS.
  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }

  void stopTracking() {
    _positionStream?.cancel();
    _stopwatch.stop();
    notifyListeners();
  }

}
