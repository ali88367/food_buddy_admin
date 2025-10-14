import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_buddy_admin/HomeMain.dart';
import 'package:get/get.dart'; // optional for navigation if you're using GetX

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isLoading = false;

  Future<void> login() async {
    setState(() {
      isLoading = true;
    });

    try {
      // 🔥 Fetch admin credentials from Firestore
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('admin')
          .doc('HxAG1y2VAn0mF99ENUdV')
          .get();

      if (snapshot.exists) {
        String firebaseEmail = snapshot.get('email');
        String firebasePassword = snapshot.get('password');

        // Check entered credentials
        if (emailController.text.trim() == firebaseEmail &&
            passwordController.text.trim() == firebasePassword) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Login successful!"),
              backgroundColor: Colors.green,
            ),
          );

          // Example navigation after success (if you’re using GetX)
           Get.offAll(() => const HomeMain());

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid email or password!"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Admin data not found in Firestore."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF93E4D0),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              SizedBox(
                width: width <= 1440
                    ? 80
                    : width > 1440 && width <= 2550
                    ? 100
                    : 150,
                height: width <= 1440
                    ? 80
                    : width > 1440 && width <= 2550
                    ? 100
                    : 150,
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Login',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: Color(0xFF264653),
                ),
              ),

              const SizedBox(height: 20),

              // Email Field
              _buildInputField(
                controller: emailController,
                hint: 'Enter email',
                icon: Icons.mail_outline,
                width: width,
              ),

              const SizedBox(height: 15),

              // Password Field
              _buildInputField(
                controller: passwordController,
                hint: 'Password',
                icon: Icons.lock,
                isPassword: true,
                width: width,
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: Color(0xFF264653),
                    ),
                  ),
                  SizedBox(
                    width: width < 425
                        ? 170
                        : width < 768
                        ? 190
                        : width <= 1440
                        ? 300
                        : 300,
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: isLoading
                        ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF264653),
                        strokeWidth: 2.5,
                      ),
                    )
                        : IconButton(
                      onPressed: login,
                      icon: Transform.scale(
                        scale: 0.5,
                        child: Image.asset(
                          'assets/arrowIcon.png',
                          color: const Color(0xFF264653),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    required double width,
  }) {
    return Container(
      width: width < 425
          ? 280
          : width < 768
          ? 300
          : 400,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? !isPasswordVisible : false,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(14.0),
          prefixIcon: Icon(icon, color: const Color(0xFF264653)),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              isPasswordVisible
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: const Color(0xFF264653),
            ),
            onPressed: () {
              setState(() {
                isPasswordVisible = !isPasswordVisible;
              });
            },
          )
              : null,
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
