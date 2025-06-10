import 'package:flutter/material.dart';

class AntrianForm extends StatefulWidget {
  final TextEditingController namaController;
  final TextEditingController nikController;
  final TextEditingController alamatController;
  final TextEditingController nomorHpController;
  final String selectedLayanan;
  final String selectedKategori;
  final Function(String?) onLayananChanged;
  final Function(String?) onKategoriChanged;
  final VoidCallback onTambahPressed;

  final FocusNode namaFocus;
  final FocusNode nikFocus;
  final FocusNode alamatFocus;
  final FocusNode nomorHpFocus;

  AntrianForm({
    required this.namaController,
    required this.nikController,
    required this.alamatController,
    required this.nomorHpController,
    required this.selectedLayanan,
    required this.selectedKategori,
    required this.onLayananChanged,
    required this.onKategoriChanged,
    required this.onTambahPressed,
    required this.namaFocus,
    required this.nikFocus,
    required this.alamatFocus,
    required this.nomorHpFocus,
  });

  @override
  State<AntrianForm> createState() => _AntrianFormState();
}

class _AntrianFormState extends State<AntrianForm> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  final Map<String, String> layananMap = {
    'Pembuatan KTP': 'pembuatan ktp',
    'Pembuatan Kartu Keluarga': 'pembuatan kartu keluarga',
    'Akta Kelahiran': 'akta kelahiran',
    'Akta Kematian': 'akta kematian',
    'Layanan Lainnya': 'layanan lainnya',
  };

  final Map<String, String> kategoriMap = {
    'Umum': 'umum',
    'Prioritas': 'prioritas',
  };

  void handleSubmit() {
  setState(() {
    _autovalidateMode = AutovalidateMode.always;
  });
  
  if (_formKey.currentState!.validate()) {
    widget.onTambahPressed();
  }
}

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GridView.count(
                crossAxisCount: isWide ? 2 : 1,
                crossAxisSpacing: 5.0,
                mainAxisSpacing: 5.0,
                shrinkWrap: true,
                childAspectRatio: 6,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildTextField(
                    'Nama Lengkap',
                    widget.namaController,
                    hint: 'Masukkan nama sesuai KTP',
                    icon: Icons.person,
                    focusNode: widget.namaFocus,
                    nextFocus: widget.nikFocus,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  _buildTextField(
                    'NIK',
                    widget.nikController,
                    hint: 'Nomor Induk Kependudukan',
                    icon: Icons.credit_card,
                    focusNode: widget.nikFocus,
                    nextFocus: widget.alamatFocus,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'NIK wajib diisi';
                      if (val.length != 16) return 'NIK harus 16 digit';
                      return null;
                    },
                  ),
                  _buildTextField(
                    'Alamat',
                    widget.alamatController,
                    hint: 'Alamat sesuai domisili',
                    icon: Icons.home,
                    focusNode: widget.alamatFocus,
                    nextFocus: widget.nomorHpFocus,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Alamat wajib diisi' : null,
                  ),
                  _buildDropdown(
                    'Jenis Layanan',
                    layananMap,
                    widget.selectedLayanan,
                    widget.onLayananChanged,
                    icon: Icons.assignment,
                  ),
                  _buildTextField(
                    'Nomor HP',
                    widget.nomorHpController,
                    hint: 'Contoh: 081234567890',
                    icon: Icons.phone,
                    focusNode: widget.nomorHpFocus,
                    inputAction: TextInputAction.done,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Nomor HP wajib diisi';
                      if (!RegExp(r'^08\d{8,11}$').hasMatch(val))
                        return 'Format nomor tidak valid';
                      return null;
                    },
                  ),
                  _buildDropdown(
                    'Kategori Antrian',
                    kategoriMap,
                    widget.selectedKategori,
                    widget.onKategoriChanged,
                    icon: Icons.group,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: handleSubmit,
                  label: Text('Tambah Antrian'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF292794),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding:
                        EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    textStyle: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  icon: Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? hint,
    IconData? icon,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    TextInputAction inputAction = TextInputAction.next,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: inputAction,
        onChanged: (value) {
        if (value.isNotEmpty && _autovalidateMode == AutovalidateMode.always) {
          // Validasi saat typing
          _formKey.currentState!.validate();
        }
      },
        onFieldSubmitted: (_) {
          if (nextFocus != null) {
            FocusScope.of(focusNode.context!).requestFocus(nextFocus);
          } else {
            focusNode.unfocus();
          }
        },
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF292794)),
          hintText: hint,
          errorStyle: TextStyle(color: Color(0xFF292794)),
          hintStyle:
              const TextStyle(color: Color.fromARGB(255, 177, 208, 241)),
          prefixIcon:
              icon != null ? Icon(icon, color: Color(0xFF292794)) : null,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF292794), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF292794)),
            borderRadius: BorderRadius.circular(8),
          ),
          errorBorder: OutlineInputBorder(
    borderSide: const BorderSide(color: Color(0xFF292794)),
    borderRadius: BorderRadius.circular(8),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: const BorderSide(color: Color(0xFF292794), width: 2),
    borderRadius: BorderRadius.circular(8),
  ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        style: const TextStyle(color: Color(0xFF292794)),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    Map<String, String> itemMap,
    String? selectedValue,
    Function(String?) onChanged, {
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF292794)),
          prefixIcon:
              icon != null ? Icon(icon, color: Color(0xFF292794)) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF292794)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF292794)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF292794), width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          filled: false,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue,
            isExpanded: true,
            iconEnabledColor: Color(0xFF292794),
            dropdownColor: Colors.white,
            style: const TextStyle(color: Color(0xFF292794)),
            items: itemMap.entries
                .map((entry) => DropdownMenuItem<String>(
                      value: entry.value,
                      child: Text(entry.key),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
