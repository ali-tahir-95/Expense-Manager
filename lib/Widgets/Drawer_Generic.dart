import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Screens/Admin/Dashboard.dart';
import '../Screens/Auth/SignIn.dart';
import '../Screens/Home/Expense_Manager.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String userName = user?.displayName ?? 'User';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFFA8D5BA),
            ),
            accountName: Text(
              userName,
              style: const TextStyle(color: Colors.white),
            ),
            accountEmail: Text(
              user?.email ?? 'No email',
              style: const TextStyle(color: Colors.white),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.account_balance_wallet,
                size: 50,
                color: Color(0xFFA8D5BA),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: Color(0xFFA8D5BA)),
            title: const Text('Dashboard'),
            onTap: () {
              // Handle Dashboard tap
              Get.offAll(DashboardScreen(
                userId: user!.uid,
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money, color: Color(0xFFA8D5BA)),
            title: const Text('Manage Expenses'),
            onTap: () {
              // Handle Manage Expenses tap
              Get.offAll(const ExpenseManagerScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFFA8D5BA)),
            title: const Text('Logout'),
            onTap: () async {
              // Show logout confirmation dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () async {
                          // Perform logout action
                          await FirebaseAuth.instance.signOut();
                          // Navigate to login screen after logout
                          Get.offAll(() => const SignInScreen());
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
