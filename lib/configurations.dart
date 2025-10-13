import 'package:flutter/material.dart';

class SystemConfigurationsPage extends StatefulWidget {
  const SystemConfigurationsPage({Key? key}) : super(key: key);

  @override
  State<SystemConfigurationsPage> createState() =>
      _SystemConfigurationsPageState();
}

class _SystemConfigurationsPageState extends State<SystemConfigurationsPage> {
  late TextEditingController cashbackRateController;
  late TextEditingController redemptionFeesController;
  late TextEditingController qrCodeExpirationController;

  @override
  void initState() {
    super.initState();
    cashbackRateController = TextEditingController(text: '5');
    redemptionFeesController = TextEditingController(text: '0.3');
    qrCodeExpirationController = TextEditingController(text: '30');
  }

  @override
  void dispose() {
    cashbackRateController.dispose();
    redemptionFeesController.dispose();
    qrCodeExpirationController.dispose();
    super.dispose();
  }

  void _saveConfigurations() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configurations saved successfully!'),
        backgroundColor: Color(0xFF7FD8BE),
        duration: Duration(seconds: 2),
      ),
    );
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
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
          keyboardType: TextInputType.numberWithOptions(decimal: true),
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