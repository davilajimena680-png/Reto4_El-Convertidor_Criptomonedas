import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/crypto_price.dart';
import '../../domain/usecases/calculate_crypto_amount.dart';
import '../../domain/usecases/get_crypto_prices.dart';

enum CryptoStatus { loading, success, error }

class CryptoProvider extends ChangeNotifier {
  /// [refreshEvery] activa el refresco automático (null = desactivado).
  CryptoProvider(
    this._getPrices,
    this._calculate, {
    Duration? refreshEvery,
  }) {
    load();
    if (refreshEvery != null) {
      _timer = Timer.periodic(refreshEvery, (_) => load(silent: true));
    }
  }

  final GetCryptoPrices _getPrices;
  final CalculateCryptoAmount _calculate;
  Timer? _timer;
  bool _disposed = false;

  CryptoStatus _status = CryptoStatus.loading;
  List<CryptoPrice> _prices = const [];
  String? _errorMessage;
  DateTime? _updatedAt;

  String _amountText = '100';
  double? _amountUsd = 100;

  CryptoStatus get status => _status;
  List<CryptoPrice> get prices => _prices;
  String? get errorMessage => _errorMessage;
  DateTime? get updatedAt => _updatedAt;
  String get amountText => _amountText;

  /// Monto válido en USD, o null si el texto no es un número.
  double? get amountUsd => _amountUsd;

  /// Carga los precios. Con [silent] no muestra el spinner si ya hay datos
  /// y, si falla, conserva los precios anteriores.
  Future<void> load({bool silent = false}) async {
    final showSpinner = !silent || _prices.isEmpty;
    if (showSpinner) {
      _status = CryptoStatus.loading;
      _errorMessage = null;
      _notify();
    }

    try {
      _prices = await _getPrices();
      _status = CryptoStatus.success;
      _errorMessage = null;
      _updatedAt = DateTime.now();
    } on Failure catch (failure) {
      if (silent && _prices.isNotEmpty) return;
      _errorMessage = failure.message;
      _status = CryptoStatus.error;
    } catch (_) {
      if (silent && _prices.isNotEmpty) return;
      _errorMessage = 'Ocurrió un error inesperado.';
      _status = CryptoStatus.error;
    }
    _notify();
  }

  void setAmountText(String text) {
    _amountText = text;
    final value = double.tryParse(text.trim().replaceAll(',', '.'));
    _amountUsd =
        (value == null || value.isNaN || value.isInfinite || value < 0)
            ? null
            : value;
    _notify();
  }

  /// Fracciones de cripto que se compran con el monto actual.
  double? amountFor(CryptoPrice price) {
    final usd = _amountUsd;
    if (usd == null) return null;
    return _calculate(usd: usd, price: price.usd);
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
