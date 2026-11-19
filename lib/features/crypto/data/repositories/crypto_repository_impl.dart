import 'dart:async';

import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/crypto_price.dart';
import '../../domain/repositories/crypto_repository.dart';
import '../datasources/crypto_remote_datasource.dart';

/// Traduce las excepciones de datos a `Failure` del dominio.
class CryptoRepositoryImpl implements CryptoRepository {
  const CryptoRepositoryImpl(this._dataSource);

  final CryptoRemoteDataSource _dataSource;

  @override
  Future<List<CryptoPrice>> getPrices() async {
    try {
      return await _dataSource.fetchPrices();
    } on ServerException catch (e) {
      if (e.statusCode == 429) throw const RateLimitFailure();
      throw const ServerFailure();
    } on http.ClientException {
      throw const NetworkFailure();
    } on TimeoutException {
      throw const NetworkFailure();
    }
  }
}
