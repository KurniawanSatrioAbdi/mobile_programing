import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Halaman_Utama extends StatefulWidget {
  const Halaman_Utama({super.key});

  @override
  State<Halaman_Utama> createState() => _Halaman_UtamaState();
}

class _Halaman_UtamaState extends State<Halaman_Utama> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _npmController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telpController = TextEditingController();
  final TextEditingController _angkatanController = TextEditingController();
  DateTime? _tanggalLahir;

  final List<String> _prodiList = [
    'Informatika',
    'Mesin',
    'Sipil',
    'Arsitektur',
  ];
  final List<String> _kelasList = ['A', 'B', 'C', 'D', 'E'];

  String? _selectedKelas;
  String? _selectedProdi;
  String _jenisKelamin = 'Pria';
  String? _editingId;

  List<Map<String, dynamic>> _items = [];
  static const String _prefsKey = 'submissions_new_design';

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _npmController.dispose();
    _emailController.dispose();
    _telpController.dispose();
    _angkatanController.dispose();
    super.dispose();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey);
    if (raw != null) {
      setState(() {
        _items = raw.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
      });
    }
  }

  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      _items.map((m) => jsonEncode(m)).toList(),
    );
  }

  String _formatTanggal(String? tanggalStr) {
    if (tanggalStr == null || tanggalStr == '-') return '-';
    try {
      final date = DateTime.parse(tanggalStr);
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();
      return '$day-$month-$year';
    } catch (e) {
      return tanggalStr;
    }
  }

  void _addItem() {
    if (_namaController.text.isEmpty || _npmController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nama dan NPM wajib diisi')));
      return;
    }

    if (_editingId != null) {
      // Mode edit - update data yang ada
      final index = _items.indexWhere((item) => item['id'] == _editingId);
      if (index != -1) {
        setState(() {
          _items[index] = {
            'id': _editingId!,
            'nama': _namaController.text,
            'alamat': _alamatController.text,
            'npm': _npmController.text,
            'email': _emailController.text,
            'telp': _telpController.text,
            'angkatan': _angkatanController.text,
            'kelas': _selectedKelas ?? '-',
            'prodi': _selectedProdi ?? '-',
            'jk': _jenisKelamin,
            'tanggalLahir': _tanggalLahir?.toIso8601String() ?? '-',
            'createdAt': _items[index]['createdAt'],
          };
        });
        _saveAll();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Data berhasil diupdate')));
      }
      _editingId = null;
    } else {
      // Mode tambah baru
      final item = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'nama': _namaController.text,
        'alamat': _alamatController.text,
        'npm': _npmController.text,
        'email': _emailController.text,
        'telp': _telpController.text,
        'angkatan': _angkatanController.text,
        'kelas': _selectedKelas ?? '-',
        'prodi': _selectedProdi ?? '-',
        'jk': _jenisKelamin,
        'tanggalLahir': _tanggalLahir?.toIso8601String() ?? '-',
        'createdAt': DateTime.now().toIso8601String(),
      };

      setState(() => _items.insert(0, item));
      _saveAll();
    }

    _namaController.clear();
    _alamatController.clear();
    _npmController.clear();
    _emailController.clear();
    _telpController.clear();
    _angkatanController.clear();

    setState(() {
      _selectedKelas = null;
      _selectedProdi = null;
      _jenisKelamin = 'Pria';
      _tanggalLahir = null;
    });
  }

  Future<void> _removeItem(int index) async {
    setState(() => _items.removeAt(index));
    await _saveAll();
  }

  void _editItem(Map<String, dynamic> item) {
    setState(() {
      _editingId = item['id'];
      _namaController.text = item['nama'];
      _alamatController.text = item['alamat'];
      _npmController.text = item['npm'];
      _emailController.text = item['email'];
      _telpController.text = item['telp'];
      _angkatanController.text = item['angkatan'] ?? '';
      _selectedKelas = item['kelas'] == '-' ? null : item['kelas'];
      _selectedProdi = item['prodi'] == '-' ? null : item['prodi'];
      _jenisKelamin = item['jk'];
      _tanggalLahir = item['tanggalLahir'] != '-'
          ? DateTime.parse(item['tanggalLahir'])
          : null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Mode edit aktif — ubah data dan tekan Simpan Data"),
      ),
    );
  }

  void _showDetail(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Detail Data'),
        contentPadding: const EdgeInsets.all(20),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Nama: ${item['nama']}"),
              const SizedBox(height: 4),
              Text("NPM: ${item['npm']}"),
              const SizedBox(height: 4),
              Text("Email: ${item['email']}"),
              const SizedBox(height: 4),
              Text("Telepon: ${item['telp']}"),
              const SizedBox(height: 4),
              Text("Alamat: ${item['alamat']}"),
              const SizedBox(height: 4),
              Text("Angkatan: ${item['angkatan'] ?? '-'}"),
              const SizedBox(height: 4),
              Text("Kelas: ${item['kelas']}"),
              const SizedBox(height: 4),
              Text("Prodi: ${item['prodi']}"),
              const SizedBox(height: 4),
              Text("Jenis Kelamin: ${item['jk']}"),
              const SizedBox(height: 4),
              Text("Tanggal Lahir: ${_formatTanggal(item['tanggalLahir'])}"),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _editItem(item);
                      },
                      child: const Text("Edit"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        int index = _items.indexOf(item);
                        _removeItem(index);
                      },
                      child: const Text("Hapus"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Form Data Mahasiswa"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _input(_namaController, "Nama"),
                              const SizedBox(height: 12),
                              _input(_npmController, "NPM"),
                              const SizedBox(height: 12),
                              _input(_emailController, "Email"),
                              const SizedBox(height: 12),
                              _input(_telpController, "Nomor Telepon"),
                              const SizedBox(height: 12),
                              _input(_alamatController, "Alamat"),
                              const SizedBox(height: 12),
                              _input(_angkatanController, "Angkatan"),
                              const SizedBox(height: 12),

                              DropdownButtonFormField(
                                decoration: _decor("Kelas"),
                                isExpanded: true,
                                value: _selectedKelas,
                                items: _kelasList
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedKelas = v),
                              ),
                              const SizedBox(height: 12),

                              DropdownButtonFormField(
                                decoration: _decor("Prodi"),
                                isExpanded: true,
                                value: _selectedProdi,
                                items: _prodiList
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedProdi = v),
                              ),
                              const SizedBox(height: 12),

                              GestureDetector(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime(2000),
                                    firstDate: DateTime(1980),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null) {
                                    setState(() => _tanggalLahir = picked);
                                  }
                                },
                                child: AbsorbPointer(
                                  child: TextField(
                                    decoration: _decor("Tanggal Lahir")
                                        .copyWith(
                                          suffixIcon: const Icon(
                                            Icons.calendar_today,
                                          ),
                                        ),
                                    controller: TextEditingController(
                                      text: _tanggalLahir == null
                                          ? ''
                                          : _formatTanggal(
                                              _tanggalLahir!.toIso8601String(),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Jenis Kelamin:"),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Radio(
                                        value: "Pria",
                                        groupValue: _jenisKelamin,
                                        onChanged: (v) =>
                                            setState(() => _jenisKelamin = v!),
                                      ),
                                      const Text("Pria"),
                                      const SizedBox(width: 16),
                                      Radio(
                                        value: "Wanita",
                                        groupValue: _jenisKelamin,
                                        onChanged: (v) =>
                                            setState(() => _jenisKelamin = v!),
                                      ),
                                      const Text("Wanita"),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(
                              colors: [Colors.blue, Colors.lightBlueAccent],
                            ),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _addItem,
                            child: Text(
                              _editingId != null
                                  ? "Update Data"
                                  : "Simpan Data",
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),

                      _items.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text("Belum ada data"),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _items.length,
                              itemBuilder: (context, index) {
                                final item = _items[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      item['nama'],
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      "${item['email']} • ${item['prodi']}",
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: Text(item['kelas']),
                                    onTap: () => _showDetail(item),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decor(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );

  Widget _input(TextEditingController c, String label) =>
      TextField(controller: c, decoration: _decor(label));
}
