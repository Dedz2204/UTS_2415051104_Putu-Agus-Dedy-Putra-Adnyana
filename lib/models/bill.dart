enum BillCategory { listrik, air, internet, telepon, lainnya }

String categoryLabel(BillCategory category) {
  switch (category) {
    case BillCategory.listrik:
      return 'Listrik';
    case BillCategory.air:
      return 'Air';
    case BillCategory.internet:
      return 'Internet';
    case BillCategory.telepon:
      return 'Telepon';
    case BillCategory.lainnya:
      return 'Lainnya';
  }
}

class Bill {
  final String id;
  final String name;
  final String providerName;
  final double amount;
  final DateTime dueDate;
  final BillCategory category;
  final bool isPaid;
  final DateTime? paidAt;
  final String? note;

  const Bill({
    required this.id,
    required this.name,
    required this.providerName,
    required this.amount,
    required this.dueDate,
    required this.category,
    this.isPaid = false,
    this.paidAt,
    this.note,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    final rawCategory = json['category']?.toString().toLowerCase();

    final category = BillCategory.values.firstWhere(
      (item) => item.name == rawCategory,
      orElse: () => BillCategory.lainnya,
    );

    final rawAmount = json['amount'];
    final amount = rawAmount is num
        ? rawAmount.toDouble()
        : double.tryParse(rawAmount?.toString() ?? '') ?? 0.0;

    final rawDueDate = json['dueDate'] ?? json['due_date'];
    final parsedDueDate = DateTime.tryParse(
      rawDueDate?.toString() ?? '',
    );

    final rawPaidAt = json['paidAt'] ?? json['paid_at'];
    final parsedPaidAt = rawPaidAt == null
        ? null
        : DateTime.tryParse(rawPaidAt.toString());

    final rawIsPaid = json['isPaid'] ?? json['is_paid'];

    return Bill(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      providerName:
          (json['providerName'] ?? json['provider_name'] ?? '').toString(),
      amount: amount,
      dueDate: parsedDueDate ?? DateTime(2000, 1, 1),
      category: category,
      isPaid: rawIsPaid == true ||
          rawIsPaid == 1 ||
          rawIsPaid == '1' ||
          rawIsPaid == 'true',
      paidAt: parsedPaidAt,
      note: json['note'] == null ||
              json['note'].toString().trim().isEmpty
          ? null
          : json['note'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'providerName': providerName,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'category': category.name,
      'isPaid': isPaid,
      'paidAt': paidAt?.toIso8601String(),
      'note': note,
    };
  }

  Bill copyWith({
    String? name,
    String? providerName,
    double? amount,
    DateTime? dueDate,
    BillCategory? category,
    bool? isPaid,
    DateTime? paidAt,
    String? note,
  }) {
    return Bill(
      id: id,
      name: name ?? this.name,
      providerName: providerName ?? this.providerName,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      isPaid: isPaid ?? this.isPaid,
      paidAt: paidAt ?? this.paidAt,
      note: note ?? this.note,
    );
  }
}
