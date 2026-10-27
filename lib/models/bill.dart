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
