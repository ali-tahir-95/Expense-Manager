import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Widgets/Drawer_Generic.dart';
import '../Admin/Dashboard.dart';
import 'Expense_Widgets/AddExpense_Popup.dart';
import 'Expense_Widgets/EditExpense_Popup.dart';
import 'Expense_Widgets/Expense_Popup.dart';

class ExpenseManagerScreen extends StatefulWidget {
  const ExpenseManagerScreen({super.key});

  @override
  _ExpenseManagerScreenState createState() => _ExpenseManagerScreenState();
}

class _ExpenseManagerScreenState extends State<ExpenseManagerScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  late CollectionReference _expensesCollection;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _expensesCollection =
        _firestore.collection('users').doc(_currentUser!.uid).collection('expenses');
  }

  Future<void> _addExpense(Map<String, dynamic> expense) async {
    await _expensesCollection.add(expense);
  }

  Future<void> _editExpense(String docId, Map<String, dynamic> updatedExpense) async {
    await _expensesCollection.doc(docId).update(updatedExpense);
  }

  Future<void> _deleteExpense(String docId) async {
    await _expensesCollection.doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Manager'),
        backgroundColor: const Color(0xFFA8D5BA),
        centerTitle: true,
      ),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    final TextEditingController nameController = TextEditingController();
                    final TextEditingController descriptionController = TextEditingController();
                    final TextEditingController amountController = TextEditingController();
                    final TextEditingController dateController = TextEditingController();
                    String category = 'Food';

                    return AddExpensePopup(
                      nameController: nameController,
                      descriptionController: descriptionController,
                      amountController: amountController,
                      dateController: dateController,
                      category: category,
                      onCategoryChanged: (String? newCategory) {
                        if (newCategory != null) {
                          category = newCategory;
                        }
                      },
                      onSave: () async {
                        final newExpense = {
                          'name': nameController.text,
                          'description': descriptionController.text,
                          'amount': double.parse(amountController.text),
                          'date': dateController.text,
                          'category': category,
                        };
                        await _addExpense(newExpense);
                        Navigator.of(context).pop();
                      },
                      onClose: () {
                        Navigator.of(context).pop();
                      },
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA8D5BA),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Expense',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _expensesCollection.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading expenses'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final expenses = snapshot.data!.docs.map((doc) {
                    return {
                      'id': doc.id,
                      'name': doc['name'],
                      'description': doc['description'],
                      'amount': doc['amount'],
                      'date': doc['date'],
                      'category': doc['category'],
                    };
                  }).toList();
                  if (expenses.isEmpty) {
                    return const Center(
                      child: Text(
                        'You didn\'t add any expenses.\nPlease add expenses.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(expenses[index]['name']),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ExpensePopup(
                                  title: expenses[index]['name'],
                                  description: expenses[index]['description'],
                                  amount: expenses[index]['amount'],
                                  date: expenses[index]['date'],
                                  category: expenses[index]['category'],
                                  onEdit: () {
                                    final TextEditingController nameController =
                                        TextEditingController(text: expenses[index]['name']);
                                    final TextEditingController descriptionController =
                                        TextEditingController(text: expenses[index]['description']);
                                    final TextEditingController amountController =
                                        TextEditingController(
                                            text: expenses[index]['amount'].toString());
                                    final TextEditingController dateController =
                                        TextEditingController(text: expenses[index]['date']);
                                    String category = expenses[index]['category'];

                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return EditExpensePopup(
                                          nameController: nameController,
                                          descriptionController: descriptionController,
                                          amountController: amountController,
                                          dateController: dateController,
                                          category: category,
                                          onCategoryChanged: (String? newCategory) {
                                            if (newCategory != null) {
                                              category = newCategory;
                                            }
                                          },
                                          onSave: () async {
                                            final updatedExpense = {
                                              'name': nameController.text,
                                              'description': descriptionController.text,
                                              'amount': double.parse(amountController.text),
                                              'date': dateController.text,
                                              'category': category,
                                            };
                                            await _editExpense(
                                                expenses[index]['id'], updatedExpense);
                                            Navigator.of(context).pop();
                                          },
                                          onClose: () {
                                            Navigator.of(context).pop();
                                          },
                                        );
                                      },
                                    );
                                    Navigator.of(context).pop();
                                  },
                                  onDelete: () async {
                                    await _deleteExpense(expenses[index]['id']);
                                    Navigator.of(context).pop();
                                  },
                                  onClose: () {
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                            );
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Color(0xFFA8D5BA)),
                                onPressed: () {
                                  final TextEditingController nameController =
                                      TextEditingController(text: expenses[index]['name']);
                                  final TextEditingController descriptionController =
                                      TextEditingController(text: expenses[index]['description']);
                                  final TextEditingController amountController =
                                      TextEditingController(
                                          text: expenses[index]['amount'].toString());
                                  final TextEditingController dateController =
                                      TextEditingController(text: expenses[index]['date']);
                                  String category = expenses[index]['category'];

                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return EditExpensePopup(
                                        nameController: nameController,
                                        descriptionController: descriptionController,
                                        amountController: amountController,
                                        dateController: dateController,
                                        category: category,
                                        onCategoryChanged: (String? newCategory) {
                                          if (newCategory != null) {
                                            category = newCategory;
                                          }
                                        },
                                        onSave: () async {
                                          final updatedExpense = {
                                            'name': nameController.text,
                                            'description': descriptionController.text,
                                            'amount': double.parse(amountController.text),
                                            'date': dateController.text,
                                            'category': category,
                                          };
                                          await _editExpense(expenses[index]['id'], updatedExpense);
                                          Navigator.of(context).pop();
                                        },
                                        onClose: () {
                                          Navigator.of(context).pop();
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Color(0xFFA8D5BA)),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Confirm Delete'),
                                        content: const Text(
                                            'Are you sure you want to delete this expense?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('No',
                                                style: TextStyle(color: Color(0xFFA8D5BA))),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await _deleteExpense(expenses[index]['id']);
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Yes',
                                                style: TextStyle(color: Color(0xFFA8D5BA))),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                User? user = FirebaseAuth.instance.currentUser;
                Get.offAll(() => DashboardScreen(userId: user!.uid));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA8D5BA),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text(
                'Expense Tracking',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
