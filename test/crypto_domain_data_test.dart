import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:reto4_convertidor_cripto/core/error/exceptions.dart';
import 'package:reto4_convertidor_cripto/core/error/failures.dart';
import 'package:reto4_convertidor_cripto/core/utils/formatters.dart';
import 'package:reto4_convertidor_cripto/features/crypto/data/datasources/crypto_remote_datasource.dart';
import 'package:reto4_convertidor_cripto/features/crypto/data/models/crypto_price_model.dart';
import 'package:reto4_convertidor_cripto/features/crypto/data/repositories/crypto_repository_impl.dart';
import 'package:reto4_convertidor_cripto/features/crypto/domain/entities/crypto.dart';
import 'package:reto4_convertidor_cripto/features/crypto/domain/usecases/calculate_crypto_amount.dart';

const _sample = {
  'bitcoin': {'usd': 50000},
  'ethereum': {'usd': 2500.5},
  'solana': {'usd': 100},
};

http.Response _json(Object body, [int status = 200]) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

void main() {
  group('CalculateCryptoAmount', () {
    const calculate = CalculateCryptoAmount();

    test('divide el monto entre el precio', () {
      expect(calculate(usd: 100, price: 50000), closeTo(0.002, 1e-12));
    });

    test('precio cero o negativo devuelve 0 (sin dividir entre cero)', () {
      expect(calculate(usd: 100, price: 0), 0);
      expect(calculate(usd: 100, price: -5), 0);
    });

    test('monto cero o negativo devuelve 0', () {
      expect(calculate(usd: 0, price: 100), 0);
      expect(calculate(usd: -10, price: 100), 0);
    });
  });

  group('CryptoPriceModel', () {
    test('parsea las tres monedas, aunque el precio venga como int', () {
      final prices = CryptoPriceModel.listFromJson(_sample);

      expect(prices.map((p) => p.crypto),
          [Crypto.bitcoin, Crypto.ethereum, Crypto.solana]);
      expect(prices[0].usd, 50000.0);
      expect(prices[1].usd, 2500.5);
    });

    test('si falta una moneda lanza ServerException', () {
      expect(
        () => CryptoPriceModel.listFromJson({
          'bitcoin': {'usd': 1},
        }),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('CryptoRemoteDataSource', () {
    test('arma la URL del endpoint simple/price', () {
      final uri = CryptoRemoteDataSource(MockClient((_) async => _json({})))
          .buildUri();

      expect(uri.host, 'api.coingecko.com');
      expect(uri.path, '/api/v3/simple/price');
      expect(uri.queryParameters['ids'], 'bitcoin,ethereum,solana');
      expect(uri.queryParameters['vs_currencies'], 'usd');
    });
  });

  group('CryptoRepositoryImpl', () {
    CryptoRepositoryImpl repoWith(MockClient client) =>
        CryptoRepositoryImpl(CryptoRemoteDataSource(client));

    test('respuesta correcta devuelve los precios', () async {
      final prices =
          await repoWith(MockClient((_) async => _json(_sample))).getPrices();

      expect(prices.length, 3);
    });

    test('429 se traduce a RateLimitFailure', () {
      final repo = repoWith(MockClient((_) async => _json({}, 429)));

      expect(repo.getPrices(), throwsA(isA<RateLimitFailure>()));
    });

    test('500 se traduce a ServerFailure', () {
      final repo = repoWith(MockClient((_) async => _json({}, 500)));

      expect(repo.getPrices(), throwsA(isA<ServerFailure>()));
    });

    test('error de red se traduce a NetworkFailure', () {
      final repo = repoWith(
          MockClient((_) async => throw http.ClientException('sin red')));

      expect(repo.getPrices(), throwsA(isA<NetworkFailure>()));
    });
  });

  group('formatUsd', () {
    test('agrega miles y 2 decimales', () {
      expect(formatUsd(67000.5), '\$67,000.50');
      expect(formatUsd(1234567.891), '\$1,234,567.89');
      expect(formatUsd(100), '\$100.00');
    });

    test('precios menores a 1 usan 4 decimales', () {
      expect(formatUsd(0.5), '\$0.5000');
    });
  });
}
