import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sidebarx/sidebarx.dart';
import 'sideBarController.dart';
import 'colors.dart';

class ExampleSidebarX extends StatefulWidget {
  const ExampleSidebarX({super.key});

  @override
  State<ExampleSidebarX> createState() => _ExampleSidebarXState();
}

class _ExampleSidebarXState extends State<ExampleSidebarX> {
  final SidebarController sidebarController = Get.put(SidebarController());

  // ──────────────────────────────────────
  //  Your beloved colors (unchanged!)
  // ──────────────────────────────────────
  static const mint = Color(0xFF93E4D0);
  static const red  = Color(0xFFE64A4A); // keep your red from colors.dart

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SidebarController>(
      builder: (_) {
        return SidebarX(
          controller: sidebarController.controller,
          theme: SidebarXTheme(
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end:   Alignment.bottomRight,
                colors: [mint, Color(0xFF7AD9C2)], // soft mint gradient
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 30,
                  offset: const Offset(12, 0),
                ),
              ],
            ),
            // ────── Item Styling ──────
            itemDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            ),
            selectedItemDecoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [red, Color(0xFFFF6B6B)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: red.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            hoverColor: red.withOpacity(0.15),
            hoverTextStyle: TextStyle(color: Colors.white),
            hoverIconTheme: const IconThemeData(
              color: Colors.red,        // ← YOUR RED
              size: 26,                 // slightly bigger = premium feel
            ),            // ────── Text & Icons ──────
            textStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 15,
              letterSpacing: 0.3,
            ),
            selectedTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
            ),
            iconTheme: const IconThemeData(color: Colors.white, size: 22),
            selectedIconTheme: const IconThemeData(color: Colors.white, size: 26),
            // ────── Spacing ──────
            itemPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemTextPadding: const EdgeInsets.only(left: 14),
          ),
          extendedTheme: const SidebarXTheme(
            width: 240,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [mint, Color(0xFF7AD9C2)],
              ),
            ),
            padding: EdgeInsets.only(top: 20),
          ),

          // ────── Header (Logo) ──────
          headerBuilder: (context, extended) => Container(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.15), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 90,
                    height: 90,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),

              ],
            ),
          ),

          // ────── Menu Items ──────
          items: [
            _item(Icons.person,          'User Data',       0),
            _item(Icons.restaurant,     'Restaurants',     1),
            _item(Icons.local_offer,    'Offers',          2),
            _item(Icons.card_giftcard,  'Redemptions',     3),
            _item(Icons.settings,       'Configurations',  4),
            _item(Icons.attach_money,   'Cash Back',       5),
            _item(Icons.bar_chart,      'Reports',         6),
          ],


        );
      },
    );
  }

  // Helper to keep code tidy
  SidebarXItem _item(IconData icon, String label, int index) {
    return SidebarXItem(
      icon: icon,
      label: label,
      onTap: () => sidebarController.selectedindex.value = index,
    );
  }
}