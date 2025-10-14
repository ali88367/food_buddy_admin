import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:food_buddy_admin/colors.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
    _searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredContacts = contacts
          .where((contact) =>
      contact.name.toLowerCase().contains(query) ||
          contact.email.toLowerCase().contains(query) ||
          contact.phone.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> fetchUsers() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();

      final List<Contact> loadedUsers = snapshot.docs.map((doc) {
        final data = doc.data();
        return Contact(
          uid: doc.id,
          name: data['user_name'] ?? 'Unknown',
          email: data['email'] ?? 'No Email',
          phone: data['phone'] ?? 'No Phone',
          avatar: data['profile_picture'] ?? '',
          isActive: !(data['is_blocked'] ?? false),
        );
      }).toList();

      setState(() {
        contacts = loadedUsers;
        filteredContacts = loadedUsers;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching users: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> toggleBlock(Contact contact) async {
    try {
      final newStatus = !contact.isActive;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(contact.uid)
          .update({'is_blocked': !newStatus});

      setState(() {
        contact.isActive = newStatus;
      });
    } catch (e) {
      debugPrint('Error blocking/unblocking user: $e');
    }
  }

  Future<void> showRedemptionHistory(String uid, BuildContext context) async {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        backgroundColor: Colors.white,
        child: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('coupon_redemptions')
              .orderBy('redemption_timestamp', descending: true)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B)),
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 40,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Redemption History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You haven\'t redeemed any coupons yet.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            final redemptions = snapshot.data!.docs;

            return Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Redemption History',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: redemptions.length,
                      itemBuilder: (context, index) {
                        final data = redemptions[index].data() as Map<String, dynamic>;
                        final timestamp = (data['redemption_timestamp'] != null)
                            ? (data['redemption_timestamp'] as Timestamp).toDate()
                            : null;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white,
                                  Colors.grey[50]!,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Icon and Title Column
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF6B6B).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.redeem,
                                      size: 24,
                                      color: Color(0xFFFF6B6B),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Title
                                        Text(
                                          data['offer_title'] ?? 'No Title',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF212121),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        // Description
                                        Text(
                                          data['description'] ?? 'No description available',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        // Details Row
                                        Wrap(
                                          spacing: 12,
                                          runSpacing: 6,
                                          children: [
                                            // Restaurant
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.store,
                                                  size: 14,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  data['restaurant_name'] ?? 'N/A',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // Date
                                            if (timestamp != null)
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.calendar_today,
                                                    size: 14,
                                                    color: Colors.grey,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    DateFormat.yMMMd().format(timestamp),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            // Cashback and Discount
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.local_offer,
                                                  size: 14,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${data['cashbackRate']}% Cashback',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.discount,
                                                  size: 14,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${(data['discount_value'] * 100).toStringAsFixed(1)}% Off',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // Fees
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.attach_money,
                                                  size: 14,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Fees: ${data['redemptionFees']}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFFFF6B6B),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1400),
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              // Search Bar
              Container(
                width: 600,
                height: 60,
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
                        size: 28,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Search users...',
                          hintStyle: TextStyle(
                            color: Colors.black54,
                            fontSize: 18,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: const [
                    SizedBox(width: 64), // Adjusted to align with smaller avatar
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Name',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(width: 64), // Adjusted to align with smaller avatar

                    Expanded(
                      flex: 2,
                      child: Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(width: 34), // Adjusted to align with smaller avatar

                    Expanded(
                      flex: 2,
                      child: Text(
                        'Phone',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(width: 130), // Adjusted to align with smaller card
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Contact List
              Expanded(
                child: isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFF6B6B),
                  ),
                )
                    : filteredContacts.isEmpty
                    ? const Center(
                  child: Text(
                    'No users found.',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black54,
                    ),
                  ),
                )
                    : ListView.builder(
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = filteredContacts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ContactCard(
                        contact: contact,
                        onBlock: () => toggleBlock(contact),
                        onViewHistory: () => showRedemptionHistory(contact.uid, context),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactCard extends StatelessWidget {
  final Contact contact;
  final VoidCallback onBlock;
  final VoidCallback onViewHistory;

  const ContactCard({
    Key? key,
    required this.contact,
    required this.onBlock,
    required this.onViewHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100, // Reduced from 120 to 100
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16), // Slightly smaller radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12, // Slightly reduced blur
            offset: const Offset(0, 3), // Slightly smaller offset
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16), // Reduced from 24
          // Avatar
          CircleAvatar(
            radius: 32, // Reduced from 38 to 32
            backgroundColor: Colors.grey[300],
            backgroundImage: contact.avatar.isNotEmpty
                ? NetworkImage(contact.avatar)
                : null,
            child: contact.avatar.isEmpty
                ? const Icon(Icons.person, size: 32, color: Colors.grey) // Reduced icon size
                : null,
          ),
          const SizedBox(width: 24), // Reduced from 40
          // Name
          Expanded(
            flex: 2,
            child: Text(
              contact.name,
              style: const TextStyle(
                fontSize: 18, // Reduced from 20
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Email
          Expanded(
            flex: 2,
            child: Text(
              contact.email,
              style: const TextStyle(
                fontSize: 18, // Reduced from 20
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Phone
          Expanded(
            flex: 2,
            child: Text(
              contact.phone,
              style: const TextStyle(
                fontSize: 18, // Reduced from 20
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Block & Status
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InkWell(
                onTap: onBlock,
                child: Text(
                  contact.isActive ? 'Block' : 'Unblock',
                  style: TextStyle(
                    fontSize: 16, // Reduced from 18
                    color: contact.isActive
                        ? const Color(0xFFFF6B6B)
                        : const Color(0xFF4CAF50),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                contact.isActive ? 'Active' : 'Blocked',
                style: TextStyle(
                  fontSize: 14, // Reduced from 16
                  color: contact.isActive ? const Color(0xFF4CAF50) : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12), // Reduced from 16
          // Redemption history icon
          IconButton(
            onPressed: onViewHistory,
            icon: const Icon(
              Icons.history,
              color: Color(0xFFFF6B6B),
              size: 24, // Reduced from 28
            ),
          ),
          const SizedBox(width: 16), // Reduced from 24
        ],
      ),
    );
  }
}

class Contact {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String avatar;
  bool isActive;

  Contact({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.isActive,
  });
}