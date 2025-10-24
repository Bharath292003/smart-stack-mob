import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({Key? key}) : super(key: key);

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool isDarkMode = false;
  bool notificationsEnabled = true;
  bool pushNotifications = true;
  bool emailNotifications = false;
  bool biometricAuth = false;
  bool autoBackup = true;
  bool analyticsEnabled = true;
  String selectedLanguage = 'English';
  String cardSortOrder = 'Recent';
  String exportFormat = 'PDF';
  
  final List<String> languages = ['English', 'Spanish', 'French', 'German', 'Italian', 'Portuguese', 'Chinese', 'Japanese'];
  final List<String> sortOptions = ['Recent', 'Alphabetical', 'Category', 'Frequency'];
  final List<String> exportFormats = ['PDF', 'VCF', 'CSV', 'JSON'];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('dark_mode') ?? false;
      notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      pushNotifications = prefs.getBool('push_notifications') ?? true;
      emailNotifications = prefs.getBool('email_notifications') ?? false;
      biometricAuth = prefs.getBool('biometric_auth') ?? false;
      autoBackup = prefs.getBool('auto_backup') ?? true;
      analyticsEnabled = prefs.getBool('analytics_enabled') ?? true;
      selectedLanguage = prefs.getString('selected_language') ?? 'English';
      cardSortOrder = prefs.getString('card_sort_order') ?? 'Recent';
      exportFormat = prefs.getString('export_format') ?? 'PDF';
    });
  }

  Future<void> _savePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
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
          'Preferences',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            _buildSection(
              title: 'Appearance',
              icon: Icons.palette_outlined,
              children: [
                _buildSwitchRow(
                  icon: Icons.dark_mode_outlined,
                  label: 'Dark Mode',
                  subtitle: 'Switch between light and dark theme',
                  value: isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      isDarkMode = value;
                    });
                    _savePreference('dark_mode', value);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Notifications Section
            _buildSection(
              title: 'Notifications',
              icon: Icons.notifications_outlined,
              children: [
                _buildSwitchRow(
                  icon: Icons.notifications_active_outlined,
                  label: 'Push Notifications',
                  subtitle: 'Receive notifications on your device',
                  value: pushNotifications,
                  onChanged: (value) {
                    setState(() {
                      pushNotifications = value;
                    });
                    _savePreference('push_notifications', value);
                  },
                ),
                _buildSwitchRow(
                  icon: Icons.email_outlined,
                  label: 'Email Notifications',
                  subtitle: 'Receive updates via email',
                  value: emailNotifications,
                  onChanged: (value) {
                    setState(() {
                      emailNotifications = value;
                    });
                    _savePreference('email_notifications', value);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
             
             // Security Section
             _buildSection(
               title: 'Security & Privacy',
               icon: Icons.security_outlined,
               children: [
                 _buildSwitchRow(
                   icon: Icons.fingerprint_outlined,
                   label: 'Biometric Authentication',
                   subtitle: 'Use fingerprint or face ID to unlock',
                   value: biometricAuth,
                   onChanged: (value) {
                     setState(() {
                       biometricAuth = value;
                     });
                     _savePreference('biometric_auth', value);
                   },
                 ),
                 _buildSwitchRow(
                   icon: Icons.analytics_outlined,
                   label: 'Analytics',
                   subtitle: 'Help improve the app with usage data',
                   value: analyticsEnabled,
                   onChanged: (value) {
                     setState(() {
                       analyticsEnabled = value;
                     });
                     _savePreference('analytics_enabled', value);
                   },
                 ),
               ],
             ),
             
             const SizedBox(height: 16),
             
             // Data & Backup Section
             _buildSection(
               title: 'Data & Backup',
               icon: Icons.backup_outlined,
               children: [
                 _buildSwitchRow(
                   icon: Icons.cloud_sync_outlined,
                   label: 'Auto Backup',
                   subtitle: 'Automatically backup your cards to cloud',
                   value: autoBackup,
                   onChanged: (value) {
                     setState(() {
                       autoBackup = value;
                     });
                     _savePreference('auto_backup', value);
                   },
                 ),
                 _buildDropdownRow(
                   icon: Icons.file_download_outlined,
                   label: 'Export Format',
                   subtitle: 'Default format for exporting cards',
                   value: exportFormat,
                   options: exportFormats,
                   onChanged: (value) {
                     setState(() {
                       exportFormat = value!;
                     });
                     _savePreference('export_format', value);
                   },
                 ),
               ],
             ),
             
             const SizedBox(height: 16),
             
             // Card Management Section
             _buildSection(
               title: 'Card Management',
               icon: Icons.credit_card_outlined,
               children: [
                 _buildDropdownRow(
                   icon: Icons.sort_outlined,
                   label: 'Default Sort Order',
                   subtitle: 'How cards are sorted in lists',
                   value: cardSortOrder,
                   options: sortOptions,
                   onChanged: (value) {
                     setState(() {
                       cardSortOrder = value!;
                     });
                     _savePreference('card_sort_order', value);
                   },
                 ),
               ],
             ),
             
             const SizedBox(height: 16),
             
             // Language Section
             _buildSection(
               title: 'Language & Region',
               icon: Icons.language_outlined,
               children: [
                 _buildDropdownRow(
                   icon: Icons.translate_outlined,
                   label: 'Language',
                   subtitle: 'Choose your preferred language',
                   value: selectedLanguage,
                   options: languages,
                   onChanged: (value) {
                     setState(() {
                       selectedLanguage = value!;
                     });
                     _savePreference('selected_language', value);
                   },
                 ),
               ],
             ),
            

          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: const Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow({
    required IconData icon,
    required String label,
    required String subtitle,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            underline: Container(),
            items: options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(
                  option,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: 20,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }
}