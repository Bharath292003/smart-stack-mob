import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({Key? key}) : super(key: key);

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool isDarkMode = false;
  bool notificationsEnabled = true;
  String selectedLanguage = 'English (US)';
  
  final List<String> languages = [
    'English (US)',
    'English (UK)',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Chinese',
    'Japanese',
    'Korean',
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('dark_mode') ?? false;
      notificationsEnabled = prefs.getBool('notifications') ?? true;
      selectedLanguage = prefs.getString('language') ?? 'English (US)';
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
    setState(() {
      isDarkMode = value;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dark mode ${value ? 'enabled' : 'disabled'}'),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);
    setState(() {
      notificationsEnabled = value;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notifications ${value ? 'enabled' : 'disabled'}'),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _changeLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    setState(() {
      selectedLanguage = language;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Language changed to $language'),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Select Language',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: languages.length,
              itemBuilder: (context, index) {
                final language = languages[index];
                return ListTile(
                  title: Text(language),
                  leading: Radio<String>(
                    value: language,
                    groupValue: selectedLanguage,
                    onChanged: (String? value) {
                      if (value != null) {
                        _changeLanguage(value);
                        Navigator.of(context).pop();
                      }
                    },
                    activeColor: AppColors.primaryDark,
                  ),
                  onTap: () {
                    _changeLanguage(language);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.primaryDark),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        title: const Text(
          'Preferences',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Section
            _buildSectionCard(
              title: 'Theme',
              icon: Icons.palette_outlined,
              children: [
                _buildSwitchTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  subtitle: 'Switch to dark theme',
                  value: isDarkMode,
                  onChanged: _toggleDarkMode,
                ),
                _buildInfoTile(
                  icon: Icons.auto_awesome_outlined,
                  title: 'Auto Theme',
                  subtitle: 'Follow system theme',
                  trailing: const Text(
                    'Coming Soon',
                    style: TextStyle(
                      color: AppColors.slate500,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Notifications Section
            _buildSectionCard(
              title: 'Notifications',
              icon: Icons.notifications_outlined,
              children: [
                _buildSwitchTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Push Notifications',
                  subtitle: 'Receive app notifications',
                  value: notificationsEnabled,
                  onChanged: _toggleNotifications,
                ),
                _buildInfoTile(
                  icon: Icons.email_outlined,
                  title: 'Email Notifications',
                  subtitle: 'Receive email updates',
                  trailing: const Text(
                    'Coming Soon',
                    style: TextStyle(
                      color: AppColors.slate500,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                _buildInfoTile(
                  icon: Icons.vibration_outlined,
                  title: 'Vibration',
                  subtitle: 'Vibrate on notifications',
                  trailing: const Text(
                    'Coming Soon',
                    style: TextStyle(
                      color: AppColors.slate500,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Language Section
            _buildSectionCard(
              title: 'Language & Region',
              icon: Icons.language_outlined,
              children: [
                _buildActionTile(
                  icon: Icons.translate_outlined,
                  title: 'Language',
                  subtitle: selectedLanguage,
                  onTap: _showLanguageDialog,
                ),
                _buildInfoTile(
                  icon: Icons.location_on_outlined,
                  title: 'Region',
                  subtitle: 'United States',
                  trailing: const Text(
                    'Coming Soon',
                    style: TextStyle(
                      color: AppColors.slate500,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                _buildInfoTile(
                  icon: Icons.access_time_outlined,
                  title: 'Time Format',
                  subtitle: '12-hour format',
                  trailing: const Text(
                    'Coming Soon',
                    style: TextStyle(
                      color: AppColors.slate500,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Display Section
            _buildSectionCard(
              title: 'Display',
              icon: Icons.display_settings_outlined,
              children: [
                _buildInfoTile(
                  icon: Icons.text_fields_outlined,
                  title: 'Font Size',
                  subtitle: 'Medium',
                  trailing: const Text(
                    'Coming Soon',
                    style: TextStyle(
                      color: AppColors.slate500,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                _buildInfoTile(
                  icon: Icons.animation_outlined,
                  title: 'Animations',
                  subtitle: 'Enabled',
                  trailing: const Text(
                    'Coming Soon',
                    style: TextStyle(
                      color: AppColors.slate500,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.slate200.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          Column(children: children),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppColors.slate600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.slate500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryDark,
            activeTrackColor: AppColors.primaryDark.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.slate100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: AppColors.slate600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.slate500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.slate400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppColors.slate600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.slate500,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}