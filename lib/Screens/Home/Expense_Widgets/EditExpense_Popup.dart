import 'package:flutter/material.dart';

class EditExpensePopup extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController amountController;
  final TextEditingController dateController;
  String category;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback onSave;
  final VoidCallback onClose;

  EditExpensePopup({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.amountController,
    required this.dateController,
    required this.category,
    required this.onCategoryChanged,
    required this.onSave,
    required this.onClose,
  });

  @override
  _EditExpensePopupState createState() => _EditExpensePopupState();
}

class _EditExpensePopupState extends State<EditExpensePopup> {
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        widget.dateController.text = picked.toString().substring(0, 10);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Expense'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: widget.nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: widget.descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: widget.amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: widget.dateController,
              decoration: const InputDecoration(labelText: 'Date'),
              onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                await _selectDate(context);
              },
            ),
            DropdownButton<String>(
              value: widget.category,
              onChanged: (String? newValue) {
                setState(() {
                  widget.category = newValue!;
                });
                widget.onCategoryChanged(newValue);
              },
              items: <String>['Food', 'Transport', 'Bills', 'Housing', 'Leisure']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onClose,
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: widget.onSave,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
