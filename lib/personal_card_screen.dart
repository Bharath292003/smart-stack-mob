import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'user_session.dart';
import 'app_colors.dart';

class PersonalCardModel {
  final String? id;
  final String? name;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;
  final String? relationship;
  final Color color;

  PersonalCardModel({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.address,
    this.notes,
    this.relationship,
    required this.color,
  });

  factory PersonalCardModel.fromJson(Map<String, dynamic> json) {
    return PersonalCardModel(
      id: json['id']?.toString(),
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      notes: json['notes'],
      relationship: json['relationship'],
      color: _getRandomColor(),
    );
  }

  static Color _getRandomColor() {
    return AppColors.getRandomPersonalColor();
  }
  
  static Color _getColorByIndex(int index) {
    return AppColors.getBusinessColorByIndex(index);
  }
}

class PersonalCardScreen extends StatefulWidget {
  const PersonalCardScreen({super.key});

  @override
  State<PersonalCardScreen> createState() => _PersonalCardScreenState();
}

class _PersonalCardScreenState extends State<PersonalCardScreen> {
  List<PersonalCardModel> _personalCards = [];
  List<PersonalCardModel> _filteredPersonalCards = [];
  bool _isLoading = true;
  int _totalCards = 0;
  PersonalCardModel? _expandedCard;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPersonalCards();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPersonalCards() async {
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
        Uri.parse('http://34.93.230.130:5001/cards/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> cardsData = data['cards'] ?? [];
        
        // Filter only personal cards
        final personalCards = cardsData
            .where((card) => card['card_type'] == 'personal')
            .map((card) => PersonalCardModel.fromJson(card))
            .toList();

        setState(() {
          _personalCards = personalCards;
          _filteredPersonalCards = personalCards; // Initialize filtered list
          _totalCards = personalCards.length;
          _isLoading = false;
        });
      } else {
        print('Failed to fetch cards: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching personal cards: $e');
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
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0F172A),
                      ),
                    )
                  : _filteredPersonalCards.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(24),
                          itemCount: _filteredPersonalCards.length,
                          itemBuilder: (context, index) {
                            final card = _filteredPersonalCards[index];
                            // Create a new card with color based on index
                            final cardWithColor = PersonalCardModel(
                              id: card.id,
                              name: card.name,
                              phone: card.phone,
                              email: card.email,
                              address: card.address,
                              notes: card.notes,
                              relationship: card.relationship,
                              color: PersonalCardModel._getColorByIndex(index),
                            );
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildCompactPersonalCard(cardWithColor),
                            );
                          },
                        ),
            ),
          ],
        ),
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
                      'Personal Cards',
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
              SizedBox(
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
              controller: _searchController,
              onChanged: _filterCards,
              decoration: const InputDecoration(
                hintText: 'Search personal cards',
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
    final isSearching = _searchController.text.isNotEmpty;
    
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
            child: Icon(
              isSearching ? Icons.search_off : Icons.person_outline,
              size: 40,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isSearching ? 'No cards found' : 'No personal cards found',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching 
                ? 'Try adjusting your search terms'
                : 'Add your first personal card to get started',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // Search functionality
  void _filterCards(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPersonalCards = _personalCards;
      } else {
        _filteredPersonalCards = _personalCards.where((card) {
          final searchQuery = query.toLowerCase();
          
          // Search in all relevant fields
          final name = card.name?.toLowerCase() ?? '';
          final relationship = card.relationship?.toLowerCase() ?? '';
          final email = card.email?.toLowerCase() ?? '';
          final phone = card.phone?.toLowerCase() ?? '';
          final address = card.address?.toLowerCase() ?? '';
          final notes = card.notes?.toLowerCase() ?? '';
          
          // Check if query matches any field
          return name.contains(searchQuery) ||
                 relationship.contains(searchQuery) ||
                 email.contains(searchQuery) ||
                 phone.contains(searchQuery) ||
                 address.contains(searchQuery) ||
                 notes.contains(searchQuery);
        }).toList();
      }
    });
  }

  Widget _buildCompactPersonalCard(PersonalCardModel card) {
    return Container(
      decoration: BoxDecoration(
        color: card.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: card.color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with profile icon and action buttons
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const Spacer(),
                // Action buttons
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _contactPerson(card),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.phone,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _expandedCard = card),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.visibility,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _shareCard(card),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.share,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Name
            Text(
              card.name ?? 'Unknown',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            
            // Relationship
            Text(
              card.relationship ?? '',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            
            // Contact info
            if (card.phone != null && card.phone!.isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      card.phone!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            
            if (card.email != null && card.email!.isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    Icons.email,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      card.email!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }



  void _showPersonalCardPopup(PersonalCardModel card) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: card.color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Profile Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Name
                      Text(
                        card.name ?? 'Unknown',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      
                      // Relationship
                      Text(
                        card.relationship ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                // Contact Details
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (card.phone != null)
                          _buildPopupDetailRow(Icons.phone, 'Phone', card.phone!),
                        if (card.email != null)
                          _buildPopupDetailRow(Icons.email, 'Email', card.email!),
                        if (card.address != null)
                          _buildPopupDetailRow(Icons.location_on, 'Address', _formatAddress(card.address!)),
                        if (card.notes != null)
                          _buildPopupDetailRow(Icons.note, 'Notes', card.notes!),
                      ],
                    ),
                  ),
                ),
                
                // Action Buttons
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      if (card.phone != null)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _makePhoneCall(card.phone!),
                            icon: const Icon(Icons.phone, size: 18),
                            label: const Text('Call'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      if (card.phone != null) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _sendMessage(card.phone ?? ''),
                          icon: const Icon(Icons.message, size: 18),
                          label: const Text('Message'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopupDetailRow(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAddress(String address) {
    if (address.isEmpty) return '';
    // Split by comma and take first two parts for compact display
    List<String> parts = address.split(',');
    if (parts.length > 2) {
      return '${parts[0].trim()}, ${parts[1].trim()}...';
    }
    return address;
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) return;
    
    _showTopRightAlert('Calling $phoneNumber...');
  }

  Future<void> _sendMessage(String phoneNumber) async {
    if (phoneNumber.isEmpty) return;
    
    _showTopRightAlert('Messaging $phoneNumber...');
  }

  void _showTopRightAlert(String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        right: 10,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  void _contactPerson(PersonalCardModel card) {
    if (card.phone != null && card.phone!.isNotEmpty) {
      _makePhoneCall(card.phone!);
    } else {
      _showTopRightAlert('No phone number available');
    }
  }

  void _shareCard(PersonalCardModel card) {
    String cardInfo = '';
    
    // Add name
    if (card.name != null && card.name!.isNotEmpty) {
      cardInfo += '${card.name}';
    }
    
    // Add relationship
    if (card.relationship != null && card.relationship!.isNotEmpty) {
      cardInfo += '\n${card.relationship}';
    }
    
    // Add contact information
    if (card.phone != null && card.phone!.isNotEmpty) {
      cardInfo += '\n📞 ${card.phone}';
    }
    
    if (card.email != null && card.email!.isNotEmpty) {
      cardInfo += '\n📧 ${card.email}';
    }
    
    if (card.address != null && card.address!.isNotEmpty) {
      cardInfo += '\n📍 ${card.address}';
    }
    
    // Add notes if available
    if (card.notes != null && card.notes!.isNotEmpty) {
      cardInfo += '\n\nNotes: ${card.notes}';
    }
    
    // Add footer
    cardInfo += '\n\nShared via Smart Stack';
    
    // Share the formatted card information
    Share.share(
      cardInfo,
      subject: 'Personal Contact - ${card.name ?? 'Contact'}',
    );
  }
}