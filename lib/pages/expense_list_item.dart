import 'package:flutter/material.dart';
import 'package:my_finance_mobile/pages/expenses/category_widget.dart';

class ExpenseListItem extends StatelessWidget {
  final int id;
  final String type;
  final String categoryName;
  final String date;
  final String description;
  final double amount;

  const ExpenseListItem({
    Key? key,
    required this.id,
    required this.type,
    required this.categoryName,
    required this.date,
    required this.description,
    required this.amount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CategoryWidget(type: type),
      title: Text(
        description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(date),
      trailing: Text(
        "RM ${amount.toStringAsFixed(2)}",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          '/show-expense',
          arguments: {
            'id': id,
            'type': type,
            'date': date,
            'description': description,
            'category': categoryName,
            'amount': amount,
          },
        );
      },
    );
  }
}
