import 'package:flutter/material.dart';

class CategoryWidget extends StatelessWidget {
  final String? type;

  const CategoryWidget({Key? key, this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, Map<String, dynamic>> categoryMap = {
      'food': {
        'color': Colors.red.shade100,
        'icon': Icons.fastfood,
        'iconColor': Colors.red,
      },
      'transportation': {
        'color': Colors.blue.shade100,
        'icon': Icons.directions_car,
        'iconColor': Colors.blue,
      },
      'shopping': {
        'color': Colors.purple.shade100,
        'icon': Icons.shopping_bag,
        'iconColor': Colors.purple,
      },
      'bill': {
        'color': Colors.orange.shade100,
        'icon': Icons.receipt,
        'iconColor': Colors.orange,
      },
      'entertainment': {
        'color': Colors.green.shade100,
        'icon': Icons.movie,
        'iconColor': Colors.green,
      },
      'others': {
        'color': Colors.grey.shade300,
        'icon': Icons.more_horiz,
        'iconColor': Colors.grey,
      },
    };

    final data = categoryMap[type?.toLowerCase() ?? ''];

    if (data == null) {
      return const CircleAvatar(
        backgroundColor: Colors.grey,
        child: Icon(Icons.help_outline, color: Colors.white),
      );
    }

    return CircleAvatar(
      backgroundColor: data['color'],
      child: Icon(data['icon'], color: data['iconColor']),
    );
  }
}
