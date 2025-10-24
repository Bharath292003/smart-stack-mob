import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
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
  
  static Color _getColorByIndex(int index) {
    return AppColors.getBusinessColorByIndex(index);
  }
}

class CompactBusinessCard extends StatelessWidget {
  final CardModel card;
  final VoidCallback onTap;
  final Function(CardModel) onShare;

  const CompactBusinessCard({
    super.key,
    required this.card,
    required this.onTap,
    required this.onShare,
  });

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
                    if (card.additionalInfo != null && card.additionalInfo!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          card.additionalInfo!,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFFE2E8F0),
                            fontWeight: FontWeight.w300,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
                        GestureDetector(
                          onTap: () => onShare(card),
                          child: Container(
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
  final Function(String) onDelete;
  final Function(CardModel) onShare;

  const ExpandedCardDialog({
    super.key,
    required this.card,
    required this.onClose,
    required this.onDelete,
    required this.onShare,
  });

  void _showDeleteConfirmation(BuildContext context, CardModel card) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Card'),
          content: const Text('Are you sure you want to delete this business card?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete(card.cardId);
              },
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Helper methods for launching external apps
  Future<void> _launchPhone(BuildContext context, String phoneNumber) async {
    // Check if phone number contains multiple numbers (separated by commas or semicolons)
    List<String> phoneNumbers = phoneNumber.split(RegExp(r'[,;]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    
    if (phoneNumbers.length > 1) {
      // Show selection dialog for multiple numbers
      String? selectedNumber = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Phone Number'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: phoneNumbers.map((number) {
                return ListTile(
                  leading: const Icon(Icons.phone),
                  title: Text(number),
                  onTap: () => Navigator.of(context).pop(number),
                );
              }).toList(),
            ),
          );
        },
      );
      
      if (selectedNumber != null) {
        await _makePhoneCall(context, selectedNumber);
      }
    } else {
      // Single number, launch directly
      await _makePhoneCall(context, phoneNumbers.first);
    }
  }

  Future<void> _launchMaps(BuildContext context, String address) async {
    try {
      // Clean and encode the address for URL
      String encodedAddress = Uri.encodeComponent(address.trim());
      
      // Try different map URL schemes with fallbacks
      List<String> mapUrls = [
        'https://maps.google.com/maps?q=$encodedAddress', // Google Maps web
        'geo:0,0?q=$encodedAddress', // Generic geo intent
        'maps:?q=$encodedAddress', // Apple Maps
      ];
      
      bool launched = false;
      
      for (String urlString in mapUrls) {
        try {
          final Uri mapUri = Uri.parse(urlString);
          if (await canLaunchUrl(mapUri)) {
            await launchUrl(mapUri, mode: LaunchMode.externalApplication);
            launched = true;
            break;
          }
        } catch (e) {
          // Continue to next URL if this one fails
          continue;
        }
      }
      
      if (!launched) {
        // Fallback: try platform default mode
        final Uri fallbackUri = Uri.parse('https://maps.google.com/maps?q=$encodedAddress');
        if (await canLaunchUrl(fallbackUri)) {
          await launchUrl(fallbackUri, mode: LaunchMode.platformDefault);
          launched = true;
        }
      }
      
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open maps for: $address')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error opening maps')),
        );
      }
    }
  }

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone dialer')),
        );
      }
    }
  }

  Future<void> _launchEmail(BuildContext context, String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: try with different URI format
        final String emailUrl = 'mailto:$email';
        final Uri fallbackUri = Uri.parse(emailUrl);
        if (await canLaunchUrl(fallbackUri)) {
          await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('No email app available');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch email app. Please check if you have an email app installed.')),
        );
      }
    }
  }

  Future<void> _launchWebsite(BuildContext context, String website) async {
    String url = website.trim();
    
    // Clean and format the URL
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    
    try {
      final Uri websiteUri = Uri.parse(url);
      if (await canLaunchUrl(websiteUri)) {
        await launchUrl(websiteUri, mode: LaunchMode.externalApplication);
      } else {
        // Try with platform default mode
        await launchUrl(websiteUri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open website: $url. Please check your internet connection.')),
        );
      }
    }
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String label, String value, {VoidCallback? onTap}) {
    VoidCallback? actualOnTap;
    
    // Set up appropriate onTap handlers based on the label
    if (label.toLowerCase() == 'email' && value.isNotEmpty) {
      actualOnTap = () => _launchEmail(context, value);
    } else if (label.toLowerCase() == 'phone' && value.isNotEmpty) {
      actualOnTap = () => _launchPhone(context, value);
    } else if (label.toLowerCase() == 'website' && value.isNotEmpty) {
      actualOnTap = () => _launchWebsite(context, value);
    } else if (label.toLowerCase() == 'location' && value.isNotEmpty) {
      actualOnTap = () => _launchMaps(context, value);
    } else {
      actualOnTap = onTap;
    }
    
    return GestureDetector(
      onTap: actualOnTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: actualOnTap != null ? Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ) : null,
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: actualOnTap != null ? const Color(0xFF3B82F6) : const Color(0xFF475569),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: actualOnTap != null ? const Color(0xFF3B82F6) : const Color(0xFF0F172A),
                      fontWeight: FontWeight.w400,
                      decoration: actualOnTap != null ? TextDecoration.underline : null,
                    ),
                  ),
                ],
              ),
            ),
            if (actualOnTap != null)
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF64748B),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: GestureDetector(
          onTap: () {}, // Prevent closing when tapping dialog
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Card Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        GestureDetector(
                          onTap: onClose,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                '×',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w300,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card Header - ATM Card Style
                          AspectRatio(
                            aspectRatio: 1.586 * 1.15, // Reduced height by 15% (increased aspect ratio)
                            child: Container(
                              decoration: BoxDecoration(
                                color: card.color,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top Section
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.work_outline,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () => onShare(card),
                                            child: Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.share,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () => _showDeleteConfirmation(context, card),
                                            child: Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  // Middle Section - Name and Title
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        card.name ?? 'Unknown',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          letterSpacing: -0.3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      if (card.jobTitle != null && card.jobTitle!.isNotEmpty)
                                        Text(
                                          card.jobTitle!,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white.withOpacity(0.8),
                                            fontWeight: FontWeight.w400,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                  // Bottom Section - Company and Contact
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (card.company != null && card.company!.isNotEmpty)
                                        Text(
                                          card.company!,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white.withOpacity(0.95),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      const SizedBox(height: 8),
                                      if (card.email != null && card.email!.isNotEmpty)
                                        Text(
                                          card.email!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white.withOpacity(0.7),
                                            fontWeight: FontWeight.w400,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Contact Information
                          const Text(
                            'CONTACT INFORMATION',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (card.email != null)
                            _buildInfoItem(context, Icons.email_outlined, 'Email', card.email!),
                          if (card.email != null) const SizedBox(height: 16),
                          if (card.phone != null)
                            _buildInfoItem(context, Icons.phone_outlined, 'Phone', card.phone!),
                          if (card.phone != null) const SizedBox(height: 16),
                          if (card.website != null)
                            _buildInfoItem(context, Icons.language, 'Website', card.website!),
                          if (card.website != null) const SizedBox(height: 16),
                          if (card.address != null)
                            _buildInfoItem(context, Icons.location_on_outlined, 'Location', card.address!),
                          if (card.address != null) const SizedBox(height: 16),
                          if (card.additionalInfo != null && card.additionalInfo!.isNotEmpty)
                            _buildInfoItem(context, Icons.info_outline, 'Additional Info', card.additionalInfo!),
                          if (card.additionalInfo != null && card.additionalInfo!.isNotEmpty) const SizedBox(height: 16),
                          const SizedBox(height: 32),
                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F172A),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Contact',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Share',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF334155),
                                      ),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BusinessCardScreen extends StatefulWidget {
  const BusinessCardScreen({super.key});

  @override
  State<BusinessCardScreen> createState() => _BusinessCardScreenState();
}

class _BusinessCardScreenState extends State<BusinessCardScreen> {
  List<CardModel> _businessCards = [];
  List<CardModel> _filteredBusinessCards = [];
  bool _isLoading = true;
  int _totalCards = 0;
  CardModel? _expandedCard;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBusinessCards();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Helper methods for launching external apps
  Future<void> _launchPhone(String phoneNumber) async {
    // Check if phone number contains multiple numbers (separated by commas or semicolons)
    List<String> phoneNumbers = phoneNumber.split(RegExp(r'[,;]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    
    if (phoneNumbers.length > 1) {
      // Show selection dialog for multiple numbers
      String? selectedNumber = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Phone Number'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: phoneNumbers.map((number) {
                return ListTile(
                  leading: const Icon(Icons.phone),
                  title: Text(number),
                  onTap: () => Navigator.of(context).pop(number),
                );
              }).toList(),
            ),
          );
        },
      );
      
      if (selectedNumber != null) {
        await _makePhoneCall(selectedNumber);
      }
    } else {
      // Single number, launch directly
      await _makePhoneCall(phoneNumbers.first);
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone dialer')),
        );
      }
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: try with different URI format
        final String emailUrl = 'mailto:$email';
        final Uri fallbackUri = Uri.parse(emailUrl);
        if (await canLaunchUrl(fallbackUri)) {
          await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('No email app available');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch email app. Please check if you have an email app installed.')),
        );
      }
    }
  }

  Future<void> _launchWebsite(String website) async {
    String url = website;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    
    final Uri websiteUri = Uri.parse(url);
    if (await canLaunchUrl(websiteUri)) {
      await launchUrl(websiteUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch website')),
        );
      }
    }
  }

  Future<void> _launchMaps(String address) async {
    try {
      // Clean and encode the address for URL
      String encodedAddress = Uri.encodeComponent(address.trim());
      
      // Try different map URL schemes with fallbacks
      List<String> mapUrls = [
        'https://maps.google.com/maps?q=$encodedAddress', // Google Maps web
        'geo:0,0?q=$encodedAddress', // Generic geo intent
        'maps:?q=$encodedAddress', // Apple Maps
      ];
      
      bool launched = false;
      
      for (String urlString in mapUrls) {
        try {
          final Uri mapUri = Uri.parse(urlString);
          if (await canLaunchUrl(mapUri)) {
            await launchUrl(mapUri, mode: LaunchMode.externalApplication);
            launched = true;
            break;
          }
        } catch (e) {
          // Continue to next URL if this one fails
          continue;
        }
      }
      
      if (!launched) {
        // Fallback: try platform default mode
        final Uri fallbackUri = Uri.parse('https://maps.google.com/maps?q=$encodedAddress');
        if (await canLaunchUrl(fallbackUri)) {
          await launchUrl(fallbackUri, mode: LaunchMode.platformDefault);
          launched = true;
        }
      }
      
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open maps for: $address')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error opening maps')),
        );
      }
    }
  }

  // Share card functionality
  void _shareCard(CardModel card) {
    String cardInfo = '';
    
    // Add name and title
    if (card.name != null && card.name!.isNotEmpty) {
      cardInfo += '${card.name}';
      if (card.jobTitle != null && card.jobTitle!.isNotEmpty) {
        cardInfo += '\n${card.jobTitle}';
      }
    }
    
    // Add company
    if (card.company != null && card.company!.isNotEmpty) {
      cardInfo += '\n${card.company}';
    }
    
    // Add contact information
    if (card.email != null && card.email!.isNotEmpty) {
      cardInfo += '\n📧 ${card.email}';
    }
    
    if (card.phone != null && card.phone!.isNotEmpty) {
      cardInfo += '\n📞 ${card.phone}';
    }
    
    if (card.website != null && card.website!.isNotEmpty) {
      cardInfo += '\n🌐 ${card.website}';
    }
    
    if (card.address != null && card.address!.isNotEmpty) {
      cardInfo += '\n📍 ${card.address}';
    }
    
    // Add additional info if available
    if (card.additionalInfo != null && card.additionalInfo!.isNotEmpty) {
      cardInfo += '\n\n${card.additionalInfo}';
    }
    
    // Add footer
    cardInfo += '\n\nShared via Smart Stack';
    
    // Share the formatted card information
    Share.share(
      cardInfo,
      subject: 'Business Card - ${card.name ?? 'Contact'}',
    );
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
        Uri.parse('http://34.93.230.130:5001/cards/$userId'),
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
          _filteredBusinessCards = businessCards; // Initialize filtered list
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

  Future<void> _deleteCard(String cardId) async {
    try {
      final userId = await UserSession.getUserId();
      if (userId == null) {
        print('User ID not found');
        return;
      }

      final response = await http.post(
        Uri.parse('http://34.93.230.130:5001/delete_or_restore'),
        headers: {
          'Content-Type': 'application/json',
          'user_id': userId,
        },
        body: json.encode({
          'card_id': cardId,
          'action': 'inactive',
        }),
      );

      if (response.statusCode == 200) {
        // Close the expanded dialog
        setState(() {
          _expandedCard = null;
        });
        
        // Refresh the business cards list
        await _fetchBusinessCards();
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Business card deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete business card'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error deleting card: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error deleting business card'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                      : _filteredBusinessCards.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.all(24),
                              itemCount: _filteredBusinessCards.length,
                              itemBuilder: (context, index) {
                                final card = _filteredBusinessCards[index];
                                // Create a new card with color based on index
                                final cardWithColor = CardModel(
                                  cardId: card.cardId,
                                  name: card.name,
                                  jobTitle: card.jobTitle,
                                  company: card.company,
                                  email: card.email,
                                  phone: card.phone,
                                  website: card.website,
                                  address: card.address,
                                  additionalInfo: card.additionalInfo,
                                  socialMedia: card.socialMedia,
                                  color: CardModel._getColorByIndex(index),
                                );
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: CompactBusinessCard(
                                    card: cardWithColor,
                                    onTap: () => setState(() => _expandedCard = cardWithColor),
                                    onShare: _shareCard,
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
            if (_expandedCard != null)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 1.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutQuart,
                    )),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: ExpandedCardDialog(
                  key: ValueKey(_expandedCard!.cardId),
                  card: _expandedCard!,
                  onClose: () => setState(() => _expandedCard = null),
                  onDelete: _deleteCard,
                  onShare: _shareCard,
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
              isSearching ? Icons.search_off : Icons.business_center_outlined,
              size: 40,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isSearching ? 'No cards found' : 'No business cards found',
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
                : 'Add your first business card to get started',
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
        _filteredBusinessCards = _businessCards;
      } else {
        _filteredBusinessCards = _businessCards.where((card) {
          final searchQuery = query.toLowerCase();
          
          // Search in all relevant fields
          final name = card.name?.toLowerCase() ?? '';
          final jobTitle = card.jobTitle?.toLowerCase() ?? '';
          final company = card.company?.toLowerCase() ?? '';
          final email = card.email?.toLowerCase() ?? '';
          final phone = card.phone?.toLowerCase() ?? '';
          final website = card.website?.toLowerCase() ?? '';
          final address = card.address?.toLowerCase() ?? '';
          final additionalInfo = card.additionalInfo?.toLowerCase() ?? '';
          
          // Check if query matches any field
          return name.contains(searchQuery) ||
                 jobTitle.contains(searchQuery) ||
                 company.contains(searchQuery) ||
                 email.contains(searchQuery) ||
                 phone.contains(searchQuery) ||
                 website.contains(searchQuery) ||
                 address.contains(searchQuery) ||
                 additionalInfo.contains(searchQuery);
        }).toList();
      }
    });
  }
}