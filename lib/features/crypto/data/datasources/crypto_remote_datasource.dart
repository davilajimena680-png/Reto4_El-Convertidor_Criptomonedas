import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/crypto.dart';
import '../models/crypto_price_model.dart';

class CryptoRemoteDataSource {
  CryptoRemoteDataSource(this._client);

  final http.Client _client;

  /// https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,solana&vs_currencies=usd
  Uri buildUri() {
    return Uri.https(ApiConstants.host, ApiConstants.simplePricePath, {
      'ids': Crypto.values.map((c) => c.id).join(','),
      'vs_currencies': 'usd',
    });
  }

  Future<List<CryptoPriceModel>> fetchPrices() async {
    final response =
        await _client.get(buildUri()).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw ServerException(response.statusCode);
    }

    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return CryptoPriceModel.listFromJson(body);
  }
}
