import 'package:flutter/material.dart';

class SecondaryHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const SecondaryHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      toolbarHeight: 60,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF1976D2),
                    Color(0xFF42A5F5)
                  ]
              )
          ),
      ),
      leading: IconButton(
          onPressed: () {
            if(Navigator.canPop(context)){
              Navigator.pop(context);
            }
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFFFAFAFA),
            size: 20,

          ),
      ),
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFFAFAFA),
          fontSize: 18,
          fontFamily: 'Arimo',
          fontWeight: FontWeight.bold ,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
