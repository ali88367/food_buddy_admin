import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:food_buddy_admin/sideBarController.dart';
import 'package:food_buddy_admin/sidebar.dart';
import 'package:get/get.dart';

import 'RedemptionLogs.dart';
import 'Restaurants.dart';
import 'UserDetails.dart';



class HomeMain extends StatefulWidget {
  const HomeMain({super.key});

  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> {
  final SidebarController sidebarController = Get.put(SidebarController());
  @override
  Widget build(BuildContext context) {
    final width=MediaQuery.of(context)!.size.width;
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if(sidebarController.showsidebar.value ==true) {
            sidebarController.showsidebar.value =false;
          }
        },
        child: Stack(
          children: [
            Row(
              children: [
                width>=768?ExampleSidebarX():SizedBox.shrink(),
                Expanded(
                    child: Obx(() => sidebarController.selectedindex.value == 0
                        ? ContactPage()
                        : sidebarController.selectedindex.value == 1
                        ? RestaurantPage()
                        : sidebarController.selectedindex.value == 2
                        ? RedemptionLogsPage()
                        : sidebarController.selectedindex.value == 3
                        ? ContactPage()
                        : sidebarController.selectedindex.value == 4
                        ? ContactPage()
                        : sidebarController.selectedindex.value == 5
                        ? ContactPage()
                        : sidebarController.selectedindex.value == 6
                        ? ContactPage()
                        : ContactPage()))
              ],
            ),
            Obx(()=>sidebarController.showsidebar.value == true? ExampleSidebarX():SizedBox.shrink(),)

          ],
        ),
      ),
    );
  }
}
