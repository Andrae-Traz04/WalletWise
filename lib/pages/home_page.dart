import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

import 'stats_page.dart';
import 'goals_page.dart';
import 'salaries_page.dart';

class HomePage extends StatefulWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  
  // Database Reference
  late DatabaseReference _userRef;
  StreamSubscription? _userDataSubscription;

  // State Variables
  double _monthlyIncome = 0.0;
  double _balance = 0.0;
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _savingsGoals = [];

  final Color primaryDark = const Color(0xFF04503d);
  final Color primaryLight = const Color(0xFF6DA18D);

  @override
  void initState() {
    super.initState();
    _setupRealtimeListener();
  }

  void _setupRealtimeListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _userRef = FirebaseDatabase.instance.ref("users/${user.uid}");

    _userDataSubscription = _userRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return;

      if (mounted) {
        setState(() {
          // 1. Update Finances
          final finances = data['finances'] as Map?;
          _balance = (finances?['balance'] ?? 0.0).toDouble();
          _monthlyIncome = (finances?['monthlyIncome'] ?? 0.0).toDouble();

          // 2. Update Transactions
          final txMap = data['transactions'] as Map?;
          _transactions.clear();
          if (txMap != null) {
            txMap.forEach((key, value) {
              _transactions.add({
                'id': key,
                'category': value['category'],
                'amount': (value['amount'] ?? 0.0).toDouble(),
                'note': value['note'],
                'date': DateTime.tryParse(value['date']) ?? DateTime.now(),
                'isIncome': value['isIncome'] ?? false,
              });
            });
            // Sort by date (newest first)
            _transactions.sort((a, b) => b['date'].compareTo(a['date']));
          }

          // 3. Update Goals
          final goalsMap = data['goals'] as Map?;
          _savingsGoals.clear();
          if (goalsMap != null) {
            goalsMap.forEach((key, value) {
              _savingsGoals.add({
                'id': key,
                'title': value['title'],
                'target': (value['target'] ?? 0.0).toDouble(),
                'saved': (value['saved'] ?? 0.0).toDouble(),
              });
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _userDataSubscription?.cancel();
    super.dispose();
  }

  // --- ACTIONS (Write to Database) ---

  void _addSalaryToBalance(double amount) {
    // Update balance and add a transaction
    double newBalance = _balance + amount;
    _userRef.child('finances').update({'balance': newBalance});

    _userRef.child('transactions').push().set({
      'category': 'Salary',
      'amount': amount,
      'note': 'Payday collected',
      'date': DateTime.now().toIso8601String(),
      'isIncome': true,
    });
  }

  void _addGoal(String title, double target, double saved) {
    _userRef.child('goals').push().set({
      'title': title,
      'target': target,
      'saved': saved,
    });
  }

  void _deleteGoal(int index) {
    String? key = _savingsGoals[index]['id'];
    if (key != null) {
      _userRef.child('goals/$key').remove();
    }
  }

  void _addFundsToGoal(int index, double amount) {
    if (_balance >= amount) {
      String? key = _savingsGoals[index]['id'];
      double currentSaved = _savingsGoals[index]['saved'];
      
      if (key != null) {
        // Update goal saved amount
        _userRef.child('goals/$key').update({'saved': currentSaved + amount});
        // Deduct from main balance
        _userRef.child('finances').update({'balance': _balance - amount});
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough balance!')),
      );
    }
  }

  void _addTransaction(String category, double amount, String note) {
    _userRef.child('transactions').push().set({
      'category': category,
      'amount': amount,
      'note': note,
      'date': DateTime.now().toIso8601String(),
      'isIncome': false,
    });
    // Deduct expense from balance
    _userRef.child('finances').update({'balance': _balance - amount});
  }

  void _updateIncome(double amount) {
    _userRef.child('finances').update({'monthlyIncome': amount});
    // If balance is 0, initialize it with allowance
    if (_balance == 0) {
      _userRef.child('finances').update({'balance': amount});
    }
  }

  void _showAddExpenseModal() {
    TextEditingController amountController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    String selectedCategory = 'Food';
    final List<String> categories = ['Rent', 'Transportation', 'Food', 'Entertainment', 'Academics', 'Health'];

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Add Expense', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(controller: amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Amount', prefixIcon: const Icon(Icons.attach_money), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 15),
          DropdownButtonFormField<String>(value: selectedCategory, items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => selectedCategory = v!, decoration: InputDecoration(labelText: 'Category', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 15),
          TextField(controller: nameController, decoration: InputDecoration(labelText: 'Note', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (amountController.text.isNotEmpty) {
                _addTransaction(selectedCategory, double.tryParse(amountController.text) ?? 0.0, nameController.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryDark, padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50)),
            child: const Text('Add Expense', style: TextStyle(color: Colors.white)),
          ),
        ]),
      ),
    );
  }

  void _showAddIncomeDialog() {
    TextEditingController incomeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Monthly Allowance'),
        content: TextField(controller: incomeController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'e.g., 5000', prefixText: '\$ ')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              _updateIncome(double.tryParse(incomeController.text) ?? 0.0);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryDark),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget buildDashboard() {
    // ... [Use the exact same buildDashboard code from your uploaded file, just ensure it uses the variables _balance, _monthlyIncome, etc.] ...
    // Note: The original code for buildDashboard provided in the question is fully compatible with these state variables.
    // I will include the critical parts below for clarity.
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Welcome,", style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8))),
                    Text(widget.username, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                  ],
                ),
                // Sign out button
                GestureDetector(
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    // Login page is handled by StreamBuilder in main.dart, but we can pop manually if needed
                    // Navigator.pop(context); 
                  },
                  child: const CircleAvatar(radius: 25, backgroundColor: Colors.white24, child: Icon(Icons.logout, color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // ... (Rest of your dashboard UI code: Balance Card, Recent Transactions) ...
            // Use _balance, _monthlyIncome, and _transactions as they are automatically updated by the listener.
             Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: primaryLight,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Main Balance", style: TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text("₱${_balance.toStringAsFixed(2)}", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _showAddIncomeDialog, 
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month, color: Colors.white70),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Monthly", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                Text("₱${_monthlyIncome.toStringAsFixed(0)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.arrow_upward, color: Colors.white70),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Expenses", style: TextStyle(color: Colors.white70, fontSize: 12)),
                              Text("₱${(_monthlyIncome - _balance < 0 ? 0 : _monthlyIncome - _balance).toStringAsFixed(0)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text("Recent Transactions", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _transactions.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                  child: const Text("No transactions yet.", style: TextStyle(color: Colors.white70), textAlign: TextAlign.center)
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final tx = _transactions[index];
                    bool isIncome = tx['isIncome'] ?? false;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isIncome ? Colors.green[100] : primaryLight.withOpacity(0.2), 
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                child: Icon(
                                  isIncome ? Icons.attach_money : Icons.shopping_bag, 
                                  color: isIncome ? Colors.green : primaryDark
                                ),
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tx['category'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  if (tx['note'] != null && tx['note'].isNotEmpty)
                                    Text(tx['note'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            isIncome 
                              ? "+₱${tx['amount'].abs().toStringAsFixed(2)}"
                              : "-₱${tx['amount'].toStringAsFixed(2)}", 
                            style: TextStyle(
                              color: isIncome ? Colors.green : Colors.red, 
                              fontWeight: FontWeight.bold, 
                              fontSize: 16
                            )
                          ),
                        ],
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDark,
      floatingActionButton: _selectedIndex == 0 
        ? FloatingActionButton(
            onPressed: _showAddExpenseModal, 
            backgroundColor: const Color(0xFFFDD835),
            child: const Icon(Icons.add, color: Colors.black)
          )
        : null,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          buildDashboard(),
          StatsPage(monthlyIncome: _monthlyIncome, transactions: _transactions),
          GoalsPage(
            goals: _savingsGoals,
            onAddGoal: _addGoal,
            onDeleteGoal: _deleteGoal,
            onAddFunds: _addFundsToGoal,
          ),
          SalariesPage(onCollectSalary: _addSalaryToBalance), 
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.white,
        indicatorColor: primaryLight.withOpacity(0.5),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.flag_outlined), selectedIcon: Icon(Icons.flag), label: 'Goals'),
          NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'Salaries'),
        ],
      ),
    );
  }
}