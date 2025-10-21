import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'app_colors.dart';
import 'models.dart';

class RecycleBinScreen extends StatefulWidget {
  const RecycleBinScreen({super.key});

  @override
  State<RecycleBinScreen> createState() => _RecycleBinScreenState();
}

class _RecycleBinScreenState extends State<RecycleBinScreen> {
  List<BusinessCard> deletedCards = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeletedCards();
  }

  Future<void> _loadDeletedCards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deletedCardsJson = prefs.getStringList('deleted_cards') ?? [];
      
      setState(() {
        deletedCards = deletedCardsJson
            .map((cardJson) => BusinessCard.fromJson(json.decode(cardJson)))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading deleted cards'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _restoreCard(BusinessCard card) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Remove from deleted cards
      final deletedCardsJson = prefs.getStringList('deleted_cards') ?? [];
      deletedCardsJson.removeWhere((cardJson) {
        final cardData = json.decode(cardJson);
        return cardData['id'] == card.id;
      });
      await prefs.setStringList('deleted_cards', deletedCardsJson);
      
      // Add back to regular cards (you might need to adjust this based on your card storage logic)
      final cardsJson = prefs.getStringList('business_cards') ?? [];
      cardsJson.add(json.encode(card.toJson()));
      await prefs.setStringList('business_cards', cardsJson);
      
      setState(() {
        deletedCards.removeWhere((c) => c.id == card.id);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${card.name} restored successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error restoring card'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _permanentlyDeleteCard(BusinessCard card) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Remove from deleted cards permanently
      final deletedCardsJson = prefs.getStringList('deleted_cards') ?? [];
      deletedCardsJson.removeWhere((cardJson) {
        final cardData = json.decode(cardJson);
        return cardData['id'] == card.id;
      });
      await prefs.setStringList('deleted_cards', deletedCardsJson);
      
      setState(() {
        deletedCards.removeWhere((c) => c.id == card.id);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${card.name} permanently deleted'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error deleting card'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearAllDeletedCards() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Recycle Bin'),
        content: const Text('Are you sure you want to permanently delete all cards in the recycle bin? This action cannot be undone.'),
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
      ),
    );

    if (confirmed == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('deleted_cards');
        
        setState(() {
          deletedCards.clear();
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All deleted cards permanently removed'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error clearing recycle bin'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showCardOptions(BusinessCard card) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.slate300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              card.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.restore, color: Colors.green),
              title: const Text('Restore Card'),
              subtitle: const Text('Move back to your cards'),
              onTap: () {
                Navigator.pop(context);
                _restoreCard(card);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete Permanently'),
              subtitle: const Text('This action cannot be undone'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(card);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BusinessCard card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Permanently'),
        content: Text('Are you sure you want to permanently delete ${card.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _permanentlyDeleteCard(card);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Recycle Bin',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (deletedCards.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.red),
              onPressed: _clearAllDeletedCards,
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryDark,
              ),
            )
          : deletedCards.isEmpty
              ? _buildEmptyState()
              : _buildDeletedCardsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.delete_outline,
              size: 60,
              color: AppColors.slate400,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Recycle Bin is Empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Deleted cards will appear here',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.slate600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeletedCardsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: deletedCards.length,
      itemBuilder: (context, index) {
        final card = deletedCards[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.slate100,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.slate600,
                size: 24,
              ),
            ),
            title: Text(
              card.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (card.title.isNotEmpty)
                  Text(
                    card.title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.slate600,
                    ),
                  ),
                if (card.company.isNotEmpty)
                  Text(
                    card.company,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.slate600,
                    ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.restore, color: Colors.green),
                  onPressed: () => _restoreCard(card),
                  tooltip: 'Restore',
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: AppColors.slate400),
                  onPressed: () => _showCardOptions(card),
                ),
              ],
            ),
            onTap: () => _showCardOptions(card),
          ),
        );
      },
    );
  }
}