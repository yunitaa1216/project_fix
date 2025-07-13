import 'package:flutter/material.dart';
import 'sidebar_item.dart';

class Sidebar extends StatelessWidget {
  final Function(String)? onItemSelected;

  const Sidebar({super.key, this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: double.infinity,
      color: const Color(0xFF2C2499),
      child: SingleChildScrollView( // Add this to make content scrollable
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Image.asset(
                  'assets/images/logo_project.png',
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 30),
            SidebarItem(
              icon: Icons.home,
              label: 'Beranda',
              onTap: () => onItemSelected?.call('Beranda'),
            ),
            SidebarItem(
              icon: Icons.edit_note,
              label: 'Input Antrian',
              onTap: () => onItemSelected?.call('Input Antrian'),
            ),
            SidebarItem(
  icon: Icons.list_alt,
  label: 'Daftar Antrian',
  onTap: () {
    Navigator.of(context).pushNamed('/antriannew');
  },
),
            SidebarItem(
              icon: Icons.history,
              label: 'Riwayat',
              onTap: () => onItemSelected?.call('Riwayat'),
            ),
            const SizedBox(height: 20), // Reduced space before logout
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: SidebarItem(
                icon: Icons.logout,
                label: 'Logout',
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFE8EAF6),
                                  ),
                                  child: const Icon(
                                    Icons.logout_rounded,
                                    size: 40,
                                    color: Color(0xFF2C2499),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Keluar dari Sistem?',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2C2499),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Anda akan keluar dari akun dan kembali ke login.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.grey[600],
                                      ),
                                      child: const Text('Batal'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          '/',
                                          (route) => false,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2C2499),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text('Ya, Logout'),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}