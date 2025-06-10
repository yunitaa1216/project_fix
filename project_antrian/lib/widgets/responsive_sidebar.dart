import 'package:flutter/material.dart';
import 'sidebar.dart';

class ResponsiveSidebar extends StatelessWidget {
  final Function(String)? onItemSelected;
  final Widget child;

  const ResponsiveSidebar({
    super.key, 
    this.onItemSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF2C2499),
          title: const Text('Antrian Dukcapil'),
        ),
        drawer: Drawer(
          child: Sidebar(onItemSelected: (label) {
            Navigator.pop(context); // Close drawer
            onItemSelected?.call(label);
          }),
        ),
        body: child, // Use the passed child widget
      );
    } else {
      return Scaffold(
        body: Row(
          children: [
            Sidebar(onItemSelected: onItemSelected),
            Expanded(child: child), // Use the passed child widget
          ],
        ),
      );
    }
  }
}