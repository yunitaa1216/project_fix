import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoggingIn = false;
  final FocusNode _passwordFocusNode = FocusNode();

  late AnimationController _morphController;
  late Animation<double> _formFadeAnimation;
  late Animation<double> _panelScaleAnimation;

  @override
  void initState() {
    super.initState();
    _morphController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _formFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _morphController, curve: Curves.easeInOut),
    );
    _panelScaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _morphController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _morphController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text('Harap isi username dan password!')),
            ],
          ),
          backgroundColor: const Color(0xFF292794),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isLoggingIn = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', jsonResponse['token']);
        await prefs.setString('username', jsonResponse['dataForClient']['username']);
        await prefs.setString('userId', jsonResponse['dataForClient']['userId']);

        _morphController.forward();
        Future.delayed(const Duration(milliseconds: 900), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/beranda');
          }
        });
      } else {
        throw Exception(jsonResponse['message'] ?? 'Login gagal');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text('Login gagal: ${e.toString().replaceFirst('Exception: ', '')}')),
            ],
          ),
          backgroundColor: Color(0xFF292794),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          duration: const Duration(seconds: 4),
        ),
      );
      setState(() => _isLoggingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final panelWidth = isMobile ? screenWidth : screenWidth * 0.35;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return isMobile
              ? Column(
                  children: [
                    _buildYellowPanel(panelWidth, isMobile),
                    Expanded(
                      child: FadeTransition(
                        opacity: _formFadeAnimation,
                        child: _buildLoginForm(context, isMobile),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    _buildYellowPanel(panelWidth, isMobile),
                    Expanded(
                      child: FadeTransition(
                        opacity: _formFadeAnimation,
                        child: _buildLoginForm(context, isMobile),
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }

  Widget _buildYellowPanel(double panelWidth, bool isMobile) {
    return AnimatedBuilder(
      animation: _panelScaleAnimation,
      builder: (_, child) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Transform.scale(
            scale: _panelScaleAnimation.value,
            alignment: Alignment.centerLeft,
            child: Container(
              width: panelWidth,
              height: isMobile ? 200 : double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFF44F), Color(0xFF292794)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(120),
                  bottomRight: Radius.circular(120),
                ),
              ),
              child: Center(
                child: AnimatedOpacity(
                  opacity: _isLoggingIn ? 0 : 1,
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logo_project.png',
                        width: isMobile ? 200 : 400,
                        height: isMobile ? 100 : 200,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'DISDUKCAPIL\nSULAWESI TENGAH',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: isMobile ? 18 : 24,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFFF44F),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginForm(BuildContext context, bool isMobile) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
        child: Container(
          width: isMobile ? double.infinity : 500,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          margin: isMobile ? const EdgeInsets.all(16) : null,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Datang!',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF292794),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Masuk ke sistem antrian Disdukcapil Sulteng',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 32),

              _buildTextField(
  controller: _usernameController,
  label: 'Username',
  icon: Icons.person_outline,
  suffix: null,
  textInputAction: TextInputAction.next,
  onSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
),
              const SizedBox(height: 20),

              _buildTextField(
  controller: _passwordController,
  label: 'Password',
  icon: Icons.lock_outline,
  obscure: _obscurePassword,
  suffix: IconButton(
    icon: Icon(
      _obscurePassword ? Icons.visibility : Icons.visibility_off,
    ),
    onPressed: () {
      setState(() => _obscurePassword = !_obscurePassword);
    },
  ),
  focusNode: _passwordFocusNode,
  textInputAction: TextInputAction.done,
  onSubmitted: (_) => _handleLogin(),
),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF292794),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: _isLoggingIn
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('LOGIN'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  bool obscure = false,
  Widget? suffix,
  FocusNode? focusNode,
  TextInputAction? textInputAction,
  void Function(String)? onSubmitted,
}) {
  return TextField(
    controller: controller,
    obscureText: obscure,
    focusNode: focusNode,
    textInputAction: textInputAction,
    onSubmitted: onSubmitted,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF1F3F8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

  // void _handleLogin() {
  //   if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
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
  //   } else {
  //     setState(() {
  //       _isLoggingIn = true;
  //     });
  //     _morphController.forward();
  //     Future.delayed(const Duration(milliseconds: 900), () {
  //       if (mounted) {
  //         Navigator.pushReplacementNamed(context, '/beranda');
  //       }
  //     });
  //   }
  // }
}
