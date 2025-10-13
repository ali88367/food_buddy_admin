import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class PaymentReportsPage extends StatefulWidget {
  const PaymentReportsPage({Key? key}) : super(key: key);

  @override
  State<PaymentReportsPage> createState() => _PaymentReportsPageState();
}

class _PaymentReportsPageState extends State<PaymentReportsPage> {
  String selectedMonth = 'Oct 1, 2025 - Oct 31, 2025';

  final List<RestaurantData> restaurants = [
    RestaurantData(
      name: 'sogat blasting burger',
      cashback: 0.0,
      redemptionFees: 0.0,
      netRevenue: 0.0,
    ),
    RestaurantData(
      name: 'Heaven',
      cashback: 0.0,
      redemptionFees: 0.0,
      netRevenue: 0.0,
    ),
    RestaurantData(
      name: 'Blasting',
      cashback: 0.0,
      redemptionFees: 0.0,
      netRevenue: 0.0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF7FD8BE),
        elevation: 0,
        title: const Text(
          'Monthly Payment Reports',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Revenue Overview
            const Text(
              'Revenue Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _RevenueCard(
                    title: 'Total Redemption Fees',
                    amount: '\$0.00',
                    backgroundColor: const Color(0xFF7FD8BE),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _RevenueCard(
                    title: 'Total Cashback',
                    amount: '\$0.00',
                    backgroundColor: Colors.red[400] ?? Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _RevenueCard(
                    title: 'Total Revenue',
                    amount: '\$0.00',
                    backgroundColor: const Color(0xFF00897B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Revenue Breakdown
            const Text(
              'Revenue Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[300] ?? Colors.grey,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Chart Area',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Date and Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: $selectedMonth',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7FD8BE),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Select Month'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00897B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Download CSV'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Restaurant Breakdown
            const Text(
              'Restaurant Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[300] ?? Colors.grey,
                    blurRadius: 4,
                  ),
                ],
              ),
            //  overflow: Overflow.hidden,
              child: Column(
                children: [
                  // Table Header
                  Container(
                    color: const Color(0xFF7FD8BE),
                    padding: const EdgeInsets.all(16),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Restaurant',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Cashback',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Redemption Fees',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
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
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Table Rows
                  ...restaurants.asMap().entries.map((entry) {
                    final isLast = entry.key == restaurants.length - 1;
                    return _RestaurantRow(
                      data: entry.value,
                      isLast: isLast,
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color backgroundColor;

  const _RevenueCard({
    required this.title,
    required this.amount,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RestaurantRow extends StatelessWidget {
  final RestaurantData data;
  final bool isLast;

  const _RestaurantRow({
    required this.data,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  data.name,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '\$${data.cashback.toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '\$${data.redemptionFees.toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '\$${data.netRevenue.toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            color: Colors.grey[200],
            height: 0,
          ),
      ],
    );
  }
}

class RestaurantData {
  final String name;
  final double cashback;
  final double redemptionFees;
  final double netRevenue;

  RestaurantData({
    required this.name,
    required this.cashback,
    required this.redemptionFees,
    required this.netRevenue,
  });
}