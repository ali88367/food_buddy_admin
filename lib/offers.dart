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
            constraints: const BoxConstraints(maxWidth: 1200),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Padding(
                  padding: EdgeInsets.fromLTRB(4, 8, 4, 16),
                  child: Text(
                    'Offers Management',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                // Tabs
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildTab('Pending'),
                      const SizedBox(width: 8),
                      _buildTab('Approved'),
                      const SizedBox(width: 8),
                      _buildTab('Rejected'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Search Bar
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(
                          Icons.search_rounded,
                          color: Colors.black38,
                          size: 22,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Search offers by title, restaurant, or description...',
                            hintStyle: TextStyle(
                              color: Colors.black38,
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Offer Cards
                Expanded(
                  child: isLoading
                      ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF4CAF50),
                      strokeWidth: 3,
                    ),
                  )
                      : filteredOffers.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_offer_outlined,
                          size: 64,
                          color: Colors.black12,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No offers found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  )
                      : GridView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
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
    Color tabColor;

    if (title == 'Pending') {
      tabColor = Colors.orange;
    } else if (title == 'Approved') {
      tabColor = const Color(0xFF4CAF50);
    } else {
      tabColor = const Color(0xFFE74C3C);
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? tabColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black54,
              ),
            ),
          ),
        ),
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
    Color statusColor;
    if (offer.status == 'ACTIVE') {
      statusColor = const Color(0xFF4CAF50);
    } else if (offer.status == 'REJECTED') {
      statusColor = const Color(0xFFE74C3C);
    } else {
      statusColor = Colors.orange;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient and status badge
          Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  statusColor.withOpacity(0.8),
                  statusColor.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Stack(
              children: [
                // Decorative pattern
                Positioned.fill(
                  child: CustomPaint(
                    painter: OfferPatternPainter(),
                  ),
                ),
                // Status badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      offer.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                // Discount badge
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_offer_rounded,
                          color: statusColor,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${offer.discountValue} ${offer.discountType}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    offer.offerTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Restaurant name
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.restaurant_rounded,
                          size: 14,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          offer.restaurantName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Description
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.description_rounded,
                          size: 14,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            offer.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Terms
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_rounded,
                        size: 14,
                        color: Colors.black38,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          offer.terms,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Dates
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[100]!, width: 1),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.event_available_rounded,
                              size: 13,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Valid: ${DateFormat('MMM d, y').format(offer.validFrom)} - ${DateFormat('MMM d, y').format(offer.validTill)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 13,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Created: ${DateFormat('MMM d, y').format(offer.createdAt)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Action buttons
                  if (selectedTab == 'Pending') ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onApprove,
                            icon: const Icon(Icons.check_circle_rounded, size: 16),
                            label: const Text(
                              'Approve',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onReject,
                            icon: const Icon(Icons.cancel_rounded, size: 16),
                            label: const Text(
                              'Reject',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE74C3C),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for decorative pattern in header
class OfferPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw circles pattern
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.8 + i * 20, size.height * 0.3),
        30 - i * 8,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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