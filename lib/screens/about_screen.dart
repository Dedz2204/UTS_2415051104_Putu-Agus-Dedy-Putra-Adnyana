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

  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF8FAFC);
  static const Color textColor = Color(0xFF0F172A);
  static const Color mutedColor = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

  final ImagePicker _imagePicker = ImagePicker();

  String _profileName = 'Pengguna PayTrack';
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
            preferences.getString(_nameKey) ?? 'Dedy Putra';
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

      setState(() => _profileName = newName);

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

      setState(() => _photoPath = savedFile.path);

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

  Widget _buildCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: background,
        foregroundColor: textColor,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primary),
            )
          : ResponsiveLayout(
              maxContentWidth: 850,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 22),
                  _buildAppIntroduction(),
                  const SizedBox(height: 26),
                  const _SectionTitle(
                    title: 'Fitur Aplikasi',
                    subtitle: 'Kemudahan yang tersedia di PayTrack',
                  ),
                  const SizedBox(height: 14),
                  _buildFeatures(),
                  const SizedBox(height: 26),
                  const _SectionTitle(
                    title: 'Informasi Pengembang',
                    subtitle: 'Identitas pembuat aplikasi',
                  ),
                  const SizedBox(height: 14),
                  _buildDeveloperInfo(),
                  const SizedBox(height: 26),
                  const _SectionTitle(
                    title: 'Teknologi',
                    subtitle: 'Teknologi yang digunakan dalam pengembangan',
                  ),
                  const SizedBox(height: 14),
                  _buildTechnologies(),
                  const SizedBox(height: 22),
                  _buildVersionCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 43,
                  backgroundColor: const Color(0xFFDBEAFE),
                  backgroundImage: _hasProfilePhoto
                      ? FileImage(File(_photoPath!))
                      : null,
                  child: !_hasProfilePhoto
                      ? const Icon(
                          Icons.person_rounded,
                          color: primary,
                          size: 45,
                        )
                      : null,
                ),
              ),
              Material(
                color: Colors.white,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _changeProfilePhoto,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: primary,
                      size: 17,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _profileName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Profil Pengguna PayTrack',
            style: TextStyle(
              color: Color(0xFFDBEAFE),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _editProfileName,
            icon: const Icon(Icons.edit_outlined, size: 17),
            label: const Text('Ubah Nama Profil'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white70),
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 11,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppIntroduction() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: primary, size: 27),
              SizedBox(width: 10),
              Text(
                'PayTrack',
                style: TextStyle(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Aplikasi pencatatan dan pengingat tagihan untuk membantu '
            'pengguna mengelola jadwal pembayaran agar lebih teratur.',
            style: TextStyle(
              color: mutedColor,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    const features = [
      _FeatureData(
        icon: Icons.receipt_long_rounded,
        title: 'Kelola Tagihan',
        description: 'Catat, lihat, ubah, dan hapus data tagihan.',
      ),
      _FeatureData(
        icon: Icons.notifications_active_outlined,
        title: 'Pantau Jatuh Tempo',
        description: 'Periksa tanggal jatuh tempo pembayaran.',
      ),
      _FeatureData(
        icon: Icons.history_rounded,
        title: 'Riwayat Pembayaran',
        description: 'Lihat tagihan yang telah ditandai lunas.',
      ),
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(feature.icon, color: primary, size: 23),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature.title,
                        style: const TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        feature.description,
                        style: const TextStyle(
                          color: mutedColor,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF16A34A),
                  size: 19,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDeveloperInfo() {
    return _buildCard(
      child: const Column(
        children: [
          _InfoTile(
            icon: Icons.person_outline_rounded,
            title: 'Nama',
            value: 'Putu Agus Dedy Putra Adnyana',
          ),
          Divider(height: 26, color: borderColor),
          _InfoTile(
            icon: Icons.badge_outlined,
            title: 'NIM',
            value: '2415051104',
          ),
          Divider(height: 26, color: borderColor),
          _InfoTile(
            icon: Icons.school_outlined,
            title: 'Program Studi',
            value: 'Pendidikan Teknik Informatika',
          ),
          Divider(height: 26, color: borderColor),
          _InfoTile(
            icon: Icons.account_balance_outlined,
            title: 'Universitas',
            value: 'Universitas Pendidikan Ganesha',
          ),
        ],
      ),
    );
  }

  Widget _buildTechnologies() {
    const technologies = [
      _TechnologyData(
        icon: Icons.flutter_dash,
        title: 'Flutter & Dart',
        description: 'Aplikasi dan antarmuka',
      ),
      _TechnologyData(
        icon: Icons.storage_rounded,
        title: 'Supabase',
        description: 'Database dan penyimpanan',
      ),
      _TechnologyData(
        icon: Icons.cloud_outlined,
        title: 'REST API',
        description: 'Informasi hari libur',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 ? 3 : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: technologies.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 112,
          ),
          itemBuilder: (context, index) {
            final technology = technologies[index];

            return _buildCard(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Icon(
                    technology.icon,
                    color: primary,
                    size: 27,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          technology.title,
                          style: const TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          technology.description,
                          style: const TextStyle(
                            color: mutedColor,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVersionCard() {
    return _buildCard(
      child: const Column(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            color: primary,
            size: 34,
          ),
          SizedBox(height: 10),
          Text(
            'PayTrack',
            style: TextStyle(
              color: textColor,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Versi 1.0.0',
            style: TextStyle(
              color: mutedColor,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Dikembangkan sebagai proyek Ujian Tengah Semester.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: mutedColor,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF2563EB), size: 21),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _TechnologyData {
  final IconData icon;
  final String title;
  final String description;

  const _TechnologyData({
    required this.icon,
    required this.title,
    required this.description,
  });
}