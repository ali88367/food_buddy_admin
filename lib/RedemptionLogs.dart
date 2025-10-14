import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:food_buddy_admin/colors.dart';

class RedemptionLogsPage extends StatefulWidget {
  const RedemptionLogsPage({Key? key}) : super(key: key);

  @override
  State<RedemptionLogsPage> createState() => _RedemptionLogsPageState();
}

class _RedemptionLogsPageState extends State<RedemptionLogsPage> {
  final TextEditingController _searchController = TextEditingController();
  String? selectedRestaurant;
  String? selectedCustomer;
  String? selectedOffer;
  String? selectedStatus;
  DateTime? startDate;
  DateTime? endDate;
  List<RedemptionLog> allLogs = [];
  bool isLoading = true;
  List<String> restaurantNames = [];
  List<String> customerIds = [];
  List<String> offerTitles = [];
  List<String> statuses = ['pending', 'completed', 'cancelled'];
  final Map<String, String> userNameCache = {};

  @override
  void initState() {
    super.initState();
    fetchRedemptionLogs();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<String> _fetchUserName(String userId) async {
    if (userNameCache.containsKey(userId)) {
      return userNameCache[userId]!;
    }
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final userName = userDoc.exists ? (userDoc.data()?['user_name'] ?? userId) : userId;
      userNameCache[userId] = userName;
      return userName;
    } catch (e) {
      debugPrint('Error fetching user name for $userId: $e');
      return userId;
    }
  }

  Future<void> fetchRedemptionLogs() async {
    try {
      final restaurantSnapshot = await FirebaseFirestore.instance.collection('restaurants').get();
      debugPrint('Fetched ${restaurantSnapshot.docs.length} restaurants');

      List<RedemptionLog> loadedLogs = [];
      Set<String> restaurants = {};
      Set<String> customers = {};
      Set<String> offers = {};

      for (var restaurantDoc in restaurantSnapshot.docs) {
        final redemptionSnapshot = await restaurantDoc.reference.collection('redemptions').get();
        debugPrint('Restaurant ${restaurantDoc.id}: Fetched ${redemptionSnapshot.docs.length} redemptions');

        for (var doc in redemptionSnapshot.docs) {
          final data = doc.data();
          debugPrint('Redemption ID: ${doc.id}, Data: $data');
          final userName = await _fetchUserName(data['userId'] ?? '');
          loadedLogs.add(RedemptionLog(
            redemptionId: doc.id,
            restaurantId: data['restaurantId'] ?? restaurantDoc.id,
            restaurantName: data['restaurantName'] ?? 'Unknown',
            offerId: data['id'] ?? '',
            offerTitle: data['offerTitle'] ?? 'No Title',
            description: data['description'] ?? '',
            discountType: data['discountType'] ?? 'Unknown',
            discountValue: data['discountValue'] ?? '0',
            terms: data['terms'] ?? '',
            status: data['status']?.toLowerCase() ?? 'pending',
            createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            validFrom: (data['validFrom'] as Timestamp?)?.toDate() ?? DateTime.now(),
            validTill: (data['validTill'] as Timestamp?)?.toDate() ?? DateTime.now(),
            userId: data['userId'] ?? '',
            userName: userName,
          ));
          restaurants.add(data['restaurantName'] ?? 'Unknown');
          customers.add(userName);
          offers.add(data['offerTitle'] ?? 'No Title');
        }
      }

      setState(() {
        allLogs = loadedLogs;
        restaurantNames = restaurants.toList()..sort();
        customerIds = customers.toList()..sort();
        offerTitles = offers.toList()..sort();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching redemption logs: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load redemption logs: $e')),
      );
      setState(() => isLoading = false);
    }
  }

  void _exportCSV() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting to CSV...')),
    );
  }

  void _exportPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting to PDF...')),
    );
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => startDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => endDate = picked);
    }
  }

  List<RedemptionLog> get filteredLogs {
    return allLogs.where((log) {
      final searchQuery = _searchController.text.toLowerCase();
      final matchesSearch = searchQuery.isEmpty ||
          log.restaurantName.toLowerCase().contains(searchQuery) ||
          log.offerTitle.toLowerCase().contains(searchQuery) ||
          log.userName.toLowerCase().contains(searchQuery);

      final matchesRestaurant = selectedRestaurant == null || log.restaurantName == selectedRestaurant;
      final matchesCustomer = selectedCustomer == null || log.userName == selectedCustomer;
      final matchesOffer = selectedOffer == null || log.offerTitle == selectedOffer;
      final matchesStatus = selectedStatus == null || log.status == selectedStatus;
      final matchesDate = (startDate == null || log.createdAt.isAfter(startDate!)) &&
          (endDate == null || log.createdAt.isBefore(endDate!.add(const Duration(days: 1))));

      return matchesSearch && matchesRestaurant && matchesCustomer && matchesOffer && matchesStatus && matchesDate;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7DD4C7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                // Title
                const Text(
                  'Redemption Logs',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                // Search Bar with Export Buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(
                                Icons.search,
                                color: Color(0xFF7DD4C7),
                                size: 22,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (_) => setState(() {}),
                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                                decoration: const InputDecoration(
                                  hintText: 'Search by restaurant, offer, or user...',
                                  hintStyle: TextStyle(color: Colors.black54, fontSize: 14),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _exportCSV,
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('CSV', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7DD4C7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _exportPDF,
                      icon: const Icon(Icons.picture_as_pdf, size: 16),
                      label: const Text('PDF', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7DD4C7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Filter Row
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown(
                        'Restaurant',
                        Icons.restaurant,
                        selectedRestaurant,
                        restaurantNames,
                            (value) => setState(() => selectedRestaurant = value),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildFilterDropdown(
                        'Customer',
                        Icons.person,
                        selectedCustomer,
                        customerIds,
                            (value) => setState(() => selectedCustomer = value),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildFilterDropdown(
                        'Offer',
                        Icons.local_offer,
                        selectedOffer,
                        offerTitles,
                            (value) => setState(() => selectedOffer = value),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildFilterDropdown(
                        'Status',
                        Icons.tune,
                        selectedStatus,
                        statuses,
                            (value) => setState(() => selectedStatus = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Date Filters
                Row(
                  children: [
                    Expanded(child: _buildDateButton('Start Date', startDate, _selectStartDate)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildDateButton('End Date', endDate, _selectEndDate)),
                  ],
                ),
                const SizedBox(height: 10),
                // Logs List
                isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
                    : filteredLogs.isEmpty
                    ? const Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    'No redemption logs found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredLogs.length,
                  itemBuilder: (context, index) => Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: RedemptionLogCard(log: filteredLogs[index]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(
      String hint,
      IconData icon,
      String? value,
      List<String> items,
      Function(String?) onChanged,
      ) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text(
                  hint,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                value: value,
                items: items.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF7DD4C7), width: 2),
        ),
        child: Text(
          date == null
              ? label
              : '${date.day}/${date.month}/${date.year}',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class RedemptionLogCard extends StatelessWidget {
  final RedemptionLog log;

  const RedemptionLogCard({Key? key, required this.log}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant Icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF7DD4C7).withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.redeem,
              color: Color(0xFF7DD4C7),
              size: 20,
            ),
          ),
          const SizedBox(width: 6),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.restaurantName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.local_offer, size: 10, color: Color(0xFF7DD4C7)),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        log.offerTitle,
                        style: const TextStyle(fontSize: 8, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.person, size: 10, color: Color(0xFF7DD4C7)),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        'User: ${log.userName} (${log.userId})',
                        style: const TextStyle(fontSize: 8, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.description, size: 10, color: Color(0xFF7DD4C7)),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        log.description,
                        style: const TextStyle(fontSize: 8, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.discount, size: 10, color: Color(0xFF7DD4C7)),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        '${log.discountValue} ${log.discountType}',
                        style: const TextStyle(fontSize: 8, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.info, size: 10, color: Color(0xFF7DD4C7)),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        log.terms,
                        style: const TextStyle(fontSize: 8, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 10, color: Color(0xFF7DD4C7)),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        'Valid: ${DateFormat.yMMMd().format(log.validFrom)} - ${DateFormat.yMMMd().format(log.validTill)}',
                        style: const TextStyle(fontSize: 8, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.timer, size: 10, color: Color(0xFF7DD4C7)),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        'Created: ${DateFormat.yMMMd().format(log.createdAt)} ${DateFormat.Hm().format(log.createdAt)}',
                        style: const TextStyle(fontSize: 8, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.timer_off, size: 10, color: Color(0xFF7DD4C7)),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        'Expires: ${DateFormat.yMMMd().format(log.expiresAt)} ${DateFormat.Hm().format(log.expiresAt)}',
                        style: const TextStyle(fontSize: 8, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: _getStatusColor(log.status).withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              log.status.toUpperCase(),
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: _getStatusColor(log.status),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFF7DD4C7);
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'cancelled':
        return const Color(0xFFE74C3C);
      default:
        return Colors.grey;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

class RedemptionLog {
  final String redemptionId;
  final String restaurantId;
  final String restaurantName;
  final String offerId;
  final String offerTitle;
  final String description;
  final String discountType;
  final String discountValue;
  final String terms;
  final String status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime validFrom;
  final DateTime validTill;
  final String userId;
  final String userName;

  RedemptionLog({
    required this.redemptionId,
    required this.restaurantId,
    required this.restaurantName,
    required this.offerId,
    required this.offerTitle,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.terms,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    required this.validFrom,
    required this.validTill,
    required this.userId,
    required this.userName,
  });
}