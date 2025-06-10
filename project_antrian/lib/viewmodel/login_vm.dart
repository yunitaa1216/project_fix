// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// void _handleLogin() async {
//   final username = _usernameController.text.trim();
//   final password = _passwordController.text.trim();

//   if (username.isEmpty || password.isEmpty) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: const [
//             Icon(Icons.info_outline, color: Colors.white),
//             SizedBox(width: 10),
//             Expanded(child: Text('Harap isi username dan password!')),
//           ],
//         ),
//         backgroundColor: const Color(0xFF292794),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//         duration: const Duration(seconds: 3),
//       ),
//     );
//     return;
//   }

//   setState(() {
//     _isLoggingIn = true;
//   });

//   try {
//     final response = await http.post(
//       Uri.parse('http://localhost:3000/api/login'), // ganti sesuai alamat server kamu
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'username': username,
//         'password': password,
//       }),
//     );

//     final jsonResponse = jsonDecode(response.body);

//     if (response.statusCode == 200 && jsonResponse['token'] != null) {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('token', jsonResponse['token']);
//       await prefs.setString('username', jsonResponse['dataForClient']['username']);
//       await prefs.setString('userId', jsonResponse['dataForClient']['userId']);

//       // animasi morph dan redirect
//       _morphController.forward();
//       Future.delayed(const Duration(milliseconds: 900), () {
//         if (mounted) {
//           Navigator.pushReplacementNamed(context, '/beranda');
//         }
//       });
//     } else {
//       throw Exception(jsonResponse['message'] ?? 'Login gagal');
//     }
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.error_outline, color: Colors.white),
//             const SizedBox(width: 10),
//             Expanded(child: Text('Login gagal: $e')),
//           ],
//         ),
//         backgroundColor: Colors.red,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//         duration: const Duration(seconds: 4),
//       ),
//     );
//     setState(() => _isLoggingIn = false);
//   }
// }
