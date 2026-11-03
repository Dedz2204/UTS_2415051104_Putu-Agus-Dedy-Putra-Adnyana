import 'package:flutter/material.dart';

import '../models/bill.dart';
import '../providers/bill_provider.dart';
import '../widgets/responsive_layout.dart';

class AddBillScreen extends StatefulWidget {
  final BillProvider provider;

  const AddBillScreen({
    super.key,
    required this.provider,
  });

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  static const Color _primaryColor = Color(0xFF2563EB);
  static const Color _textColor = Color(0xFF0F172A);
  static const Color _mutedColor = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFFE2E8F0);
  static const Color _backgroundColor = Color(0xFFF8FAFC);

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _providerController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  BillCategory _category = BillCategory.listrik;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));

  bool _isSaving = false;

  bool get _isProcessing => _isSaving || widget.provider.isAdding;

  double _parseAmount(String value) {
    final cleanedValue = value
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();

    return double.tryParse(cleanedValue) ?? 0;
  }

  String get _formattedDate {
    return '${_dueDate.day.toString().padLeft(2, '0')}/'
        '${_dueDate.month.toString().padLeft(2, '0')}/'
        '${_dueDate.year}';
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (selectedDate != null && mounted) {
      setState(() {
        _dueDate = selectedDate;
      });
    }
  }

  Future<void> _saveBill() async {
    if (_isProcessing) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = _parseAmount(_amountController.text);

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jumlah tagihan harus lebih dari 0.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSaving = true;
    });

    try {
      final bill = Bill(
        id: '',
        name: _nameController.text.trim(),
        providerName: _providerController.text.trim(),
        amount: amount,
        category: _category,
        dueDate: _dueDate,
        isPaid: false,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      await widget.provider.addBill(bill);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tagihan berhasil ditambahkan.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal menyimpan tagihan. Periksa koneksi internet dan coba lagi.',
          ),
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
          _formattedDate,
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
  void dispose() {
    _nameController.dispose();
    _providerController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Tambah Tagihan',
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
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(
            top: 12,
            bottom: 32,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
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
                              Icons.receipt_long_rounded,
                              color: _primaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Informasi Tagihan',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _textColor,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Lengkapi informasi tagihan baru.',
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
                        'Masukkan nama, penyedia, dan jumlah tagihan.',
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _nameController,
                        enabled: !_isProcessing,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: _inputDecoration(
                          label: 'Nama Tagihan',
                          hint: 'Contoh: Tagihan Listrik',
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
                        decoration: _inputDecoration(
                          label: 'Penyedia Tagihan',
                          hint: 'Contoh: PLN, Telkomsel, PDAM',
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
                        decoration: _inputDecoration(
                          label: 'Jumlah Tagihan',
                          hint: 'Contoh: 150000',
                          icon: Icons.payments_outlined,
                          prefix: const Text('Rp '),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Jumlah tagihan wajib diisi.';
                          }

                          if (_parseAmount(value) <= 0) {
                            return 'Jumlah tagihan harus lebih dari 0.';
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
                        items: BillCategory.values.map((category) {
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
                        'Tambahkan informasi jika diperlukan.',
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _noteController,
                        enabled: !_isProcessing,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 3,
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
                    onPressed: _isProcessing ? null : _saveBill,
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
                      _isProcessing ? 'Menyimpan...' : 'Simpan Tagihan',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}