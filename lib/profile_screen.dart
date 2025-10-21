import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_session.dart';
import 'login_page.dart';
import 'app_colors.dart';
import 'card_details_screen.dart';
import 'preferences_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? userName;
  String? userPhone;
  String? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await UserSession.getUserData();
      setState(() {
        userName = userData['user_name'] ?? 'Unknown User';
        userPhone = userData['user_phone'] ?? 'No phone number';
        userId = userData['user_id'] ?? 'No ID';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }



  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: AppColors.slate600),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.slate500),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      try {
        await UserSession.clearUserData();
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error logging out: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  void _showComingSoonSnackBar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _navigateToCardDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CardDetailsScreen(),
      ),
    );
  }

  void _navigateToPreferences() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PreferencesScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryDark,
              ),
            )
          : CustomScrollView(
              slivers: [
                // Professional Header with Gradient
                SliverAppBar(
                  expandedHeight: 280,
                  floating: false,
                  pinned: true,
                  backgroundColor: AppColors.primaryDark,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.businessGradient,
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 60),
                            // Enhanced Avatar
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 57,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                child: Text(
                                  (userName ?? 'U').substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // User Name
                            Text(
                              userName ?? 'Unknown User',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            // User Phone with Icon
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.phone,
                                  size: 16,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  userPhone ?? 'No phone number',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w400,
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
                
                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        
                        // Settings Section
                        _buildSectionCard(
                          title: 'Settings',
                          icon: Icons.settings_outlined,
                          children: [
                            _buildActionTile(
                              icon: Icons.credit_card_outlined,
                              title: 'Your Card Details',
                              subtitle: 'Manage your business card',
                              onTap: () => _navigateToCardDetails(),
                            ),
                            _buildActionTile(
                              icon: Icons.tune_outlined,
                              title: 'Preferences',
                              subtitle: 'Theme, notifications, and language',
                              onTap: () => _navigateToPreferences(),
                            ),
                            _buildActionTile(
                              icon: Icons.security_outlined,
                              title: 'Privacy & Security',
                              subtitle: 'Manage your privacy settings',
                              onTap: () => _showComingSoonSnackBar('Privacy Settings'),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Help & Support Section
                        _buildSectionCard(
                          title: 'Help & Support',
                          icon: Icons.help_outline,
                          children: [
                            _buildActionTile(
                              icon: Icons.help_center_outlined,
                              title: 'FAQ',
                              subtitle: 'Frequently asked questions',
                              onTap: () => _showComingSoonSnackBar('FAQ'),
                            ),
                            _buildActionTile(
                              icon: Icons.contact_support_outlined,
                              title: 'Contact Support',
                              subtitle: 'Get help from our team',
                              onTap: () => _showComingSoonSnackBar('Contact Support'),
                            ),
                            _buildActionTile(
                              icon: Icons.feedback_outlined,
                              title: 'Send Feedback',
                              subtitle: 'Share your thoughts',
                              onTap: () => _showComingSoonSnackBar('Feedback'),
                            ),
                            _buildActionTile(
                              icon: Icons.star_outline,
                              title: 'Rate App',
                              subtitle: 'Rate us on the App Store',
                              onTap: () => _showComingSoonSnackBar('Rate App'),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // About Section
                        _buildSectionCard(
                          title: 'About',
                          icon: Icons.info_outline,
                          children: [
                            _buildInfoTile(
                              icon: Icons.apps_outlined,
                              title: 'App Version',
                              subtitle: 'Smart Stack v1.0.0',
                            ),
                            _buildActionTile(
                              icon: Icons.description_outlined,
                              title: 'Terms of Service',
                              subtitle: 'Read our terms',
                              onTap: () => _showComingSoonSnackBar('Terms of Service'),
                            ),
                            _buildActionTile(
                              icon: Icons.privacy_tip_outlined,
                              title: 'Privacy Policy',
                              subtitle: 'Read our privacy policy',
                              onTap: () => _showComingSoonSnackBar('Privacy Policy'),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Logout Button
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.red700.withOpacity(0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _logout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.red700,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout, size: 20),
                                SizedBox(width: 12),
                                Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    bool showEditIcon = false,
    VoidCallback? onEdit,
    bool isCollapsible = false,
    bool isExpanded = false,
    VoidCallback? onToggle,
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
          GestureDetector(
            onTap: isCollapsible ? onToggle : null,
            child: Padding(
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
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  if (isCollapsible)
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AppColors.primaryDark,
                      size: 24,
                    ),
                  if (showEditIcon && isExpanded)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: GestureDetector(
                        onTap: onEdit,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 18,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (!isCollapsible || isExpanded)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Column(
                children: children,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isComingSoon = false,
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
          const SizedBox(width: 16),
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
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: isComingSoon ? AppColors.slate400 : AppColors.slate600,
                    fontStyle: isComingSoon ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
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
      borderRadius: BorderRadius.circular(12),
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
            const SizedBox(width: 16),
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.slate600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.slate400,
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
          const SizedBox(width: 16),
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
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.slate600,
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
            inactiveThumbColor: AppColors.slate400,
            inactiveTrackColor: AppColors.slate200,
          ),
        ],
      ),
    );
  }
}