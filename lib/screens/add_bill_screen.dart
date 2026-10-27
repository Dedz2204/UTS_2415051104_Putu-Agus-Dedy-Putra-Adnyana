import 'package:flutter/material.dart';

import '../models/bill.dart';
import '../providers/bill_provider.dart';

class AddBillScreen extends StatefulWidget {
  final BillProvider provider;

  const AddBillScreen({super.key, required this.provider});

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _provider = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();

  BillCategory _category = BillCategory.internet;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));

  @override
  void dispose() {
    _name.dispose();
    _provider.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null) setState(() => _dueDate = date);
  }

  void _saveBill() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(
      _amount.text.replaceAll('.', '').replaceAll(',', '.'),
    );

    if (amount == null || amount <= 0) return;

    widget.provider.addBill(
      Bill(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: _name.text.trim(),
        providerName: _provider.text.trim(),
        amount: amount,
        dueDate: _dueDate,
        category: _category,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      ),
    );

    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tagihan berhasil ditambahkan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Tagihan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2864F0),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.receipt_long, color: Colors.white, size: 35),
                  SizedBox(height: 12),
                  Text(
                    'Catat Tagihan Baru',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Isi informasi tagihan dengan lengkap.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Informasi Tagihan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Nama tagihan',
                hintText: 'Contoh: Tagihan Internet',
                prefixIcon: Icon(Icons.receipt),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _provider,
              decoration: const InputDecoration(
                labelText: 'Penyedia layanan',
                hintText: 'Contoh: IndiHome',
                prefixIcon: Icon(Icons.business),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Penyedia wajib diisi' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nominal tagihan',
                prefixText: 'Rp ',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              validator: (v) {
                final value = double.tryParse(
                  (v ?? '').replaceAll('.', '').replaceAll(',', '.'),
                );
                return value == null || value <= 0
                    ? 'Masukkan nominal yang valid'
                    : null;
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<BillCategory>(
              initialValue: BillCategory.listrik,
              decoration: const InputDecoration(
                labelText: 'Kategori tagihan',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: BillCategory.values
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(categoryLabel(category)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: 14),
            Card(
              color: Colors.white,
              elevation: 0,
              child: ListTile(
                leading: const Icon(
                  Icons.calendar_month,
                  color: Color(0xFF2864F0),
                ),
                title: const Text('Tanggal jatuh tempo'),
                subtitle: Text(
                  '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                ),
                trailing: const Icon(Icons.edit_calendar),
                onTap: _chooseDate,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _note,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                hintText: 'Tambahkan keterangan...',
                prefixIcon: Icon(Icons.notes),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: _saveBill,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Simpan Tagihan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
