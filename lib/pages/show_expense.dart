import 'package:flutter/material.dart';
import 'package:my_finance_mobile/constants.dart';
import 'package:my_finance_mobile/pages/expenses/category_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ShowExpensePage extends StatelessWidget {
  final Map<String, dynamic> expense;

  const ShowExpensePage({super.key, required this.expense});

  void _confirmDelete(int id, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this expense?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                deleteExpense(id, context); // Call the delete callback
              },
            ),
          ],
        );
      },
    );
  }

  void deleteExpense(int id, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.delete(
      Uri.parse('$baseUrl/api/expenses/$id'), // or use your IP
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        actions: [
          IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/edit-expense',
                  arguments: {
                    'id': expense['id'],
                    'category': expense['type'],
                    'date': expense['date'],
                    'description': expense['description'],
                    'amount': expense['amount'],
                  },
                );
              }),
          IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _confirmDelete(expense['id'], context);
              }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CategoryWidget(type: expense['type']),
                Text("RM ${(expense['amount'] as num).toStringAsFixed(2)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 24),
            buildRow('Description:', expense['description']),
            buildRow('Category:', expense['category']),
            buildRow('Date:', expense['date']),
          ],
        ),
      ),
    );
  }

  Widget buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.red))),
          Expanded(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
