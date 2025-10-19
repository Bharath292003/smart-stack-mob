import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'login_page.dart';
import 'camera_scanner.dart';
import 'business_card_screen.dart';
import 'personal_card_screen.dart';
import 'other_card_screen.dart';
import 'user_session.dart';
import 'session_debug_helper.dart';
import 'models.dart';

class HomePage extends StatefulWidget {
  final String userName;
  final String? phoneNumber;

  const HomePage({
    Key? key,
    required this.userName,
    this.phoneNumber,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _totalCards = 0;
  bool _isLoadingCards = false;
  bool _isCardFlipped = false;
  late BusinessCard currentUserCard;
  late List<Category> categories;

  @override
  void initState() {
    super.initState();
    
    // Initialize current user card with actual user data
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

  Future<void> _fetchTotalCards() async {
    setState(() {
      _isLoadingCards = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        return;
      }

      final response = await http.get(
        Uri.parse('https://smartstackapi.onrender.com/api/cards/total'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _totalCards = data['total'] ?? 0;
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

  @override
  Widget build(BuildContext context) {
    return HomeScreen(
      currentUserCard: currentUserCard,
      totalCards: _totalCards,
      categories: categories,
      isCardFlipped: _isCardFlipped,
      onFlipCard: () => setState(() => _isCardFlipped = !_isCardFlipped),
      onCategoryTap: _onCategoryTap,
    );
  }
}

// Home Screen from design_reference.dart
class HomeScreen extends StatelessWidget {
  final BusinessCard currentUserCard;
  final int totalCards;
  final List<Category> categories;
  final bool isCardFlipped;
  final VoidCallback onFlipCard;
  final Function(String) onCategoryTap;

  const HomeScreen({
    Key? key,
    required this.currentUserCard,
    required this.totalCards,
    required this.categories,
    required this.isCardFlipped,
    required this.onFlipCard,
    required this.onCategoryTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildFlipCard(),
                    _buildCategories(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CameraScannerPage()),
          );
        },
        backgroundColor: const Color(0xFF0F172A),
        child: const Icon(Icons.camera_alt, size: 20),
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
                child: const Icon(
                  Icons.more_vert,
                  color: Color(0xFF475569),
                  size: 20,
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
            tween: Tween<double>(begin: 0, end: isCardFlipped ? math.pi : 0),
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
                    '$totalCards',
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
                onTap: onFlipCard,
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
            child: GestureDetector(
              onTap: onFlipCard,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '×',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CATEGORIES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          ...categories.map((category) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => onCategoryTap(category.id),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            category.icon,
                            color: const Color(0xFF334155),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${category.count} ${category.count == 1 ? 'card' : 'cards'}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF94A3B8),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

// Blinking Arrow Widget
class BlinkingArrow extends StatefulWidget {
  const BlinkingArrow({Key? key}) : super(key: key);

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
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 0.3).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: const Icon(
        Icons.chevron_right,
        color: Color(0xFF94A3B8),
        size: 16,
      ),
    );
  }
}