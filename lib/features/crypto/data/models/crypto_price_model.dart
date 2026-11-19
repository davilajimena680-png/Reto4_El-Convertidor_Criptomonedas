import '../../../../core/error/exceptions.dart';
import '../../domain/entities/crypto.dart';
import '../../domain/entities/crypto_price.dart';

class CryptoPriceModel extends CryptoPrice {
  const CryptoPriceModel({required super.crypto, required super.usd});

  /// Respuesta de CoinGecko: `{"bitcoin": {"usd": 67000}, ...}`
  static List<CryptoPriceModel> listFromJson(Map<String, dynamic> json) {
    return [
      for (final crypto in Crypto.values)
        CryptoPriceModel(crypto: crypto, usd: _usdOf(json, crypto)),
    ];
  }

  static double _usdOf(Map<String, dynamic> json, Crypto crypto) {
    final entry = json[crypto.id];
    final usd = entry is Map<String, dynamic> ? entry['usd'] : null;
    if (usd is! num) {
      // La API respondió 200 pero sin el precio esperado.
      throw const ServerException();
    }
    return usd.toDouble();
  }
}
