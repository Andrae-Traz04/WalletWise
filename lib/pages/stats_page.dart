import 'package:flutter/material.dart';

class StatsPage extends StatelessWidget {
  final double monthlyIncome;
  final List<Map<String, dynamic>> transactions;

  const StatsPage({
    super.key,
    required this.monthlyIncome,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4CAF50);

    // Calculate Totals
    double totalExpenses = 0.0;
    for (var tx in transactions) {
      totalExpenses += tx['amount'];
    }

    double spendingPercentage = monthlyIncome == 0 ? 0 : (totalExpenses / monthlyIncome);
    if (spendingPercentage > 1.0) spendingPercentage = 1.0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Financial Health', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // --- GRAPH CARD ---
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
              ),
              child: Column(
                children: [
                  const Text('Budget Utilization', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Text(
                    '${(spendingPercentage * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 40, 
                      fontWeight: FontWeight.bold, 
                      color: spendingPercentage > 0.8 ? Colors.red : primaryColor
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // The Bar Graph
                  Stack(
                    children: [
                      Container(height: 30, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15))),
                      FractionallySizedBox(
                        widthFactor: spendingPercentage,
                        child: Container(height: 30, decoration: BoxDecoration(color: spendingPercentage > 0.8 ? Colors.red : primaryColor, borderRadius: BorderRadius.circular(15))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Spent', style: TextStyle(color: Colors.grey)),
                          Text('\$${totalExpenses.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Total Income', style: TextStyle(color: Colors.grey)),
                          Text('\$${monthlyIncome.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
