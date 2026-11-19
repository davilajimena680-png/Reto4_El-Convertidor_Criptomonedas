import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'features/crypto/data/datasources/crypto_remote_datasource.dart';
import 'features/crypto/data/repositories/crypto_repository_impl.dart';
import 'features/crypto/domain/usecases/calculate_crypto_amount.dart';
import 'features/crypto/domain/usecases/get_crypto_prices.dart';
import 'features/crypto/presentation/pages/crypto_page.dart';
import 'features/crypto/presentation/providers/crypto_provider.dart';

void main() {
  // Composición de dependencias: datasource -> repositorio -> casos de uso.
  final repository =
      CryptoRepositoryImpl(CryptoRemoteDataSource(http.Client()));

  runApp(
    ChangeNotifierProvider(
      create: (_) => CryptoProvider(
        GetCryptoPrices(repository),
        const CalculateCryptoAmount(),
        refreshEvery: const Duration(minutes: 1),
      ),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Convertidor de Cripto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const CryptoPage(),
    );
  }
}
