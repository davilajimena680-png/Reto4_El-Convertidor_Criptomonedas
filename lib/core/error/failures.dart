/// Errores que entiende el resto de la app (dominio y presentación).
abstract class Failure implements Exception {
  const Failure(this.message);

  final String message;

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure()
      : super('Sin conexión. Revisa tu internet e inténtalo de nuevo.');
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'El servidor no respondió bien.']);
}

class RateLimitFailure extends Failure {
  const RateLimitFailure()
      : super('Demasiadas consultas a CoinGecko. Espera un minuto e inténtalo de nuevo.');
}
