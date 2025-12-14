import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    this.title = 'SafeTrek',
    this.subtitle = 'Giữ bạn an toàn trên mọi hành trình',
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      toolbarHeight: 60,
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFF1877F2), // Use solid color to match design
      title: Row(
        children: [
          const Icon(
            Icons.shield_outlined,
            size: 32,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
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
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60 + (bottom?.preferredSize.height ?? 0));
}
