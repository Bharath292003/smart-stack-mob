// import 'package:flutter/material.dart';
// import 'dart:math' as math;
//
// void main() {
//   runApp(const SmartStackApp());
// }
//
// class SmartStackApp extends StatelessWidget {
//   const SmartStackApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Smart Stack',
//       theme: ThemeData(
//         primarySwatch: Colors.grey,
//         fontFamily: 'SF Pro Display', // iOS default, fallback to system
//       ),
//       home: const SmartStackHome(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
//
// class SmartStackHome extends StatefulWidget {
//   const SmartStackHome({super.key});
//
//   @override
//   State<SmartStackHome> createState() => _SmartStackHomeState();
// }
//
// class _SmartStackHomeState extends State<SmartStackHome> {
//   String currentScreen = 'welcome';
//   String? selectedCategory;
//   BusinessCard? expandedCard;
//   bool isCardFlipped = false;
//
//   // Current user's card data
//   final BusinessCard currentUserCard = BusinessCard(
//     id: 0,
//     name: 'John Anderson',
//     title: 'Product Manager',
//     company: 'Smart Stack Inc.',
//     email: 'john.anderson@smartstack.com',
//     phone: '+1 (555) 000-1234',
//     website: 'www.smartstack.com',
//     location: 'San Francisco, CA',
//     color: const Color(0xFF0F172A),
//   );
//
//   // Sample data for digital cards
//   final Map<String, List<BusinessCard>> cardStacks = {
//     'business': [
//       BusinessCard(
//         id: 1,
//         name: 'Alex Morrison',
//         title: 'Senior Product Manager',
//         company: 'TechVision Inc.',
//         email: 'alex.morrison@techvision.com',
//         phone: '+1 (555) 123-4567',
//         website: 'www.techvision.com',
//         location: 'San Francisco, CA',
//         color: const Color(0xFF1E293B),
//       ),
//       BusinessCard(
//         id: 2,
//         name: 'Sarah Chen',
//         title: 'Marketing Director',
//         company: 'Digital Nexus',
//         email: 'sarah.c@digitalnexus.io',
//         phone: '+1 (555) 987-6543',
//         website: 'www.digitalnexus.io',
//         location: 'New York, NY',
//         color: const Color(0xFF262626),
//       ),
//       BusinessCard(
//         id: 3,
//         name: 'Michael Rodriguez',
//         title: 'Chief Technology Officer',
//         company: 'CloudScale Solutions',
//         email: 'm.rodriguez@cloudscale.com',
//         phone: '+1 (555) 456-7890',
//         website: 'www.cloudscale.com',
//         location: 'Austin, TX',
//         color: const Color(0xFF27272A),
//       ),
//       BusinessCard(
//         id: 4,
//         name: 'Emily Watson',
//         title: 'UX Design Lead',
//         company: 'Creative Studios',
//         email: 'emily.watson@creativestudios.com',
//         phone: '+1 (555) 234-5678',
//         website: 'www.creativestudios.com',
//         location: 'Seattle, WA',
//         color: const Color(0xFF1F2937),
//       ),
//     ],
//     'personal': [
//       BusinessCard(
//         id: 5,
//         name: 'David Park',
//         title: 'Freelance Designer',
//         company: 'Self Employed',
//         email: 'david.park@gmail.com',
//         phone: '+1 (555) 111-2222',
//         website: 'www.davidparkdesign.com',
//         location: 'Los Angeles, CA',
//         color: const Color(0xFF1E293B),
//       ),
//       BusinessCard(
//         id: 6,
//         name: 'Jessica Taylor',
//         title: 'Yoga Instructor',
//         company: 'Wellness Center',
//         email: 'jessica.taylor@wellness.com',
//         phone: '+1 (555) 333-4444',
//         website: 'www.jessicayoga.com',
//         location: 'Miami, FL',
//         color: const Color(0xFF262626),
//       ),
//     ],
//     'favorites': [
//       BusinessCard(
//         id: 7,
//         name: 'Robert Chang',
//         title: 'Investment Advisor',
//         company: 'Premier Wealth',
//         email: 'r.chang@premierwealth.com',
//         phone: '+1 (555) 777-8888',
//         website: 'www.premierwealth.com',
//         location: 'Boston, MA',
//         color: const Color(0xFF1E293B),
//       ),
//     ],
//     'important': [
//       BusinessCard(
//         id: 8,
//         name: 'Dr. Amanda Roberts',
//         title: 'Medical Director',
//         company: 'HealthFirst Clinic',
//         email: 'a.roberts@healthfirst.com',
//         phone: '+1 (555) 999-0000',
//         website: 'www.healthfirst.com',
//         location: 'Chicago, IL',
//         color: const Color(0xFF1E293B),
//       ),
//     ],
//   };
//
//   List<Category> get categories => [
//         Category(
//           id: 'business',
//           name: 'Business Cards',
//           icon: Icons.work_outline,
//           count: cardStacks['business']?.length ?? 0,
//         ),
//         Category(
//           id: 'personal',
//           name: 'Personal',
//           icon: Icons.person_outline,
//           count: cardStacks['personal']?.length ?? 0,
//         ),
//         Category(
//           id: 'favorites',
//           name: 'Favorites',
//           icon: Icons.star_border,
//           count: cardStacks['favorites']?.length ?? 0,
//         ),
//         Category(
//           id: 'important',
//           name: 'Important',
//           icon: Icons.archive_outlined,
//           count: cardStacks['important']?.length ?? 0,
//         ),
//       ];
//
//   int get totalCards {
//     return cardStacks.values.fold(0, (sum, list) => sum + list.length);
//   }
//
//   void openCategory(String categoryId) {
//     setState(() {
//       selectedCategory = categoryId;
//       currentScreen = 'stack';
//     });
//   }
//
//   void goBack() {
//     setState(() {
//       currentScreen = 'home';
//       selectedCategory = null;
//       expandedCard = null;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _buildCurrentScreen(),
//     );
//   }
//
//   Widget _buildCurrentScreen() {
//     switch (currentScreen) {
//       case 'welcome':
//         return WelcomeScreen(
//           onLogin: () => setState(() => currentScreen = 'home'),
//           onSignUp: () => setState(() => currentScreen = 'signup'),
//         );
//       case 'signup':
//         return SignUpScreen(
//           onBack: () => setState(() => currentScreen = 'welcome'),
//           onSignUp: () => setState(() => currentScreen = 'home'),
//         );
//       case 'home':
//         return HomeScreen(
//           currentUserCard: currentUserCard,
//           totalCards: totalCards,
//           categories: categories,
//           isCardFlipped: isCardFlipped,
//           onFlipCard: () => setState(() => isCardFlipped = !isCardFlipped),
//           onCategoryTap: openCategory,
//         );
//       case 'stack':
//         return StackScreen(
//           category: categories.firstWhere((c) => c.id == selectedCategory),
//           cards: cardStacks[selectedCategory] ?? [],
//           onBack: goBack,
//           expandedCard: expandedCard,
//           onCardTap: (card) => setState(() => expandedCard = card),
//           onCloseExpanded: () => setState(() => expandedCard = null),
//         );
//       default:
//         return const SizedBox();
//     }
//   }
// }
//
// // Welcome/Login Screen
// class WelcomeScreen extends StatefulWidget {
//   final VoidCallback onLogin;
//   final VoidCallback onSignUp;
//
//   const WelcomeScreen({
//     super.key,
//     required this.onLogin,
//     required this.onSignUp,
//   });
//
//   @override
//   State<WelcomeScreen> createState() => _WelcomeScreenState();
// }
//
// class _WelcomeScreenState extends State<WelcomeScreen> {
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 80),
//                 // Logo
//                 _buildLogo(),
//                 const SizedBox(height: 80),
//                 // Login Form
//                 _buildLoginForm(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLogo() {
//     return Column(
//       children: [
//         // Stacked Cards Logo
//         SizedBox(
//           height: 160,
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               // Back card 1
//               Positioned(
//                 top: 8,
//                 left: 12,
//                 child: Transform.rotate(
//                   angle: -0.1,
//                   child: Container(
//                     width: 176,
//                     height: 128,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF334155).withOpacity(0.4),
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                   ),
//                 ),
//               ),
//               // Back card 2
//               Positioned(
//                 top: 12,
//                 left: 6,
//                 child: Transform.rotate(
//                   angle: -0.05,
//                   child: Container(
//                     width: 176,
//                     height: 128,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF1E293B).withOpacity(0.6),
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                   ),
//                 ),
//               ),
//               // Main card
//               Container(
//                 width: 176,
//                 height: 128,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF0F172A),
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.3),
//                       blurRadius: 20,
//                       offset: const Offset(0, 10),
//                     ),
//                   ],
//                 ),
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       width: 96,
//                       height: 2,
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(1),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Container(
//                       width: 128,
//                       height: 2,
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.25),
//                         borderRadius: BorderRadius.circular(1),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Container(
//                       width: 80,
//                       height: 2,
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.15),
//                         borderRadius: BorderRadius.circular(1),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Container(
//                       width: 112,
//                       height: 2,
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(1),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 32),
//         const Text(
//           'Smart Stack',
//           style: TextStyle(
//             fontSize: 36,
//             fontWeight: FontWeight.w300,
//             color: Color(0xFF0F172A),
//             letterSpacing: -0.5,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Text(
//           'Your Digital Card Collection',
//           style: TextStyle(
//             fontSize: 14,
//             color: const Color(0xFF64748B),
//             fontWeight: FontWeight.w400,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildLoginForm() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Welcome Back',
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.w300,
//             color: Color(0xFF0F172A),
//             letterSpacing: -0.5,
//           ),
//         ),
//         const SizedBox(height: 32),
//         // Phone Number
//         Text(
//           'PHONE NUMBER',
//           style: TextStyle(
//             fontSize: 11,
//             fontWeight: FontWeight.w500,
//             color: const Color(0xFF475569),
//             letterSpacing: 0.8,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextField(
//           controller: phoneController,
//           keyboardType: TextInputType.phone,
//           decoration: InputDecoration(
//             hintText: '+1 (555) 000-0000',
//             hintStyle: const TextStyle(
//               color: Color(0xFF94A3B8),
//               fontSize: 14,
//             ),
//             filled: true,
//             fillColor: const Color(0xFFF8FAFC),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(
//                 color: Color(0xFFE2E8F0),
//                 width: 1,
//               ),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(
//                 color: Color(0xFFE2E8F0),
//                 width: 1,
//               ),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(
//                 color: Color(0xFF94A3B8),
//                 width: 1,
//               ),
//             ),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 14,
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//         // Password
//         Text(
//           'PASSWORD',
//           style: TextStyle(
//             fontSize: 11,
//             fontWeight: FontWeight.w500,
//             color: const Color(0xFF475569),
//             letterSpacing: 0.8,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextField(
//           controller: passwordController,
//           obscureText: true,
//           decoration: InputDecoration(
//             hintText: 'Enter your password',
//             hintStyle: const TextStyle(
//               color: Color(0xFF94A3B8),
//               fontSize: 14,
//             ),
//             filled: true,
//             fillColor: const Color(0xFFF8FAFC),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(
//                 color: Color(0xFFE2E8F0),
//                 width: 1,
//               ),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(
//                 color: Color(0xFFE2E8F0),
//                 width: 1,
//               ),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(
//                 color: Color(0xFF94A3B8),
//                 width: 1,
//               ),
//             ),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 14,
//             ),
//           ),
//         ),
//         const SizedBox(height: 24),
//         // Login Button
//         SizedBox(
//           width: double.infinity,
//           child: ElevatedButton(
//             onPressed: widget.onLogin,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF0F172A),
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(vertical: 14),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               elevation: 0,
//             ),
//             child: const Text(
//               'Login',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 24),
//         // Divider
//         Row(
//           children: [
//             Expanded(
//               child: Container(
//                 height: 1,
//                 color: const Color(0xFFE2E8F0),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Text(
//                 'OR',
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: const Color(0xFF94A3B8),
//                   letterSpacing: 0.8,
//                 ),
//               ),
//             ),
//             Expanded(
//               child: Container(
//                 height: 1,
//                 color: const Color(0xFFE2E8F0),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 24),
//         // Sign Up Link
//         Center(
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 "Don't have an account? ",
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Color(0xFF475569),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: widget.onSignUp,
//                 child: const Text(
//                   'Sign Up',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Color(0xFF0F172A),
//                     fontWeight: FontWeight.w500,
//                     decoration: TextDecoration.underline,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 40),
//       ],
//     );
//   }
//
//   @override
//   void dispose() {
//     phoneController.dispose();
//     passwordController.dispose();
//     super.dispose();
//   }
// }
//
// // Sign Up Screen
// class SignUpScreen extends StatefulWidget {
//   final VoidCallback onBack;
//   final VoidCallback onSignUp;
//
//   const SignUpScreen({
//     super.key,
//     required this.onBack,
//     required this.onSignUp,
//   });
//
//   @override
//   State<SignUpScreen> createState() => _SignUpScreenState();
// }
//
// class _SignUpScreenState extends State<SignUpScreen> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPasswordController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Header
//             Container(
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 border: Border(
//                   bottom: BorderSide(
//                     color: Color(0xFFE2E8F0),
//                     width: 1,
//                   ),
//                 ),
//               ),
//               padding: const EdgeInsets.all(24),
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: widget.onBack,
//                     child: Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFF1F5F9),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: const Icon(
//                         Icons.arrow_back,
//                         size: 20,
//                         color: Color(0xFF334155),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   const Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Create Account',
//                           style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.w300,
//                             color: Color(0xFF0F172A),
//                             letterSpacing: -0.5,
//                           ),
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           'Join Smart Stack today',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Color(0xFF64748B),
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // Form
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildTextField('FULL NAME', 'John Anderson', nameController, false),
//                     const SizedBox(height: 20),
//                     _buildTextField('PHONE NUMBER', '+1 (555) 000-0000', phoneController, false, TextInputType.phone),
//                     const SizedBox(height: 20),
//                     _buildTextField('PASSWORD', 'Create a password', passwordController, true),
//                     const SizedBox(height: 20),
//                     _buildTextField('CONFIRM PASSWORD', 'Confirm your password', confirmPasswordController, true),
//                     const SizedBox(height: 32),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: widget.onSignUp,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF0F172A),
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           elevation: 0,
//                         ),
//                         child: const Text(
//                           'Create Account',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField(
//     String label,
//     String hint,
//     TextEditingController controller,
//     bool obscure, [
//     TextInputType? keyboardType,
//   ]) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 11,
//             fontWeight: FontWeight.w500,
//             color: Color(0xFF475569),
//             letterSpacing: 0.8,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextField(
//           controller: controller,
//           obscureText: obscure,
//           keyboardType: keyboardType,
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: const TextStyle(
//               color: Color(0xFF94A3B8),
//               fontSize: 14,
//             ),
//             filled: true,
//             fillColor: const Color(0xFFF8FAFC),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(
//                 color: Color(0xFFE2E8F0),
//                 width: 1,
//               ),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(
//                 color: Color(0xFFE2E8F0),
//                 width: 1,
//               ),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(
//                 color: Color(0xFF94A3B8),
//                 width: 1,
//               ),
//             ),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 14,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   @override
//   void dispose() {
//     nameController.dispose();
//     phoneController.dispose();
//     passwordController.dispose();
//     confirmPasswordController.dispose();
//     super.dispose();
//   }
// }
//
// // Home Screen
// class HomeScreen extends StatelessWidget {
//   final BusinessCard currentUserCard;
//   final int totalCards;
//   final List<Category> categories;
//   final bool isCardFlipped;
//   final VoidCallback onFlipCard;
//   final Function(String) onCategoryTap;
//
//   const HomeScreen({
//     super.key,
//     required this.currentUserCard,
//     required this.totalCards,
//     required this.categories,
//     required this.isCardFlipped,
//     required this.onFlipCard,
//     required this.onCategoryTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildHeader(),
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     _buildFlipCard(),
//                     _buildCategories(),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {},
//         backgroundColor: const Color(0xFF0F172A),
//         child: const Icon(Icons.camera_alt, size: 20),
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         border: Border(
//           bottom: BorderSide(
//             color: Color(0xFFE2E8F0),
//             width: 1,
//           ),
//         ),
//       ),
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Smart Stack',
//                     style: TextStyle(
//                       fontSize: 30,
//                       fontWeight: FontWeight.w300,
//                       color: Color(0xFF0F172A),
//                       letterSpacing: -0.5,
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     'Digital Business Cards',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Color(0xFF64748B),
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 width: 40,
//                 height: 40,
//                 child: const Icon(
//                   Icons.more_vert,
//                   color: Color(0xFF475569),
//                   size: 20,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 24),
//           // Search Bar
//           Container(
//             decoration: BoxDecoration(
//               color: const Color(0xFFF8FAFC),
//               border: Border.all(
//                 color: const Color(0xFFE2E8F0).withOpacity(0.8),
//                 width: 1,
//               ),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: 'Search cards',
//                 hintStyle: const TextStyle(
//                   color: Color(0xFF94A3B8),
//                   fontSize: 14,
//                 ),
//                 prefixIcon: const Icon(
//                   Icons.search,
//                   color: Color(0xFF94A3B8),
//                   size: 18,
//                 ),
//                 border: InputBorder.none,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 14,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFlipCard() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
//       decoration: const BoxDecoration(
//         border: Border(
//           bottom: BorderSide(
//             color: Color(0xFFF1F5F9),
//             width: 1,
//           ),
//         ),
//       ),
//       child: Transform.scale(
//         scale: 0.85,
//         child: AspectRatio(
//           aspectRatio: 1.76,
//           child: TweenAnimationBuilder<double>(
//             tween: Tween<double>(begin: 0, end: isCardFlipped ? math.pi : 0),
//             duration: const Duration(milliseconds: 800),
//             curve: Curves.easeInOut,
//             builder: (context, value, child) {
//               final isUnder = value > math.pi / 2;
//               return Transform(
//                 alignment: Alignment.center,
//                 transform: Matrix4.identity()
//                   ..setEntry(3, 2, 0.001)
//                   ..rotateY(value),
//                 child: isUnder
//                     ? Transform(
//                         alignment: Alignment.center,
//                         transform: Matrix4.identity()..rotateY(math.pi),
//                         child: _buildCardBack(),
//                       )
//                     : _buildCardFront(),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCardFront() {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFF0F172A),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Top Section
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'CATEGORIES',
//                     style: TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w500,
//                       color: const Color(0xFF94A3B8),
//                       letterSpacing: 0.8,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   const Text(
//                     '4',
//                     style: TextStyle(
//                       fontSize: 30,
//                       fontWeight: FontWeight.w300,
//                       color: Colors.white,
//                       letterSpacing: -0.5,
//                     ),
//                   ),
//                 ],
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     'TOTAL CARDS',
//                     style: TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w500,
//                       color: const Color(0xFF94A3B8),
//                       letterSpacing: 0.8,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     '$totalCards',
//                     style: const TextStyle(
//                       fontSize: 30,
//                       fontWeight: FontWeight.w300,
//                       color: Colors.white,
//                       letterSpacing: -0.5,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           // Middle Section
//           Transform.translate(
//             offset: const Offset(0, -8),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   'Hi ',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.w300,
//                     color: const Color(0xFF94A3B8),
//                     letterSpacing: -0.5,
//                   ),
//                 ),
//                 Text(
//                   currentUserCard.name.split(' ')[0],
//                   style: const TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.w300,
//                     color: Colors.white,
//                     letterSpacing: -0.5,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Bottom Section
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               const Flexible(
//                 child: Text(
//                   'Click here for your business card',
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: Color(0xFFCBD5E1),
//                     fontWeight: FontWeight.w400,
//                   ),
//                   textAlign: TextAlign.right,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               BlinkingArrow(),
//               const SizedBox(width: 8),
//               GestureDetector(
//                 onTap: onFlipCard,
//                 child: Container(
//                   width: 48,
//                   height: 48,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Icon(
//                     Icons.credit_card,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCardBack() {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFF1E293B),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.all(20),
//       child: Stack(
//         children: [
//           Column(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Top Section
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Icon(
//                   Icons.person_outline,
//                   color: Colors.white,
//                   size: 20,
//                 ),
//               ),
//               // Middle Section
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     currentUserCard.name,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.white,
//                       letterSpacing: -0.5,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     currentUserCard.title,
//                     style: TextStyle(
//                       fontSize: 11,
//                       color: const Color(0xFFCBD5E1),
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                 ],
//               ),
//               // Bottom Section
//               Text(
//                 currentUserCard.company,
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.white.withOpacity(0.9),
//                 ),
//               ),
//             ],
//           ),
//           Positioned(
//             top: 16,
//             right: 16,
//             child: GestureDetector(
//               onTap: onFlipCard,
//               child: Container(
//                 width: 32,
//                 height: 32,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Center(
//                   child: Text(
//                     '×',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w300,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCategories() {
//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'CATEGORIES',
//             style: TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w600,
//               color: const Color(0xFF64748B),
//               letterSpacing: 0.8,
//             ),
//           ),
//           const SizedBox(height: 16),
//           ...categories.map((category) => Padding(
//                 padding: const EdgeInsets.only(bottom: 8),
//                 child: GestureDetector(
//                   onTap: () => onCategoryTap(category.id),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       border: Border.all(
//                         color: const Color(0xFFE2E8F0),
//                         width: 1,
//                       ),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: const EdgeInsets.all(16),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 44,
//                           height: 44,
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFF8FAFC),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Icon(
//                             category.icon,
//                             color: const Color(0xFF334155),
//                             size: 20,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 category.name,
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                   color: Color(0xFF0F172A),
//                                 ),
//                               ),
//                               const SizedBox(height: 2),
//                               Text(
//                                 '${category.count} ${category.count == 1 ? 'card' : 'cards'}',
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   color: Color(0xFF64748B),
//                                   fontWeight: FontWeight.w400,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const Icon(
//                           Icons.chevron_right,
//                           color: Color(0xFF94A3B8),
//                           size: 20,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               )),
//         ],
//       ),
//     );
//   }
// }
//
// // Blinking Arrow Widget
// class BlinkingArrow extends StatefulWidget {
//   const BlinkingArrow({super.key});
//
//   @override
//   State<BlinkingArrow> createState() => _BlinkingArrowState();
// }
//
// class _BlinkingArrowState extends State<BlinkingArrow>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat(reverse: true);
//     _animation = Tween<double>(begin: 1.0, end: 0.3).animate(_controller);
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: _animation,
//       child: const Icon(
//         Icons.chevron_right,
//         color: Color(0xFF94A3B8),
//         size: 16,
//       ),
//     );
//   }
// }
//
// // Stack Screen
// class StackScreen extends StatelessWidget {
//   final Category category;
//   final List<BusinessCard> cards;
//   final VoidCallback onBack;
//   final BusinessCard? expandedCard;
//   final Function(BusinessCard) onCardTap;
//   final VoidCallback onCloseExpanded;
//
//   const StackScreen({
//     super.key,
//     required this.category,
//     required this.cards,
//     required this.onBack,
//     required this.expandedCard,
//     required this.onCardTap,
//     required this.onCloseExpanded,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Column(
//               children: [
//                 _buildHeader(),
//                 Expanded(
//                   child: ListView.builder(
//                     padding: const EdgeInsets.all(24),
//                     itemCount: cards.length,
//                     itemBuilder: (context, index) {
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 12),
//                         child: CompactBusinessCard(
//                           card: cards[index],
//                           onTap: () => onCardTap(cards[index]),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             if (expandedCard != null)
//               ExpandedCardDialog(
//                 card: expandedCard!,
//                 onClose: onCloseExpanded,
//               ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {},
//         backgroundColor: const Color(0xFF0F172A),
//         child: const Icon(Icons.add, size: 20),
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         border: Border(
//           bottom: BorderSide(
//             color: Color(0xFFE2E8F0),
//             width: 1,
//           ),
//         ),
//       ),
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               GestureDetector(
//                 onTap: onBack,
//                 child: Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF1F5F9),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Icon(
//                     Icons.arrow_back,
//                     size: 20,
//                     color: Color(0xFF334155),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       category.name,
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.w300,
//                         color: Color(0xFF0F172A),
//                         letterSpacing: -0.5,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       '${category.count} ${category.count == 1 ? 'card' : 'cards'}',
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Color(0xFF64748B),
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 width: 40,
//                 height: 40,
//                 child: const Icon(
//                   Icons.more_vert,
//                   color: Color(0xFF475569),
//                   size: 20,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 24),
//           // Search Bar
//           Container(
//             decoration: BoxDecoration(
//               color: const Color(0xFFF8FAFC),
//               border: Border.all(
//                 color: const Color(0xFFE2E8F0).withOpacity(0.8),
//                 width: 1,
//               ),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: 'Search in this category',
//                 hintStyle: const TextStyle(
//                   color: Color(0xFF94A3B8),
//                   fontSize: 14,
//                 ),
//                 prefixIcon: const Icon(
//                   Icons.search,
//                   color: Color(0xFF94A3B8),
//                   size: 18,
//                 ),
//                 border: InputBorder.none,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 14,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Compact Business Card Widget
// class CompactBusinessCard extends StatelessWidget {
//   final BusinessCard card;
//   final VoidCallback onTap;
//
//   const CompactBusinessCard({
//     super.key,
//     required this.card,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(
//             color: const Color(0xFFE2E8F0),
//             width: 1,
//           ),
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: AspectRatio(
//           aspectRatio: 1.76,
//           child: Container(
//             decoration: BoxDecoration(
//               color: card.color,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Top Section
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: const Icon(
//                         Icons.work_outline,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                     ),
//                     Container(
//                       width: 32,
//                       height: 32,
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: const Icon(
//                         Icons.star_border,
//                         color: Colors.white,
//                         size: 16,
//                       ),
//                     ),
//                   ],
//                 ),
//                 // Middle Section
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       card.name,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.white,
//                         letterSpacing: -0.5,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       card.title,
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: const Color(0xFFCBD5E1),
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ],
//                 ),
//                 // Bottom Section
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       card.company,
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.white.withOpacity(0.9),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Container(
//                             height: 36,
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: const Center(
//                               child: Text(
//                                 'Contact',
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Container(
//                             height: 36,
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: const Center(
//                               child: Text(
//                                 'View',
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Container(
//                           width: 36,
//                           height: 36,
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: const Icon(
//                             Icons.share,
//                             color: Colors.white,
//                             size: 16,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // Expanded Card Dialog
// class ExpandedCardDialog extends StatelessWidget {
//   final BusinessCard card;
//   final VoidCallback onClose;
//
//   const ExpandedCardDialog({
//     super.key,
//     required this.card,
//     required this.onClose,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onClose,
//       child: Container(
//         color: Colors.black.withOpacity(0.6),
//         child: GestureDetector(
//           onTap: () {}, // Prevent closing when tapping dialog
//           child: Align(
//             alignment: Alignment.bottomCenter,
//             child: Container(
//               height: MediaQuery.of(context).size.height * 0.85,
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(24),
//                   topRight: Radius.circular(24),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   // Header
//                   Container(
//                     padding: const EdgeInsets.all(24),
//                     decoration: const BoxDecoration(
//                       border: Border(
//                         bottom: BorderSide(
//                           color: Color(0xFFE2E8F0),
//                           width: 1,
//                         ),
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'Card Details',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w500,
//                             color: Color(0xFF0F172A),
//                           ),
//                         ),
//                         GestureDetector(
//                           onTap: onClose,
//                           child: Container(
//                             width: 36,
//                             height: 36,
//                             decoration: BoxDecoration(
//                               color: const Color(0xFFF1F5F9),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: const Center(
//                               child: Text(
//                                 '×',
//                                 style: TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.w300,
//                                   color: Color(0xFF334155),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Content
//                   Expanded(
//                     child: SingleChildScrollView(
//                       padding: const EdgeInsets.all(24),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Card Header
//                           Container(
//                             decoration: BoxDecoration(
//                               color: card.color,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             padding: const EdgeInsets.all(24),
//                             child: Stack(
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Container(
//                                       width: 56,
//                                       height: 56,
//                                       decoration: BoxDecoration(
//                                         color: Colors.white.withOpacity(0.1),
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       child: const Icon(
//                                         Icons.work_outline,
//                                         color: Colors.white,
//                                         size: 28,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 16),
//                                     Text(
//                                       card.name,
//                                       style: const TextStyle(
//                                         fontSize: 24,
//                                         fontWeight: FontWeight.w500,
//                                         color: Colors.white,
//                                         letterSpacing: -0.5,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       card.title,
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         color: const Color(0xFFCBD5E1),
//                                         fontWeight: FontWeight.w400,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 16),
//                                     Text(
//                                       card.company,
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w500,
//                                         color: Colors.white.withOpacity(0.9),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Positioned(
//                                   top: 0,
//                                   right: 0,
//                                   child: Container(
//                                     width: 32,
//                                     height: 32,
//                                     decoration: BoxDecoration(
//                                       color: Colors.white.withOpacity(0.1),
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     child: const Icon(
//                                       Icons.star_border,
//                                       color: Colors.white,
//                                       size: 16,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 24),
//                           // Contact Information
//                           Text(
//                             'CONTACT INFORMATION',
//                             style: TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.w600,
//                               color: const Color(0xFF64748B),
//                               letterSpacing: 0.8,
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           _buildInfoItem(Icons.email_outlined, 'Email', card.email),
//                           const SizedBox(height: 16),
//                           _buildInfoItem(Icons.phone_outlined, 'Phone', card.phone),
//                           const SizedBox(height: 16),
//                           _buildInfoItem(Icons.language, 'Website', card.website),
//                           const SizedBox(height: 16),
//                           _buildInfoItem(Icons.location_on_outlined, 'Location', card.location),
//                           const SizedBox(height: 32),
//                           // Action Buttons
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Container(
//                                   height: 50,
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFF0F172A),
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: const Center(
//                                     child: Text(
//                                       'Contact',
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w500,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Container(
//                                   height: 50,
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFFF1F5F9),
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: const Center(
//                                     child: Text(
//                                       'Share',
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w500,
//                                         color: Color(0xFF334155),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoItem(IconData icon, String label, String value) {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFFF8FAFC),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       padding: const EdgeInsets.all(16),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               border: Border.all(
//                 color: const Color(0xFFE2E8F0),
//                 width: 1,
//               ),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(
//               icon,
//               color: const Color(0xFF475569),
//               size: 20,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label.toUpperCase(),
//                   style: const TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w500,
//                     color: Color(0xFF64748B),
//                     letterSpacing: 0.8,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Color(0xFF0F172A),
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Data Models
// class BusinessCard {
//   final int id;
//   final String name;
//   final String title;
//   final String company;
//   final String email;
//   final String phone;
//   final String website;
//   final String location;
//   final Color color;
//
//   BusinessCard({
//     required this.id,
//     required this.name,
//     required this.title,
//     required this.company,
//     required this.email,
//     required this.phone,
//     required this.website,
//     required this.location,
//     required this.color,
//   });
// }
//
// class Category {
//   final String id;
//   final String name;
//   final IconData icon;
//   final int count;
//
//   Category({
//     required this.id,
//     required this.name,
//     required this.icon,
//     required this.count,
//   });
// }
