import 'package:flutter/material.dart';
import 'package:food_buddy_admin/colors.dart';


class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Contact> contacts = [
    Contact(
      name: 'mark22',
      email: 'mark22@gmail.com',
      phone: '+923096265959',
      avatar: 'assets/mark.jpg',
      isActive: true,
    ),
    Contact(
      name: 'Shees',
      email: 'ali@gmail.com',
      phone: '+923110079481',
      avatar: 'assets/shees.jpg',
      isActive: true,
    ),
    Contact(
      name: 'Kevin Jason',
      email: 'kevin11@gmail.com',
      phone: '+923213825152',
      avatar: 'assets/kevin.jpg',
      isActive: true,
    ),
    Contact(
      name: 'khalid',
      email: 'hies@gmail.com',
      phone: '+923366120844',
      avatar: 'assets/khalid.jpg',
      isActive: true,
    ),
  ];

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
                          hintText: 'Search',
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
                  children: [
                    const SizedBox(width: 80),
                    const Expanded(
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
                    const Expanded(
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
                    const Expanded(
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
                    Container(width: 150),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Contact List
              Expanded(
                child: ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ContactCard(contact: contacts[index]),
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

  const ContactCard({Key? key, required this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 24),
          // Avatar
          CircleAvatar(
            radius: 38,
            backgroundColor: Colors.grey[300],
            child: const Icon(
              Icons.person,
              size: 40,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 40),
          // Name
          Expanded(
            flex: 2,
            child: Text(
              contact.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          // Email
          Expanded(
            flex: 2,
            child: Text(
              contact.email,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black87,
              ),
            ),
          ),
          // Phone
          Expanded(
            flex: 2,
            child: Text(
              contact.phone,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black87,
              ),
            ),
          ),
          // Block button and status
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Block',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFFFF6B6B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                contact.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 16,
                  color: contact.isActive
                      ? const Color(0xFF4CAF50)
                      : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Delete icon
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.delete_outline,
              color: Color(0xFFFF6B6B),
              size: 28,
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}

class Contact {
  final String name;
  final String email;
  final String phone;
  final String avatar;
  final bool isActive;

  Contact({
    required this.name,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.isActive,
  });
}