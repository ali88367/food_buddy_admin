import 'package:flutter/material.dart';


class RestaurantPage extends StatefulWidget {
  const RestaurantPage({Key? key}) : super(key: key);

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  final TextEditingController _searchController = TextEditingController();
  String selectedTab = 'Pending';

  List<Restaurant> allRestaurants = [
    Restaurant(
      name: 'Heaven',
      location: 'HHHR Tower - Dubai - United Arab Emirates',
      type: 'Continental',
      hours: '9 am - 9am',
      phone: '+923186584407',
      email: 'heaven@gmail.com',
      rating: 0.0,
      reviewCount: 0,
      createdAt: 'Oct 11, 2025 5:43 PM',
      status: 'PENDING',
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800',
    ),
    Restaurant(
      name: 'Blasting',
      location: 'Mall of Multan, Bosan Road, Shalimar Colony, Multan, Pakistan',
      type: 'Italian',
      hours: '12:00 PM - 11:00 PM',
      phone: '+923213825155',
      email: 'blasting@gmail.com',
      rating: 3.91,
      reviewCount: 11,
      createdAt: 'Oct 11, 2025 4:44 PM',
      status: 'PENDING',
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800',
    ),
  ];

  List<Restaurant> get filteredRestaurants {
    final query = _searchController.text.toLowerCase();
    return allRestaurants.where((restaurant) {
      final matchesSearch = query.isEmpty ||
          restaurant.name.toLowerCase().contains(query) ||
          restaurant.type.toLowerCase().contains(query);
      final matchesTab = selectedTab == 'Pending'
          ? restaurant.status == 'PENDING'
          : selectedTab == 'Approved'
          ? restaurant.status == 'APPROVED'
          : restaurant.status == 'REJECTED';
      return matchesSearch && matchesTab;
    }).toList();
  }

  void _approveRestaurant(Restaurant restaurant) {
    setState(() {
      restaurant.status = 'APPROVED';
    });
  }

  void _rejectRestaurant(Restaurant restaurant) {
    setState(() {
      restaurant.status = 'REJECTED';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7DD4C7),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.fromLTRB(60, 30, 60, 20),
              child: Text(
                'Restaurants',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Row(
                children: [
                  _buildTab('Pending'),
                  const SizedBox(width: 60),
                  _buildTab('Approved'),
                  const SizedBox(width: 60),
                  _buildTab('Rejected'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
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
                          hintText: 'Search by name or type...',
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
            const SizedBox(height: 25),
            // Restaurant Cards
            Expanded(
              child: filteredRestaurants.isEmpty
                  ? const Center(
                child: Text(
                  'No restaurants found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              )
                  : GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.35,
                  crossAxisSpacing: 25,
                  mainAxisSpacing: 25,
                ),
                itemCount: filteredRestaurants.length,
                itemBuilder: (context, index) {
                  return RestaurantCard(
                    restaurant: filteredRestaurants[index],
                    onApprove: () => _approveRestaurant(filteredRestaurants[index]),
                    onReject: () => _rejectRestaurant(filteredRestaurants[index]),
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
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            width: 80,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
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

  const RestaurantCard({
    Key? key,
    required this.restaurant,
    required this.onApprove,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  color: Colors.grey[900],
                  child: Image.network(
                    restaurant.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[900],
                        child: const Icon(
                          Icons.restaurant,
                          size: 50,
                          color: Colors.white30,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    restaurant.status,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.location_on, restaurant.location, const Color(0xFF7DD4C7)),
                  const SizedBox(height: 4),
                  _buildInfoRow(Icons.restaurant_menu, 'Type: ${restaurant.type}', const Color(0xFF7DD4C7)),
                  const SizedBox(height: 4),
                  _buildInfoRow(Icons.access_time, 'Hours: ${restaurant.hours}', const Color(0xFF7DD4C7)),
                  const SizedBox(height: 4),
                  _buildInfoRow(Icons.phone, restaurant.phone, const Color(0xFF7DD4C7)),
                  const SizedBox(height: 4),
                  _buildInfoRow(Icons.email, restaurant.email, const Color(0xFF7DD4C7)),
                  const SizedBox(height: 4),
                  _buildInfoRow(
                    Icons.star,
                    'Rating: ${restaurant.rating.toStringAsFixed(2)} (${restaurant.reviewCount} reviews)',
                    const Color(0xFF7DD4C7),
                  ),
                  const SizedBox(height: 4),
                  _buildInfoRow(Icons.calendar_today, 'Created: ${restaurant.createdAt}', const Color(0xFF7DD4C7)),
                  const Spacer(),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: onApprove,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7DD4C7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Approve',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: onReject,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE74C3C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Reject',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
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

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class Restaurant {
  final String name;
  final String location;
  final String type;
  final String hours;
  final String phone;
  final String email;
  final double rating;
  final int reviewCount;
  final String createdAt;
  String status;
  final String imageUrl;

  Restaurant({
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
  });
}