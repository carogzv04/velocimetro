import 'package:geolocator/geolocator.dart';

/// Servicio de ubicación personalizado que encapsula
/// la verificación de permisos y el rastreo de posición.
class LocationService {

  /// Verifica si los servicios de ubicación están habilitados
  /// y solicita permisos si es necesario.

  /// Retorna `true` si el permiso es concedido, `false` en caso contrario.
  static Future<bool> checkAndRequestPermission() async {
    // Verifica si el GPS/dispositivo tiene servicios de ubicación activos.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    // Verifica el estado actual del permiso de ubicación.
    LocationPermission permission = await Geolocator.checkPermission();

    // Si está denegado, intenta solicitar permiso al usuario.
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Retorna true solo si el permiso es "mientras se usa la app" o "siempre".
    return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
  }

  /// La posición solo se actualizará si el usuario se mueve al menos 1 metro.
  static Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best, // Máxima precisión (consume más batería).
        distanceFilter: 1, // Se actualiza si se ha movido al menos 1 metro.
      ),
    );
  }
}
