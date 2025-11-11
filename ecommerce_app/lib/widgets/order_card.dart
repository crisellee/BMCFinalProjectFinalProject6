import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderCard({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    // Format the date safely
    final Timestamp? timestamp = orderData['createdAt'];
    final String formattedDate = timestamp != null
        ? DateFormat('MM/dd/yyyy - hh:mm a').format(timestamp.toDate())
        : 'Date not available';

    // Null-safe fields
    final double subtotal = (orderData['subtotal'] ?? 0.0).toDouble();
    final double vat = (orderData['vat'] ?? 0.0).toDouble();
    final double totalPrice = (orderData['totalPrice'] ?? 0.0).toDouble();
    final int itemCount = orderData['itemCount'] ?? 0;
    final String status = orderData['status'] ?? 'Pending';

    final List items = orderData['items'] ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total amount
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: '₱',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  TextSpan(
                    text: totalPrice.toStringAsFixed(2),
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text('Items: $itemCount\nStatus: $status'),
            const SizedBox(height: 6),
            Text('Date: $formattedDate', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const Divider(),

            // List of items
            Column(
              children: items.map<Widget>((item) {
                final name = item['name'] ?? 'No Name';
                final qty = item['quantity'] ?? 0;
                final price = (item['price'] ?? 0.0).toDouble();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$name x$qty'),
                    Text('₱${(price * qty).toStringAsFixed(2)}'),
                  ],
                );
              }).toList(),
            ),
            const Divider(),

            // Subtotal / VAT / Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:'),
                Text('₱${subtotal.toStringAsFixed(2)}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('VAT (12%):'),
                Text('₱${vat.toStringAsFixed(2)}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
                Text(
                  '₱${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
