import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_session.dart';

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
  final List<Color> gradientColors;

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
    required this.gradientColors,
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
      gradientColors: _getRandomGradientColors(),
    );
  }

  static List<Color> _getRandomGradientColors() {
    // Using the John Anderson gradient (dark slate) for all business cards
    return [Color(0xFF1E293B), Color(0xFF0F172A)];
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
      backgroundColor: Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Color(0xFF334155)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Business Cards',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            _isLoading 
                                ? 'Loading...' 
                                : '$_totalCards cards in stack',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search, color: Color(0xFF475569)),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            // Cards List
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4F46E5),
                      ),
                    )
                  : _businessCards.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.business_center_outlined,
                                size: 64,
                                color: Color(0xFF94A3B8),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No business cards found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Add your first business card to get started',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(24),
                          itemCount: _businessCards.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _businessCards.length) {
                              // Add Card Button
                              return Container(
                                margin: EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Color(0xFFCBD5E1),
                                    width: 2,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {},
                                    borderRadius: BorderRadius.circular(20),
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add, color: Color(0xFF64748B)),
                                          SizedBox(width: 8),
                                          Text(
                                            'Add New Card',
                                            style: TextStyle(
                                              color: Color(0xFF64748B),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }

                            final card = _businessCards[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Color(0xFFE2E8F0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 20,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Card Header with Gradient
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: card.gradientColors,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                      ),
                                      padding: EdgeInsets.all(24),
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
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 24,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    if (card.jobTitle != null) ...[
                                                      SizedBox(height: 4),
                                                      Text(
                                                        card.jobTitle!,
                                                        style: TextStyle(
                                                          color: Colors.white.withOpacity(0.9),
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                    if (card.company != null && card.name != null) ...[
                                                      SizedBox(height: 4),
                                                      Text(
                                                        card.company!,
                                                        style: TextStyle(
                                                          color: Colors.white.withOpacity(0.7),
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(50),
                                                ),
                                                child: IconButton(
                                                  icon: Icon(Icons.star_border, color: Colors.white),
                                                  onPressed: () {},
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Card Details
                                    Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          if (card.email != null)
                                            _buildContactRow(Icons.email_outlined, card.email!),
                                          if (card.email != null && card.phone != null)
                                            SizedBox(height: 12),
                                          if (card.phone != null)
                                            _buildContactRow(Icons.phone_outlined, card.phone!),
                                          if (card.phone != null && card.website != null)
                                            SizedBox(height: 12),
                                          if (card.website != null)
                                            _buildContactRow(Icons.language, card.website!),
                                          if (card.website != null && card.address != null)
                                            SizedBox(height: 12),
                                          if (card.address != null)
                                            _buildContactRow(Icons.location_on_outlined, card.address!),
                                          if (card.additionalInfo != null) ...[
                                            SizedBox(height: 12),
                                            _buildContactRow(Icons.info_outline, card.additionalInfo!),
                                          ],
                                          SizedBox(height: 20),
                                          Container(
                                            height: 1,
                                            color: Color(0xFFF1F5F9),
                                          ),
                                          SizedBox(height: 20),
                                          // Action Buttons
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () {},
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Color(0xFFF1F5F9),
                                                    foregroundColor: Color(0xFF334155),
                                                    elevation: 0,
                                                    padding: EdgeInsets.symmetric(vertical: 12),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'View Details',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () {},
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Color(0xFF4F46E5),
                                                    elevation: 0,
                                                    padding: EdgeInsets.symmetric(vertical: 12),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Contact',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 14,
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
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Color(0xFF94A3B8)),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
            ),
          ),
        ),
      ],
    );
  }
}