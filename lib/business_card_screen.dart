import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_session.dart';
import 'app_colors.dart';

// Card Model
class CardModel {
  final String cardId;
  final String? name;
  final String? jobTitle;
  final String? company;
  final String? email;
  final String? phone;
  final String? website;
  final String? address;
  final String? additionalInfo;
  final Map<String, String?>? socialMedia;
  final Color color;

  CardModel({
    required this.cardId,
    this.name,
    this.jobTitle,
    this.company,
    this.email,
    this.phone,
    this.website,
    this.address,
    this.additionalInfo,
    this.socialMedia,
    required this.color,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      cardId: json['card_id'] ?? '',
      name: json['name'],
      jobTitle: json['job_title'],
      company: json['company'],
      email: json['email'],
      phone: json['phone'],
      website: json['website'],
      address: json['address'],
      additionalInfo: json['additional_info'],
      socialMedia: json['social_media'] != null 
          ? Map<String, String?>.from(json['social_media'])
          : null,
      color: _getRandomColor(),
    );
  }

  static Color _getRandomColor() {
    return AppColors.getRandomBusinessColor();
  }
}

class CompactBusinessCard extends StatelessWidget {
  final CardModel card;
  final VoidCallback onTap;

  const CompactBusinessCard({
    Key? key,
    required this.card,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: AspectRatio(
          aspectRatio: 1.76,
          child: Container(
            decoration: BoxDecoration(
              color: card.color,
              borderRadius: BorderRadius.circular(16),
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
                        Icons.work_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.star_border,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                // Middle Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.name ?? card.company ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (card.jobTitle != null)
                      Text(
                        card.jobTitle!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFCBD5E1),
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
                // Bottom Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (card.company != null && card.name != null)
                      Text(
                        card.company!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'Contact',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'View',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.share,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ExpandedCardDialog extends StatelessWidget {
  final CardModel card;
  final VoidCallback onClose;

  const ExpandedCardDialog({
    Key? key,
    required this.card,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                decoration: BoxDecoration(
                  color: card.color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card.name ?? card.company ?? 'Unknown',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (card.jobTitle != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  card.jobTitle!,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                              if (card.company != null && card.name != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  card.company!,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: onClose,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (card.email != null)
                      _buildContactRow(Icons.email_outlined, card.email!),
                    if (card.email != null && card.phone != null)
                      const SizedBox(height: 16),
                    if (card.phone != null)
                      _buildContactRow(Icons.phone_outlined, card.phone!),
                    if (card.phone != null && card.website != null)
                      const SizedBox(height: 16),
                    if (card.website != null)
                      _buildContactRow(Icons.language, card.website!),
                    if (card.website != null && card.address != null)
                      const SizedBox(height: 16),
                    if (card.address != null)
                      _buildContactRow(Icons.location_on_outlined, card.address!),
                    if (card.additionalInfo != null) ...[
                      const SizedBox(height: 16),
                      _buildContactRow(Icons.info_outline, card.additionalInfo!),
                    ],
                    const SizedBox(height: 24),
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF1F5F9),
                              foregroundColor: const Color(0xFF334155),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Share',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F172A),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Contact',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF64748B)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
            ),
          ),
        ),
      ],
    );
  }
}

class BusinessCardScreen extends StatefulWidget {
  const BusinessCardScreen({Key? key}) : super(key: key);

  @override
  State<BusinessCardScreen> createState() => _BusinessCardScreenState();
}

class _BusinessCardScreenState extends State<BusinessCardScreen> {
  List<CardModel> _businessCards = [];
  bool _isLoading = true;
  int _totalCards = 0;
  CardModel? _expandedCard;

  @override
  void initState() {
    super.initState();
    _fetchBusinessCards();
  }

  Future<void> _fetchBusinessCards() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final userId = await UserSession.getUserId();
      if (userId == null) {
        print('User ID not found');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:5001/cards/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> cardsData = data['cards'] ?? [];
        
        // Filter only business cards
        final businessCards = cardsData
            .where((card) => card['card_type'] == 'business')
            .map((card) => CardModel.fromJson(card))
            .toList();

        setState(() {
          _businessCards = businessCards;
          _totalCards = businessCards.length;
          _isLoading = false;
        });
      } else {
        print('Failed to fetch cards: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching business cards: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF0F172A),
                          ),
                        )
                      : _businessCards.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.all(24),
                              itemCount: _businessCards.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: CompactBusinessCard(
                                    card: _businessCards[index],
                                    onTap: () => setState(() => _expandedCard = _businessCards[index]),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
            if (_expandedCard != null)
              ExpandedCardDialog(
                card: _expandedCard!,
                onClose: () => setState(() => _expandedCard = null),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF0F172A),
        child: const Icon(Icons.add, size: 20),
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
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    size: 20,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Business Cards',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isLoading 
                          ? 'Loading...' 
                          : '$_totalCards ${_totalCards == 1 ? 'card' : 'cards'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
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
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search business cards',
                hintStyle: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Color(0xFF94A3B8),
                  size: 18,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.business_center_outlined,
              size: 40,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No business cards found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first business card to get started',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}