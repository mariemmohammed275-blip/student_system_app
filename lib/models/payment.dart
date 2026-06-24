class PaymentSummary {
  final double total;
  final double paid;
  final double remaining;
  final int invoicesCount;

  PaymentSummary({
    required this.total,
    required this.paid,
    required this.remaining,
    required this.invoicesCount,
  });

  factory PaymentSummary.fromJson(Map<String, dynamic> json) {
    return PaymentSummary(
      total: (json['total'] ?? 0).toDouble(),
      paid: (json['paid'] ?? 0).toDouble(),
      remaining: (json['remaining'] ?? 0).toDouble(),
      invoicesCount: json['invoicesCount'] ?? 0,
    );
  }
}

class InvoiceItem {
  final String title;
  final double amount;

  InvoiceItem({required this.title, required this.amount});

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      title: json['title'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}

class Invoice {
  final String id;
  final int academicYear;
  final String term;
  final double totalAmount;
  final double paidAmount;
  final String status;
  final String dueDate;
  final String issueDate; // Mapped from createdAt
  final String currency;
  final List<InvoiceItem> items;

  Invoice({
    required this.id,
    required this.academicYear,
    required this.term,
    required this.totalAmount,
    required this.paidAmount,
    required this.status,
    required this.dueDate,
    required this.issueDate,
    required this.currency,
    required this.items,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    List<InvoiceItem> parsedItems = itemsList
        .map((i) => InvoiceItem.fromJson(i))
        .toList();

    return Invoice(
      id: json['_id'] ?? '',
      academicYear: json['academicYear'] ?? 1,
      term: json['term'] ?? 'Invoice',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'unpaid',
      dueDate: json['dueDate'] ?? '',
      issueDate: json['createdAt'] ?? '',
      currency: json['currency'] ?? 'EGP',
      items: parsedItems,
    );
  }
}
