import '../entities/crypto_price.dart';
import '../repositories/crypto_repository.dart';

class GetCryptoPrices {
  const GetCryptoPrices(this._repository);

  final CryptoRepository _repository;

  Future<List<CryptoPrice>> call() => _repository.getPrices();
}
