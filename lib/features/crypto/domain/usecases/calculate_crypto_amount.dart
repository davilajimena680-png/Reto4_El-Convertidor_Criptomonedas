/// Cuántas fracciones de una cripto se compran con [usd] dólares.
class CalculateCryptoAmount {
  const CalculateCryptoAmount();

  double call({required double usd, required double price}) {
    if (price <= 0 || usd <= 0) return 0;
    return usd / price;
  }
}
