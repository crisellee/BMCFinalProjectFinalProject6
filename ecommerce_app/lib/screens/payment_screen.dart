import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/screens/order_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum PaymentMethod { card, gcash, bank }

class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  const PaymentScreen({super.key, required this.totalAmount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _selectedMethod = PaymentMethod.card;
  bool _isLoading = false;

  Future<void> _processPayment() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 3));

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    await cartProvider.placeOrder();
    await cartProvider.clearCart();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
            (route) => false,
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final total = '₱${widget.totalAmount.toStringAsFixed(2)}';

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Total Amount:', style: Theme.of(context).textTheme.titleLarge),
            Text(total,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 24),
            const Divider(),
            Text('Select Payment Method:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),

            RadioListTile(
              title: const Text('Credit/Debit Card'),
              value: PaymentMethod.card,
              groupValue: _selectedMethod,
              onChanged: (v) => setState(() => _selectedMethod = v!),
              secondary: const Icon(Icons.credit_card),
            ),
            RadioListTile(
              title: const Text('GCash'),
              value: PaymentMethod.gcash,
              groupValue: _selectedMethod,
              onChanged: (v) => setState(() => _selectedMethod = v!),
              secondary: const Icon(Icons.phone_android),
            ),
            RadioListTile(
              title: const Text('Bank Transfer'),
              value: PaymentMethod.bank,
              groupValue: _selectedMethod,
              onChanged: (v) => setState(() => _selectedMethod = v!),
              secondary: const Icon(Icons.account_balance),
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: _isLoading ? null : _processPayment,
              child: _isLoading
                  ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                  : Text('Pay Now ($total)'),
            ),
          ],
        ),
      ),
    );
  }
}
