// FILE: pengaturan.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ================== HALAMAN PENGATURAN =====================
class HalamanPengaturan extends StatefulWidget {
  const HalamanPengaturan({super.key});

  @override
  State<HalamanPengaturan> createState() => _HalamanPengaturanState();
}

class _HalamanPengaturanState extends State<HalamanPengaturan> {
  bool _notifikasiOrderBaru = true;
  bool _notifikasiSelesai = true;
  bool _modeGelap = false;
  String _bahasa = 'Indonesia';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pengaturan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1976D2),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              'Notifikasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Notifikasi Order Baru'),
                  subtitle: const Text(
                    'Dapatkan notifikasi saat ada order baru',
                  ),
                  value: _notifikasiOrderBaru,
                  activeColor: const Color(0xFF1976D2),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.notifications_active,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _notifikasiOrderBaru = value;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value
                              ? 'Notifikasi order baru diaktifkan'
                              : 'Notifikasi order baru dinonaktifkan',
                        ),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Notifikasi Order Selesai'),
                  subtitle: const Text('Notifikasi saat laundry selesai'),
                  value: _notifikasiSelesai,
                  activeColor: const Color(0xFF1976D2),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.check_circle, color: Colors.green),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _notifikasiSelesai = value;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value
                              ? 'Notifikasi selesai diaktifkan'
                              : 'Notifikasi selesai dinonaktifkan',
                        ),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              'Tampilan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Mode Gelap'),
                  subtitle: const Text('Aktifkan tema gelap'),
                  value: _modeGelap,
                  activeColor: const Color(0xFF1976D2),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.dark_mode, color: Colors.purple),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _modeGelap = value;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Fitur mode gelap akan datang di versi berikutnya',
                        ),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.language, color: Colors.orange),
                  ),
                  title: const Text('Bahasa'),
                  subtitle: Text(_bahasa),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text('Pilih Bahasa'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RadioListTile<String>(
                              title: const Text('Indonesia'),
                              value: 'Indonesia',
                              groupValue: _bahasa,
                              activeColor: const Color(0xFF1976D2),
                              onChanged: (value) {
                                setState(() {
                                  _bahasa = value!;
                                });
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Bahasa diubah ke Indonesia'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                            RadioListTile<String>(
                              title: const Text('English'),
                              value: 'English',
                              groupValue: _bahasa,
                              activeColor: const Color(0xFF1976D2),
                              onChanged: (value) {
                                setState(() {
                                  _bahasa = value!;
                                });
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Language feature coming soon',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              'Data & Penyimpanan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.backup, color: Colors.blue),
                  ),
                  title: const Text('Backup Data'),
                  subtitle: const Text('Cadangkan data ke penyimpanan'),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Row(
                          children: [
                            Icon(Icons.backup, color: Colors.blue[700]),
                            const SizedBox(width: 12),
                            const Text('Backup Data'),
                          ],
                        ),
                        content: const Text(
                          'Fitur backup akan tersedia di versi premium.\n\nDengan fitur ini, Anda dapat menyimpan semua data orderan ke cloud storage.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.restore, color: Colors.green),
                  ),
                  title: const Text('Restore Data'),
                  subtitle: const Text('Pulihkan data dari backup'),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Row(
                          children: [
                            Icon(Icons.restore, color: Colors.green[700]),
                            const SizedBox(width: 12),
                            const Text('Restore Data'),
                          ],
                        ),
                        content: const Text(
                          'Fitur restore akan tersedia di versi premium.\n\nAnda dapat memulihkan data orderan dari backup yang telah disimpan.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_forever, color: Colors.red),
                  ),
                  title: const Text(
                    'Hapus Semua Data',
                    style: TextStyle(color: Colors.red),
                  ),
                  subtitle: const Text('Menghapus semua data secara permanen'),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.red),
                            const SizedBox(width: 12),
                            const Text('Konfirmasi Hapus'),
                          ],
                        ),
                        content: const Text(
                          'Apakah Anda yakin ingin menghapus SEMUA data?\n\n'
                          '⚠️ Data yang dihapus tidak dapat dikembalikan!',
                        ),
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
                            child: const Text('Hapus Semua'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('laundry_orders_data');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Semua data berhasil dihapus'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ================== HALAMAN BANTUAN =====================
class HalamanBantuan extends StatelessWidget {
  const HalamanBantuan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Bantuan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1976D2),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.help_outline, size: 60, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'Pusat Bantuan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Panduan lengkap penggunaan aplikasi',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              'Panduan Penggunaan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          _buildHelpCard(
            context,
            'Cara Menambah Orderan',
            Icons.add_circle,
            const Color(0xFF1976D2),
            [
              '1. Buka halaman Beranda',
              '2. Tekan tombol "Tambah Order" di pojok kanan bawah',
              '3. Isi semua informasi orderan (nama, no telp, jenis laundry, dll)',
              '4. Pilih tanggal masuk dan selesai',
              '5. Tekan tombol "Simpan"',
            ],
          ),

          _buildHelpCard(
            context,
            'Cara Edit & Hapus Orderan',
            Icons.edit,
            Colors.orange,
            [
              '1. Tap pada card orderan yang ingin diedit/hapus',
              '2. Pilih "Edit Orderan" untuk mengubah data',
              '3. Atau pilih "Hapus Orderan" untuk menghapus',
              '4. Konfirmasi perubahan atau penghapusan',
            ],
          ),

          _buildHelpCard(
            context,
            'Melihat Status Laundry',
            Icons.local_laundry_service,
            Colors.green,
            [
              '1. Buka tab "Status" di bottom navbar',
              '2. Filter orderan berdasarkan status',
              '3. Tap pada orderan untuk melihat detail',
              '4. Gunakan tombol WhatsApp/Telepon untuk konfirmasi',
            ],
          ),

          _buildHelpCard(
            context,
            'Melihat Laporan',
            Icons.assessment,
            Colors.purple,
            [
              '1. Buka tab "Laporan" di bottom navbar',
              '2. Lihat ringkasan total orderan dan pendapatan',
              '3. Cek distribusi orderan per jenis laundry',
              '4. Gunakan tombol refresh untuk update data',
            ],
          ),

          _buildHelpCard(
            context,
            'Hubungi Pelanggan',
            Icons.phone,
            Colors.red,
            [
              '1. Buka detail orderan atau halaman Status',
              '2. Tekan tombol "Telepon" untuk menelepon langsung',
              '3. Atau tekan "WhatsApp" untuk chat via WA',
              '4. Pesan otomatis akan tersedia untuk konfirmasi',
            ],
          ),

          const SizedBox(height: 24),

          // FAQ Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              'FAQ (Pertanyaan Umum)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          _buildFaqCard(
            'Bagaimana cara mengubah status orderan?',
            'Buka detail orderan, pilih Edit, kemudian ubah status di dropdown menu Status.',
          ),

          _buildFaqCard(
            'Data orderan hilang, bagaimana?',
            'Pastikan Anda tidak menghapus data aplikasi. Untuk keamanan, gunakan fitur Backup Data (tersedia di versi premium).',
          ),

          _buildFaqCard(
            'Apakah bisa export data ke Excel?',
            'Fitur export akan tersedia di update berikutnya.',
          ),

          const SizedBox(height: 24),

          // Contact Support
          Card(
            elevation: 3,
            color: const Color(0xFF1976D2).withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 50,
                    color: const Color(0xFF1976D2),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Masih Butuh Bantuan?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hubungi tim support kami melalui\nemail atau WhatsApp',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.contact_support),
                    label: const Text('Hubungi Support'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHelpCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<String> steps,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: steps
                  .map(
                    (step) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle, size: 18, color: color),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              step,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqCard(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.quiz, color: Colors.amber, size: 24),
        ),
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
