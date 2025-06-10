import 'package:flutter/material.dart';

Widget buildDropdown(
  String label,
  List<String> options,
  String value,
  void Function(String?) onChanged, {
  required IconData icon,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      // Gunakan lebar proporsional pada layar kecil
      double dropdownWidth = constraints.maxWidth < 400 ? double.infinity : 280;

      return SizedBox(
        width: dropdownWidth,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true, // Supaya item dropdown tidak terpotong
              value: value,
              items: options
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(item, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      );
    },
  );
}
