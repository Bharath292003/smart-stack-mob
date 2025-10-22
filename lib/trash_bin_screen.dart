import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_session.dart';
import 'app_colors.dart';

// Deleted Card Model
class DeletedCardModel {
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
  final String cardType;
  final String createdAt;
  final List<String> tags;

  DeletedCardModel({
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
    required this.cardType,
    required this.createdAt,
    required this.tags,
  });

  factory DeletedCardModel.fromJson(Map<String, dynamic> json) {
    return DeletedCardModel(
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
      cardType: json['card_type'] ?? '',
      createdAt: json['created_at'] ?? '',
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
    );
  }
}

class TrashBinScreen extends StatefulWidget {
  const TrashBinScreen({Key? key}) : super(key: key);

  @override
  State<TrashBinScreen> createState() => _TrashBinScreenState();
}

class _TrashBinScreenState extends State<TrashBinScreen> {
  List<DeletedCardModel> _deletedCards = [];
  bool _isLoading = true;
  int _totalDeletedCards = 0;

  @override
  void initState() {
    super.initState();
    _fetchDeletedCards();
  }

  Future<void> _fetchDeletedCards() async {
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

      final request = http.Request('GET', Uri.parse('http://34.93.230.130:5001/deleted_cards'));
      request.headers['Content-Type'] = 'application/json';
      request.body = json.encode({
        'user_id': userId,
      });
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> cardsData = data['deleted_cards'] ?? [];
        
        final deletedCards = cardsData
            .map((card) => DeletedCardModel.fromJson(card))
            .toList();

        setState(() {
          _deletedCards = deletedCards;
          _totalDeletedCards = data['total_deleted_cards'] ?? 0;
          _isLoading = false;
        });
      } else {
        print('Failed to fetch deleted cards: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching deleted cards: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getCardColor(int index) {
    return AppColors.businessCardColors[index % AppColors.businessCardColors.length];
  }

  Future<void> _restoreCard(String cardId) async {
    try {
      final userId = await UserSession.getUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User ID not found'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('http://34.93.230.130:5001/restore_card'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'card_id': cardId,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card restored successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchDeletedCards(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to restore card'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error restoring card: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _permanentlyDeleteCard(String cardId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permanently Delete Card'),
          content: const Text('This action cannot be undone. Are you sure you want to permanently delete this card?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final userId = await UserSession.getUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User ID not found'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final response = await http.delete(
        Uri.parse('http://34.93.230.130:5001/permanently_delete_card'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'card_id': cardId,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card permanently deleted'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchDeletedCards(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete card'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting card: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showDeleteAllDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Cards'),
          content: const Text('This will permanently delete all cards in the trash bin. This action cannot be undone. Are you sure?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final userId = await UserSession.getUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User ID not found'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final response = await http.delete(
        Uri.parse('http://34.93.230.130:5001/delete_all_cards'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All cards permanently deleted'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchDeletedCards(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete all cards'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting all cards: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Trash Bin',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_deletedCards.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Color(0xFF0F172A)),
              onPressed: _showDeleteAllDialog,
              tooltip: 'Delete All',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _deletedCards.isEmpty
              ? _buildEmptyState()
              : _buildDeletedCardsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No deleted cards',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Deleted cards will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeletedCardsList() {
    return Column(
      children: [
        // Header with count
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Text(
            '$_totalDeletedCards deleted card${_totalDeletedCards != 1 ? 's' : ''}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        
        // Cards list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _deletedCards.length,
            itemBuilder: (context, index) {
              final card = _deletedCards[index];
              return _buildDeletedCardItem(card, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeletedCardItem(DeletedCardModel card, int index) {
    final cardColor = _getCardColor(index);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and delete indicator
            Row(
              children: [
                Expanded(
                  child: Text(
                    card.name ?? 'Unknown Name',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'DELETED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Restore icon
                GestureDetector(
                  onTap: () => _restoreCard(card.cardId),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.restore,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Delete permanently icon
                GestureDetector(
                  onTap: () => _permanentlyDeleteCard(card.cardId),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_forever,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            if (card.jobTitle != null) ...[
              const SizedBox(height: 4),
              Text(
                card.jobTitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            
            if (card.company != null) ...[
              const SizedBox(height: 4),
              Text(
                card.company!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Contact info
            if (card.phone != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      card.phone!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            
            if (card.email != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.email,
                    size: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      card.email!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            
            if (card.address != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      card.address!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
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
}