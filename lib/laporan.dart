import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HalamanLaporan extends StatefulWidget {
  const HalamanLaporan({super.key});

  @override
  State<HalamanLaporan> createState() => _HalamanLaporanState();
}

class _HalamanLaporanState extends State<HalamanLaporan> {
  List<Map<String, dynamic>> _orders = [];
  static const String _prefsKey = 'laundry_orders_data';

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _showAllTime = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
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

  List<Map<String, dynamic>> _getFilteredOrders() {
    if (_showAllTime) {
      return _orders;
    }

    return _orders.where((order) {
      try {
        final createdAt = DateTime.parse(order['createdAt']);
        return createdAt.month == _selectedMonth &&
            createdAt.year == _selectedYear;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  int _hitungTotalOrder(List<Map<String, dynamic>> orders) => orders.length;

  int _hitungTotalPendapatan(List<Map<String, dynamic>> orders) {
    int total = 0;
    for (var order in orders) {
      total += int.parse(
        order['harga'].toString().replaceAll(RegExp(r'[^0-9]'), ''),
      );
    }
    return total;
  }

  int _hitungOrderSelesai(List<Map<String, dynamic>> orders) {
    return orders
        .where((order) =>
            order['status'] == 'Selesai' || order['status'] == 'Diambil')
        .length;
  }

  int _hitungOrderProses(List<Map<String, dynamic>> orders) {
    return orders
        .where((order) =>
            order['status'] != 'Selesai' && order['status'] != 'Diambil')
        .length;
  }

  int _hitungSudahBayar(List<Map<String, dynamic>> orders) {
    return orders
        .where((order) =>
            (order['statusPembayaran'] ?? 'Belum Bayar') == 'Sudah Bayar')
        .length;
  }

  int _hitungBelumBayar(List<Map<String, dynamic>> orders) {
    return orders
        .where((order) =>
            (order['statusPembayaran'] ?? 'Belum Bayar') == 'Belum Bayar')
        .length;
  }

  List<Map<String, dynamic>> _getOrderBelumBayar(
      List<Map<String, dynamic>> orders) {
    return orders
        .where((order) =>
            (order['statusPembayaran'] ?? 'Belum Bayar') == 'Belum Bayar')
        .toList();
  }

  double _hitungTotalBerat(List<Map<String, dynamic>> orders) {
    double total = 0;
    for (var order in orders) {
      try {
        final beratStr = order['berat'].toString().replaceAll(',', '.');
        total += double.parse(beratStr);
      } catch (e) {
        // Skip error
      }
    }
    return total;
  }

  Map<String, int> _hitungPerJenis(List<Map<String, dynamic>> orders) {
    Map<String, int> jenis = {};
    for (var order in orders) {
      String jenisLaundry = order['jenis'];
      if (jenis.containsKey(jenisLaundry)) {
        jenis[jenisLaundry] = jenis[jenisLaundry]! + 1;
      } else {
        jenis[jenisLaundry] = 1;
      }
    }
    return jenis;
  }

  String _formatRupiah(int angka) {
    return 'Rp ${angka.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String _getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return months[month - 1];
  }

  void _showMonthYearPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        int tempMonth = _selectedMonth;
        int tempYear = _selectedYear;

        return StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pilih Periode',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            labelText: "Bulan",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          value: tempMonth,
                          items: List.generate(12, (index) {
                            return DropdownMenuItem(
                                value: index + 1,
                                child: Text(_getMonthName(index + 1)));
                          }),
                          onChanged: (value) {
                            setModalState(() => tempMonth = value!);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            labelText: "Tahun",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          value: tempYear,
                          items: List.generate(5, (index) {
                            final year = DateTime.now().year - 2 + index;
                            return DropdownMenuItem(
                                value: year, child: Text(year.toString()));
                          }),
                          onChanged: (value) {
                            setModalState(() => tempYear = value!);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedMonth = tempMonth;
                          _selectedYear = tempYear;
                          _showAllTime = false;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Terapkan',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _getFilteredOrders();
    final totalOrder = _hitungTotalOrder(filteredOrders);
    final totalPendapatan = _hitungTotalPendapatan(filteredOrders);
    final orderSelesai = _hitungOrderSelesai(filteredOrders);
    final orderProses = _hitungOrderProses(filteredOrders);
    final sudahBayar = _hitungSudahBayar(filteredOrders);
    final belumBayar = _hitungBelumBayar(filteredOrders);
    final totalBerat = _hitungTotalBerat(filteredOrders);
    final perJenis = _hitungPerJenis(filteredOrders);
    final orderBelumBayar = _getOrderBelumBayar(filteredOrders);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan",
            style: TextStyle(fontWeight: FontWeight.bold)),
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
      body: SafeArea(
        child: Stack(
          children: [
            _orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assessment_outlined,
                            size: 100, color: Colors.grey[300]),
                        const SizedBox(height: 20),
                        Text('Belum ada data laporan',
                            style: TextStyle(
                                fontSize: 20, color: Colors.grey[600])),
                        const SizedBox(height: 10),
                        Text('Tambahkan orderan terlebih dahulu',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[400])),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Ringkasan Laundry",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: _showMonthYearPicker,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1976D2)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFF1976D2),
                                        width: 1.5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.calendar_month,
                                          color: Color(0xFF1976D2)),
                                      const SizedBox(width: 8),
                                      Text(
                                        _showAllTime
                                            ? 'Semua Waktu'
                                            : '${_getMonthName(_selectedMonth)} $_selectedYear',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1976D2)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _showAllTime = !_showAllTime;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _showAllTime
                                      ? const Color(0xFF1976D2)
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.all_inclusive,
                                    color: _showAllTime
                                        ? Colors.white
                                        : Colors.grey[600]),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.3,
                          children: [
                            _buildStatCard("Total Order", "$totalOrder",
                                Icons.receipt_long, Colors.blue),
                            _buildStatCard(
                                "Pendapatan",
                                _formatRupiah(totalPendapatan),
                                Icons.currency_exchange,
                                Colors.green),
                            _buildStatCard("Order Selesai", "$orderSelesai",
                                Icons.check_circle, Colors.purple),
                            _buildStatCard("Diproses", "$orderProses",
                                Icons.hourglass_empty, Colors.orange),
                            _buildStatCard("Sudah Bayar", "$sudahBayar",
                                Icons.check_circle, Colors.green),
                            _buildStatCard("Belum Bayar", "$belumBayar",
                                Icons.pending, Colors.red),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                            "Total Berat Cucian",
                            "${totalBerat.toStringAsFixed(1)} Kg",
                            Icons.scale,
                            Colors.teal),
                        const SizedBox(height: 24),
                        const Text("Distribusi per Jenis",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        perJenis.isEmpty
                            ? Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Center(
                                      child: Text(
                                          "Belum ada data jenis laundry",
                                          style: TextStyle(
                                              color: Colors.grey[600]))),
                                ),
                              )
                            : Column(
                                children: perJenis.entries.map((entry) {
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: const Color(0xFF1976D2)
                                            .withOpacity(0.1),
                                        child: const Icon(
                                            Icons.local_laundry_service,
                                            color: Color(0xFF1976D2)),
                                      ),
                                      title: Text(entry.key,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1976D2),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text("${entry.value} order",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Belum Bayar",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text("$belumBayar Order",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        orderBelumBayar.isEmpty
                            ? Card(
                                color: Colors.green[50],
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle,
                                          color: Colors.green[700], size: 40),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("Semua Sudah Bayar! 🎉",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green[700])),
                                            const SizedBox(height: 4),
                                            Text(
                                                "Tidak ada orderan yang belum dibayar",
                                                style: TextStyle(
                                                    color: Colors.grey[600])),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Column(
                                children: orderBelumBayar.map((order) {
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                          color: Colors.red[200]!, width: 1),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.red[100],
                                        child: Icon(Icons.person,
                                            color: Colors.red[700]),
                                      ),
                                      title: Text(order['namaPelanggan'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text('No. ${order['noOrder']}'),
                                          Text(
                                              '${order['jenis']} - ${order['berat']} Kg'),
                                        ],
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            _formatRupiah(int.parse(
                                                order['harga']
                                                    .toString()
                                                    .replaceAll(
                                                        RegExp(r'[^0-9]'),
                                                        ''))),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red[700],
                                                fontSize: 14),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: const Text("BELUM BAYAR",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 9,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                      ],
                    ),
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
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(title,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: color),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text(value,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
