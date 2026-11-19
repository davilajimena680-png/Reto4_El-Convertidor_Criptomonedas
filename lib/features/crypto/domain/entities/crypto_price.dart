import 'crypto.dart';

class CryptoPrice {
  const CryptoPrice({required this.crypto, required this.usd});

  final Crypto crypto;

  /// Precio de 1 unidad en dólares.
  final double usd;
}
