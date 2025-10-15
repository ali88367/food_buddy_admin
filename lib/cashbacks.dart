import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CashbackMonitoringPage extends StatefulWidget {
  const CashbackMonitoringPage({Key? key}) : super(key: key);

  @override
  State<CashbackMonitoringPage> createState() => _CashbackMonitoringPageState();
}

class _CashbackMonitoringPageState extends State<CashbackMonitoringPage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<UserCashback> userBreakdown = [];
  List<RestaurantCashback> restaurantBreakdown = [];
  List<ThresholdAlert> thresholdAlerts = [];
  double totalCashback = 0;
  double totalRedempionFees = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTransactionData();
  }

  Future<void> _fetchTransactionData() async {
    try {
      setState(() => isLoading = true);

      // Fetch all completed transactions
      final querySnapshot = await _firestore
          .collection('transactions')
          .where('status', isEqualTo: 'completed')
          .get();

      Map<String, double> userCashbackMap = {};
      Map<String, double> restaurantCashbackMap = {};
      // This map will store users who just crossed the threshold
      Map<String, double> triggeredAlerts = {};
      double cashbackSum = 0;
      double feesSum = 0;

      // 1. First, process all transactions to aggregate data
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final cashback = (data['cashbackAmount'] ?? 0).toDouble();
        final fee = (data['transactionFee'] ?? 0).toDouble();
        final customerId = data['customerId'] ?? 'Unknown';
        final restaurantName = data['restaurantName'] ?? 'Unknown';

        // Sum totals
        cashbackSum += cashback;
        feesSum += fee;

        // Get user's cashback total before this transaction
        double previousCashback = userCashbackMap[customerId] ?? 0;
        // Update user's cashback total
        userCashbackMap[customerId] = previousCashback + cashback;

        // Group by restaurant
        restaurantCashbackMap[restaurantName] =
            (restaurantCashbackMap[restaurantName] ?? 0) + cashback;

        // Check if this transaction made the user cross the threshold
        if (userCashbackMap[customerId]! >= 5.0 && previousCashback < 5.0) {
          triggeredAlerts[customerId] = userCashbackMap[customerId]!;
        }
      }

      // 2. Get all unique user IDs to fetch their names
      final userIds = userCashbackMap.keys.toList();
      Map<String, String> userIdToNameMap = {};

      if (userIds.isNotEmpty) {
        // Firestore 'whereIn' can handle up to 30 items per query.
        // We'll batch requests if there are more than 30 users.
        List<List<String>> chunks = [];
        for (var i = 0; i < userIds.length; i += 30) {
          chunks.add(userIds.sublist(i, i + 30 > userIds.length ? userIds.length : i + 30));
        }

        for (final chunk in chunks) {
          final usersSnapshot = await _firestore
              .collection('users')
              .where(FieldPath.documentId, whereIn: chunk)
              .get();

          for (var userDoc in usersSnapshot.docs) {
            // Assuming the field name in your 'users' collection is 'user_name'
            userIdToNameMap[userDoc.id] = userDoc.data()['user_name'] as String? ?? 'Unknown User';
          }
        }
      }

      // 3. Now, build the final lists using the fetched user names
      final finalUserBreakdown = userCashbackMap.entries.map((entry) {
        final userId = entry.key;
        // Use the fetched name, or fallback to the user ID if not found
        final userName = userIdToNameMap[userId] ?? userId;
        return UserCashback(userName: userName, totalCashback: entry.value);
      }).toList()
        ..sort((a, b) => b.totalCashback.compareTo(a.totalCashback));

      final finalAlerts = triggeredAlerts.entries.map((entry) {
        final userId = entry.key;
        final userName = userIdToNameMap[userId] ?? userId;
        final totalCashback = entry.value;
        return ThresholdAlert(
          message:
          'User $userName has reached \$5 threshold with \$${totalCashback.toStringAsFixed(2)}',
        );
      }).toList();

      setState(() {
        totalCashback = cashbackSum;
        totalRedempionFees = feesSum;
        userBreakdown = finalUserBreakdown;
        restaurantBreakdown = restaurantCashbackMap.entries
            .map((e) =>
            RestaurantCashback(restaurantName: e.key, totalCashback: e.value))
            .toList()
          ..sort((a, b) => b.totalCashback.compareTo(a.totalCashback));
        thresholdAlerts = finalAlerts;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar('Error fetching data: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Refresh Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                color: const Color(0xFF7DD4C7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Cashback Monitoring',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _fetchTransactionData,
                      tooltip: 'Refresh Data',
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overview Section
                      const Text(
                        'Overview',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Overview Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildOverviewCard(
                              'Total Cashback',
                              '\$${totalCashback.toStringAsFixed(2)}',
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildOverviewCard(
                              'Total Redemption Fees',
                              '\$${totalRedempionFees.toStringAsFixed(2)}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      // Cashback vs Redemption Fees Chart
                      const Text(
                        'Cashback vs Redemption Fees',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        width: double.infinity,
                        height: 220,
                        padding: const EdgeInsets.all(20),
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
                        child: _buildComparisonChart(),
                      ),
                      const SizedBox(height: 40),
                      // Breakdown by User
                      const Text(
                        'Breakdown by User',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildUserTable(),
                      const SizedBox(height: 40),
                      // Breakdown by Restaurant
                      const Text(
                        'Breakdown by Restaurant',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildRestaurantTable(),
                      const SizedBox(height: 40),
                      // Threshold Alerts
                      const Text(
                        'Threshold Alerts',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(25),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (thresholdAlerts.isEmpty)
                              const Text(
                                'No users approaching \$5 threshold.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            if (thresholdAlerts.isNotEmpty)
                              ...thresholdAlerts.map((alert) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.orange,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        alert.message,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(String title, String amount) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF7DD4C7),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonChart() {
    final maxValue = (totalCashback > totalRedempionFees ? totalCashback : totalRedempionFees) * 1.2;
    final cashbackPercent = maxValue > 0 ? (totalCashback / maxValue).toDouble() : 0.0;
    final feesPercent = maxValue > 0 ? (totalRedempionFees / maxValue).toDouble() : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cashback Bar
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Cashback',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '\$${totalCashback.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7DD4C7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: cashbackPercent,
                  minHeight: 30,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7DD4C7)),
                ),
              ),
            ],
          ),
        ),
        // Redemption Fees Bar
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Redemption Fees',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "\$${totalRedempionFees.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[300],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: feesPercent,
                minHeight: 30,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red[300]!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserTable() {
    return Container(
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
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF7DD4C7),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: const [
                Expanded(
                  // *** CHANGE: Updated table header text ***
                  child: Text(
                    'User Name',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  'Total Cashback',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (userBreakdown.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Text(
                'No data available',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black38,
                ),
              ),
            ),
          ...userBreakdown.map((user) => Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    user.userName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Text(
                  '\$${user.totalCashback.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRestaurantTable() {
    return Container(
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
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF7DD4C7),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: const [
                Expanded(
                  child: Text(
                    'Restaurant',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  'Total Cashback',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (restaurantBreakdown.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Text(
                'No data available',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black38,
                ),
              ),
            ),
          ...restaurantBreakdown.map((restaurant) => Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    restaurant.restaurantName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Text(
                  '\$${restaurant.totalCashback.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class UserCashback {
  final String userName;
  final double totalCashback;

  UserCashback({
    required this.userName,
    required this.totalCashback,
  });
}

class RestaurantCashback {
  final String restaurantName;
  final double totalCashback;

  RestaurantCashback({
    required this.restaurantName,
    required this.totalCashback,
  });
}

class ThresholdAlert {
  final String message;

  ThresholdAlert({
    required this.message,
  });
}