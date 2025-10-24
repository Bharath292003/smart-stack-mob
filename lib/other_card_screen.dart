import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'user_session.dart';
import 'app_colors.dart';

class OtherCardModel {
  final String? id;
  final String? title;
  final String? type;
  final String? details;
  final String? cardId;
  final String? expiry;
  final String? notes;
  final Color color;

  OtherCardModel({
    this.id,
    this.title,
    this.type,
    this.details,
    this.cardId,
    this.expiry,
    this.notes,
    required this.color,
  });

  factory OtherCardModel.fromJson(Map<String, dynamic> json) {
    return OtherCardModel(
      id: json['id']?.toString(),
      title: json['title'] ?? json['name'],
      type: json['type'] ?? json['card_type'],
      details: json['details'] ?? json['description'],
      cardId: json['card_id'] ?? json['cardId'],
      expiry: json['expiry'] ?? json['expiry_date'],
      notes: json['notes'] ?? json['additional_info'],
      color: _getRandomColor(),
    );
  }

  static Color _getRandomColor() {
    return AppColors.getRandomOtherColor();
  }
}

class OtherCardScreen extends StatefulWidget {
  const OtherCardScreen({super.key});

  @override
  State<OtherCardScreen> createState() => _OtherCardScreenState();
}

class _OtherCardScreenState extends State<OtherCardScreen> {
  List<OtherCardModel> _otherCards = [];
  List<OtherCardModel> _filteredOtherCards = [];
  bool _isLoading = true;
  int _totalCards = 0;
  OtherCardModel? _expandedCard;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchOtherCards();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchOtherCards() async {
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
        
        // Filter only other cards (not business or personal)
        final otherCards = cardsData
            .where((card) => card['card_type'] != 'business' && card['card_type'] != 'personal')
            .map((card) => OtherCardModel.fromJson(card))
            .toList();

        setState(() {
          _otherCards = otherCards;
          _filteredOtherCards = otherCards; // Initialize filtered list
          _totalCards = otherCards.length;
          _isLoading = false;
        });
      } else {
        print('Failed to fetch cards: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching other cards: $e');
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
                  : _filteredOtherCards.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(24),
                          itemCount: _filteredOtherCards.length,
                          itemBuilder: (context, index) {
                            final card = _filteredOtherCards[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildCompactOtherCard(card),
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
                      'Other Cards',
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
                hintText: 'Search other cards',
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
              isSearching ? Icons.search_off : Icons.credit_card_outlined,
              size: 40,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isSearching ? 'No cards found' : 'No other cards found',
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
                : 'Add your first other card to get started',
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
        _filteredOtherCards = _otherCards;
      } else {
        _filteredOtherCards = _otherCards.where((card) {
          final searchQuery = query.toLowerCase();
          
          // Search in all relevant fields
          final title = card.title?.toLowerCase() ?? '';
          final type = card.type?.toLowerCase() ?? '';
          final details = card.details?.toLowerCase() ?? '';
          final cardId = card.cardId?.toLowerCase() ?? '';
          final notes = card.notes?.toLowerCase() ?? '';
          
          // Check if query matches any field
          return title.contains(searchQuery) ||
                 type.contains(searchQuery) ||
                 details.contains(searchQuery) ||
                 cardId.contains(searchQuery) ||
                 notes.contains(searchQuery);
        }).toList();
      }
    });
  }

  Widget _buildCompactOtherCard(OtherCardModel card) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [card.color, card.color.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: card.color.withOpacity(0.3),
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
            // Header with card icon and action buttons
            Row(
              children: [
                Icon(
                  _getCardIcon(card.type ?? ''),
                  color: Colors.white,
                  size: 24,
                ),
                const Spacer(),
                // Action buttons
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _contactSupport(card),
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
            
            // Title
            Text(
              card.title ?? 'Unknown',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            
            // Type
            Text(
              card.type ?? '',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            
            // Card details
            if (card.cardId != null && card.cardId!.isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    Icons.credit_card,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      card.cardId!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            
            if (card.expiry != null && card.expiry!.isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Expires: ${card.expiry}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
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

  IconData _getCardIcon(String type) {
    switch (type.toLowerCase()) {
      case 'membership':
        return Icons.card_membership;
      case 'id card':
        return Icons.badge;
      case 'insurance':
        return Icons.health_and_safety;
      case 'rewards':
        return Icons.stars;
      default:
        return Icons.credit_card;
    }
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
              color: const Color(0xFF8B5CF6),
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

  void _contactSupport(OtherCardModel card) {
    _showTopRightAlert('Contacting support for ${card.title ?? 'card'}...');
  }

  void _shareCard(OtherCardModel card) {
    String cardInfo = '';
    
    // Add title/name
    if (card.title != null && card.title!.isNotEmpty) {
      cardInfo += '${card.title}';
    }
    
    // Add type
    if (card.type != null && card.type!.isNotEmpty) {
      cardInfo += '\nType: ${card.type}';
    }
    
    // Add card ID if available
    if (card.cardId != null && card.cardId!.isNotEmpty) {
      cardInfo += '\nID: ${card.cardId}';
    }
    
    // Add footer
    cardInfo += '\n\nShared via Smart Stack';
    
    // Share the formatted card information
    Share.share(
      cardInfo,
      subject: 'Card - ${card.title ?? 'Other Card'}',
    );
  }
}

class ExpandedOtherCardDialog extends StatelessWidget {
  final OtherCardModel card;
  final VoidCallback onClose;

  const ExpandedOtherCardDialog({
    super.key,
    required this.card,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent closing when tapping the card
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [card.color, card.color.withOpacity(0.8)],
                ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        _getCardIcon(card.type ?? ''),
                        color: Colors.white,
                        size: 32,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: onClose,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Title and Type
                  Text(
                    card.title ?? 'Unknown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    card.type ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Details
                   if (card.details != null && card.details!.isNotEmpty)
                     _buildDetailRow('Details', card.details!),
                   if (card.cardId != null && card.cardId!.isNotEmpty)
                     _buildDetailRow('Card ID', card.cardId!),
                   if (card.expiry != null && card.expiry!.isNotEmpty)
                     _buildDetailRow('Expiry', card.expiry!),
                   if (card.notes != null && card.notes!.isNotEmpty)
                     _buildDetailRow('Notes', card.notes!),
                  
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: card.color,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.share, size: 18),
                          label: const Text('Share'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
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
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCardIcon(String type) {
    switch (type.toLowerCase()) {
      case 'membership':
        return Icons.card_membership;
      case 'id card':
        return Icons.badge;
      case 'insurance':
        return Icons.health_and_safety;
      case 'rewards':
        return Icons.stars;
      default:
        return Icons.credit_card;
    }
  }
}