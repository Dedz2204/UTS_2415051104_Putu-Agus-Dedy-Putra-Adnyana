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
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _providerController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late BillCategory _category;
  late DateTime _dueDate;

  bool _isSaving = false;

  List<BillCategory> get _categories => BillCategory.values;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.bill.name);
    _providerController =
        TextEditingController(text: widget.bill.providerName);
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
    final normalized = value.trim().replaceAll('.', '').replaceAll(',', '.');
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

  void _updateBill() {
    if (_isSaving || !_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final amount = _parseAmount(_amountController.text);

    if (amount == null || amount <= 0) {
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

      final updatedBill = widget.bill.copyWith(
        name: _nameController.text.trim(),
        providerName: _providerController.text.trim(),
        amount: amount,
        category: _category,
        dueDate: _dueDate,
        note: note.isEmpty ? null : note,
      );

      widget.provider.updateBill(updatedBill);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tagihan berhasil diperbarui.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui tagihan: $error'),
          behavior: SnackBarBehavior.floating,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Edit Tagihan',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFFF5F7FB),
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: ResponsiveLayout(
        maxContentWidth: 760,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ubah Informasi Tagihan',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Perbarui informasi tagihan sesuai kebutuhanmu.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 26),

                    _buildLabel('Nama Tagihan'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
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
                    const SizedBox(height: 20),

                    _buildLabel('Penyedia Tagihan'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _providerController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
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
                    const SizedBox(height: 20),

                    _buildLabel('Jumlah Tagihan'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                        hint: 'Contoh: 150000',
                        icon: Icons.payments_outlined,
                        prefixText: 'Rp ',
                      ),
                      validator: (value) {
                        final amount = _parseAmount(value ?? '');

                        if (amount == null || amount <= 0) {
                          return 'Masukkan jumlah yang valid.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('Kategori'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<BillCategory>(
                      initialValue: _category,
                      isExpanded: true,
                      decoration: _inputDecoration(
                        hint: 'Pilih kategori',
                        icon: Icons.category_outlined,
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem<BillCategory>(
                          value: category,
                          child: Text(categoryLabel(category)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _category = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('Tanggal Jatuh Tempo'),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDate,
                      borderRadius: BorderRadius.circular(14),
                      child: InputDecorator(
                        decoration: _inputDecoration(
                          hint: 'Pilih tanggal',
                          icon: Icons.calendar_month_outlined,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _formatDate(_dueDate),
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.edit_calendar_outlined,
                              color: Color(0xFF2563EB),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('Catatan (Opsional)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _noteController,
                      minLines: 3,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _inputDecoration(
                        hint: 'Tambahkan catatan jika diperlukan',
                        icon: Icons.notes_rounded,
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isSaving ? null : _updateBill,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          _isSaving
                              ? 'Menyimpan...'
                              : 'Simpan Perubahan',
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pastikan informasi tagihan yang diperbarui sudah benar.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    String? prefixText,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefixText,
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF64748B),
      ),
      alignLabelWithHint: alignLabelWithHint,
      filled: true,
      fillColor: const Color(0xFFFAFBFE),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF2563EB),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }
}