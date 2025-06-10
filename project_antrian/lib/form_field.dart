import 'package:flutter/material.dart';

Widget buildTextField(
  String label,
  TextEditingController controller, {
  required String hint,
  required IconData icon,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      double fieldWidth = constraints.maxWidth < 400 ? double.infinity : 280;

      return SizedBox(
        width: fieldWidth,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon),
            labelStyle: TextStyle(color: Colors.grey[700]),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      );
    },
  );
}
