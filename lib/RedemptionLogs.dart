import 'package:flutter/material.dart';


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

  List<RedemptionLog> allLogs = [
    RedemptionLog(
      restaurantName: 'sogat blasting burger',
      offerName: 'test',
      customerName: 'khalid',
      customerId: 'taEVaGmJqnPmM4deAXgd70mPAJW2',
      timestamp: DateTime(2025, 10, 13, 19, 0),
      status: 'pending',
    ),
    RedemptionLog(
      restaurantName: 'Blasting',
      offerName: 'New',
      customerName: 'khalid',
      customerId: 'taEVaGmJqnPmM4deAXgd70mPAJW2',
      timestamp: DateTime(2025, 10, 13, 19, 0),
      status: 'pending',
    ),
  ];

  List<RedemptionLog> get filteredLogs {
    return allLogs.where((log) {
      final searchQuery = _searchController.text.toLowerCase();
      final matchesSearch = searchQuery.isEmpty ||
          log.restaurantName.toLowerCase().contains(searchQuery) ||
          log.offerName.toLowerCase().contains(searchQuery) ||
          log.customerName.toLowerCase().contains(searchQuery);

      final matchesRestaurant = selectedRestaurant == null ||
          log.restaurantName == selectedRestaurant;
      final matchesCustomer = selectedCustomer == null ||
          log.customerName == selectedCustomer;
      final matchesOffer = selectedOffer == null ||
          log.offerName == selectedOffer;
      final matchesStatus = selectedStatus == null ||
          log.status == selectedStatus;

      return matchesSearch && matchesRestaurant && matchesCustomer &&
          matchesOffer && matchesStatus;
    }).toList();
  }

  void _exportCSV() {
    // CSV export logic would go here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting to CSV...')),
    );
  }

  void _exportPDF() {
    // PDF export logic would go here
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
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 25),
                // Search Bar with Export Buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.grey.shade300, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Icon(
                                Icons.search,
                                color: Color(0xFF7DD4C7),
                                size: 24,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (_) => setState(() {}),
                                style: const TextStyle(fontSize: 15),
                                decoration: const InputDecoration(
                                  hintText: 'Search by Restaurant, Offer or Customer',
                                  hintStyle: TextStyle(
                                    color: Colors.black38,
                                    fontSize: 15,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    // CSV Button
                    ElevatedButton.icon(
                      onPressed: _exportCSV,
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('CSV'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7DD4C7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // PDF Button
                    ElevatedButton.icon(
                      onPressed: _exportPDF,
                      icon: const Icon(Icons.picture_as_pdf, size: 18),
                      label: const Text('PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7DD4C7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Filter Row
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown(
                        'Restaurant',
                        Icons.restaurant,
                        selectedRestaurant,
                        ['sogat blasting burger', 'Blasting'],
                            (value) => setState(() => selectedRestaurant = value),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildFilterDropdown(
                        'Customer',
                        Icons.person,
                        selectedCustomer,
                        ['khalid'],
                            (value) => setState(() => selectedCustomer = value),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildFilterDropdown(
                        'Offer',
                        Icons.local_offer,
                        selectedOffer,
                        ['test', 'New'],
                            (value) => setState(() => selectedOffer = value),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildFilterDropdown(
                        'Status',
                        Icons.tune,
                        selectedStatus,
                        ['pending', 'completed', 'cancelled'],
                            (value) => setState(() => selectedStatus = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                // Date Filters
                Row(
                  children: [
                    _buildDateButton(
                      'Start Date',
                      startDate,
                      _selectStartDate,
                    ),
                    const SizedBox(width: 15),
                    _buildDateButton(
                      'End Date',
                      endDate,
                      _selectEndDate,
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                // Logs List
                ...filteredLogs.map((log) => Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: RedemptionLogCard(log: log),
                )),
                if (filteredLogs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Text(
                      'No redemption logs found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
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
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFF7DD4C7), width: 2),
        ),
        child: Text(
          date == null
              ? label
              : '${date.day}/${date.month}/${date.year}',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Restaurant Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF7DD4C7).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.restaurant,
              color: Color(0xFF7DD4C7),
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.restaurantName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.local_offer, size: 14, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text(
                      log.offerName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person, size: 14, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text(
                      '${log.customerName} (${log.customerId})',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text(
                      '${log.timestamp.day.toString().padLeft(2, '0')} ${_getMonthName(log.timestamp.month)}, ${log.timestamp.year} ${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusColor(log.status).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              log.status,
              style: TextStyle(
                fontSize: 14,
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
  final String restaurantName;
  final String offerName;
  final String customerName;
  final String customerId;
  final DateTime timestamp;
  final String status;

  RedemptionLog({
    required this.restaurantName,
    required this.offerName,
    required this.customerName,
    required this.customerId,
    required this.timestamp,
    required this.status,
  });
}