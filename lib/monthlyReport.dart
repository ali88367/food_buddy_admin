import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'dart:html' as html;
import 'package:fl_chart/fl_chart.dart'; // ← NEW: Add to pubspec.yaml

class PaymentReportsPage extends StatefulWidget {
  const PaymentReportsPage({Key? key}) : super(key: key);
  @override
  State<PaymentReportsPage> createState() => _PaymentReportsPageState();
}

class _PaymentReportsPageState extends State<PaymentReportsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime _selectedStartDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _selectedEndDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

  bool _isLoading = true;
  double totalRedemptionFees = 0.0;
  double totalCashback = 0.0;
  double totalCashbackDistributed = 0.0;
  double totalCashbackRedeemed = 0.0;
  Map<String, RestaurantData> restaurantMap = {};
  List<RestaurantData> filteredRestaurants = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // FORCE show your 1 transaction
    _selectedStartDate = DateTime(2024, 1, 1);
    _selectedEndDate = DateTime.now();
    _fetchTransactions();
    _startAutoRefresh();
    _searchController.addListener(_filterRestaurants);
  }
  @override
  void dispose() {
    _searchController.removeListener(_filterRestaurants);
    _searchController.dispose();
    super.dispose();
  }

  void _startAutoRefresh() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _fetchTransactions();
        _startAutoRefresh();
      }
    });
  }

  String get selectedMonth {
    final f = DateFormat('MMM d, yyyy');
    return '${f.format(_selectedStartDate)} - ${f.format(_selectedEndDate)}';
  }

  Future<void> _fetchTransactions() async {
    setState(() => _isLoading = true);
    try {
      totalRedemptionFees = totalCashback = totalCashbackDistributed = totalCashbackRedeemed = 0.0;
      restaurantMap.clear();

      final start = Timestamp.fromDate(_selectedStartDate);
      final end = Timestamp.fromDate(_selectedEndDate.add(const Duration(days: 1)));

      final snap = await _firestore
          .collection('transactions')
          .where('timestamp', isGreaterThanOrEqualTo: start)
          .where('timestamp', isLessThan: end)
          .get();

      for (var doc in snap.docs) {
        final d = doc.data();
        if (d['status'] != 'completed') continue;

        final cashback = (d['cashbackAmount'] as num?)?.toDouble() ?? 0.0;
        final fee = (d['transactionFee'] as num?)?.toDouble() ?? 0.0;
        final id = d['restaurantId']?.toString() ?? 'unknown';
        final name = d['restaurantName']?.toString() ?? 'Unknown';

        totalCashback += cashback;
        totalRedemptionFees += fee;
        totalCashbackDistributed += cashback;

        restaurantMap.putIfAbsent(id, () => RestaurantData(
          name: name,
          cashback: 0,
          redemptionFees: 0,
          netRevenue: 0,
          redemptionCount: 0,
        ));

        final r = restaurantMap[id]!;
        restaurantMap[id] = RestaurantData(
          name: name,
          cashback: r.cashback + cashback,
          redemptionFees: r.redemptionFees + fee,
          netRevenue: r.netRevenue + (fee - cashback),
          redemptionCount: r.redemptionCount + 1,
        );
      }
      totalCashbackRedeemed = totalCashback;
      _filterRestaurants();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterRestaurants() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredRestaurants = restaurantMap.values
          .where((r) => r.name.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _selectedStartDate, end: _selectedEndDate),
    );
    if (picked != null) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
      });
      _fetchTransactions();
    }
  }

  void _downloadCSV() {
    final rows = [
      ['Payment Report - $selectedMonth'],
      [],
      ['Summary'],
      ['Total Fees', totalRedemptionFees.toStringAsFixed(2)],
      ['Total Cashback', totalCashback.toStringAsFixed(2)],
      ['Net Revenue', (totalRedemptionFees - totalCashback).toStringAsFixed(2)],
      [],
      ['Restaurant', 'Redemptions', 'Cashback', 'Fees', 'Net'],
      ...filteredRestaurants.map((r) => [
        r.name,
        r.redemptionCount,
        r.cashback.toStringAsFixed(2),
        r.redemptionFees.toStringAsFixed(2),
        r.netRevenue.toStringAsFixed(2),
      ])
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final blob = html.Blob([csv.codeUnits]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..download = 'foodbuddy_report_${DateFormat('yyyy_MM').format(_selectedStartDate)}.csv'
      ..click();
    html.Url.revokeObjectUrl(url);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV downloaded!')));
  }

  @override
  Widget build(BuildContext context) {
    final netRevenue = totalRedemptionFees - totalCashback;
    final restaurants = filteredRestaurants;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7FD8BE),
        title: const Text('Monthly Payment Reports', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _fetchTransactions),
          IconButton(icon: const Icon(Icons.auto_awesome, color: Colors.white), tooltip: 'Auto-refresh ON', onPressed: () {}),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF7FD8BE)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search restaurants...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            // // Charts
            // if (restaurants.isNotEmpty) ...[
            //   const _SectionHeader(title: 'Revenue Breakdown', subtitle: 'Visual overview'),
            //   const SizedBox(height: 16),
            //   Row(
            //     children: [
            //       Expanded(child: _PieChartWidget(fees: totalRedemptionFees, cashback: totalCashback)),
            //       const SizedBox(width: 16),
            //       Expanded(child: _BarChartWidget(data: restaurants.take(5).toList())),
            //     ],
            //   ),
            //   const SizedBox(height: 32),
            // ],

            // Revenue Cards
            _buildRevenueCards(netRevenue),
            const SizedBox(height: 32),

            // Date & Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [const Icon(Icons.calendar_today, size: 16), const SizedBox(width: 8), Text(selectedMonth)]),
                Row(children: [
                  OutlinedButton.icon(onPressed: _selectDateRange, icon: const Icon(Icons.edit_calendar), label: const Text('Change')),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(onPressed: _downloadCSV, icon: const Icon(Icons.download), label: const Text('CSV')),
                ]),
              ],
            ),
            const SizedBox(height: 32),

            // Table
            _SectionHeader(title: 'Restaurant Breakdown', subtitle: '${restaurants.length} restaurants'),
            const SizedBox(height: 16),
            _buildTable(restaurants),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCards(double netRevenue) {
    return Row(
      children: [
        Expanded(child: _RevenueCard(title: 'Fees', amount: '\$${totalRedemptionFees.toStringAsFixed(2)}', icon: Icons.payments, color: const Color(0xFF7FD8BE))),
        const SizedBox(width: 16),
        Expanded(child: _RevenueCard(title: 'Cashback', amount: '\$${totalCashback.toStringAsFixed(2)}', icon: Icons.card_giftcard, color: const Color(0xFFFF6B9D))),
        const SizedBox(width: 16),
        Expanded(child: _RevenueCard(title: 'Net', amount: '\$${netRevenue.toStringAsFixed(2)}', icon: Icons.trending_up, color: const Color(0xFF00897B))),
      ],
    );
  }

  Widget _buildTable(List<RestaurantData> restaurants) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)]),
      child: restaurants.isEmpty
          ? const Padding(padding: EdgeInsets.all(40), child: Text('No data', style: TextStyle(color: Colors.grey)))
          : Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(color: Color(0xFF7FD8BE), borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
            child: const Row(children: [
              Expanded(flex: 2, child: Text('Restaurant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
              Expanded(child: Text('Count', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
              Expanded(child: Text('Cashback', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
              Expanded(child: Text('Fees', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
              Expanded(child: Text('Net', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
            ]),
          ),
          ...restaurants.asMap().entries.map((e) {
            final r = e.value;
            final even = e.key % 2 == 0;
            return _RestaurantRow(data: r, isEven: even);
          }),
        ],
      ),
    );
  }
}

// ────────────────── NEW WIDGETS ──────────────────
// REPLACE BOTH CHART WIDGETS WITH THESE
class _PieChartWidget extends StatelessWidget {
  final double fees, cashback;
  const _PieChartWidget({required this.fees, required this.cashback});

  @override
  Widget build(BuildContext context) {
    final total = fees + cashback;
    if (total == 0) {
      return const Card(
        child: Padding(padding: EdgeInsets.all(40), child: Text('No data')),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(                     // ← THIS WRAPS THE CARD
        height: 260,                      // ← FIXED HEIGHT = NO INFINITY
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Revenue Split', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Expanded(                     // ← LET PIE FILL THE REMAINING SPACE
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: fees,
                        color: const Color(0xFF7FD8BE),
                        title: '${(fees / total * 100).toInt()}%',
                        titleStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      PieChartSectionData(
                        value: cashback,
                        color: const Color(0xFFFF6B9D),
                        title: '${(cashback / total * 100).toInt()}%',
                        titleStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                    sectionsSpace: 4,
                    centerSpaceRadius: 30,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Keep your existing helper widgets below (_SectionHeader, _RevenueCard, etc.)
// ... (copy-paste them from your old file – they stay 100% the same)

class _SectionHeader extends StatelessWidget {
  final String title, subtitle;
  const _SectionHeader({required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)), Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey))]);
}

class _RevenueCard extends StatelessWidget {
  final String title, amount;
  final IconData icon;
  final Color color;
  const _RevenueCard({required this.title, required this.amount, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]), borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 13)), Icon(icon, color: Colors.white)]),
        const SizedBox(height: 16),
        Text(amount, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _RestaurantRow extends StatelessWidget {
  final RestaurantData data;
  final bool isEven;
  const _RestaurantRow({required this.data, required this.isEven});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: isEven ? const Color(0xFFF8FAFB) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(children: [
        Expanded(flex: 2, child: Text(data.name, style: const TextStyle(fontWeight: FontWeight.w500))),
        Expanded(child: Text('${data.redemptionCount}', textAlign: TextAlign.center)),
        Expanded(child: Text('\$${data.cashback.toStringAsFixed(2)}', textAlign: TextAlign.center)),
        Expanded(child: Text('\$${data.redemptionFees.toStringAsFixed(2)}', textAlign: TextAlign.center)),
        Expanded(child: Text('\$${data.netRevenue.toStringAsFixed(2)}', textAlign: TextAlign.center, style: TextStyle(color: data.netRevenue >= 0 ? const Color(0xFF00897B) : Colors.red, fontWeight: FontWeight.w600))),
      ]),
    );
  }
}

class RestaurantData {
  final String name;
  final double cashback, redemptionFees, netRevenue;
  final int redemptionCount;
  RestaurantData({required this.name, required this.cashback, required this.redemptionFees, required this.netRevenue, required this.redemptionCount});
}