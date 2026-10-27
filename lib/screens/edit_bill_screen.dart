import 'package:flutter/material.dart';

import '../models/bill.dart';
import '../providers/bill_provider.dart';
import '../widgets/responsive_layout.dart';

class EditBillScreen extends StatefulWidget {
  final Bill bill;
  final BillProvider provider;

  const EditBillScreen({super.key, required this.bill, required this.provider});

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

  final List<BillCategory> _categories = BillCategory.values;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.bill.name);

    _providerController = TextEditingController(text: widget.bill.providerName);

    _amountController = TextEditingController(
      text: widget.bill.amount.toStringAsFixed(0),
    );

    _noteController = TextEditingController(text: widget.bill.note ?? '');

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

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null && mounted) {
      setState(() {
        _dueDate = selectedDate;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  double? _parseAmount(String value) {
    final normalized = value.trim().replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  void _updateBill() {
    if (!_formKey.currentState!.validate() || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final amount = _parseAmount(_amountController.text);

      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Masukkan jumlah tagihan yang valid.')),
        );
        return;
      }

      final updatedBill = widget.bill.copyWith(
        name: _nameController.text.trim(),
        providerName: _providerController.text.trim(),
        amount: amount,
        category: _category,
        dueDate: _dueDate,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      widget.provider.updateBill(updatedBill);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tagihan berhasil diperbarui.')),
      );

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui tagihan: $error')),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Tagihan')),
      body: ResponsiveLayout(
        maxContentWidth: 760,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            children: [
              const Text(
                'Ubah Informasi Tagihan',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Tagihan',
                  prefixIcon: Icon(Icons.receipt_long_outlined),
                  border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  labelText: 'Penyedia Tagihan',
                  prefixIcon: Icon(Icons.business_outlined),
                  border: OutlineInputBorder(),
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
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Jumlah Tagihan (Rp)',
                  prefixIcon: Icon(Icons.payments_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final amount = _parseAmount(value ?? '');

                  if (amount == null || amount <= 0) {
                    return 'Masukkan jumlah yang valid.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<BillCategory>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
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
              const SizedBox(height: 16),

              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Jatuh Tempo',
                    prefixIcon: Icon(Icons.calendar_month_outlined),
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(_formatDate(_dueDate))),
                      const Icon(Icons.edit_calendar_outlined),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _noteController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: _isSaving ? null : _updateBill,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Perubahan'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
