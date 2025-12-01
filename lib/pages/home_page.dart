import 'package:flutter/material.dart';

// --- RELATIVE IMPORTS ---
// Make sure these files exist in your lib/pages/ folder
import 'stats_page.dart';
import 'goals_page.dart';
import 'salaries_page.dart';

class HomePage extends StatefulWidget {
  final String username; 
  // Defaulting to "Student" if no name is passed
  const HomePage({super.key, this.username = "Student"});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; 
  
  // --- STATE VARIABLES ---
  double _monthlyIncome = 0.0;
  double _balance = 0.0; 
  
  // Data Lists
  List<Map<String, dynamic>> _transactions = []; 
  final List<Map<String, dynamic>> _savingsGoals = [];

  // Theme Colors
  final Color primaryDark = const Color(0xFF04503d); // Dark Green
  final Color primaryLight = const Color(0xFF6DA18D); // Light Green

  // --- LOGIC: SALARIES (Connected to SalariesPage) ---
  void _addSalaryToBalance(double amount) {
    setState(() {
      _balance += amount;
      
      // Add record to transactions so it appears in history
      _transactions.insert(0, {
        'category': 'Salary',
        'amount': amount, // Positive amount for income logic
        'note': 'Payday collected',
        'date': DateTime.now(),
        'isIncome': true, // Flag to show it as green
      });
    });
  }

  // --- LOGIC: GOALS (Connected to GoalsPage) ---
  void _addGoal(String title, double target, double saved) {
    setState(() {
      _savingsGoals.add({'title': title, 'target': target, 'saved': saved});
    });
  }

  void _deleteGoal(int index) {
    setState(() {
      _savingsGoals.removeAt(index);
    });
  }

  void _addFundsToGoal(int index, double amount) {
    setState(() {
      if (_balance >= amount) {
        _savingsGoals[index]['saved'] += amount;
        _balance -= amount; // Deduct from wallet when moving to savings
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not enough balance to save that amount!')),
        );
      }
    });
  }

  // --- LOGIC: TRANSACTIONS (EXPENSES) ---
  void _addTransaction(String category, double amount, String note) {
    setState(() {
      _transactions.insert(0, {
        'category': category,
        'amount': amount,
        'note': note,
        'date': DateTime.now(),
        'isIncome': false,
      });
      _balance -= amount; 
    });
  }

  // --- LOGIC: INCOME (ALLOWANCE) ---
  void _updateIncome(double amount) {
    setState(() {
      _monthlyIncome = amount;
      // Logic: If balance is 0, we assume they are starting fresh with this allowance
      if (_balance == 0) _balance = amount; 
    });
  }

  // --- MODAL: ADD EXPENSE ---
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

  // --- MODAL: SET INCOME ---
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

  // --- DASHBOARD WIDGET (Fixed Syntax Errors) ---
  Widget buildDashboard() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Header
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
                const CircleAvatar(radius: 25, backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white)),
              ],
            ),

            const SizedBox(height: 30),

            // Balance Card
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
                  
                  // Allowance vs Expenses Summary
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // INCOME CLICKABLE AREA
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
                      
                      // EXPENSES DISPLAY AREA
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
            
            // Recent Transactions Section
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
      
      // Floating button only on Home Tab (Index 0)
      floatingActionButton: _selectedIndex == 0 
        ? FloatingActionButton(
            onPressed: _showAddExpenseModal, 
            backgroundColor: const Color(0xFFFDD835), // Yellow contrast
            child: const Icon(Icons.add, color: Colors.black)
          )
        : null,

      body: IndexedStack(
        index: _selectedIndex,
        children: [
          buildDashboard(), // Tab 0: Dashboard

          // Tab 1: Stats
          StatsPage(
            monthlyIncome: _monthlyIncome,
            transactions: _transactions,
          ),

          // Tab 2: Goals
          GoalsPage(
            goals: _savingsGoals,
            onAddGoal: _addGoal,
            onDeleteGoal: _deleteGoal,
            onAddFunds: _addFundsToGoal,
          ),

          // Tab 3: Salaries
          SalariesPage(
            onCollectSalary: _addSalaryToBalance,
          ), 
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

