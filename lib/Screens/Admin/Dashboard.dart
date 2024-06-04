import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../Widgets/Drawer_Generic.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../Widgets/Drawer_Generic.dart';
import '../Home/Expense_Manager.dart';

class DashboardScreen extends StatelessWidget {
  final String userId;

  const DashboardScreen({super.key, required this.userId});

  Future<List<ExpenseData>> _fetchExpenses() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference expensesCollection =
        firestore.collection('users').doc(userId).collection('expenses');

    QuerySnapshot querySnapshot = await expensesCollection.get();
    List<QueryDocumentSnapshot> docs = querySnapshot.docs;

    Map<String, double> dailyExpenses = {};

    for (var doc in docs) {
      DateTime date = DateTime.parse(doc['date']);
      String day = _dayOfWeek(date.weekday);

      if (dailyExpenses.containsKey(day)) {
        dailyExpenses[day] = dailyExpenses[day]! + doc['amount'];
      } else {
        dailyExpenses[day] = doc['amount'];
      }
    }

    return dailyExpenses.entries.map((entry) => ExpenseData(entry.key, entry.value)).toList();
  }

  String _dayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFFA8D5BA),
        centerTitle: true,
      ),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Expense Manager',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFFA8D5BA),
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: FutureBuilder<List<ExpenseData>>(
                future: _fetchExpenses(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error loading expenses'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No expenses to display'));
                  } else {
                    return SfCartesianChart(
                      primaryXAxis: const CategoryAxis(),
                      title: const ChartTitle(text: 'Expenses Overview'),
                      legend: const Legend(isVisible: true),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <CartesianSeries>[
                        LineSeries<ExpenseData, String>(
                          dataSource: snapshot.data!,
                          xValueMapper: (ExpenseData expenses, _) => expenses.day,
                          yValueMapper: (ExpenseData expenses, _) => expenses.amount,
                          name: 'Daily Expenses',
                          dataLabelSettings: const DataLabelSettings(isVisible: true),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Get.offAll(() => const ExpenseManagerScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA8D5BA),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text(
                'Manage Expenses',
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

class ExpenseData {
  ExpenseData(this.day, this.amount);

  final String day;
  final double amount;
}
