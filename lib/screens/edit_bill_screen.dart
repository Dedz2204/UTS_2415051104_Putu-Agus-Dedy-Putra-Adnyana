import 'package:flutter/material.dart';

import '../models/bill.dart';
import '../providers/bill_provider.dart';
import '../widgets/responsive_layout.dart';

class EditBillScreen extends StatefulWidget {
  final Bill bill;
  final BillProvider provider;

  const EditBillScreen({
    super.key,
    required this.bill,
    required this.provider,
  });

  @override
  State<EditBillScreen> createState() => _EditBillScreenState();
}

class _EditBillScreenState extends State<EditBillScreen> {
  static const Color _primaryColor = Color(0xFF2563EB);
  static const Color _textColor = Color(0xFF0F172A);
  static const Color _mutedColor = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFFE2E8F0);
  static const Color _backgroundColor = Color(0xFFF8FAFC);

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _providerController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late BillCategory _category;
  late DateTime _dueDate;

  bool _isSaving = false;

  bool get _isProcessing => _isSaving || widget.provider.isUpdating;

  List<BillCategory> get _categories => BillCategory.values;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.bill.name);
    _providerController = TextEditingController(
      text: widget.bill.providerName,
    );
    _amountController = TextEditingController(
      text: widget.bill.amount.toStringAsFixed(0),
    );
    _noteController = TextEditingController(
      text: widget.bill.note ?? '',
    );

    _category = widget.bill.category;
    _dueDate = widget.bill.dueDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _providerController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double? _parseAmount(String value) {
    final normalized = value
        .trim()
        .replaceAll('.', '')
        .replaceAll(',', '.');

    return double.tryParse(normalized);
  }

  String _formatDate(DateTime date) {
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
      'Desember',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _selectDate() async {
    if (_isProcessing) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate.isBefore(today) ? today : _dueDate,
      firstDate: today.isBefore(_dueDate) ? today : _dueDate,
      lastDate: DateTime(2100),
      helpText: 'Pilih tanggal jatuh tempo',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (selectedDate != null && mounted) {
      setState(() {
        _dueDate = selectedDate;
      });
    }
  }

  Future<void> _updateBill() async {
    if (_isProcessing) return;

    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final amount = _parseAmount(_amountController.text);

    if (amount == null || !amount.isFinite || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan jumlah tagihan yang valid.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final note = _noteController.text.trim();

      final updatedBill = Bill(
        id: widget.bill.id,
        name: _nameController.text.trim(),
        providerName: _providerController.text.trim(),
        amount: amount,
        category: _category,
        dueDate: _dueDate,
        isPaid: widget.bill.isPaid,
        paidAt: widget.bill.paidAt,
        note: note.isEmpty ? null : note,
      );

      await widget.provider.updateBill(updatedBill);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tagihan berhasil diperbarui.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal memperbarui tagihan. Periksa koneksi internet dan coba lagi.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? prefix,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: _mutedColor),
      prefix: prefix,
      alignLabelWithHint: alignLabelWithHint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _primaryColor,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: _textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: _mutedColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _isProcessing ? null : _selectDate,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: _inputDecoration(
          label: 'Tanggal Jatuh Tempo',
          hint: 'Pilih tanggal',
          icon: Icons.calendar_month_outlined,
        ).copyWith(
          suffixIcon: const Icon(
            Icons.edit_calendar_outlined,
            color: _primaryColor,
          ),
        ),
        child: Text(
          _formatDate(_dueDate),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Edit Tagihan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _textColor,
          ),
        ),
        backgroundColor: _backgroundColor,
        foregroundColor: _textColor,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ResponsiveLayout(
        maxContentWidth: 760,
        child: Form(
          key: _formKey,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.only(
              top: 12,
              bottom: 32,
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.edit_note_rounded,
                            color: _primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ubah Informasi Tagihan',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _textColor,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Perbarui informasi tagihan sesuai kebutuhan.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _mutedColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _buildSectionTitle(
                      'Detail Tagihan',
                      'Perbarui nama, penyedia, dan jumlah tagihan.',
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _nameController,
                      enabled: !_isProcessing,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                        label: 'Nama Tagihan',
                        hint: 'Contoh: Tagihan Wi-Fi',
                        icon: Icons.receipt_long_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama tagihan wajib diisi.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _providerController,
                      enabled: !_isProcessing,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                        label: 'Penyedia Tagihan',
                        hint: 'Contoh: PLN atau penyedia internet',
                        icon: Icons.business_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Penyedia tagihan wajib diisi.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _amountController,
                      enabled: !_isProcessing,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                        label: 'Jumlah Tagihan',
                        hint: 'Contoh: 150000',
                        icon: Icons.payments_outlined,
                        prefix: const Text('Rp '),
                      ),
                      validator: (value) {
                        final amount = _parseAmount(value ?? '');

                        if (amount == null ||
                            !amount.isFinite ||
                            amount <= 0) {
                          return 'Masukkan jumlah yang valid.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    _buildSectionTitle(
                      'Kategori dan Jatuh Tempo',
                      'Pilih kategori serta tanggal pembayaran.',
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<BillCategory>(
                      initialValue: _category,
                      isExpanded: true,
                      decoration: _inputDecoration(
                        label: 'Kategori Tagihan',
                        hint: 'Pilih kategori',
                        icon: Icons.category_outlined,
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem<BillCategory>(
                          value: category,
                          child: Text(categoryLabel(category)),
                        );
                      }).toList(),
                      onChanged: _isProcessing
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() {
                                  _category = value;
                                });
                              }
                            },
                    ),
                    const SizedBox(height: 16),

                    _buildDatePicker(),
                    const SizedBox(height: 24),

                    _buildSectionTitle(
                      'Catatan Tambahan',
                      'Tambahkan atau ubah catatan jika diperlukan.',
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _noteController,
                      enabled: !_isProcessing,
                      minLines: 3,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _inputDecoration(
                        label: 'Catatan (Opsional)',
                        hint: 'Tambahkan catatan jika diperlukan',
                        icon: Icons.notes_outlined,
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isProcessing ? null : _updateBill,
                  icon: _isProcessing
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _isProcessing ? 'Menyimpan...' : 'Simpan Perubahan',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _primaryColor.withValues(
                      alpha: 0.6,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pastikan informasi tagihan yang diperbarui sudah benar.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _mutedColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}