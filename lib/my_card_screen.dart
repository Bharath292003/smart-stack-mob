import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models.dart';

class MyCardScreen extends StatefulWidget {
  final BusinessCard currentUserCard;
  final Function(BusinessCard) onCardUpdated;

  const MyCardScreen({
    Key? key,
    required this.currentUserCard,
    required this.onCardUpdated,
  }) : super(key: key);

  @override
  State<MyCardScreen> createState() => _MyCardScreenState();
}

class _MyCardScreenState extends State<MyCardScreen> {
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _companyController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _websiteController;
  late TextEditingController _locationController;
  late TextEditingController _linkedinController;
  late TextEditingController _twitterController;
  late TextEditingController _instagramController;
  late TextEditingController _facebookController;
  late TextEditingController _aboutController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadSavedData();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.currentUserCard.name);
    _titleController = TextEditingController(text: widget.currentUserCard.title);
    _companyController = TextEditingController(text: widget.currentUserCard.company);
    _emailController = TextEditingController(text: widget.currentUserCard.email);
    _phoneController = TextEditingController(text: widget.currentUserCard.phone);
    _websiteController = TextEditingController(text: widget.currentUserCard.website);
    _locationController = TextEditingController(text: widget.currentUserCard.location);
    _linkedinController = TextEditingController();
    _twitterController = TextEditingController();
    _instagramController = TextEditingController();
    _facebookController = TextEditingController();
    _aboutController = TextEditingController();
  }

  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCardData = prefs.getString('user_card_data');
      
      if (savedCardData != null) {
        final cardData = json.decode(savedCardData);
        setState(() {
          _nameController.text = cardData['name'] ?? widget.currentUserCard.name;
          _titleController.text = cardData['title'] ?? widget.currentUserCard.title;
          _companyController.text = cardData['company'] ?? widget.currentUserCard.company;
          _emailController.text = cardData['email'] ?? widget.currentUserCard.email;
          _phoneController.text = cardData['phone'] ?? widget.currentUserCard.phone;
          _websiteController.text = cardData['website'] ?? widget.currentUserCard.website;
          _locationController.text = cardData['location'] ?? widget.currentUserCard.location;
          _linkedinController.text = cardData['linkedin'] ?? '';
          _twitterController.text = cardData['twitter'] ?? '';
          _instagramController.text = cardData['instagram'] ?? '';
          _facebookController.text = cardData['facebook'] ?? '';
          _aboutController.text = cardData['about'] ?? '';
        });
      }
    } catch (e) {
      print('Error loading saved data: $e');
    }
  }

  Future<void> _saveCardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final cardData = {
        'name': _nameController.text,
        'title': _titleController.text,
        'company': _companyController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'website': _websiteController.text,
        'location': _locationController.text,
        'linkedin': _linkedinController.text,
        'twitter': _twitterController.text,
        'instagram': _instagramController.text,
        'facebook': _facebookController.text,
        'about': _aboutController.text,
      };

      await prefs.setString('user_card_data', json.encode(cardData));

      // Create updated BusinessCard object
      final updatedCard = BusinessCard(
        id: widget.currentUserCard.id,
        name: _nameController.text,
        title: _titleController.text,
        company: _companyController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        website: _websiteController.text,
        location: _locationController.text,
        color: widget.currentUserCard.color,
      );

      // Call the callback to update the parent
      widget.onCardUpdated(updatedCard);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Card saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving card: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
    _linkedinController.dispose();
    _twitterController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Card',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveCardData,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Preview
            _buildCardPreview(),
            const SizedBox(height: 32),
            
            // Basic Information Section
            _buildSection(
              title: 'Basic Information',
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _titleController,
                  label: 'Job Title / Designation',
                  icon: Icons.work_outline,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _companyController,
                  label: 'Company / Organization',
                  icon: Icons.business_outlined,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Contact Information Section
            _buildSection(
              title: 'Contact Information',
              children: [
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _websiteController,
                  label: 'Website',
                  icon: Icons.language_outlined,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _locationController,
                  label: 'Location',
                  icon: Icons.location_on_outlined,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Social Media Section
            _buildSection(
              title: 'Social Media',
              children: [
                _buildTextField(
                  controller: _linkedinController,
                  label: 'LinkedIn Profile',
                  icon: Icons.link_outlined,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _twitterController,
                  label: 'Twitter Handle',
                  icon: Icons.alternate_email_outlined,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _instagramController,
                  label: 'Instagram Handle',
                  icon: Icons.camera_alt_outlined,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _facebookController,
                  label: 'Facebook Profile',
                  icon: Icons.facebook_outlined,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Additional Information Section
            _buildSection(
              title: 'Additional Information',
              children: [
                _buildTextField(
                  controller: _aboutController,
                  label: 'About / Bio',
                  icon: Icons.info_outline,
                  maxLines: 4,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPreview() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF334155)],
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
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const Text(
                'Preview',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFCBD5E1),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          // Middle Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _nameController.text.isEmpty ? 'Your Name' : _nameController.text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _titleController.text.isEmpty ? 'Your Title' : _titleController.text,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFCBD5E1),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          // Bottom Section
          Text(
            _companyController.text.isEmpty ? 'Your Company' : _companyController.text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: (value) {
          setState(() {}); // Trigger rebuild to update preview
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF6B7280)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}