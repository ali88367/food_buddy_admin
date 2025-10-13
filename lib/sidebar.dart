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

  @override
  Widget build(BuildContext context) {
    const mint = Color(0xFF93E4D0); // mint background color

    return GetBuilder<SidebarController>(
      builder: (_) {
        return SidebarX(
          controller: sidebarController.controller,
          theme: SidebarXTheme(
            margin: const EdgeInsets.all(0),
            decoration: const BoxDecoration(
              color: mint,
            ),
            itemDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 1),
            ),
            hoverColor: red,
            hoverTextStyle: TextStyle(color: Colors.white),
            selectedItemDecoration: BoxDecoration(
              color: red,

              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),

            selectedTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),

            iconTheme: const IconThemeData(
              color: Colors.white,
              size: 20,
            ),
            selectedIconTheme: const IconThemeData(
              color: Colors.white,
              size: 22,
            ),
            itemTextPadding: const EdgeInsets.symmetric(horizontal: 12),
            itemPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          ),
          extendedTheme: SidebarXTheme(
            width: 220,
            decoration: const BoxDecoration(color: mint),
          ),
          headerBuilder: (context, extended) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: Column(
              children: [
                Image.asset(
                  'assets/logo.png', // place your logo in assets
                  width: 100,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
          items: [
            SidebarXItem(
              icon: Icons.person,
              label: 'User Data',
              onTap: () => sidebarController.selectedindex.value = 0,
            ),
            SidebarXItem(
              icon: Icons.restaurant,
              label: 'Restaurants',
              onTap: () => sidebarController.selectedindex.value = 1,
            ),
            SidebarXItem(
              icon: Icons.local_offer,
              label: 'Offers',
              onTap: () => sidebarController.selectedindex.value = 2,
            ),
            SidebarXItem(
              icon: Icons.card_giftcard,
              label: 'Redemptions',
              onTap: () => sidebarController.selectedindex.value = 3,
            ),
            SidebarXItem(
              icon: Icons.settings,
              label: 'Configurations',
              onTap: () => sidebarController.selectedindex.value = 4,
            ),
            SidebarXItem(
              icon: Icons.attach_money,
              label: 'Cash Back',
              onTap: () => sidebarController.selectedindex.value = 5,
            ),
            SidebarXItem(
              icon: Icons.bar_chart,
              label: 'Reports',
              onTap: () => sidebarController.selectedindex.value = 6,
            ),
          ],
          footerBuilder: (context, extended) => const Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
          ),
        );
      },
    );
  }
}
