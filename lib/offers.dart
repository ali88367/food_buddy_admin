import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:food_buddy_admin/colors.dart';

class OffersPage extends StatefulWidget {
  const OffersPage({Key? key}) : super(key: key);

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  final TextEditingController _searchController = TextEditingController();
  String selectedTab = 'Pending';
  List<Offer> offers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOffers();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchOffers() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('offers').get();
      debugPrint('Fetched ${snapshot.docs.length} offers');

      final List<Offer> loadedOffers = snapshot.docs.map((doc) {
        final data = doc.data();
        debugPrint('Offer ID: ${doc.id}, Data: $data');
        return Offer(
          offerId: doc.id,
          restaurantId: data['restaurant_id'] ?? '',
          restaurantName: data['restaurant_name'] ?? 'Unknown',
          offerTitle: data['offerTitle'] ?? 'No Title',
          description: data['description'] ?? '',
          discountType: data['discountType'] ?? 'Unknown',
          discountValue: data['discountValue'] ?? '0',
          terms: data['terms'] ?? '',
          status: data['status']?.toUpperCase() ?? 'PENDING',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          validFrom: (data['validFrom'] as Timestamp?)?.toDate() ?? DateTime.now(),
          validTill: (data['validTill'] as Timestamp?)?.toDate() ?? DateTime.now(),
          userId: data['userId'] ?? '',
        );
      }).toList();

      setState(() {
        offers = loadedOffers;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching offers: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load offers: $e')),
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> _approveOffer(Offer offer) async {
    try {
      await FirebaseFirestore.instance
          .collection('offers')
          .doc(offer.offerId)
          .update({'status': 'active'});
      setState(() {
        offer.status = 'ACTIVE';
      });
    } catch (e) {
      debugPrint('Error approving offer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve offer: $e')),
      );
    }
  }

  Future<void> _rejectOffer(Offer offer) async {
    try {
      await FirebaseFirestore.instance
          .collection('offers')
          .doc(offer.offerId)
          .update({'status': 'rejected'});
      setState(() {
        offer.status = 'REJECTED';
      });
    } catch (e) {
      debugPrint('Error rejecting offer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject offer: $e')),
      );
    }
  }

  List<Offer> get filteredOffers {
    final query = _searchController.text.toLowerCase();
    return offers.where((offer) {
      final matchesSearch = query.isEmpty ||
          offer.offerTitle.toLowerCase().contains(query) ||
          offer.restaurantName.toLowerCase().contains(query) ||
          offer.description.toLowerCase().contains(query);
      final matchesTab = selectedTab == 'Pending'
          ? offer.status == 'PENDING'
          : selectedTab == 'Approved'
          ? offer.status == 'ACTIVE'
          : offer.status == 'REJECTED';
      return matchesSearch && matchesTab;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Padding(
                  padding: EdgeInsets.fromLTRB(10, 16, 10, 8),
                  child: Text(
                    'Offers',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                // Tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      _buildTab('Pending'),
                      const SizedBox(width: 16),
                      _buildTab('Approved'),
                      const SizedBox(width: 16),
                      _buildTab('Rejected'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
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
                            color: Color(0xFFFF6B6B),
                            size: 22,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Search by title, restaurant, or description...',
                              hintStyle: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Offer Cards
                Expanded(
                  child: isLoading
                      ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF6B6B),
                    ),
                  )
                      : filteredOffers.isEmpty
                      ? const Center(
                    child: Text(
                      'No offers found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  )
                      : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: filteredOffers.length,
                    itemBuilder: (context, index) {
                      return OfferCard(
                        offer: filteredOffers[index],
                        onApprove: () => _approveOffer(filteredOffers[index]),
                        onReject: () => _rejectOffer(filteredOffers[index]),
                        selectedTab: selectedTab,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
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
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? const Color(0xFFFF6B6B) : Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 50,
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

class OfferCard extends StatelessWidget {
  final Offer offer;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final String selectedTab;

  const OfferCard({
    Key? key,
    required this.offer,
    required this.onApprove,
    required this.onReject,
    required this.selectedTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Status
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                child: Container(
                  height: 70,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(
                      Icons.local_offer,
                      size: 36,
                      color: Color(0xFFFF6B6B),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: offer.status == 'ACTIVE'
                        ? const Color(0xFF4CAF50).withOpacity(0.9)
                        : offer.status == 'REJECTED'
                        ? const Color(0xFFE74C3C).withOpacity(0.9)
                        : Colors.grey[300]!.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    offer.status,
                    style: const TextStyle(
                      fontSize: 10,
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
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    offer.offerTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Restaurant
                  Row(
                    children: [
                      const Icon(Icons.restaurant, size: 12, color: Color(0xFFFF6B6B)),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          offer.restaurantName,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Discount
                  Row(
                    children: [
                      const Icon(Icons.discount, size: 12, color: Color(0xFFFF6B6B)),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          '${offer.discountValue} ${offer.discountType}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Validity
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 12, color: Color(0xFFFF6B6B)),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          'Valid: ${DateFormat.yMMMd().format(offer.validFrom)} - ${DateFormat.yMMMd().format(offer.validTill)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Description
                  Row(
                    children: [
                      const Icon(Icons.description, size: 12, color: Color(0xFFFF6B6B)),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          offer.description,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Terms
                  Row(
                    children: [
                      const Icon(Icons.info, size: 12, color: Color(0xFFFF6B6B)),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          offer.terms,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Created At
                  Row(
                    children: [
                      const Icon(Icons.create, size: 12, color: Color(0xFFFF6B6B)),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          'Created: ${DateFormat.yMMMd().format(offer.createdAt)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Buttons
                  if (selectedTab == 'Pending')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: onApprove,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF4CAF50),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            'Approve',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 6),
                        TextButton(
                          onPressed: onReject,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFFE74C3C),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            'Reject',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
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

class Offer {
  final String offerId;
  final String restaurantId;
  final String restaurantName;
  final String offerTitle;
  final String description;
  final String discountType;
  final String discountValue;
  final String terms;
  String status;
  final DateTime createdAt;
  final DateTime validFrom;
  final DateTime validTill;
  final String userId;

  Offer({
    required this.offerId,
    required this.restaurantId,
    required this.restaurantName,
    required this.offerTitle,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.terms,
    required this.status,
    required this.createdAt,
    required this.validFrom,
    required this.validTill,
    required this.userId,
  });
}