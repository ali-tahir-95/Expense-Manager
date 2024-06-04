import 'package:flutter/material.dart';

class ExpensePopup extends StatelessWidget {
  final String title;
  final String description;
  final double amount;
  final String date;
  final String category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onClose;

  const ExpensePopup({
    super.key,
    required this.title,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
    required this.onEdit,
    required this.onDelete,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Description: $description'),
          Text('Amount: \$${amount.toStringAsFixed(2)}'),
          Text('Date: $date'),
          Text('Category: $category'),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: onClose,
          child: const Text('Close'),
        ),
      ],
    );
  }
}
