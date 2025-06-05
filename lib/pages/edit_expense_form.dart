import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:my_finance_mobile/constants.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditExpenseForm extends StatefulWidget {
  final Map<String, dynamic> expense;

  const EditExpenseForm({required this.expense, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditExpenseFormState();
}

class _EditExpenseFormState extends State<EditExpenseForm> {
  late TextEditingController amountController = TextEditingController();
  late TextEditingController descriptionController = TextEditingController();
  late TextEditingController dateController = TextEditingController();

  String? category;
  String? amountError;
  String? categoryError;
  String? dateError;
  String? descriptionError;

  @override
  void initState() {
    super.initState();

    descriptionController = TextEditingController(text: widget.expense['description']);
    amountController = TextEditingController(text: widget.expense['amount'].toString());
    dateController = TextEditingController(text: widget.expense['date']);
    category = widget.expense['category'];
  }

  @override
  Widget build(BuildContext context) {
    Future<List<dynamic>> fetchCategories() async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.get(
        Uri.parse('$baseUrl/api/categories'), // or use your IP
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load categories');
      }
    }

    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (picked != null) {
        setState(() {
          dateController.text = picked.toIso8601String().split('T')[0]; // YYYY-MM-DD
        });
      }
    }

    updateExpense(BuildContext context) async {
      EasyLoading.show();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final itemId = widget.expense['id'];
      final response = await http.put(
        Uri.parse('$baseUrl/api/expenses/$itemId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': "Bearer $token",
        },
        body: jsonEncode({
          'category': category,
          'description': descriptionController.text,
          'amount': amountController.text,
          'expense_date': dateController.text,
        }),
      );

      if (response.statusCode == 200) {
        EasyLoading.dismiss();
        Fluttertoast.showToast(
          msg: "Success",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red.shade600,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        EasyLoading.dismiss();
        final error = json.decode(response.body);

        if (error['errors'] != null) {
          final errors = error['errors'];

          setState(() {
            dateError = errors['expense_date']?.first;
            descriptionError = errors['description']?.first;
            amountError = errors['amount']?.first;
            categoryError = errors['category']?.first;
          });
        }
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Update Expense'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: FutureBuilder<List<dynamic>>(
            future: fetchCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final categories = snapshot.data ?? [];

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: category,
                      items: categories.map<DropdownMenuItem<String>>((category) {
                        return DropdownMenuItem<String>(
                          value: category['type'],
                          child: Text(category['name']),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => category = value),
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        errorText: descriptionError,
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: dateController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      decoration: InputDecoration(
                        labelText: 'Date',
                        errorText: dateError,
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixText: "RM ",
                        labelText: 'Amount',
                        errorText: amountError,
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        updateExpense(context);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
