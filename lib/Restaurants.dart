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
          status: data['is_approved']?.toUpperCase() ?? 'PENDING',
          imageUrl: data['image_url'] ?? '',
          services: List<String>.from(data['services'] ?? []),
          openStatus: data['open_status'] ?? true,
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

  Future<void> _approveRestaurant(Restaurant restaurant) async {
    try {
      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurant.id)
          .update({'is_approved': 'approved'});
      setState(() {
        restaurant.status = 'APPROVED';
      });
    } catch (e) {
      debugPrint('Error approving restaurant: $e');
    }
  }

  Future<void> _rejectRestaurant(Restaurant restaurant) async {
    try {
      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurant.id)
          .update({'is_approved': 'rejected'});
      setState(() {
        restaurant.status = 'REJECTED';
      });
    } catch (e) {
      debugPrint('Error rejecting restaurant: $e');
    }
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
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.fromLTRB(40, 24, 40, 16),
              child: Text(
                'Restaurants',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                children: [
                  _buildTab('Pending'),
                  const SizedBox(width: 24),
                  _buildTab('Approved'),
                  const SizedBox(width: 24),
                  _buildTab('Rejected'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Icon(
                        Icons.search,
                        color: Color(0xFFFF6B6B),
                        size: 24,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Search by name, type, or location...',
                          hintStyle: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Restaurant Cards
            Expanded(
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFF6B6B),
                ),
              )
                  : filteredRestaurants.isEmpty
                  ? const Center(
                child: Text(
                  'No restaurants found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),
              )
                  : GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: filteredRestaurants.length,
                itemBuilder: (context, index) {
                  return RestaurantCard(
                    restaurant: filteredRestaurants[index],
                    onApprove: () => _approveRestaurant(filteredRestaurants[index]),
                    onReject: () => _rejectRestaurant(filteredRestaurants[index]),
                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditRestaurantPage(
                            restaurant: filteredRestaurants[index],
                            onSave: () => fetchRestaurants(), // Refresh list after save
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

  Widget _buildTab(String title) {
    final isSelected = selectedTab == title;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = title),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isSelected ? const Color(0xFFFF6B6B) : Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFF6B6B) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onEdit;
  final String selectedTab;

  const RestaurantCard({
    Key? key,
    required this.restaurant,
    required this.onApprove,
    required this.onReject,
    required this.onEdit,
    required this.selectedTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image and Status
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: restaurant.imageUrl.isNotEmpty
                      ? Image.network(
                    restaurant.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.restaurant,
                        size: 40,
                        color: Colors.grey,
                      );
                    },
                  )
                      : const Icon(
                    Icons.restaurant,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: restaurant.status == 'APPROVED'
                        ? const Color(0xFF4CAF50).withOpacity(0.9)
                        : restaurant.status == 'REJECTED'
                        ? const Color(0xFFE74C3C).withOpacity(0.9)
                        : Colors.grey[300]!.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    restaurant.status,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Color(0xFFFF6B6B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant.location,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Type and Services
                  Row(
                    children: [
                      const Icon(Icons.restaurant_menu, size: 14, color: Color(0xFFFF6B6B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${restaurant.type} • ${restaurant.services.join(", ")}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Hours
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Color(0xFFFF6B6B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant.hours,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Phone
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 14, color: Color(0xFFFF6B6B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant.phone,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Email
                  Row(
                    children: [
                      const Icon(Icons.email, size: 14, color: Color(0xFFFF6B6B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant.email,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Created At
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Color(0xFFFF6B6B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Created: ${DateFormat.yMMMd().format(restaurant.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Color(0xFFFF6B6B)),
                      const SizedBox(width: 4),
                      Text(
                        '${restaurant.rating.toStringAsFixed(1)} (${restaurant.reviewCount} reviews)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (selectedTab == 'Pending') ...[
                        TextButton(
                          onPressed: onApprove,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF4CAF50),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Approve',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: onReject,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFFE74C3C),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Reject',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                      if (selectedTab == 'Approved')
                        TextButton(
                          onPressed: onEdit,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFFFF6B6B),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Edit',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
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
}

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
  });
}