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
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFF472B6),size:18),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
            },
          ),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFF472B6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}