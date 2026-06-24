import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../Controllers/payments_controller.dart';
import 'package:intl/intl.dart';

class Payments extends StatelessWidget {
  final PaymentsController controller = Get.put(PaymentsController());

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    // A slightly off-white or deep-dark background makes the clean white/grey cards pop out better
    final Color scaffoldColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        title: Text(
          "Payments",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 3));
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Text(
              controller.errorMessage.value,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchPaymentsData,
          color: Colors.blueAccent,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            children: [
              _buildSummaryDashboard(isDark),
              const SizedBox(height: 32),
              Text(
                "Recent Invoices",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              ...controller.invoices
                  .map((invoice) => _buildInvoiceItem(invoice, isDark))
                  .toList(),
            ],
          ),
        );
      }),
    );
  }

  // --- 1. The Professional Summary Dashboard ---
  Widget _buildSummaryDashboard(bool isDark) {
    final summary = controller.summary.value;
    if (summary == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Account Balance",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildMetricItem(
                  "Total",
                  summary.total,
                  isDark,
                  Colors.blueAccent,
                ),
              ),
              _buildVerticalDivider(isDark),
              Expanded(
                child: _buildMetricItem(
                  "Paid",
                  summary.paid,
                  isDark,
                  Colors.green,
                ),
              ),
              _buildVerticalDivider(isDark),
              Expanded(
                child: _buildMetricItem(
                  "Remaining",
                  summary.remaining,
                  isDark,
                  Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    String title,
    double amount,
    bool isDark,
    Color valueColor,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.grey[500] : Colors.grey[500],
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "${amount.toStringAsFixed(0)}",
          style: TextStyle(
            color: valueColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          "EGP",
          style: TextStyle(
            color: isDark ? Colors.grey[600] : Colors.grey[400],
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      width: 1,
      height: 40,
      color: isDark ? Colors.white10 : Colors.grey[200],
    );
  }

  // --- 2. The Custom Invoice Item Layout ---
  // --- 2. The Detailed Invoice Item Layout ---
  Widget _buildInvoiceItem(invoice, bool isDark) {
    DateTime parsedDueDate = DateTime.parse(invoice.dueDate);
    DateTime parsedIssueDate = DateTime.parse(invoice.issueDate);
    String formattedDueDate = DateFormat('MMM dd, yyyy').format(parsedDueDate);
    String formattedIssueDate = DateFormat(
      'MMM dd, yyyy',
    ).format(parsedIssueDate);

    bool isPaid = invoice.status.toString().toLowerCase() == 'paid';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Academic Year & Term + Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Year ${invoice.academicYear} • ${invoice.term}",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Issued: $formattedIssueDate",
                      style: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(isPaid, isDark),
            ],
          ),

          const SizedBox(height: 16),

          // Items Breakdown Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: invoice.items.map<Widget>((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "${item.amount.toStringAsFixed(0)} ${invoice.currency}",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[300] : Colors.grey[800],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(
              color: isDark ? Colors.white10 : Colors.grey[200],
              height: 1,
            ),
          ),

          // Footer: Due Date and Total Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Due Date",
                    style: TextStyle(
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDueDate,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isPaid
                          ? (isDark ? Colors.grey[400] : Colors.grey[600])
                          : (isDark
                                ? Colors.red[300]
                                : Colors
                                      .red[700]), // Highlight overdue/unpaid dates
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Total Amount",
                    style: TextStyle(
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${invoice.totalAmount.toStringAsFixed(0)} ${invoice.currency}",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isPaid, bool isDark) {
    final bgColor = isPaid
        ? (isDark ? Colors.green.withOpacity(0.15) : Colors.green[50])
        : (isDark ? Colors.red.withOpacity(0.15) : Colors.red[50]);

    final textColor = isPaid
        ? (isDark ? Colors.greenAccent : Colors.green[700])
        : (isDark ? Colors.redAccent : Colors.red[700]);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor!.withOpacity(0.2), width: 1),
      ),
      child: Text(
        isPaid ? "PAID" : "UNPAID",
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
