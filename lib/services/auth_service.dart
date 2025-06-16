import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _authGoogle = GoogleSignIn();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static User? get currentUser => _auth.currentUser;

  static Future<void> signInWithEmail(String email, String password, BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        _showErrorMsg(e.code, context, e.message);
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorMsg("sign-in-error", context, "Terjadi kesalahan saat masuk: ${e.toString()}");
      }
    }
  }

  static Future<User?> signUpWithEmail(
    String username,
    String email,
    String password,
    BuildContext context
  ) async {
    if (username.trim().isEmpty) {
      if (context.mounted) {
        _showErrorMsg("username-empty", context, "Nama pengguna tidak boleh kosong.");
      }
      return null;
    }
    try {
      UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
        );

      User? newUser = userCredential.user;
      if (newUser != null) {
        await newUser.updateProfile(displayName: username.trim());
        await _firestore.collection('users').doc(newUser.uid).set({
          'uid': newUser.uid,
          'email': newUser.email,
          'displayName': username.trim(),
          'createdAt': Timestamp.now(),
          'setupComplete': false,
          'seedKey': null,
          'selectedPlant': null,
          'photoURL': newUser.photoURL,
        });
        return newUser;
      }
      return null;
    } on FirebaseAuthException catch(e) {
      if (context.mounted) {
        _showErrorMsg(e.code, context, e.message);
      }
      return null;
    } catch (e) {
      if (context.mounted) {
        _showErrorMsg("sign-up-error", context, "Terjadi kesalahan saat mendaftar: ${e.toString()}");
      }
      return null;
    }
  }

  static Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _authGoogle.signIn();
      if (googleUser == null) {
        return null;
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        final docRef = _firestore.collection('users').doc(user.uid);
        final docSnap = await docRef.get();

        if (!docSnap.exists) {
          await docRef.set({
            'uid': user.uid,
            'email': user.email,
            'displayName': user.displayName ?? "Pengguna Google",
            'photoURL': user.photoURL,
            'createdAt': Timestamp.now(),
            'setupComplete': false,
            'seedKey': null,
            'selectedPlant': null
          });
        } else {
           await docRef.update({
            if (user.displayName != null) 'displayName': user.displayName,
            if (user.photoURL != null) 'photoURL': user.photoURL,
          });
        }
      }
      return user;
    } on FirebaseAuthException catch(e) {
      if (context.mounted) {
        _showErrorMsg(e.code, context, e.message);
      }
      return null;
    } catch (e) {
      if (context.mounted) {
        _showErrorMsg("google-sign-in-failed", context, "Gagal masuk dengan Google: ${e.toString()}");
      }
      return null;
    }
  }

  static Future<void> signOut(BuildContext context) async {
    try {
      await _authGoogle.signOut();
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print("[AuthService] Error saat sign out: $e");
      }
      if (context.mounted){
        _showErrorMsg("sign-out-error", context, "Gagal keluar: ${e.toString()}");
      }
    }
  }

  static Future<void> sendPasswordResetEmail (String email, BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (context.mounted) {
        _showInfoMsg("Email reset password telah dikirim", context);
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        _showErrorMsg(e.code, context, e.message);
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorMsg("password-reset-error", context, "Gagal mengirim email reset password: ${e.toString()}");
      }
    }
  }

  static Future<DocumentSnapshot?> getUserDoc(String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (e) {
      if (kDebugMode) print('[AuthService] Error Firestore getUserDoc: $e');
      return null;
    }
  }

  static Future<bool> updateUserDocument(String uid, Map<String, dynamic> data, BuildContext context) async {
    try {
      if (kDebugMode) print("[AuthService] updateUserDocument: Attempting to update UID $uid with data: $data");
      await _firestore.collection('users').doc(uid).update(data);
      if (kDebugMode) print("[AuthService] updateUserDocument: Successfully updated UID $uid with data $data.");
      return true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("[AuthService] updateUserDocument: FAILED to update UID $uid with data $data. Error: $e");
        print("[AuthService] StackTrace: $stackTrace");
      }
      if (context.mounted) {
        _showErrorMsg("firestore-update-failed", context, "Gagal memperbarui data pengguna: ${e.toString()}");
      }
      return false;
    }
  }

  static Future<bool> claimSeedKey (String uid, String seedKey, BuildContext context) async {
    final seedKeyDocRef = _firestore.collection('seedKeys').doc(seedKey);
    final userDocRef = _firestore.collection('users').doc(uid);

    try {
      return await _firestore.runTransaction((transaction) async {
        DocumentSnapshot seedKeySnap = await transaction.get(seedKeyDocRef);

        if (seedKeySnap.exists) {
          final Map<String, dynamic>? seedKeyData = seedKeySnap.data() as Map<String, dynamic>?;
          final String? ownerUid = seedKeyData?['uid'];

          if (ownerUid != null && ownerUid.isNotEmpty && ownerUid != uid) {
            if (context.mounted) {
              _showErrorMsg("seedkey-already-claimed", context, "SeedKey ini sudah digunakan oleh pengguna lain");
            }
            return false;
          }
           transaction.update(seedKeyDocRef, {
            'uid': uid, 
            'assignedAt': Timestamp.now(),
          });
        } else {
          transaction.set(seedKeyDocRef, {
            'uid': uid,
            'assignedAt': Timestamp.now(),
          });
        }
        transaction.update(userDocRef, {'seedKey': seedKey});
        return true;
      });  
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print("[AuthService] claimSeedKey FirebaseException: UID $uid, SeedKey $seedKey. Error: ${e.message}, Code: ${e.code}");
        print("[AuthService] StackTrace: ${e.stackTrace}");
      }
      if (context.mounted) {
        _showErrorMsg(e.code, context, e.message ?? "Terjadi error Firebase saat memproses SeedKey.");
      }
      return false;
    } catch(e, stackTrace) {
      if (kDebugMode) {
        print("[AuthService] claimSeedKey General Exception: UID $uid, SeedKey $seedKey. Error: $e");
        print("[AuthService] StackTrace: $stackTrace");
      }
      if (context.mounted) {
        _showErrorMsg("transaction-general-error", context, "Gagal memproses SeedKey: ${e.toString()}");
      }
      return false;
    }
  }

  static void _showErrorMsg(String errorCode, BuildContext context, String? defaultMessage) {
    if (!context.mounted) return;
    String errorMessage;
    switch (errorCode) {
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        errorMessage = 'Email atau Kata Sandi Anda Salah';
        break;
      case 'network-request-failed':
        errorMessage = 'Gagal terhubung. Periksa koneksi internet Anda';
        break;
      case 'invalid-email':
        errorMessage = 'Format email anda salah. Masukkan email yang benar';
        break;
      case 'email-already-in-use':
        errorMessage = 'Email ini sudah terdaftar. Silakan gunakan email lain atau masuk.';
        break;
      case 'weak-password':
        errorMessage = 'Kata sandi terlalu lemah. Gunakan minimal 6 karakter.';
        break;
      case 'username-empty':
        errorMessage = defaultMessage ?? 'Nama pengguna tidak boleh kosong.';
        break;
      case 'seedkey-already-claimed':
        errorMessage = defaultMessage ?? 'SeedKey sudah digunakan oleh pengguna lain.';
        break;
      case 'google-sign-in-failed':
      case 'sign-in-error':
      case 'sign-up-error':
      case 'password-reset-error':
      case 'firestore-update-failed':
      case 'transaction-general-error':
      case 'sign-out-error':
        errorMessage = defaultMessage ?? 'Terjadi kesalahan. Silakan coba lagi.';
        break;
      default:
        errorMessage = defaultMessage ?? 'Terjadi kesalahan: $errorCode';
        if (kDebugMode) print("AuthService Unhandled Error Code: $errorCode, Message: $defaultMessage");
    }
    final snackBar = SnackBar(
      content: Text(errorMessage),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void _showInfoMsg (String message, BuildContext context) {
    if (!context.mounted) return;
    final snackBar = SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}