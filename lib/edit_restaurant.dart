import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:food_buddy_admin/colors.dart';

import 'Restaurants.dart';

class EditRestaurantPage extends StatefulWidget {
  final Restaurant restaurant;
  final VoidCallback onSave;

  const EditRestaurantPage({
    Key? key,
    required this.restaurant,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EditRestaurantPage> createState() => _EditRestaurantPageState();
}

class _EditRestaurantPageState extends State<EditRestaurantPage> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _typeController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _servicesController;
  TimeOfDay? _openingTime;
  TimeOfDay? _closingTime;
  late bool _openStatus;
  Uint8List? _selectedImageBytes;
  File? _selectedImageFile;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.restaurant.name);
    _addressController = TextEditingController(text: widget.restaurant.location);
    _typeController = TextEditingController(text: widget.restaurant.type);
    _phoneController = TextEditingController(text: widget.restaurant.phone);
    _emailController = TextEditingController(text: widget.restaurant.email);
    _servicesController = TextEditingController(text: widget.restaurant.services.join(', '));
    _openingTime = _parseTime(widget.restaurant.hours.split('-')[0].trim());
    _closingTime = widget.restaurant.hours.split('-').length > 1
        ? _parseTime(widget.restaurant.hours.split('-')[1].trim())
        : null;
    _openStatus = widget.restaurant.openStatus;
    _imageUrl = widget.restaurant.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _typeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _servicesController.dispose();
    super.dispose();
  }

  TimeOfDay? _parseTime(String time) {
    try {
      final parts = time.trim().split(' ');
      final timeParts = parts[0].split(':');
      final hour = int.parse(timeParts[0]);
      final minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;
      final isPM = parts.length > 1 && parts[1].toLowerCase().contains('pm');
      return TimeOfDay(hour: isPM ? hour % 12 + 12 : hour % 12, minute: minute);
    } catch (e) {
      return null;
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null && (result.files.single.path != null || result.files.single.bytes != null)) {
        setState(() {
          if (kIsWeb) {
            _selectedImageBytes = result.files.single.bytes;
            _selectedImageFile = null;
          } else {
            _selectedImageFile = File(result.files.single.path!);
            _selectedImageBytes = null;
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick image')),
      );
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImageBytes == null && _selectedImageFile == null) return _imageUrl;
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('restaurants/${widget.restaurant.id}/profile_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
      if (kIsWeb) {
        if (_selectedImageBytes != null) {
          await storageRef.putData(_selectedImageBytes!);
        }
      } else {
        if (_selectedImageFile != null) {
          await storageRef.putFile(_selectedImageFile!);
        }
      }
      final url = await storageRef.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
      return null;
    }
  }

  Future<void> _saveChanges() async {
    try {
      final imageUrl = await _uploadImage();
      if (imageUrl == null && (_selectedImageBytes != null || _selectedImageFile != null)) return; // Image upload failed

      await FirebaseFirestore.instance.collection('restaurants').doc(widget.restaurant.id).update({
        'restaurant_name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'restaurant_type': _typeController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'image_url': imageUrl ?? '',
        'services': _servicesController.text.isEmpty
            ? []
            : _servicesController.text.split(',').map((s) => s.trim()).toList(),
        'opening_time': _formatTime(_openingTime),
        'closing_time': _formatTime(_closingTime),
        'open_status': _openStatus,
        'updated_at': Timestamp.now(),
      });
      widget.onSave();
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error updating restaurant: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update restaurant: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit Restaurant',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey, size: 24),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Form
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Picker
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 100,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: _selectedImageBytes != null
                                ? Image.memory(
                              _selectedImageBytes!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                            )
                                : _selectedImageFile != null && !kIsWeb
                                ? Image.file(
                              _selectedImageFile!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                            )
                                : _imageUrl != null && _imageUrl!.isNotEmpty
                                ? Image.network(
                              _imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                            )
                                : _buildImagePlaceholder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(_nameController, 'Restaurant Name', Icons.restaurant),
                        const SizedBox(height: 12),
                        _buildTextField(_addressController, 'Address', Icons.location_on),
                        const SizedBox(height: 12),
                        _buildTextField(_typeController, 'Restaurant Type', Icons.category),
                        const SizedBox(height: 12),
                        _buildTimePickerField('Opening Time', _openingTime, (time) => setState(() => _openingTime = time)),
                        const SizedBox(height: 12),
                        _buildTimePickerField('Closing Time', _closingTime, (time) => setState(() => _closingTime = time)),
                        const SizedBox(height: 12),
                        _buildTextField(_phoneController, 'Phone Number', Icons.phone),
                        const SizedBox(height: 12),
                        _buildTextField(_emailController, 'Email Address', Icons.email),
                        const SizedBox(height: 12),
                        _buildTextField(_servicesController, 'Services (comma-separated)', Icons.room_service),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Open Status',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF212121),
                              ),
                            ),
                            Switch(
                              value: _openStatus,
                              activeColor: const Color(0xFFFF6B6B),
                              onChanged: (value) => setState(() => _openStatus = value),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Buttons
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black54,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _saveChanges,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFFFF6B6B),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image, size: 40, color: Colors.grey),
            SizedBox(height: 4),
            Text(
              'Select Image',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFFFF6B6B)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
        ),
      ),
    );
  }

  Widget _buildTimePickerField(String label, TimeOfDay? time, Function(TimeOfDay) onTimeSelected) {
    return GestureDetector(
      onTap: () async {
        final selectedTime = await showTimePicker(
          context: context,
          initialTime: time ?? TimeOfDay.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFFFF6B6B),
                  onPrimary: Colors.white,
                  onSurface: Colors.black87,
                ),
              ),
              child: child!,
            );
          },
        );
        if (selectedTime != null) {
          onTimeSelected(selectedTime);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
          prefixIcon: const Icon(Icons.access_time, size: 20, color: Color(0xFFFF6B6B)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
          ),
        ),
        child: Text(
          time != null ? _formatTime(time) : 'Select time',
          style: TextStyle(
            fontSize: 14,
            color: time != null ? Colors.black87 : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}