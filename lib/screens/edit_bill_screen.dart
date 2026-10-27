import 'package:flutter/material.dart';

import '../models/bill.dart';
import '../providers/bill_provider.dart';

class EditBillScreen extends StatefulWidget {
  final BillProvider provider;
  final Bill bill;

  const EditBillScreen({super.key, required this.provider, required this.bill});

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

  @override
  void initState() {
    super.initState();

    final bill = widget.bill;

    _nameController = TextEditingController(text: bill.name);
    _providerController = TextEditingController(text: bill.providerName);
    _amountController = TextEditingController(
      text: bill.amount.toStringAsFixed(
        bill.amount == bill.amount.roundToDouble() ? 0 : 2,
      ),
    );
    _noteController = TextEditingController(text: bill.note ?? '');

    _category = bill.category;
    _dueDate = bill.dueDate;
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
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Pilih tanggal jatuh tempo',
    );

    if (selectedDate != null && mounted) {
      setState(() {
        _dueDate = selectedDate;
      });
    }
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

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final amountText = _amountController.text
        .trim()
        .replaceAll('.', '')
        .replaceAll(',', '.');
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal tagihan harus lebih dari nol.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedBill = widget.bill.copyWith(
        name: _nameController.text.trim(),
        providerName: _providerController.text.trim(),
        amount: amount,
        dueDate: _dueDate,
        category: _category,
        note: _noteController.text.trim(),
      );

      widget.provider.updateBill(updatedBill);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tagihan berhasil diperbarui.')),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui tagihan: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2864F0);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Tagihan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Perbarui informasi tagihan kamu.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nama Tagihan',
                hintText: 'Contoh: Tagihan Internet',
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
            const SizedBox(height: 18),

            TextFormField(
              controller: _providerController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Penyedia Layanan',
                hintText: 'Contoh: PLN atau IndiHome',
                prefixIcon: Icon(Icons.business_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Penyedia layanan wajib diisi.';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Nominal Tagihan',
                prefixText: 'Rp ',
                prefixIcon: Icon(Icons.payments_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nominal tagihan wajib diisi.';
                }

                final normalized = value
                    .trim()
                    .replaceAll('.', '')
                    .replaceAll(',', '.');
                final amount = double.tryParse(normalized);

                if (amount == null || amount <= 0) {
                  return 'Masukkan nominal yang valid.';
                }

                return null;
              },
            ),
            const SizedBox(height: 18),

            DropdownButtonFormField<BillCategory>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Kategori Tagihan',
                prefixIcon: Icon(Icons.category_outlined),
                border: OutlineInputBorder(),
              ),
              items: BillCategory.values.map((category) {
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
            const SizedBox(height: 18),

            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(8),
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
            const SizedBox(height: 18),

            TextFormField(
              controller: _noteController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Catatan (Opsional)',
                hintText: 'Tambahkan catatan tagihan',
                prefixIcon: Icon(Icons.notes_outlined),
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _saveChanges,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Perubahan'),
                style: FilledButton.styleFrom(backgroundColor: primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
