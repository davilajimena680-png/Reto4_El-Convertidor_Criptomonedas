import 'package:flutter_test/flutter_test.dart';
import 'package:reto4_convertidor_cripto/core/error/failures.dart';
import 'package:reto4_convertidor_cripto/features/crypto/domain/entities/crypto.dart';
import 'package:reto4_convertidor_cripto/features/crypto/domain/entities/crypto_price.dart';
import 'package:reto4_convertidor_cripto/features/crypto/domain/repositories/crypto_repository.dart';
import 'package:reto4_convertidor_cripto/features/crypto/domain/usecases/calculate_crypto_amount.dart';
import 'package:reto4_convertidor_cripto/features/crypto/domain/usecases/get_crypto_prices.dart';
import 'package:reto4_convertidor_cripto/features/crypto/presentation/providers/crypto_provider.dart';

class FakeRepository implements CryptoRepository {
  FakeRepository({this.failure});

  Failure? failure;
  int calls = 0;

  @override
  Future<List<CryptoPrice>> getPrices() async {
    calls++;
    if (failure != null) throw failure!;
    return const [
      CryptoPrice(crypto: Crypto.bitcoin, usd: 50000),
      CryptoPrice(crypto: Crypto.ethereum, usd: 2500),
      CryptoPrice(crypto: Crypto.solana, usd: 100),
    ];
  }
}

CryptoProvider _provider(FakeRepository repo) => CryptoProvider(
      GetCryptoPrices(repo),
      const CalculateCryptoAmount(),
    );

void main() {
  test('carga los precios al iniciar', () async {
    final provider = _provider(FakeRepository());
    expect(provider.status, CryptoStatus.loading);

    await Future<void>.delayed(Duration.zero);

    expect(provider.status, CryptoStatus.success);
    expect(provider.prices.length, 3);
    expect(provider.updatedAt, isNotNull);
  });

  test('calcula las fracciones con el monto por defecto (100 USD)', () async {
    final provider = _provider(FakeRepository());
    await Future<void>.delayed(Duration.zero);

    expect(provider.amountFor(provider.prices[0]), closeTo(0.002, 1e-12));
    expect(provider.amountFor(provider.prices[2]), closeTo(1, 1e-12));
  });

  test('setAmountText acepta coma decimal', () async {
    final provider = _provider(FakeRepository());
    await Future<void>.delayed(Duration.zero);

    provider.setAmountText('2,5');

    expect(provider.amountUsd, 2.5);
  });

  test('un monto inválido deja amountUsd y el resultado en null', () async {
    final provider = _provider(FakeRepository());
    await Future<void>.delayed(Duration.zero);

    provider.setAmountText('abc');

    expect(provider.amountUsd, isNull);
    expect(provider.amountFor(provider.prices.first), isNull);
  });

  test('un Failure deja el estado en error', () async {
    final provider =
        _provider(FakeRepository(failure: const NetworkFailure()));
    await Future<void>.delayed(Duration.zero);

    expect(provider.status, CryptoStatus.error);
    expect(provider.errorMessage, contains('Sin conexión'));
  });

  test('un refresco silencioso fallido conserva los precios', () async {
    final repo = FakeRepository();
    final provider = _provider(repo);
    await Future<void>.delayed(Duration.zero);

    repo.failure = const ServerFailure();
    await provider.load(silent: true);

    expect(provider.status, CryptoStatus.success);
    expect(provider.prices.length, 3);
  });

  test('un refresco manual fallido sí muestra el error', () async {
    final repo = FakeRepository();
    final provider = _provider(repo);
    await Future<void>.delayed(Duration.zero);

    repo.failure = const ServerFailure();
    await provider.load();

    expect(provider.status, CryptoStatus.error);
  });
}
