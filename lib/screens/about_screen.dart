import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  static const Color primaryColor = Color(0xFF2864F0);

  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();

  String _name = '';
  String? _photoPath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _name = prefs.getString('profile_name') ?? '';
      _photoPath = prefs.getString('profile_photo');
      _isLoading = false;
    });
  }

  Future<void> _editName() async {
    _nameController.text = _name;

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ubah Nama'),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          maxLength: 50,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Nama pengguna',
            hintText: 'Masukkan nama kamu',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final value = _nameController.text.trim();

              if (value.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Nama tidak boleh kosong.')),
                );
                return;
              }

              Navigator.pop(dialogContext, value);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (newName == null || newName.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', newName.trim());

    if (!mounted) return;

    setState(() {
      _name = newName.trim();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Nama berhasil diperbarui.')));
  }

  Future<void> _changePhoto() async {
    try {
      final XFile? selected = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1000,
      );

      if (selected == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final extension = selected.path.contains('.')
          ? selected.path.split('.').last
          : 'jpg';

      final savedFile = await File(selected.path).copy(
        '${directory.path}/profile_${DateTime.now().millisecondsSinceEpoch}.$extension',
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_photo', savedFile.path);

      if (!mounted) return;

      setState(() {
        _photoPath = savedFile.path;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil diperbarui.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal memilih foto: $error')));
    }
  }

  Future<void> _removePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile_photo');

    if (_photoPath != null) {
      try {
        final file = File(_photoPath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {
        // Profil tetap bisa diperbarui jika file lama gagal dihapus.
      }
    }

    if (!mounted) return;

    setState(() {
      _photoPath = null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final hasPhoto = _photoPath != null && File(_photoPath!).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tentang',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 54,
                      backgroundColor: Colors.white,
                      backgroundImage: hasPhoto
                          ? FileImage(File(_photoPath!))
                          : null,
                      child: hasPhoto
                          ? null
                          : const Icon(
                              Icons.person,
                              size: 62,
                              color: primaryColor,
                            ),
                    ),
                    Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: 'Ganti foto profil',
                        onPressed: _changePhoto,
                        icon: const Icon(
                          Icons.camera_alt_outlined,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _name.isEmpty ? 'Nama belum diisi' : _name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Pengguna ExpenseTask',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 18),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _editName,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Ubah Nama'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _changePhoto,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Ganti Foto'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                if (hasPhoto) ...[
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: _removePhoto,
                    child: const Text(
                      'Hapus Foto Profil',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Tentang Aplikasi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            color: Colors.white,
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        color: primaryColor,
                        size: 30,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'ExpenseTask',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Aplikasi untuk membantu mengelola tagihan, '
                    'memantau pembayaran, dan melihat riwayat '
                    'tagihan agar lebih teratur.',
                    style: TextStyle(color: Colors.black54, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            color: Colors.white,
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.receipt_long_outlined,
                    color: primaryColor,
                  ),
                  title: Text('Kelola Tagihan'),
                  subtitle: Text('Tambah dan pantau tagihan kamu.'),
                ),
                Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(Icons.history, color: primaryColor),
                  title: Text('Riwayat Pembayaran'),
                  subtitle: Text('Lihat tagihan yang sudah dibayar.'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'ExpenseTask • Versi 1.0.0',
              style: TextStyle(color: Colors.black45),
            ),
          ),
        ],
      ),
    );
  }
}
