import 'package:flutter/material.dart';


class MonthlyPaymentReportsPage extends StatelessWidget {
  const MonthlyPaymentReportsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6EDCC4), Color(0xFF5FC9B3)],
              ),
            ),
            child: const Text(
              'Monthly Payment Reports',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Revenue Overview Section
                  const Text(
                    'Revenue Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Revenue Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildRevenueCard(
                          'Total Redemption Fees',
                          '\$0.00',
                          const Color(0xFF6EDCC4),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildRevenueCard(
                          'Total Cashback',
                          '\$0.00',
                          const Color(0xFFFF6B6B),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildRevenueCard(
                          'Total Revenue',
                          '\$0.00',
                          const Color(0xFF4ECDC4),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Revenue Breakdown Section
                  const Text(
                    'Revenue Breakdown',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Empty Chart Area
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Date and Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Date: Oct 1, 2025 - Oct 31, 2025',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF999999),
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6EDCC4),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Select Month'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A085),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Download CSV'),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Restaurant Breakdown Section
                  const Text(
                    'Restaurant Breakdown',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Restaurant Table
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
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
                            gradient: LinearGradient(
                              colors: [Color(0xFF6EDCC4), Color(0xFF5FC9B3)],
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Table(
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(1),
                              2: FlexColumnWidth(1),
                              3: FlexColumnWidth(1),
                            },
                            children: [
                              TableRow(
                                children: [
                                  _buildTableHeader('Restaurant'),
                                  _buildTableHeader('Cashback'),
                                  _buildTableHeader('Redemption Fees'),
                                  _buildTableHeader('Net Revenue'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Table Rows
                        Table(
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(1),
                            3: FlexColumnWidth(1),
                          },
                          children: [
                            _buildTableRow('Soqat', '\$0.00', '\$0.00', '\$0.00', false),
                            _buildTableRow('Heaven', '\$0.00', '\$0.00', '\$0.00', true),
                            _buildTableRow('Blasting', '\$0.00', '\$0.00', '\$0.00', false),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  TableRow _buildTableRow(String restaurant, String cashback,
      String redemption, String revenue, bool isEven) {
    return TableRow(
      decoration: BoxDecoration(
        color: isEven ? const Color(0xFFF8F9FA) : Colors.white,
      ),
      children: [
        _buildTableCell(restaurant),
        _buildTableCell(cashback),
        _buildTableCell(redemption),
        _buildTableCell(revenue),
      ],
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF2D2D2D),
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}