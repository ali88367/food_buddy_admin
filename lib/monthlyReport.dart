import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentReportsPage extends StatefulWidget {
  const PaymentReportsPage({Key? key}) : super(key: key);

  @override
  State<PaymentReportsPage> createState() => _PaymentReportsPageState();
}

class _PaymentReportsPageState extends State<PaymentReportsPage> {
  String selectedMonth = 'Oct 1, 2025 - Oct 31, 2025';

  // Sample data
  final double totalRedemptionFees = 0.0;
  final double totalCashback = 0.0;
  final double totalCashbackDistributed = 0.0;
  final double totalCashbackRedeemed = 0.0;

  final List<RestaurantData> restaurants = [
    RestaurantData(
      name: 'Sogat Blasting Burger',
      cashback: 0.0,
      redemptionFees: 0.0,
      netRevenue: 0.0,
      redemptionCount: 0,
    ),
    RestaurantData(
      name: 'Heaven',
      cashback: 0.0,
      redemptionFees: 0.0,
      netRevenue: 0.0,
      redemptionCount: 0,
    ),
    RestaurantData(
      name: 'Blasting',
      cashback: 0.0,
      redemptionFees: 0.0,
      netRevenue: 0.0,
      redemptionCount: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final netRevenue = totalRedemptionFees - totalCashback;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7FD8BE),
        elevation: 0,
        title: const Text(
          'Monthly Payment Reports',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              // Refresh data
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Revenue Overview Section
            _SectionHeader(
              title: 'Revenue Overview',
              subtitle: 'Total fees and revenue for selected period',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _RevenueCard(
                    title: 'Redemption Fees',
                    amount: '\$${totalRedemptionFees.toStringAsFixed(2)}',
                    subtitle: 'From restaurant usage',
                    backgroundColor: const Color(0xFF7FD8BE),
                    icon: Icons.payments_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _RevenueCard(
                    title: 'Total Cashback',
                    amount: '\$${totalCashback.toStringAsFixed(2)}',
                    subtitle: 'Customer redemptions',
                    backgroundColor: const Color(0xFFFF6B9D),
                    icon: Icons.card_giftcard_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _RevenueCard(
                    title: 'Net Revenue',
                    amount: '\$${netRevenue.toStringAsFixed(2)}',
                    subtitle: 'After cashback',
                    backgroundColor: const Color(0xFF00897B),
                    icon: Icons.trending_up,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Cashback Monitoring Section
            _SectionHeader(
              title: 'Cashback Monitoring',
              subtitle: 'Track cashback distribution and redemption',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _CashbackMetric(
                          label: 'Distributed',
                          amount: '\$${totalCashbackDistributed.toStringAsFixed(2)}',
                          icon: Icons.arrow_upward,
                          color: const Color(0xFF2196F3),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 60,
                        color: Colors.grey[200],
                      ),
                      Expanded(
                        child: _CashbackMetric(
                          label: 'Redeemed',
                          amount: '\$${totalCashbackRedeemed.toStringAsFixed(2)}',
                          icon: Icons.arrow_downward,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 60,
                        color: Colors.grey[200],
                      ),
                      Expanded(
                        child: _CashbackMetric(
                          label: 'Pending',
                          amount: '\$${(totalCashbackDistributed - totalCashbackRedeemed).toStringAsFixed(2)}',
                          icon: Icons.pending_outlined,
                          color: const Color(0xFFFFA726),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFB74D)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Color(0xFFFF9800), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No customers approaching \$5 redemption threshold',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Revenue Breakdown Chart
            _SectionHeader(
              title: 'Revenue Breakdown',
              subtitle: 'Visual representation of monthly trends',
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text(
                      'Chart will be displayed here',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Install fl_chart package to visualize data',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Date Selection and Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      selectedMonth,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        // Show month picker
                      },
                      icon: const Icon(Icons.edit_calendar, size: 18),
                      label: const Text('Select Month'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF7FD8BE),
                        side: const BorderSide(color: Color(0xFF7FD8BE)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Download CSV
                      },
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Download CSV'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00897B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Restaurant Breakdown Table
            _SectionHeader(
              title: 'Restaurant Breakdown',
              subtitle: 'Detailed revenue breakdown by restaurant',
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF7FD8BE),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Restaurant',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Redemptions',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Cashback',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Fees',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Net Revenue',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Table Rows
                  ...restaurants.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return _RestaurantRow(
                      data: data,
                      isEven: index % 2 == 0,
                      isLast: index == restaurants.length - 1,
                    );
                  }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _RevenueCard extends StatelessWidget {
  final String title;
  final String amount;
  final String subtitle;
  final Color backgroundColor;
  final IconData icon;

  const _RevenueCard({
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.backgroundColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [backgroundColor, backgroundColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(icon, color: Colors.white.withOpacity(0.9), size: 24),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _CashbackMetric extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color color;

  const _CashbackMetric({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          amount,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _RestaurantRow extends StatelessWidget {
  final RestaurantData data;
  final bool isEven;
  final bool isLast;

  const _RestaurantRow({
    required this.data,
    required this.isEven,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isEven ? const Color(0xFFF8FAFB) : Colors.white,
        borderRadius: isLast
            ? const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        )
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              data.name,
              style: const TextStyle(
                color: Color(0xFF2D3748),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${data.redemptionCount}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '\$${data.cashback.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '\$${data.redemptionFees.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '\$${data.netRevenue.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: data.netRevenue >= 0 ? const Color(0xFF00897B) : const Color(0xFFE53935),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RestaurantData {
  final String name;
  final double cashback;
  final double redemptionFees;
  final double netRevenue;
  final int redemptionCount;

  RestaurantData({
    required this.name,
    required this.cashback,
    required this.redemptionFees,
    required this.netRevenue,
    required this.redemptionCount,
  });
}