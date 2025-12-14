import 'package:flutter/material.dart';

class SecondaryHeader extends StatelessWidget {
  final String title;

  const SecondaryHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E90FF)),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
            },
          ),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1E90FF),
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: 'Arimo',
            ),
          ),
        ],
      ),
    );
  }
}
