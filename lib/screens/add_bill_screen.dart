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
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Tambah Tagihan'),
        backgroundColor: const Color(0xFFF5F7FB),
        foregroundColor: const Color(0xFF0F172A),
      ),
      body: ResponsiveLayout(
        maxContentWidth: 760,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informasi Tagihan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _nameController,
                  enabled: !_isProcessing,
                  decoration: const InputDecoration(
                    labelText: 'Nama Tagihan',
                    hintText: 'Contoh: Tagihan Listrik',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.receipt_long),
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
                  decoration: const InputDecoration(
                    labelText: 'Penyedia Tagihan',
                    hintText: 'Contoh: PLN, Telkomsel, PDAM',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
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
                  decoration: const InputDecoration(
                    labelText: 'Jumlah Tagihan',
                    hintText: 'Contoh: 150000',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.payments_outlined),
                    prefixText: 'Rp ',
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
                const SizedBox(height: 16),

                DropdownButtonFormField<BillCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(
                    labelText: 'Kategori Tagihan',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category_outlined),
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

                InkWell(
                  onTap: _isProcessing ? null : _selectDate,
                  borderRadius: BorderRadius.circular(8),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Jatuh Tempo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_month),
                    ),
                    child: Text(
                      '${_dueDate.day.toString().padLeft(2, '0')}/'
                      '${_dueDate.month.toString().padLeft(2, '0')}/'
                      '${_dueDate.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _noteController,
                  enabled: !_isProcessing,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (Opsional)',
                    hintText: 'Tambahkan catatan jika diperlukan',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.notes),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isProcessing ? null : _saveBill,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Simpan Tagihan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
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