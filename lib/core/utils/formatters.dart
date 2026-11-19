/// Formatea dólares con separador de miles: 67000.5 -> $67,000.50
String formatUsd(double value) {
  final fixed = value.toStringAsFixed(value >= 1 ? 2 : 4);
  final parts = fixed.split('.');
  final integer = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '\$$integer.${parts[1]}';
}
