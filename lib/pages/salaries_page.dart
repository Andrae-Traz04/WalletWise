import 'package:flutter/material.dart';

class SalariesPage extends StatefulWidget {
  // This function sends money back to the HomePage
  final Function(double amount) onCollectSalary;

  const SalariesPage({super.key, required this.onCollectSalary});

  @override
  State<SalariesPage> createState() => _SalariesPageState();
}

class _SalariesPageState extends State<SalariesPage> {
  final Color primaryDark = const Color(0xFF04503d);
  
  // List to track different jobs/gigs
  final List<Map<String, dynamic>> _jobs = [];

  // --- DIALOG: ADD NEW JOB ---
  void _showAddJobDialog() {
    TextEditingController jobNameController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    TextEditingController dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Salary Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: jobNameController,
              decoration: const InputDecoration(labelText: 'Job Name (e.g. Barista)'),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Salary Amount (\$)'),
            ),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: 'Payday (e.g. 15th & 30th)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (jobNameController.text.isNotEmpty && amountController.text.isNotEmpty) {
                setState(() {
                  _jobs.add({
                    'job': jobNameController.text,
                    'amount': double.tryParse(amountController.text) ?? 0.0,
                    'date': dateController.text,
                    'lastCollected': 'Never',
                  });
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryDark),
            child: const Text('Add Job', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- LOGIC: COLLECT PAY ---
  void _collectPay(int index) {
    double amount = _jobs[index]['amount'];
    
    // 1. Send money to Main Balance (HomePage)
    widget.onCollectSalary(amount);

    // 2. Update local status
    setState(() {
      _jobs[index]['lastCollected'] = DateTime.now().toString().split(' ')[0]; // Today's date
    });

    // 3. Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added \$$amount to your Main Balance!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Salaries'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle, color: primaryDark),
            onPressed: _showAddJobDialog,
          )
        ],
      ),
      body: _jobs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_outline, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  Text('No jobs added yet.', style: TextStyle(color: Colors.grey[500])),
                  Text('Tap + to add a salary source.', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _jobs.length,
              itemBuilder: (context, index) {
                final job = _jobs[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(job['job'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              Text('Payday: ${job['date']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                          Text(
                            '\$${job['amount']}', 
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: primaryDark)
                          ),
                        ],
                      ),
                      const Divider(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Last: ${job['lastCollected']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ElevatedButton.icon(
                            onPressed: () => _collectPay(index),
                            icon: const Icon(Icons.download, size: 16),
                            label: const Text('Collect Pay'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryDark,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}