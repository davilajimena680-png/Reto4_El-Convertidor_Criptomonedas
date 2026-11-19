import '../entities/crypto_price.dart';

abstract class CryptoRepository {
  /// Lanza un `Failure` si algo sale mal.
  Future<List<CryptoPrice>> getPrices();
}
