import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/services/email_service.dart';

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String pincode;
  final String city;
  final String address;
  final bool isMember;

  const UserProfile({
    this.uid = '',
    this.name = '',
    this.email = '',
    this.pincode = '',
    this.city = '',
    this.address = '',
    this.isMember = false,
  });

  bool get isComplete => name.isNotEmpty && pincode.isNotEmpty && email.isNotEmpty;

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      pincode: map['pincode'] as String? ?? '',
      city: map['city'] as String? ?? '',
      address: map['address'] as String? ?? '',
      isMember: map['isMember'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'pincode': pincode,
    'city': city,
    'address': address,
    'isMember': isMember,
  };
}

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  UserProfile _profile = const UserProfile();
  String? _verificationId;
  int? _resendToken;
  ConfirmationResult? _webConfirmationResult;
  bool _loading = false;
  bool _profileLoading = false;
  bool _adminLoading = false;
  bool _isAdmin = false;
  String? _error;

  User? get user => _user;
  UserProfile get profile => _profile;
  bool get isLoggedIn => _user != null;
  bool get isProfileComplete => _profile.isComplete;
  bool get loading => _loading;
  bool get profileLoading => _profileLoading;
  bool get adminLoading => _adminLoading;
  bool get isAdmin => _isAdmin;
  String? get error => _error;

  AuthProvider() {
    _user = _auth.currentUser;
    if (_user != null) {
      _loadProfile();
      _checkAdminStatus();
    }
    _auth.authStateChanges().listen((user) {
      _user = user;
      if (user != null) {
        _loadProfile();
        _checkAdminStatus();
      } else {
        _profile = const UserProfile();
        _isAdmin = false;
      }
      notifyListeners();
    });
  }

  Future<void> _checkAdminStatus() async {
    if (_user == null) {
      _isAdmin = false;
      return;
    }
    _adminLoading = true;
    notifyListeners();
    try {
      final doc = await _firestore.collection('admins').doc(_user!.uid).get();
      _isAdmin = doc.exists;
    } catch (_) {
      _isAdmin = false;
    }
    _adminLoading = false;
    notifyListeners();
  }

  Future<bool> refreshAdminStatus() async {
    await _checkAdminStatus();
    return _isAdmin;
  }

  Future<bool> ensureAdminAccess({
    required String adminId,
    required String adminPass,
  }) async {
    if (_user == null) return false;

    // Must match local admin credentials.
    if (adminId != 'admin' || adminPass != 'jgs@2026') {
      return false;
    }

    try {
      await _checkAdminStatus();
      return _isAdmin;
    } catch (e) {
      debugPrint('ensureAdminAccess error: $e');
      return false;
    }
  }

  Future<void> _loadProfile() async {
    if (_user == null) return;
    _profileLoading = true;
    notifyListeners();
    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists && doc.data() != null) {
        _profile = UserProfile.fromMap(_user!.uid, doc.data()!);
        debugPrint('Profile loaded: ${_profile.name}, ${_profile.pincode}');
      } else {
        debugPrint('No profile document found for uid: ${_user!.uid}');
        _profile = const UserProfile();
      }
    } catch (e) {
      debugPrint('Firestore loadProfile error: $e');
      _profile = const UserProfile();
    }
    _profileLoading = false;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    await _loadProfile();
  }

  Future<bool> saveProfile(UserProfile profile) async {
    if (_user == null) return false;
    _profileLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _firestore.collection('users').doc(_user!.uid).set({
        ...profile.toMap(),
        'phone': _user!.phoneNumber ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      // Send welcome email if it's a new/complete profile
      if (profile.isComplete) {
        EmailService.sendWelcomeEmail(profile);
      }

      _profile = profile;
      _profileLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Firestore saveProfile error: $e');
      _error = 'Failed to save profile. Please try again.';
      _profileLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> joinMembership() async {
    if (_user == null) return false;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _firestore.collection('users').doc(_user!.uid).update({
        'isMember': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      // Update local profile directly to avoid an extra read
      _profile = UserProfile(
        uid: _profile.uid,
        name: _profile.name,
        email: _profile.email,
        pincode: _profile.pincode,
        city: _profile.city,
        address: _profile.address,
        isMember: true,
      );
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Firestore joinMembership error: $e');
      _error = 'Failed to join membership. Please try again.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  /// Send OTP to the given phone number (with +91 prefix).
  Future<void> sendOtp({
    required String phoneNumber,
    required VoidCallback onCodeSent,
    required void Function(String error) onError,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    if (kIsWeb) {
      try {
        _webConfirmationResult = await _auth.signInWithPhoneNumber(
          '+91$phoneNumber',
        );
        _loading = false;
        notifyListeners();
        onCodeSent();
      } on FirebaseAuthException catch (e) {
        _loading = false;
        _error = _mapError(e.code);
        notifyListeners();
        onError(_error!);
      }
      return;
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: '+91$phoneNumber',
      timeout: const Duration(seconds: 60),
      forceResendingToken: _resendToken,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification (Android only)
        await _auth.signInWithCredential(credential);
        _loading = false;
        notifyListeners();
      },
      verificationFailed: (FirebaseAuthException e) {
        _loading = false;
        _error = _mapError(e.code);
        notifyListeners();
        onError(_error!);
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        _loading = false;
        notifyListeners();
        onCodeSent();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  /// Verify the 6-digit OTP code.
  Future<bool> verifyOtp(String otp) async {
    if (kIsWeb) {
      if (_webConfirmationResult == null) {
        _error = 'Session expired. Please request a new OTP.';
        notifyListeners();
        return false;
      }

      _loading = true;
      _error = null;
      notifyListeners();

      try {
        await _webConfirmationResult!.confirm(otp);
        await _loadProfile();
        _loading = false;
        notifyListeners();
        return true;
      } on FirebaseAuthException catch (e) {
        _loading = false;
        _error = _mapError(e.code);
        notifyListeners();
        return false;
      }
    }

    if (_verificationId == null) {
      _error = 'Session expired. Please request a new OTP.';
      notifyListeners();
      return false;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
      await _loadProfile();
      _loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _loading = false;
      _error = _mapError(e.code);
      notifyListeners();
      return false;
    }
  }

  /// Resend OTP to the same number.
  Future<void> resendOtp({
    required String phoneNumber,
    required void Function(String error) onError,
  }) async {
    await sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: () {},
      onError: onError,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _verificationId = null;
    _resendToken = null;
    _webConfirmationResult = null;
    notifyListeners();
  }

  String _mapError(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'Invalid phone number. Please check and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'captcha-check-failed':
        return 'Captcha check failed. Please try again.';
      case 'invalid-verification-code':
        return 'Invalid OTP. Please check and try again.';
      case 'session-expired':
        return 'OTP expired. Please request a new one.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
