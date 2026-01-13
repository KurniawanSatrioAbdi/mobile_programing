import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latihan/nota.dart';

class Halaman_Utama extends StatefulWidget {
  final VoidCallback? onDataChanged;

  const Halaman_Utama({super.key, this.onDataChanged});

  @override
  State<Halaman_Utama> createState() => _Halaman_UtamaState();
}

class _Halaman_UtamaState extends State<Halaman_Utama> {
  final TextEditingController _noOrderController = TextEditingController();
  final TextEditingController _namaPelangganController =
      TextEditingController();
  final TextEditingController _noTelpController = TextEditingController();
  final TextEditingController _beratController = TextEditingController();
  final TextEditingController _hargaPerKgController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  final List<String> _jenisList = [
    'Cuci Kering',
    'Cuci Setrika',
    'Setrika Saja',
    'Cuci Express',
    'Dry Clean',
  ];

  final List<String> _statusList = [
    'Diproses',
    'Dicuci',
    'Disetrika',
    'Selesai',
    'Diambil',
  ];

  final List<String> _statusPembayaranList = [
    'Belum Bayar',
    'Sudah Bayar',
  ];

  // Map harga otomatis per jenis laundry
  final Map<String, int> _hargaPerJenis = {
    'Cuci Kering': 4000,
    'Cuci Setrika': 7000,
    'Setrika Saja': 5000,
    'Cuci Express': 14000,
    'Dry Clean': 0, // Masih manual input karena harga belum ditentukan
  };

  String? _selectedJenis;
  String _selectedStatus = 'Diproses';
  String _selectedStatusPembayaran = 'Belum Bayar';
  DateTime _tanggalMasuk = DateTime.now();
  DateTime _tanggalSelesai = DateTime.now().add(const Duration(days: 2));

  List<Map<String, dynamic>> _orders = [];
  static const String _prefsKey = 'laundry_orders_data';
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _generateNoOrder();
  }

  @override
  void dispose() {
    _noOrderController.dispose();
    _namaPelangganController.dispose();
    _noTelpController.dispose();
    _beratController.dispose();
    _hargaPerKgController.dispose();
    _hargaController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  void _hitungTotalHarga() {
    final berat = double.tryParse(_beratController.text.trim()) ?? 0;
    final hargaPerKgText = _hargaPerKgController.text.trim();
    final hargaPerKg =
        int.tryParse(hargaPerKgText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final total = (berat * hargaPerKg).toInt();
    _hargaController.text = total.toString();
  }

  void _setHargaOtomatis(String? jenis) {
    if (jenis != null && _hargaPerJenis.containsKey(jenis)) {
      final harga = _hargaPerJenis[jenis]!;
      if (harga > 0) {
        _hargaPerKgController.text = harga.toString();
      } else {
        // Untuk Dry Clean, biarkan kosong agar bisa diisi manual
        _hargaPerKgController.clear();
      }
      _hitungTotalHarga();
    }
  }

  void _generateNoOrder() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final noOrder = 'LND${timestamp.substring(timestamp.length - 6)}';
    _noOrderController.text = noOrder;
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isRefreshing = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey);

    // Delay sedikit untuk memberikan feedback visual
    await Future.delayed(const Duration(milliseconds: 500));

    if (raw != null) {
      setState(() {
        _orders =
            raw.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
      });
    }

    setState(() {
      _isRefreshing = false;
    });

    // Tampilkan snackbar konfirmasi
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data berhasil diperbarui: ${_orders.length} orderan'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      _orders.map((m) => jsonEncode(m)).toList(),
    );

    // Panggil callback untuk refresh halaman lain
    widget.onDataChanged?.call();
  }

  String _formatRupiah(String angka) {
    if (angka.isEmpty || angka == '0') return 'Rp 0';
    try {
      int nilai = int.parse(angka.replaceAll(RegExp(r'[^0-9]'), ''));
      return 'Rp ${nilai.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    } catch (e) {
      return 'Rp 0';
    }
  }

  String _formatTanggal(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _pilihTanggal(BuildContext context, bool isTanggalMasuk) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isTanggalMasuk ? _tanggalMasuk : _tanggalSelesai,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1976D2),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isTanggalMasuk) {
          _tanggalMasuk = picked;
        } else {
          _tanggalSelesai = picked;
        }
      });
    }
  }

  void _showAddDialog() {
    _generateNoOrder();
    _namaPelangganController.clear();
    _noTelpController.clear();
    _beratController.clear();
    _hargaPerKgController.clear();
    _hargaController.clear();
    _catatanController.clear();
    _selectedJenis = null;
    _selectedStatus = 'Diproses';
    _selectedStatusPembayaran = 'Belum Bayar';
    _tanggalMasuk = DateTime.now();
    _tanggalSelesai = DateTime.now().add(const Duration(days: 2));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1976D2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add_circle,
                          color: Color(0xFF1976D2),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Tambah Orderan Baru',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _noOrderController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Nomor Order",
                      prefixIcon: const Icon(Icons.confirmation_number),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _namaPelangganController,
                    decoration: InputDecoration(
                      labelText: "Nama Pelanggan",
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF1976D2),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noTelpController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "No. Telepon",
                      prefixIcon: const Icon(Icons.phone),
                      prefixText: '+62 ',
                      hintText: '8xxxxxxxxxx',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF1976D2),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Jenis Laundry",
                      prefixIcon: const Icon(Icons.local_laundry_service),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF1976D2),
                          width: 2,
                        ),
                      ),
                    ),
                    value: _selectedJenis,
                    items: _jenisList
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) {
                      setDialogState(() {
                        _selectedJenis = v;
                        _setHargaOtomatis(v);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _beratController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: "Berat (Kg)",
                      prefixIcon: const Icon(Icons.scale),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF1976D2),
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        _hitungTotalHarga();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _hargaPerKgController,
                    keyboardType: TextInputType.number,
                    readOnly: _selectedJenis != null &&
                        _selectedJenis != 'Dry Clean' &&
                        _hargaPerJenis[_selectedJenis] != 0,
                    decoration: InputDecoration(
                      labelText: "Harga per Kg",
                      prefixIcon: const Icon(Icons.currency_exchange),
                      prefixText: 'Rp ',
                      filled: _selectedJenis != null &&
                          _selectedJenis != 'Dry Clean' &&
                          _hargaPerJenis[_selectedJenis] != 0,
                      fillColor: _selectedJenis != null &&
                              _selectedJenis != 'Dry Clean' &&
                              _hargaPerJenis[_selectedJenis] != 0
                          ? Colors.grey[100]
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF1976D2),
                          width: 2,
                        ),
                      ),
                      helperText: _selectedJenis != null &&
                              _selectedJenis != 'Dry Clean' &&
                              _hargaPerJenis[_selectedJenis] != 0
                          ? 'Harga otomatis sesuai jenis laundry'
                          : 'Masukkan harga per kg',
                      helperStyle: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        _hitungTotalHarga();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _hargaController,
                    keyboardType: TextInputType.number,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Total Harga",
                      prefixIcon: const Icon(Icons.payments),
                      prefixText: 'Rp ',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      helperText: 'Otomatis terhitung: Berat x Harga per Kg',
                      helperStyle:
                          TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () => _pilihTanggal(context, true).then((_) {
                            setDialogState(() {});
                          }),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  color: Color(0xFF1976D2)),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tanggal Masuk',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    _formatTanggal(_tanggalMasuk),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => _pilihTanggal(context, false).then((_) {
                            setDialogState(() {});
                          }),
                          child: Row(
                            children: [
                              const Icon(Icons.event_available,
                                  color: Color(0xFF1976D2)),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tanggal Selesai',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    _formatTanggal(_tanggalSelesai),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Status",
                      prefixIcon: const Icon(Icons.info),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF1976D2),
                          width: 2,
                        ),
                      ),
                    ),
                    value: _selectedStatus,
                    items: _statusList
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) =>
                        setDialogState(() => _selectedStatus = v!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Status Pembayaran",
                      prefixIcon: const Icon(Icons.payment),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF1976D2),
                          width: 2,
                        ),
                      ),
                    ),
                    value: _selectedStatusPembayaran,
                    items: _statusPembayaranList
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) =>
                        setDialogState(() => _selectedStatusPembayaran = v!),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _catatanController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Catatan (Opsional)",
                      prefixIcon: const Icon(Icons.note),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF1976D2),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            _addOrder();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Simpan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addOrder() {
    if (_namaPelangganController.text.isEmpty ||
        _noTelpController.text.isEmpty ||
        _selectedJenis == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama, No. Telepon, dan Jenis Laundry wajib diisi!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final order = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'noOrder': _noOrderController.text,
      'namaPelanggan': _namaPelangganController.text,
      'noTelp': '+62${_noTelpController.text}',
      'jenis': _selectedJenis!,
      'berat': _beratController.text.isEmpty ? '0' : _beratController.text,
      'hargaPerKg': _hargaPerKgController.text.isEmpty
          ? '0'
          : _hargaPerKgController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      'harga': _hargaController.text.isEmpty
          ? '0'
          : _hargaController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      'tanggalMasuk': _formatTanggal(_tanggalMasuk),
      'tanggalSelesai': _formatTanggal(_tanggalSelesai),
      'status': _selectedStatus,
      'statusPembayaran': _selectedStatusPembayaran,
      'catatan': _catatanController.text,
      'createdAt': DateTime.now().toIso8601String(),
    };

    setState(() {
      _orders.insert(0, order);
    });

    _saveAll();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Orderan berhasil ditambahkan'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _removeOrder(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus orderan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _orders.removeAt(index));
      await _saveAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Orderan berhasil dihapus')),
        );
      }
    }
  }

  void _editOrder(Map<String, dynamic> order, int index) {
    final namaPelanggan = TextEditingController(text: order['namaPelanggan']);
    // Hilangkan +62 dari nomor telepon untuk ditampilkan di field
    String noTelpValue = order['noTelp'];
    if (noTelpValue.startsWith('+62')) {
      noTelpValue = noTelpValue.substring(3);
    }
    final noTelp = TextEditingController(text: noTelpValue);
    final berat = TextEditingController(text: order['berat']);
    final harga = TextEditingController(text: order['harga']);

    String selectedJenis = order['jenis'];
    String selectedStatus = order['status'];
    String selectedStatusPembayaran =
        order['statusPembayaran'] ?? 'Belum Bayar';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Edit Orderan",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: namaPelanggan,
                    decoration: InputDecoration(
                      labelText: "Nama Pelanggan",
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: noTelp,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "No. Telepon",
                      prefixIcon: const Icon(Icons.phone),
                      prefixText: '+62 ',
                      hintText: '8xxxxxxxxxx',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Jenis Laundry",
                      prefixIcon: const Icon(Icons.local_laundry_service),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    value: selectedJenis,
                    items: _jenisList
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => selectedJenis = v!),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: berat,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Berat (Kg)",
                            prefixIcon: const Icon(Icons.scale),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: harga,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Harga",
                            prefixIcon: const Icon(Icons.currency_exchange),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Status",
                      prefixIcon: const Icon(Icons.info),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    value: selectedStatus,
                    items: _statusList
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => selectedStatus = v!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Status Pembayaran",
                      prefixIcon: const Icon(Icons.payment),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    value: selectedStatusPembayaran,
                    items: _statusPembayaranList
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) =>
                        setDialogState(() => selectedStatusPembayaran = v!),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              _orders[index]['namaPelanggan'] =
                                  namaPelanggan.text;
                              _orders[index]['noTelp'] = '+62${noTelp.text}';
                              _orders[index]['jenis'] = selectedJenis;
                              _orders[index]['berat'] = berat.text;
                              _orders[index]['harga'] = harga.text.replaceAll(
                                RegExp(r'[^0-9]'),
                                '',
                              );
                              _orders[index]['status'] = selectedStatus;
                              _orders[index]['statusPembayaran'] =
                                  selectedStatusPembayaran;
                            });

                            await _saveAll();
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Orderan berhasil diupdate'),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Simpan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Diproses':
        return Colors.orange;
      case 'Dicuci':
        return Colors.blue;
      case 'Disetrika':
        return Colors.purple;
      case 'Selesai':
        return Colors.green;
      case 'Diambil':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Diproses':
        return Icons.hourglass_empty;
      case 'Dicuci':
        return Icons.local_laundry_service;
      case 'Disetrika':
        return Icons.iron;
      case 'Selesai':
        return Icons.check_circle;
      case 'Diambil':
        return Icons.done_all;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Beranda",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1976D2),
        elevation: 0,
        actions: [
          _isRefreshing
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF1976D2),
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _isRefreshing ? null : _loadOrders,
                  tooltip: 'Muat ulang data',
                ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1976D2).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Orderan',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_orders.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.local_laundry_service,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // List Orderan
              Expanded(
                child: _orders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 100,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Belum ada orderan",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Tekan tombol + untuk menambah",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          final statusColor = _getStatusColor(order['status']);
                          final statusIcon = _getStatusIcon(order['status']);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(25),
                                    ),
                                  ),
                                  builder: (context) => Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Pilih Aksi',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        ListTile(
                                          leading: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[50],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.receipt_long,
                                              color: Color(0xFF1976D2),
                                            ),
                                          ),
                                          title: const Text('Cetak Nota'),
                                          subtitle: const Text(
                                              'Lihat dan bagikan nota'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    NotaLaundry(order: order),
                                              ),
                                            );
                                          },
                                        ),
                                        const Divider(),
                                        ListTile(
                                          leading: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.orange[50],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.edit,
                                              color: Colors.orange,
                                            ),
                                          ),
                                          title: const Text('Edit Orderan'),
                                          subtitle:
                                              const Text('Ubah data orderan'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _editOrder(order, index);
                                          },
                                        ),
                                        const Divider(),
                                        ListTile(
                                          leading: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.red[50],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                          title: const Text('Hapus Orderan'),
                                          subtitle:
                                              const Text('Hapus orderan ini'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _removeOrder(index);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                order['namaPelanggan'],
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'No. ${order['noOrder']}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: statusColor
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: statusColor,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(statusIcon,
                                                      size: 16,
                                                      color: statusColor),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    order['status'],
                                                    style: TextStyle(
                                                      color: statusColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    (order['statusPembayaran'] ??
                                                                'Belum Bayar') ==
                                                            'Sudah Bayar'
                                                        ? Colors.green
                                                            .withOpacity(0.1)
                                                        : Colors.red
                                                            .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: (order['statusPembayaran'] ??
                                                              'Belum Bayar') ==
                                                          'Sudah Bayar'
                                                      ? Colors.green
                                                      : Colors.red,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    (order['statusPembayaran'] ??
                                                                'Belum Bayar') ==
                                                            'Sudah Bayar'
                                                        ? Icons.check_circle
                                                        : Icons.pending,
                                                    size: 12,
                                                    color: (order['statusPembayaran'] ??
                                                                'Belum Bayar') ==
                                                            'Sudah Bayar'
                                                        ? Colors.green
                                                        : Colors.red,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    order['statusPembayaran'] ??
                                                        'Belum Bayar',
                                                    style: TextStyle(
                                                      color: (order['statusPembayaran'] ??
                                                                  'Belum Bayar') ==
                                                              'Sudah Bayar'
                                                          ? Colors.green
                                                          : Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    const Divider(),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.local_laundry_service,
                                            size: 18, color: Colors.grey[600]),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${order['jenis']} - ${order['berat']} Kg',
                                          style: TextStyle(
                                              color: Colors.grey[700]),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today,
                                                size: 18,
                                                color: Colors.grey[600]),
                                            const SizedBox(width: 8),
                                            Text(
                                              order['tanggalSelesai'],
                                              style: TextStyle(
                                                  color: Colors.grey[700]),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          _formatRupiah(order['harga']),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1976D2),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          // Overlay loading saat refresh
          if (_isRefreshing)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF1976D2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Memuat data...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF1976D2),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah Order',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
