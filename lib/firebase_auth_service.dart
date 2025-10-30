import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Phone Authentication Service
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;

  /// Get the current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  /// Send OTP to the provided phone number
  /// [phoneNumber] should be in E.164 format (e.g., +1234567890)
  /// [onCodeSent] callback when OTP is sent successfully
  /// [onVerificationFailed] callback when verification fails
  /// [onVerificationCompleted] callback when auto-verification completes
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onVerificationFailed,
    Function(PhoneAuthCredential)? onVerificationCompleted,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification on Android devices
        if (onVerificationCompleted != null) {
          onVerificationCompleted(credential);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        String errorMessage = 'Verification failed';

        if (e.code == 'invalid-phone-number') {
          errorMessage = 'The phone number is invalid';
        } else if (e.code == 'too-many-requests') {
          errorMessage = 'Too many requests. Please try again later';
        } else if (e.code == 'operation-not-allowed') {
          errorMessage = 'Phone authentication is not enabled';
        } else {
          errorMessage = e.message ?? 'Verification failed';
        }

        onVerificationFailed(errorMessage);
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  /// Verify the OTP code entered by the user
  /// [verificationId] the verification ID received in onCodeSent
  /// [otpCode] the 6-digit OTP code entered by the user
  /// Returns the UserCredential if successful, throws error otherwise
  Future<UserCredential> verifyOTP({
    required String verificationId,
    required String otpCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        throw 'Invalid OTP code. Please try again';
      } else if (e.code == 'session-expired') {
        throw 'OTP expired. Please request a new code';
      } else {
        throw e.message ?? 'Verification failed';
      }
    }
  }

  /// Sign in with phone credential (used for auto-verification)
  Future<UserCredential> signInWithCredential(PhoneAuthCredential credential) async {
    return await _auth.signInWithCredential(credential);
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get the current verification ID
  String? get verificationId => _verificationId;

  /// Get the user's phone number
  String? get phoneNumber => currentUser?.phoneNumber;
}