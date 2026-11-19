/// Criptomonedas soportadas por la app.
enum Crypto {
  bitcoin('bitcoin', 'BTC', 'Bitcoin', 8),
  ethereum('ethereum', 'ETH', 'Ethereum', 6),
  solana('solana', 'SOL', 'Solana', 4);

  const Crypto(this.id, this.symbol, this.displayName, this.fractionDigits);

  /// Id que usa CoinGecko.
  final String id;
  final String symbol;
  final String displayName;

  /// Decimales con los que se muestra una fracción de esta moneda.
  final int fractionDigits;
}
