import 'package:flutter/material.dart';

// Card Model
class CardModel {
  final int id;
  final String name;
  final String title;
  final String company;
  final String email;
  final String phone;
  final String website;
  final String location;
  final List<Color> gradientColors;

  CardModel({
    required this.id,
    required this.name,
    required this.title,
    required this.company,
    required this.email,
    required this.phone,
    required this.website,
    required this.location,
    required this.gradientColors,
  });
}

// Category Model
class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final int count;
  final List<Color> gradientColors;
  final List<CardModel> cards;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.count,
    required this.gradientColors,
    required this.cards,
  });
}

class BusinessCardScreen extends StatelessWidget {
  const BusinessCardScreen({Key? key}) : super(key: key);

  CategoryModel getBusinessCategory() {
    return CategoryModel(
      id: 'business',
      name: 'Business Cards',
      icon: Icons.business_center,
      count: 24,
      gradientColors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
      cards: [
        CardModel(
          id: 1,
          name: 'John Anderson',
          title: 'Senior Product Manager',
          company: 'TechCorp Industries',
          email: 'j.anderson@techcorp.com',
          phone: '+1 (555) 123-4567',
          website: 'techcorp.com',
          location: 'San Francisco, CA',
          gradientColors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
        CardModel(
          id: 2,
          name: 'Sarah Mitchell',
          title: 'Chief Marketing Officer',
          company: 'Digital Innovations Ltd',
          email: 'sarah.m@digitalinnov.com',
          phone: '+1 (555) 987-6543',
          website: 'digitalinnov.com',
          location: 'New York, NY',
          gradientColors: [Color(0xFF9333EA), Color(0xFF7E22CE)],
        ),
        CardModel(
          id: 3,
          name: 'Michael Chen',
          title: 'Lead Software Engineer',
          company: 'CloudSync Solutions',
          email: 'mchen@cloudsync.io',
          phone: '+1 (555) 456-7890',
          website: 'cloudsync.io',
          location: 'Austin, TX',
          gradientColors: [Color(0xFF059669), Color(0xFF047857)],
        ),
        CardModel(
          id: 4,
          name: 'Emily Rodriguez',
          title: 'Business Development Director',
          company: 'Global Ventures Inc',
          email: 'e.rodriguez@globalventures.com',
          phone: '+1 (555) 234-5678',
          website: 'globalventures.com',
          location: 'Miami, FL',
          gradientColors: [Color(0xFFF97316), Color(0xFFEA580C)],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = getBusinessCategory();

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
                            category.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            '${category.count} cards in stack',
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
              child: ListView.builder(
                padding: EdgeInsets.all(24),
                itemCount: category.cards.length + 1,
                itemBuilder: (context, index) {
                  if (index == category.cards.length) {
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

                  final card = category.cards[index];
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
                                            card.name,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            card.title,
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.9),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            card.company,
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.7),
                                              fontSize: 14,
                                            ),
                                          ),
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
                                _buildContactRow(Icons.email_outlined, card.email),
                                SizedBox(height: 12),
                                _buildContactRow(Icons.phone_outlined, card.phone),
                                SizedBox(height: 12),
                                _buildContactRow(Icons.language, card.website),
                                SizedBox(height: 12),
                                _buildContactRow(Icons.location_on_outlined, card.location),
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