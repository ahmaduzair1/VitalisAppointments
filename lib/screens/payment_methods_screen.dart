import 'package:flutter/material.dart';
import '../widgets/vitalis_card.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('How you pay')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: [
          Text(
            'Pay the consultation fee in the app when you book, or settle at the clinic desk. The admin board shows who is still unpaid.',
            style: TextStyle(color: cs.onSurfaceVariant, height: 1.5),
          ),
          const SizedBox(height: 20),
          VitalisCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _item(cs, Icons.local_hospital_outlined, 'Pay at clinic',
                    'Book now, pay when you arrive. Status stays Unpaid until the desk or you mark it paid.'),
                const Divider(height: 28),
                _item(cs, Icons.credit_card_rounded, 'Card in the app',
                    'Confirms the visit as Paid in hospital records. Card numbers are never stored in this app.'),
                const Divider(height: 28),
                _item(cs, Icons.account_balance_wallet_outlined, 'Mobile wallet',
                    'Same as pay-now for JazzCash / EasyPaisa style confirmation.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(ColorScheme cs, IconData icon, String title, String body) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: cs.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurface)),
              const SizedBox(height: 4),
              Text(body, style: TextStyle(color: cs.onSurfaceVariant, height: 1.45, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}
