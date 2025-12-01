import 'package:flutter/material.dart';

class GoalsPage extends StatefulWidget {
  final List<Map<String, dynamic>> goals;
  final Function(String title, double target, double saved) onAddGoal;
  final Function(int index) onDeleteGoal;
  final Function(int index, double amount) onAddFunds; // <--- New Callback

  const GoalsPage({
    super.key,
    required this.goals,
    required this.onAddGoal,
    required this.onDeleteGoal,
    required this.onAddFunds, // <--- Require it here
  });

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final Color primaryColor = const Color(0xFF4CAF50);

  // --- DIALOG: CREATE NEW GOAL ---
  void _showAddGoalDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController targetController = TextEditingController();
    TextEditingController savedController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Savings Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Goal Name')),
            TextField(controller: targetController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Target Amount (\$)')),
            TextField(controller: savedController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Initial Savings (\$)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && targetController.text.isNotEmpty) {
                widget.onAddGoal(
                  titleController.text,
                  double.tryParse(targetController.text) ?? 0.0,
                  double.tryParse(savedController.text) ?? 0.0,
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text('Add Goal', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- NEW DIALOG: ADD FUNDS TO EXISTING GOAL ---
  void _showAddFundsDialog(int index) {
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add to ${widget.goals[index]['title']}'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Amount to Add',
            prefixText: '\$ ',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (amountController.text.isNotEmpty) {
                double amount = double.tryParse(amountController.text) ?? 0.0;
                widget.onAddFunds(index, amount); // Call the logic in HomePage
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddGoalDialog,
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Goal', style: TextStyle(color: Colors.white)),
      ),
      body: widget.goals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flag_outlined, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  Text('Set your first savings goal!', style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: widget.goals.length,
              itemBuilder: (context, index) {
                final goal = widget.goals[index];
                double progress = goal['target'] == 0 ? 0 : goal['saved'] / goal['target'];
                double displayProgress = progress > 1.0 ? 1.0 : progress;

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Title + Delete
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(goal['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => widget.onDeleteGoal(index),
                          ),
                        ],
                      ),
                      
                      // Progress Text
                      Text('\$${goal['saved']} saved of \$${goal['target']}', style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 10),
                      
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: displayProgress,
                          minHeight: 12,
                          backgroundColor: Colors.grey[100],
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // "Add Funds" Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showAddFundsDialog(index),
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Add Money'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: BorderSide(color: primaryColor),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
