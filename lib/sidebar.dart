
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:food_buddy_admin/colors.dart';
import 'package:food_buddy_admin/sideBarController.dart';

import 'package:get/get.dart';
import 'package:sidebarx/sidebarx.dart';



class ExampleSidebarX extends StatefulWidget {
  @override
  State<ExampleSidebarX> createState() => _ExampleSidebarXState();
}

class _ExampleSidebarXState extends State<ExampleSidebarX> {

  // void _showLogoutDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         backgroundColor: backgroundColor,
  //         title: Text('Logout'),
  //         content: Text('Are you sure you want to logout?'),
  //         actions: <Widget>[
  //           CustomButton(
  //             color: Colors.transparent,
  //             width: 100,
  //             height: 40,
  //             text: 'No',
  //             textColor: Colors.red,
  //             onPressed: () {
  //               sidebarController.selectedindex.value = 0;
  //
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           CustomButton(
  //             width: 100,
  //             height: 40,
  //             text: 'Yes',
  //             onPressed: () async {
  //               await FirebaseAuth.instance.signOut();
  //               Navigator.of(context).pop();
  //               Navigator.of(context).pushReplacement(
  //                 MaterialPageRoute(builder: (context) => LoginPage()),
  //               );
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  final SidebarController sidebarController = Get.put(SidebarController());

  @override
  Widget build(BuildContext context) {
    print('hellosidebarController${sidebarController.selectedindex.value}');
    // final setNameProvider=Provider.of<GetHeadingNurseName>(context,listen: false);
    return GetBuilder<SidebarController>(
        builder: (sidebarController) {
          return SidebarX(
            controller: sidebarController.controller,
            theme: SidebarXTheme(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              hoverColor: Colors.green,
              textStyle:
              TextStyle(color: Colors.blue.withOpacity(0.5), fontSize: 18),
              selectedTextStyle:
              const TextStyle(color: Colors.blue, fontSize: 18),
              hoverTextStyle: const TextStyle(
                fontSize: 18,
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
              itemTextPadding: const EdgeInsets.only(left: 10),
              selectedItemTextPadding: const EdgeInsets.only(left: 10),
              itemDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue),
              ),
              selectedItemDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white,
                ),
                gradient: LinearGradient(
                  colors: [Colors.white70, Colors.blue.withOpacity(0.5)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green,
                    blurRadius: 30,
                  )
                ],
              ),
              iconTheme: IconThemeData(
                color: Colors.blue,
                size: 10,
              ),
              selectedIconTheme: const IconThemeData(
                color: Colors.white,
                size: 10,
              ),
            ),
            extendedTheme: SidebarXTheme(
              width: 200,
              decoration: BoxDecoration(
                color: background,
              ),
            ),
            footerDivider: Divider(),
            headerBuilder: (context, extended) {
              return Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Obx(
                        () =>
                    sidebarController.showsidebar.value == true
                        ? Align(
                        alignment: Alignment.topRight,
                        child: Icon(
                          Icons.clear_sharp,
                          color: Colors.blue,
                        ))
                        : SizedBox.shrink(),
                  ),
                  Get.width <= 1440
                      ? SizedBox(
                    height: 100,
                    width: 500,
                    child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Image.asset('assets/logo.png')),
                  )
                      : Get.width > 1440 && Get.width <= 2550
                      ? SizedBox(
                    height: 100,
                    width: 500,
                    child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Image.asset('assets/logo.png')),
                  )
                      : SizedBox(
                    height: 80,
                    width: 220,
                    child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Image.asset('assets/logo.png')),
                  ),
                ],
              );
            },
            items: [
              SidebarXItem(
                  onTap: () {
                    sidebarController.selectedindex.value = 0;

                  },
                  iconBuilder: (selected, hovered) {
                    return Icon(
                      Icons.home,
                      color: Colors.transparent,
                    );
                  },
                  label: 'User Data'),
              SidebarXItem(
                  onTap: () {
                    sidebarController.selectedindex.value = 1;

                  },
                  iconBuilder: (selected, hovered) {
                    return Icon(
                      Icons.home,
                      color: Colors.transparent,
                    );
                  },
                  label: 'Assesments'),
              SidebarXItem(
                  onTap: () {
                    sidebarController.selectedindex.value = 2;


                  },
                  iconBuilder: (selected, hovered) {
                    return Icon(
                      Icons.home,
                      color: Colors.transparent,
                    );
                  },
                  label: 'Read'),
              SidebarXItem(
                  onTap: () {
                    sidebarController.selectedindex.value = 3;

                    // setNameProvider.setName('Profile');
                  },
                  iconBuilder: (selected, hovered) {
                    return Icon(
                      Icons.home,
                      color: Colors.transparent,
                    );
                  },
                  label: 'Responses'),
              SidebarXItem(
                  onTap: () {
                    sidebarController.selectedindex.value =
                    4;

                    // setNameProvider.setName('Profile');
                  },
                  iconBuilder: (selected, hovered) {
                    return Icon(
                      Icons.home,
                      color: Colors.transparent,
                    );
                  },
                  label: 'Add Audio'),
              SidebarXItem(
                  onTap: () {
                    sidebarController.selectedindex.value =
                    5;

                    // setNameProvider.setName('Profile');
                  },
                  iconBuilder: (selected, hovered) {
                    return Icon(
                      Icons.home,
                      color: Colors.transparent,
                    );
                  },
                  label: 'Notifications'),
              SidebarXItem(
                  onTap: () {
                    sidebarController.selectedindex.value =
                    6;

                    // setNameProvider.setName('Profile');
                  },
                  iconBuilder: (selected, hovered) {
                    return Icon(
                      Icons.home,
                      color: Colors.transparent,
                    );
                  },
                  label: 'Help'),
              SidebarXItem(
                  onTap: () {
                    sidebarController.selectedindex.value =
                    7;

                    // setNameProvider.setName('Profile');
                  },
                  iconBuilder: (selected, hovered) {
                    return Icon(
                      Icons.home,
                      color: Colors.transparent,
                    );
                  },
                  label: 'Challenges'),
              SidebarXItem(
                  onTap: () {
                    sidebarController.selectedindex.value = 0;
                    sidebarController.controller =SidebarXController(selectedIndex: 0, extended: true);sidebarController.update();
                    //
                //    _showLogoutDialog();

                  },
                  iconBuilder: (selected, hovered) {
                    return Icon(
                      Icons.home,
                      color: Colors.transparent,
                    );
                  },
                  label: 'Log out'),

            ],
          );
        });
  }
}
