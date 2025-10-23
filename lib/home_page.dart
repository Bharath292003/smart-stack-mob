import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'dart:math' as math;
import 'login_page.dart';
import 'camera_scanner.dart';
import 'business_card_screen.dart';
import 'personal_card_screen.dart';
import 'other_card_screen.dart';
import 'profile_screen.dart';
import 'models.dart';
import 'user_session.dart';
import 'api_helper.dart';
import 'my_card_screen.dart';

class HomePage extends StatefulWidget {
  final String userName;
  final String? phoneNumber;

  const HomePage({
    super.key,
    required this.userName,
    this.phoneNumber,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _totalCards = 0;
  bool _isLoadingCards = false;
  bool _isCardFlipped = false;
  late BusinessCard currentUserCard;
  late List<Category> categories;
  
  // Image processing state variables
  bool _isProcessingImage = false;
  bool _isProcessingComplete = false;
  double _processingProgress = 0.0;
  String? _processingError;
  Map<String, dynamic>? _extractedCardData;
  
  // Animation controllers
  late AnimationController _rotationController;
  late AnimationController _progressController;
  late AnimationController _checkmarkController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _checkmarkAnimation;
  
  // Category creation
  final TextEditingController _categoryNameController = TextEditingController();
  bool _isCreatingCategory = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );
    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Initialize animations
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _checkmarkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _checkmarkController,
      curve: Curves.elasticOut,
    ));
    
    // Initialize current user card with actual user data
    _loadUserCard();

    // Initialize categories
    categories = [
      Category(
        id: 'business',
        name: 'Business',
        icon: Icons.business_center,
        count: 24,
      ),
      Category(
        id: 'personal',
        name: 'Personal',
        icon: Icons.person,
        count: 12,
      ),
      Category(
        id: 'favorites',
        name: 'Favorites',
        icon: Icons.star,
        count: 8,
      ),
      Category(
        id: 'important',
        name: 'Important',
        icon: Icons.flag,
        count: 15,
      ),
    ];

    _fetchTotalCards();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _progressController.dispose();
    _checkmarkController.dispose();
    _categoryNameController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    // Refresh all data on the home screen
    await _fetchTotalCards();
    
    // Reset any processing states
    setState(() {
      _isProcessingImage = false;
      _isProcessingComplete = false;
      _processingError = null;
      _processingProgress = 0.0;
      _extractedCardData = null;
    });
    
    // Stop any running animations
    _rotationController.stop();
    _progressController.reset();
    _checkmarkController.reset();
  }

  Future<void> _fetchTotalCards() async {
    setState(() {
      _isLoadingCards = true;
    });

    try {
      // Get user ID from UserSession
      final userId = await UserSession.getUserId();
      
      if (userId == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        return;
      }

      final response = await http.get(
        Uri.parse('http://34.93.230.130:5001/cards/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _totalCards = data['total_cards'] ?? 0;
        });
      } else if (response.statusCode == 401) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      print('Error fetching total cards: $e');
    } finally {
      setState(() {
        _isLoadingCards = false;
      });
    }
  }

  void _onCategoryTap(String categoryId) {
    switch (categoryId) {
      case 'business':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BusinessCardScreen(),
          ),
        );
        break;
      case 'personal':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PersonalCardScreen(),
          ),
        );
        break;
      case 'favorites':
      case 'important':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const OtherCardScreen(),
          ),
        );
        break;
    }
  }

  void _onProfileTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  }

  void _navigateToBusinessCards() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BusinessCardScreen()),
    );
  }

  Future<void> _loadUserCard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cardDataJson = prefs.getString('user_card_data');
      
      if (cardDataJson != null) {
        final cardData = json.decode(cardDataJson);
        setState(() {
          currentUserCard = BusinessCard(
            id: 0,
            name: cardData['name'] ?? widget.userName,
            title: cardData['title'] ?? 'Your Title',
            company: cardData['company'] ?? 'Your Company',
            email: cardData['email'] ?? 'your.email@example.com',
            phone: cardData['phone'] ?? widget.phoneNumber ?? 'Your Phone',
            website: cardData['website'] ?? 'www.yourwebsite.com',
            location: cardData['location'] ?? 'Your Location',
            color: const Color(0xFF0F172A),
          );
        });
      } else {
        // Initialize with default values if no saved data
        setState(() {
          currentUserCard = BusinessCard(
            id: 0,
            name: widget.userName,
            title: 'Your Title',
            company: 'Your Company',
            email: 'your.email@example.com',
            phone: widget.phoneNumber ?? 'Your Phone',
            website: 'www.yourwebsite.com',
            location: 'Your Location',
            color: const Color(0xFF0F172A),
          );
        });
      }
    } catch (e) {
      // Fallback to default values on error
      setState(() {
        currentUserCard = BusinessCard(
          id: 0,
          name: widget.userName,
          title: 'Your Title',
          company: 'Your Company',
          email: 'your.email@example.com',
          phone: widget.phoneNumber ?? 'Your Phone',
          website: 'www.yourwebsite.com',
          location: 'Your Location',
          color: const Color(0xFF0F172A),
        );
      });
    }
  }

  void _navigateToMyCard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyCardScreen(
          currentUserCard: currentUserCard,
          onCardUpdated: (updatedCard) {
            setState(() {
              currentUserCard = updatedCard;
            });
            // Save updated card data to SharedPreferences
            _saveUserCardData(updatedCard);
          },
        ),
      ),
    );
  }

  Future<void> _saveUserCardData(BusinessCard card) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cardData = {
        'name': card.name,
        'title': card.title,
        'company': card.company,
        'email': card.email,
        'phone': card.phone,
        'website': card.website,
        'location': card.location,
      };
      final cardDataJson = json.encode(cardData);
      await prefs.setString('user_card_data', cardDataJson);
    } catch (e) {
      // Handle error silently or show a snackbar if needed
      print('Error saving user card data: $e');
    }
  }

  void _startImageProcessing() {
    setState(() {
      _isProcessingImage = true;
      _isProcessingComplete = false;
      _processingError = null;
      _processingProgress = 0.0;
    });
    
    // Start animations
    _rotationController.repeat();
    _progressController.forward();
  }

  void _onProcessingSuccess(Map<String, dynamic> data) {
    setState(() {
      _isProcessingImage = false;
      _isProcessingComplete = true;
      _extractedCardData = data;
    });
    
    // Stop rotation and start checkmark animation
    _rotationController.stop();
    _progressController.stop();
    _checkmarkController.forward();
  }

  void _onProcessingError(String error) {
    setState(() {
      _isProcessingImage = false;
      _isProcessingComplete = false;
      _processingError = error;
    });
    
    // Stop animations
    _rotationController.stop();
    _progressController.stop();
  }

  void _showCameraOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              const Text(
                'Add Business Card',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 20),
              // Options
              ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Color(0xFF0F172A),
                    size: 24,
                  ),
                ),
                title: const Text(
                  'Take Photo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0F172A),
                  ),
                ),
                subtitle: const Text(
                  'Capture a business card with camera',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CameraScannerPage()),
                  );
                  
                  // Handle the result from camera scanner
                  if (result != null && result is Map<String, dynamic>) {
                    if (result['success'] == true) {
                      // Start processing UI immediately
                      _startImageProcessing();
                      
                      try {
                        // Process the image data on home screen
                        final imageBytes = result['imageBytes'];
                        final fileName = result['fileName'];
                        
                        final response = await ApiHelper.uploadImageForCardExtraction(
                          imageBytes,
                          fileName,
                        );
                        
                        if (response.statusCode >= 200 && response.statusCode < 300) {
                          final responseData = json.decode(response.body);
                          _onProcessingSuccess(responseData);
                        } else {
                          _onProcessingError('Processing failed: ${response.statusCode}');
                        }
                      } catch (apiError) {
                        _onProcessingError('Network error: $apiError');
                      }
                    } else {
                      // Handle error case
                      _onProcessingError(result['error'] ?? 'Unknown error occurred');
                    }
                  }
                },
              ),
              ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: Color(0xFF0F172A),
                    size: 24,
                  ),
                ),
                title: const Text(
                  'Upload from Gallery',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0F172A),
                  ),
                ),
                subtitle: const Text(
                  'Choose an image from your device',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _pickImageFromGallery() async {
    try {
      if (kIsWeb) {
        // Use file_picker for web compatibility
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        
        if (result != null && result.files.single.bytes != null) {
          final fileBytes = result.files.single.bytes!;
          final fileName = result.files.single.name;
          
          print('Image selected: $fileName');
          print('File size: ${fileBytes.length} bytes');
          
          // Start processing UI
          _startImageProcessing();
          
          try {
            // Send image to backend for processing
            final response = await ApiHelper.uploadImageForCardExtraction(
              fileBytes,
              fileName,
            );
            
            if (response.statusCode >= 200 && response.statusCode < 300) {
              final responseData = json.decode(response.body);
              print('Card extraction successful: $responseData');
              _onProcessingSuccess(responseData);
            } else {
              print('Card extraction failed: ${response.statusCode} - ${response.body}');
              _onProcessingError('Processing failed: ${response.statusCode}');
            }
          } catch (apiError) {
            print('API Error: $apiError');
            _onProcessingError('Network error: $apiError');
          }
        }
      } else {
        // Use image_picker for mobile platforms
        final ImagePicker imagePicker = ImagePicker();
        final XFile? image = await imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
        
        if (image != null) {
          print('Image selected: ${image.path}');
          
          // Start processing UI
          _startImageProcessing();
          
          try {
            // Read image bytes for mobile
            final imageBytes = await image.readAsBytes();
            final fileName = image.name;
            
            // Send image to backend for processing
            final response = await ApiHelper.uploadImageForCardExtraction(
              imageBytes,
              fileName,
            );
            
            if (response.statusCode >= 200 && response.statusCode < 300) {
              final responseData = json.decode(response.body);
              print('Card extraction successful: $responseData');
              _onProcessingSuccess(responseData);
            } else {
              print('Card extraction failed: ${response.statusCode} - ${response.body}');
              _onProcessingError('Processing failed: ${response.statusCode}');
            }
          } catch (apiError) {
            print('API Error: $apiError');
            _onProcessingError('Network error: $apiError');
          }
        }
      }
    } catch (e) {
      print('Error selecting image: $e');
      _onProcessingError('Error selecting image: $e');
    }
  }

  void _showCreateCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Create your own category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CATEGORY NAME',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF475569),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _categoryNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter category name',
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF94A3B8),
                          width: 1,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _categoryNameController.clear();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isCreatingCategory ? null : () => _createCategory(setState),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isCreatingCategory
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _createCategory(StateSetter setState) async {
    if (_categoryNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a category name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isCreatingCategory = true;
    });

    try {
      final userId = await UserSession.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final response = await http.post(
        Uri.parse('http://34.93.230.130:5001/add_category'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': userId,
          'category_name': _categoryNameController.text.trim(),
        }),
      );

      setState(() {
        _isCreatingCategory = false;
      });

      // Close dialog first
      _categoryNameController.clear();
      Navigator.of(context).pop();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Category created successfully'),
            backgroundColor: const Color(0xFF0F172A), // App's primary color
          ),
        );
      } else {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorData['message'] ?? 'Failed to create category'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isCreatingCategory = false;
      });
      
      // Close dialog first
      _categoryNameController.clear();
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                color: const Color(0xFF0F172A),
                backgroundColor: Colors.white,
                strokeWidth: 2.5,
                displacement: 40.0,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildFlipCard(),
                      _buildProcessingSection(),
                      _buildCategories(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCameraOptions,
        backgroundColor: const Color(0xFF0F172A),
        child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Smart Stack',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Digital Business Cards',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: IconButton(
                   onPressed: _onProfileTap,
                   icon: const Icon(
                     Icons.person_outline,
                     color: Color(0xFF475569),
                     size: 20,
                   ),
                   padding: EdgeInsets.zero,
                 ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: Border.all(
                color: const Color(0xFFE2E8F0).withOpacity(0.8),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search cards',
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF94A3B8),
                  size: 18,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlipCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF1F5F9),
            width: 1,
          ),
        ),
      ),
      child: Transform.scale(
        scale: 0.85,
        child: AspectRatio(
          aspectRatio: 1.76,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: _isCardFlipped ? math.pi : 0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              final isUnder = value > math.pi / 2;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(value),
                child: isUnder
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(math.pi),
                        child: _buildCardBack(),
                      )
                    : _buildCardFront(),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCardFront() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
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
        children: [
          // Top Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CATEGORIES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '4',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'TOTAL CARDS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_totalCards',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Middle Section
          Transform.translate(
            offset: const Offset(0, -8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hi ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  currentUserCard.name.split(' ')[0],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          // Bottom Section
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Flexible(
                child: Text(
                  'Click here for your business card',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFCBD5E1),
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 8),
              BlinkingArrow(),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _isCardFlipped = !_isCardFlipped),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.credit_card,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
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
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Section
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
              // Middle Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentUserCard.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentUserCard.title,
                    style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFFCBD5E1),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              // Bottom Section
              Text(
                currentUserCard.company,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _navigateToMyCard,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _isCardFlipped = !_isCardFlipped),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.flip_to_front,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              GestureDetector(
                onTap: _showCreateCategoryDialog,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return GestureDetector(
                onTap: () => _onCategoryTap(category.id),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          category.icon,
                          color: const Color(0xFF0F172A),
                          size: 20,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${category.count} cards',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingSection() {
    if (!_isProcessingImage && !_isProcessingComplete && _processingError == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_isProcessingImage) ...[
            // Processing state
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 2 * math.pi,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Color(0xFF0F172A),
                      size: 30,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'AI is working its magic ✨',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Extracting card details in a few seconds...',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Column(
                  children: [
                    LinearProgressIndicator(
                      value: _progressAnimation.value,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F172A)),
                      minHeight: 6,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_progressAnimation.value * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                );
              },
            ),
          ] else if (_isProcessingComplete) ...[
            // Success state
            AnimatedBuilder(
              animation: _checkmarkAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _checkmarkAnimation.value,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 30,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Process Completed! ✅',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your business card has been successfully processed',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _navigateToBusinessCards,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Check Results',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ] else if (_processingError != null) ...[
            // Error state
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Processing Failed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _processingError!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isProcessingImage = false;
                    _isProcessingComplete = false;
                    _processingError = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class BlinkingArrow extends StatefulWidget {
  const BlinkingArrow({super.key});

  @override
  State<BlinkingArrow> createState() => _BlinkingArrowState();
}

class _BlinkingArrowState extends State<BlinkingArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: const Icon(
            Icons.arrow_forward,
            color: Color(0xFFCBD5E1),
            size: 16,
          ),
        );
      },
    );
  }
}