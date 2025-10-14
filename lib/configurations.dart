import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SystemConfigurationsPage extends StatefulWidget {
  const SystemConfigurationsPage({Key? key}) : super(key: key);

  @override
  State<SystemConfigurationsPage> createState() =>
      _SystemConfigurationsPageState();
}

class _SystemConfigurationsPageState extends State<SystemConfigurationsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController cashbackRateController;
  late TextEditingController redemptionFeesController;
  late TextEditingController qrCodeExpirationController;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    cashbackRateController = TextEditingController();
    redemptionFeesController = TextEditingController();
    qrCodeExpirationController = TextEditingController();
    _fetchConfigurations();
  }

  /// 🔹 Fetch values from Firestore
  Future<void> _fetchConfigurations() async {
    try {
      DocumentSnapshot snapshot =
      await _firestore.collection('configurations').doc('system_settings').get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        cashbackRateController.text = data['cashbackRate'].toString();
        redemptionFeesController.text = data['redemptionFees'].toString();
        qrCodeExpirationController.text = data['qrExpirationTime'].toString();
      }
    } catch (e) {
      debugPrint("Error fetching configurations: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load configurations"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// 🔹 Update values in Firestore
  Future<void> _saveConfigurations() async {
    try {
      await _firestore.collection('configurations').doc('system_settings').update({
        'cashbackRate': double.tryParse(cashbackRateController.text) ?? 0,
        'redemptionFees': double.tryParse(redemptionFeesController.text) ?? 0,
        'qrExpirationTime': int.tryParse(qrCodeExpirationController.text) ?? 0,
        'updatedAt': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configurations updated successfully!'),
          backgroundColor: Color(0xFF7FD8BE),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint("Error saving configurations: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save configurations'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    cashbackRateController.dispose();
    redemptionFeesController.dispose();
    qrCodeExpirationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7FD8BE),
        elevation: 0,
        title: const Text(
          'System Configurations',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF7FD8BE)))
          : Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Adjust System Parameters',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7FD8BE),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Cashback Rate Input
                  _ConfigurationInput(
                    label: 'Cashback Rate (%)',
                    controller: cashbackRateController,
                  ),
                  const SizedBox(height: 20),

                  // Redemption Fees Input
                  _ConfigurationInput(
                    label: 'Redemption Fees (USD)',
                    controller: redemptionFeesController,
                  ),
                  const SizedBox(height: 20),

                  // QR Code Expiration Input
                  _ConfigurationInput(
                    label: 'QR Code Expiration (minutes)',
                    controller: qrCodeExpirationController,
                  ),
                  const SizedBox(height: 40),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveConfigurations,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7FD8BE),
                        foregroundColor: Colors.white,
                        padding:
                        const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Save Configurations',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Updated At Display
                  FutureBuilder<DocumentSnapshot>(
                    future: _firestore
                        .collection('configurations')
                        .doc('system_settings')
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox();
                      }
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const SizedBox();
                      }
                      final data = snapshot.data!.data() as Map<String, dynamic>;
                      final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();
                      return Text(
                        updatedAt != null
                            ? 'Last Updated: ${DateFormat.yMMMd().add_jm().format(updatedAt)}'
                            : '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfigurationInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _ConfigurationInput({
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey[300] ?? Colors.grey,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey[300] ?? Colors.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF7FD8BE),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
