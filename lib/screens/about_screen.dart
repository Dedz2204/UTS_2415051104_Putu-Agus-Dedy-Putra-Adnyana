import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/responsive_layout.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  static const String _nameKey = 'expense_task_profile_name';
  static const String _photoKey = 'expense_task_profile_photo';

  final ImagePicker _imagePicker = ImagePicker();

  String _profileName = 'Pengguna ExpenseTask';
  String? _photoPath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final preferences = await SharedPreferences.getInstance();

      if (!mounted) return;

      setState(() {
        _profileName =
            preferences.getString(_nameKey) ?? 'Pengguna ExpenseTask';
        _photoPath = preferences.getString(_photoKey);
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _editProfileName() async {
    final controller = TextEditingController(text: _profileName);

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ubah Nama Profil'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Nama',
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
              final value = controller.text.trim();

              if (value.isNotEmpty) {
                Navigator.pop(dialogContext, value);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (newName == null || !mounted) return;

    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_nameKey, newName);

      if (!mounted) return;

      setState(() {
        _profileName = newName;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama profil berhasil diperbarui.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan nama: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _changeProfilePhoto() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (image == null || !mounted) return;

      final directory = await getApplicationDocumentsDirectory();
      final extension =
          image.path.contains('.') ? image.path.split('.').last : 'jpg';

      final savedFile = await File(image.path).copy(
        '${directory.path}/expense_task_profile.$extension',
      );

      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_photoKey, savedFile.path);

      if (!mounted) return;

      setState(() {
        _photoPath = savedFile.path;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto profil berhasil diperbarui.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih foto: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  bool get _hasProfilePhoto {
    final path = _photoPath;

    return path != null && File(path).existsSync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFFF5F7FB),
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveLayout(
              maxContentWidth: 850,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  // Informasi profil pengguna.
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundColor: const Color(0xFFEFF6FF),
                          backgroundImage: _hasProfilePhoto
                              ? FileImage(File(_photoPath!))
                              : null,
                          child: !_hasProfilePhoto
                              ? const Icon(
                                  Icons.person_outline_rounded,
                                  size: 46,
                                  color: Color(0xFF2563EB),
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _profileName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Profil Pengguna',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _editProfileName,
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Ubah Nama'),
                            ),
                            OutlinedButton.icon(
                              onPressed: _changeProfilePhoto,
                              icon: const Icon(
                                Icons.photo_camera_outlined,
                              ),
                              label: const Text('Ubah Foto'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Informasi aplikasi tanpa logo.
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ExpenseTask',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Aplikasi pencatatan dan pengingat tagihan '
                          'untuk membantu mengelola jadwal pembayaran.',
                          style: TextStyle(
                            color: Colors.white,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Fitur Aplikasi',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const _FeatureTile(
                    icon: Icons.receipt_long_outlined,
                    title: 'Kelola Tagihan',
                    description:
                        'Catat, lihat, ubah, dan hapus data tagihan.',
                  ),
                  const _FeatureTile(
                    icon: Icons.notifications_active_outlined,
                    title: 'Pantau Jatuh Tempo',
                    description:
                        'Periksa tanggal jatuh tempo agar pembayaran '
                        'lebih teratur.',
                  ),
                  const _FeatureTile(
                    icon: Icons.history_rounded,
                    title: 'Riwayat Pembayaran',
                    description:
                        'Lihat tagihan yang telah ditandai lunas '
                        'dan total pembayarannya.',
                  ),
                  const _FeatureTile(
                    icon: Icons.devices_outlined,
                    title: 'Tampilan Responsif',
                    description:
                        'Antarmuka menyesuaikan ukuran layar perangkat.',
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'ExpenseTask',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Versi 1.0.0',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Dikembangkan sebagai proyek UTS.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFF2563EB),
            size: 26,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}