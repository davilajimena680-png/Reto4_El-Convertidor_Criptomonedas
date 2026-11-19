import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:reto4_convertidor_cripto/features/crypto/domain/entities/crypto.dart';
import 'package:reto4_convertidor_cripto/features/crypto/domain/entities/crypto_price.dart';
import 'package:reto4_convertidor_cripto/features/crypto/domain/repositories/crypto_repository.dart';
import 'package:reto4_convertidor_cripto/features/crypto/domain/usecases/calculate_crypto_amount.dart';
import 'package:reto4_convertidor_cripto/features/crypto/domain/usecases/get_crypto_prices.dart';
import 'package:reto4_convertidor_cripto/features/crypto/presentation/pages/crypto_page.dart';
import 'package:reto4_convertidor_cripto/features/crypto/presentation/providers/crypto_provider.dart';

class _FakeRepository implements CryptoRepository {
  @override
  Future<List<CryptoPrice>> getPrices() async => const [
        CryptoPrice(crypto: Crypto.bitcoin, usd: 50000),
        CryptoPrice(crypto: Crypto.ethereum, usd: 2500),
        CryptoPrice(crypto: Crypto.solana, usd: 100),
      ];
}

void main() {
  testWidgets('muestra precios y recalcula al cambiar el monto', (tester) async {
    final provider = CryptoProvider(
      GetCryptoPrices(_FakeRepository()),
      const CalculateCryptoAmount(),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: CryptoPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bitcoin'), findsOneWidget);
    expect(find.text('0.00200000 BTC'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '500');
    await tester.pump();

    expect(find.text('0.01000000 BTC'), findsOneWidget);
    expect(find.text('5.0000 SOL'), findsOneWidget);
  });
}
