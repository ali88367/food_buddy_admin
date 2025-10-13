import 'package:flutter/material.dart';
import 'package:food_buddy_admin/HomeMain.dart';
import 'package:food_buddy_admin/Login.dart';
import 'package:food_buddy_admin/UserDetails.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',

      home: HomeMain(),
    );
  }
}

