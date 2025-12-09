import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      toolbarHeight: 60,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment(0.5, 0),
                end: Alignment(0.5, 1),
                colors: [const Color(0xFF1E90FF), const Color(0xFF0066CC)]
            )
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            child: const Icon(
              Icons.shield_outlined,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'SafeTrek',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
              Text(
                'Giữ bạn an toàn trên mọi hành trình',
                style: TextStyle(
                  color: Color(0xFFDAEAFE),
                  fontSize: 11,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w400,
                  height: 1.25,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
