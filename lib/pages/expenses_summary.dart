import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_finance_mobile/constants.dart';
import 'package:my_finance_mobile/pages/expenses/category_widget.dart';
import 'package:my_finance_mobile/pages/expenses/empty_state_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:month_year_picker/month_year_picker.dart';
import 'package:intl/intl.dart';

class ExpensesSummary extends StatefulWidget {
  const ExpensesSummary({super.key});

  @override
  State<StatefulWidget> createState() => ExpensesSummaryState();
}

class ExpensesSummaryState extends State {
  DateTime selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    Future<List<dynamic>> fetchExpensesSummary() async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.get(
        Uri.parse('$baseUrl/api/expenses/summary/${DateFormat('yyyyMM').format(selectedDate)}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load expenses');
      }
    }

    void pickMonthYear() async {
      final DateTime? picked = await showMonthYearPicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );

      if (picked != null) {
        selectedDate = picked;

        setState(() {
          fetchExpensesSummary();
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton.icon(
              onPressed: pickMonthYear,
              icon: const Icon(
                Icons.calendar_today,
                size: 18,
                color: Colors.white,
              ),
              label: Text(
                DateFormat.yMMMM().format(selectedDate),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchExpensesSummary(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final expenses = snapshot.data ?? [];

          if (expenses.isEmpty) {
            return const EmptyStateWidget();
          }

          double totalAmount = expenses.fold(0.0, (sum, item) {
            final amount = double.tryParse(item['total_amount'].toString()) ?? 0.0;
            return sum + amount;
          });

          return Column(
            children: [
              AspectRatio(
                aspectRatio: 1.3,
                child: AspectRatio(
                  aspectRatio: 1.5,
                  child: PieChart(
                    PieChartData(
                      borderData: FlBorderData(
                        show: false,
                      ),
                      sectionsSpace: 2,
                      centerSpaceRadius: 0,
                      sections: showingSections(expenses, totalAmount),
                    ),
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Category Breakdown',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ...expenses.map((expense) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(expense['category']['name']),
                            Text("RM${double.tryParse(expense['total_amount'].toString())?.toStringAsFixed(2) ?? 0.00}"),
                          ],
                        );
                      }).toList(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "RM${double.tryParse(totalAmount.toString())?.toStringAsFixed(2) ?? 0.00}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Column(
              //   children: [
              //     // Pie chart here

              //     const SizedBox(height: 20),

              //     Padding(
              //       padding: const EdgeInsets.all(16.0),
              //       child: Container(
              //         padding: const EdgeInsets.all(12),
              //         decoration: BoxDecoration(
              //           color: Colors.white,
              //           borderRadius: BorderRadius.circular(12),
              //           boxShadow: [BoxShadow(blurRadius: 4, color: Colors.grey.shade300)],
              //         ),
              //         child: const Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Text("Total Spent", style: TextStyle(fontWeight: FontWeight.bold)),
              //             Text("RM 179.00", style: TextStyle(fontSize: 18, color: Colors.black87)),
              //             SizedBox(height: 8),
              //             Text("Top Category: Food & Dining", style: TextStyle(color: Colors.red)),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ],
              // )
            ],
          );
        },
      ),
    );
  }

  List<PieChartSectionData> showingSections(expenses, totalAmount) {
    return List.generate(expenses.length, (i) {
      const fontSize = 16.0;
      const radius = 100.0;
      const widgetSize = 40.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      switch (i) {
        default:
          return PieChartSectionData(
            color: getCategoryColor(expenses[i]['category']['type']),
            value: double.tryParse(expenses[i]['total_amount'].toString()) ?? 0.0 / totalAmount * 100,
            title: "RM${expenses[i]['total_amount']}",
            radius: radius,
            titleStyle: const TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Color(0xffffffff),
              shadows: shadows,
            ),
            badgeWidget: _Badge(
              size: widgetSize,
              type: expenses[i]['category']['type'],
              borderColor: Colors.black,
            ),
            badgePositionPercentageOffset: .98,
          );
      }
    });
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.size,
    required this.type,
    required this.borderColor,
  });
  final double size;
  final String type;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        // color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      // padding: EdgeInsets.all(size * .15),
      child: CategoryWidget(
        type: type,
      ),
    );
  }
}

Color getCategoryColor(String type) {
  switch (type.toLowerCase()) {
    case 'food':
      return Colors.red;
    case 'transportation':
      return Colors.blue;
    case 'shopping':
      return Colors.purple;
    case 'bill':
      return Colors.orange;
    case 'entertainment':
      return Colors.green;
    case 'others':
      return Colors.grey;
    default:
      return Colors.grey;
  }
}
