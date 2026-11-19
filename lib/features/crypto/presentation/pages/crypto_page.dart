import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/crypto_provider.dart';
import '../widgets/crypto_card.dart';

class CryptoPage extends StatefulWidget {
  const CryptoPage({super.key});

  @override
  State<CryptoPage> createState() => _CryptoPageState();
}

class _CryptoPageState extends State<CryptoPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: context.read<CryptoProvider>().amountText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CryptoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Convertidor de Cripto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar precios',
            onPressed: provider.load,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                onChanged: provider.setAmountText,
                decoration: InputDecoration(
                  labelText: 'Monto en USD',
                  prefixText: '\$ ',
                  border: const OutlineInputBorder(),
                  errorText: provider.amountUsd == null
                      ? 'Escribe un monto válido'
                      : null,
                ),
              ),
            ),
            Expanded(child: _content(provider)),
          ],
        ),
      ),
    );
  }

  Widget _content(CryptoProvider provider) {
    switch (provider.status) {
      case CryptoStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case CryptoStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 48),
                const SizedBox(height: 12),
                Text(provider.errorMessage ?? '', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: provider.load,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        );

      case CryptoStatus.success:
        final updated = provider.updatedAt;
        return RefreshIndicator(
          onRefresh: provider.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              for (final price in provider.prices)
                CryptoCard(price: price, amount: provider.amountFor(price)),
              if (updated != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Actualizado ${_two(updated.hour)}:${_two(updated.minute)}:${_two(updated.second)} · se refresca cada minuto',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        );
    }
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}
