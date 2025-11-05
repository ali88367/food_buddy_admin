import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:food_buddy_admin/colors.dart';

import 'edit_restaurant.dart';

class RestaurantPage extends StatefulWidget {
  const RestaurantPage({Key? key}) : super(key: key);

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  final TextEditingController _searchController = TextEditingController();
  String selectedTab = 'Pending';
  List<Restaurant> restaurants = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRestaurants();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchRestaurants() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('restaurants').get();

      final List<Restaurant> loadedRestaurants = snapshot.docs.map((doc) {
        final data = doc.data();
        return Restaurant(
          id: doc.id,
          name: data['restaurant_name'] ?? 'Unknown',
          location: data['address'] ?? 'No Address',
          type: data['restaurant_type'] ?? 'Unknown',
          hours: '${data['opening_time'] ?? 'N/A'} - ${data['closing_time'] ?? 'N/A'}',
          phone: data['phone'] ?? 'No Phone',
          email: data['email'] ?? 'No Email',
          rating: (data['average_ratings'] ?? 0).toDouble(),
          reviewCount: data['total_reviews'] ?? 0,
          createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
          status: data['is_approved']?.toString().toUpperCase() ?? 'PENDING',
          imageUrl: data['image_url'] ?? '',
          services: List<String>.from(data['services'] ?? []),
          openStatus: data['open_status'] ?? true,
          emailApprovalStatus: data['is_approved_email']?.toString().toLowerCase() ?? 'pending',
          licenseUrl: data['license_url'] ?? '',
          licenseVerified: data['license_verified'] ?? false,
        );
      }).toList();

      setState(() {
        restaurants = loadedRestaurants;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching restaurants: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _verifyEmail(Restaurant restaurant) async {
    try {
      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurant.id)
          .update({'is_approved_email': 'approved'});

      setState(() {
        restaurant.emailApprovalStatus = 'approved';
      });
    } catch (e) {
      debugPrint('Error verifying email: $e');
    }
  }

  void _showVerificationDialog(Restaurant restaurant) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => VerificationDialog(
        restaurant: restaurant,
        onApprove: () async {
          try {
            await FirebaseFirestore.instance
                .collection('restaurants')
                .doc(restaurant.id)
                .update({
              'is_approved': 'approved',
              'license_verified': true,
            });
            setState(() {
              restaurant.status = 'APPROVED';
              restaurant.licenseVerified = true;
            });
            Navigator.pop(context);
          } catch (e) {
            debugPrint('Error approving: $e');
          }
        },
        onReject: () async {
          try {
            await FirebaseFirestore.instance
                .collection('restaurants')
                .doc(restaurant.id)
                .update({'is_approved': 'rejected'});
            setState(() {
              restaurant.status = 'REJECTED';
            });
            Navigator.pop(context);
          } catch (e) {
            debugPrint('Error rejecting: $e');
          }
        },
      ),
    );
  }

  List<Restaurant> get filteredRestaurants {
    final query = _searchController.text.toLowerCase();
    return restaurants.where((restaurant) {
      final matchesSearch = query.isEmpty ||
          restaurant.name.toLowerCase().contains(query) ||
          restaurant.type.toLowerCase().contains(query) ||
          restaurant.location.toLowerCase().contains(query);
      final matchesTab = selectedTab == 'Pending'
          ? restaurant.status == 'PENDING'
          : selectedTab == 'Approved'
          ? restaurant.status == 'APPROVED'
          : restaurant.status == 'REJECTED';
      return matchesSearch && matchesTab;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(32, 20, 32, 20),
              decoration: BoxDecoration(
                color: Colors.white,
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
                  const Text(
                    'Restaurant Management',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage and approve restaurant listings',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Row(
                children: [
                  _buildTab('Pending', filteredRestaurants.where((r) => r.status == 'PENDING').length),
                  const SizedBox(width: 32),
                  _buildTab('Approved', filteredRestaurants.where((r) => r.status == 'APPROVED').length),
                  const SizedBox(width: 32),
                  _buildTab('Rejected', filteredRestaurants.where((r) => r.status == 'REJECTED').length),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Icon(
                        Icons.search_rounded,
                        color: Colors.grey[400],
                        size: 22,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF212121),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search by name, type, or location...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Restaurant Cards
            Expanded(
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF4CAF50),
                  strokeWidth: 3,
                ),
              )
                  : filteredRestaurants.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restaurant_menu_outlined,
                      size: 64,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No restaurants found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 20),
                itemCount: filteredRestaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = filteredRestaurants[index];
                  return RestaurantCard(
                    restaurant: restaurant,
                    onVerifyEmail: () => _verifyEmail(restaurant),
                    onVerify: () => _showVerificationDialog(restaurant),
                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditRestaurantPage(
                            restaurant: restaurant,
                            onSave: () => fetchRestaurants(),
                          ),
                        ),
                      );
                    },
                    selectedTab: selectedTab,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int count) {
    final isSelected = selectedTab == title;
    Color tabColor;

    if (title == 'Pending') {
      tabColor = Colors.grey.shade600;
    } else if (title == 'Approved') {
      tabColor = const Color(0xFF4CAF50);
    } else {
      tabColor = const Color(0xFFE74C3C);
    }

    return GestureDetector(
      onTap: () => setState(() => selectedTab = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? tabColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? tabColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? tabColor : Colors.grey.shade600,
              ),
            ),
            // const SizedBox(width: 8),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            //   decoration: BoxDecoration(
            //     color: isSelected ? tabColor : Colors.grey.shade300,
            //     borderRadius: BorderRadius.circular(10),
            //   ),
            //   child: Text(
            //     count.toString(),
            //     style: TextStyle(
            //       fontSize: 12,
            //       fontWeight: FontWeight.w600,
            //       color: isSelected ? Colors.white : Colors.grey.shade700,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// RESTAURANT CARD
// ===========================================================================
class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onVerifyEmail;
  final VoidCallback onVerify;
  final VoidCallback onEdit;
  final String selectedTab;

  const RestaurantCard({
    Key? key,
    required this.restaurant,
    required this.onVerifyEmail,
    required this.onVerify,
    required this.onEdit,
    required this.selectedTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool canVerify = restaurant.emailApprovalStatus == 'approved';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: restaurant.status == 'APPROVED'
              ? const Color(0xFF4CAF50).withOpacity(0.2)
              : restaurant.status == 'REJECTED'
              ? const Color(0xFFE74C3C).withOpacity(0.2)
              : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: restaurant.status == 'APPROVED'
                ? const Color(0xFF4CAF50).withOpacity(0.08)
                : restaurant.status == 'REJECTED'
                ? const Color(0xFFE74C3C).withOpacity(0.08)
                : Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: restaurant.status == 'APPROVED'
                      ? [const Color(0xFF4CAF50).withOpacity(0.1), Colors.white]
                      : restaurant.status == 'REJECTED'
                      ? [const Color(0xFFE74C3C).withOpacity(0.1), Colors.white]
                      : [Colors.grey.shade100, Colors.white],
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  restaurant.imageUrl.isNotEmpty
                      ? Image.network(
                    restaurant.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.restaurant_rounded,
                          size: 48,
                          color: restaurant.status == 'APPROVED'
                              ? const Color(0xFF4CAF50).withOpacity(0.3)
                              : restaurant.status == 'REJECTED'
                              ? const Color(0xFFE74C3C).withOpacity(0.3)
                              : Colors.grey[400],
                        ),
                      );
                    },
                  )
                      : Center(
                    child: Icon(
                      Icons.restaurant_rounded,
                      size: 48,
                      color: restaurant.status == 'APPROVED'
                          ? const Color(0xFF4CAF50).withOpacity(0.3)
                          : restaurant.status == 'REJECTED'
                          ? const Color(0xFFE74C3C).withOpacity(0.3)
                          : Colors.grey[400],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                        stops: const [0.0, 0.3, 0.7, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: restaurant.status == 'APPROVED'
                            ? const Color(0xFF4CAF50)
                            : restaurant.status == 'REJECTED'
                            ? const Color(0xFFE74C3C)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: restaurant.status == 'PENDING'
                            ? Border.all(color: Colors.grey.shade300, width: 1.5)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: (restaurant.status == 'APPROVED'
                                ? const Color(0xFF4CAF50)
                                : restaurant.status == 'REJECTED'
                                ? const Color(0xFFE74C3C)
                                : Colors.grey)
                                .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        restaurant.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: restaurant.status == 'PENDING'
                              ? Colors.grey.shade700
                              : Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: restaurant.openStatus
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFE74C3C),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: (restaurant.openStatus
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFE74C3C))
                                .withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            restaurant.openStatus ? 'Open' : 'Closed',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurant.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF212121),
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.amber.shade600,
                                    Colors.amber.shade700,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    restaurant.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    ' (${restaurant.reviewCount})',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // ACTION BUTTONS
                      if (selectedTab == 'Pending') ...[
                        if (restaurant.emailApprovalStatus == 'pending')
                          _buildActionButton(
                            icon: Icons.mark_email_read_rounded,
                            color: Colors.blue,
                            onTap: onVerifyEmail,
                            tooltip: 'Verify Email',
                          ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: Icons.verified_user_rounded,
                          color: canVerify ? const Color(0xFF9C27B0) : Colors.grey.shade400,
                          onTap: canVerify ? onVerify : null,
                          tooltip: canVerify
                              ? 'Verify Restaurant & License'
                              : 'Verify email first',
                        ),
                      ],
                      if (selectedTab == 'Approved')
                        _buildActionButton(
                          icon: Icons.edit_rounded,
                          color: const Color(0xFF4CAF50),
                          onTap: onEdit,
                          tooltip: 'Edit',
                        ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Wrap(
                    spacing: 24,
                    runSpacing: 10,
                    children: [
                      _buildInfoItem(Icons.location_on_rounded, restaurant.location),
                      _buildInfoItem(Icons.restaurant_menu_rounded,
                          '${restaurant.type} • ${restaurant.services.join(", ")}'),
                      _buildInfoItem(Icons.schedule_rounded, restaurant.hours),
                      _buildInfoItem(Icons.phone_rounded, restaurant.phone),
                      _buildInfoItem(Icons.email_rounded, restaurant.email),
                      _buildInfoItem(Icons.calendar_today_rounded,
                          'Joined ${DateFormat.yMMMd().format(restaurant.createdAt)}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    required String tooltip,
  }) {
    final bool isEnabled = onTap != null;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.4,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(isEnabled ? 0.15 : 0.05),
                  color.withOpacity(isEnabled ? 0.08 : 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: color.withOpacity(isEnabled ? 0.4 : 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(isEnabled ? 0.2 : 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 20, color: isEnabled ? color : Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF4CAF50)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// PROFESSIONAL VERIFICATION DIALOG
// ===========================================================================
class VerificationDialog extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const VerificationDialog({
    Key? key,
    required this.restaurant,
    required this.onApprove,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPdf = restaurant.licenseUrl.toLowerCase().endsWith('.pdf');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 20,
      child: Container(
        width: 900,
        constraints: const BoxConstraints(maxHeight: 800),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF86E3D0), // base aqua color
                    Color(0xFF6BD3BF), // slightly darker tone
                    Color(0xFF4CC3AE), // deeper teal shade
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),


        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_rounded, color: Colors.white, size: 32),
                  const SizedBox(width: 16),
                  const Text(
                    'Restaurant Verification',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('Restaurant Name', restaurant.name, Icons.store),
                            const Divider(height: 24),
                            _buildInfoRow('Address', restaurant.location, Icons.location_on),
                            _buildInfoRow('Type', restaurant.type, Icons.category),
                            _buildInfoRow('Services', restaurant.services.join(', '), Icons.room_service),
                            _buildInfoRow('Hours', restaurant.hours, Icons.access_time),
                            _buildInfoRow('Phone', restaurant.phone, Icons.phone),
                            _buildInfoRow('Email', restaurant.email, Icons.email),
                            _buildInfoRow('Joined', DateFormat.yMMMd().format(restaurant.createdAt), Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // License Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.description, color: background),
                                const SizedBox(width: 8),
                                const Text(
                                  'Business License',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (restaurant.licenseUrl.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error, color: Colors.red),
                                    const SizedBox(width: 8),
                                    const Text('No license uploaded', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              )
                            else
                              Container(
                                height: 380,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: isPdf
                                      ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.picture_as_pdf, size: 80, color: Colors.red),
                                        const SizedBox(height: 16),
                                        ElevatedButton.icon(
                                          onPressed: (){},
                                        //  onPressed: () => jsAllowInterop(window.open(restaurant.licenseUrl, '_blank')),
                                          icon: const Icon(Icons.open_in_new),
                                          label: const Text('Open PDF in New Tab'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: background,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                      : Image.network(
                                    restaurant.licenseUrl,
                                    fit: BoxFit.contain,
                                    loadingBuilder: (context, child, progress) {
                                      return progress == null ? child : const Center(child: CircularProgressIndicator());
                                    },
                                    errorBuilder: (context, error, stackTrace) =>
                                    const Center(child: Icon(Icons.broken_image, size: 80, color: Colors.grey)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: onReject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE74C3C),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Reject', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: Colors.white)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Approve', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: background),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF212121)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// RESTAURANT MODEL
// ===========================================================================
class Restaurant {
  final String id;
  final String name;
  final String location;
  final String type;
  final String hours;
  final String phone;
  final String email;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  String status;
  final String imageUrl;
  final List<String> services;
  final bool openStatus;

  String emailApprovalStatus;
  String licenseUrl;
  bool licenseVerified;

  Restaurant({
    required this.id,
    required this.name,
    required this.location,
    required this.type,
    required this.hours,
    required this.phone,
    required this.email,
    required this.rating,
    required this.reviewCount,
    required this.createdAt,
    required this.status,
    required this.imageUrl,
    required this.services,
    required this.openStatus,
    required this.emailApprovalStatus,
    required this.licenseUrl,
    required this.licenseVerified,
  });
}