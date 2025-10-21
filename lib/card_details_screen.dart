import 'package:flutter/material.dart';
import 'app_colors.dart';

class CardDetailsScreen extends StatefulWidget {
  const CardDetailsScreen({Key? key}) : super(key: key);

  @override
  State<CardDetailsScreen> createState() => _CardDetailsScreenState();
}

class _CardDetailsScreenState extends State<CardDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  
  // Controllers for form fields
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCardData();
  }

  void _loadCardData() {
    // Load existing card data - for now using placeholder data
    _nameController.text = 'John Doe';
    _titleController.text = 'Software Engineer';
    _companyController.text = 'Tech Company Inc.';
    _emailController.text = 'john.doe@example.com';
    _phoneController.text = '+1 (555) 123-4567';
    _websiteController.text = 'www.johndoe.com';
    _locationController.text = 'San Francisco, CA';
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // Save the changes - implement actual save logic here
      setState(() {
        _isEditing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Card details saved successfully!'),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
    });
    _loadCardData(); // Reset to original data
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        title: const Text(
          'Card Details',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              onPressed: _toggleEdit,
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Card',
            ),
          if (_isEditing) ...[
            IconButton(
              onPressed: _cancelEdit,
              icon: const Icon(Icons.close),
              tooltip: 'Cancel',
            ),
            IconButton(
              onPressed: _saveChanges,
              icon: const Icon(Icons.check),
              tooltip: 'Save',
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Preview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryDark, AppColors.slate700],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameController.text.isEmpty ? 'Your Name' : _nameController.text,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _titleController.text.isEmpty ? 'Your Title' : _titleController.text,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _companyController.text.isEmpty ? 'Your Company' : _companyController.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.email, size: 16, color: Colors.white.withOpacity(0.8)),
                        const SizedBox(width: 8),
                        Text(
                          _emailController.text.isEmpty ? 'your.email@example.com' : _emailController.text,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 16, color: Colors.white.withOpacity(0.8)),
                        const SizedBox(width: 8),
                        Text(
                          _phoneController.text.isEmpty ? '+1 (555) 123-4567' : _phoneController.text,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Form Fields
              _buildFormField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              _buildFormField(
                controller: _titleController,
                label: 'Job Title',
                icon: Icons.work_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your job title';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              _buildFormField(
                controller: _companyController,
                label: 'Company',
                icon: Icons.business_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your company';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              _buildFormField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              _buildFormField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              _buildFormField(
                controller: _websiteController,
                label: 'Website',
                icon: Icons.language_outlined,
                keyboardType: TextInputType.url,
              ),
              
              const SizedBox(height: 16),
              
              _buildFormField(
                controller: _locationController,
                label: 'Location',
                icon: Icons.location_on_outlined,
              ),
              
              const SizedBox(height: 32),
              
              if (_isEditing)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _cancelEdit,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.primaryDark),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: (value) {
        setState(() {}); // Update card preview
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.slate300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.slate300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.slate200),
        ),
        filled: true,
        fillColor: _isEditing ? Colors.white : AppColors.slate100,
        labelStyle: TextStyle(
          color: _isEditing ? AppColors.primaryDark : AppColors.slate500,
        ),
      ),
      style: TextStyle(
        color: _isEditing ? Colors.black : AppColors.slate600,
      ),
    );
  }
}