import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/crypto_price.dart';

class CryptoCard extends StatelessWidget {
  const CryptoCard({super.key, required this.price, required this.amount});

  final CryptoPrice price;

  /// Fracciones que se compran con el monto actual (null = monto inválido).
  final double? amount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final crypto = price.crypto;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              child: Text(crypto.symbol.substring(0, 1)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(crypto.displayName, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    '1 ${crypto.symbol} = ${formatUsd(price.usd)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Recibirías', style: theme.textTheme.bodySmall),
                Text(
                  amount == null
                      ? '—'
                      : '${amount!.toStringAsFixed(crypto.fractionDigits)} ${crypto.symbol}',
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
