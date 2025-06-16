import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:seedina/login_page/setup/esp_conn_setup.dart';
import 'package:seedina/login_page/setup/seedkey_step.dart';
import 'package:seedina/login_page/setup/selection_plant_step.dart';
import 'package:seedina/services/auth_service.dart';
import 'package:seedina/main_page/portalscreen.dart';
import 'package:flutter/foundation.dart';

enum Destination { loading, seedKeySetup, plantSetup, espSetup, portal }

class SetupCheckWrapper extends StatefulWidget {
  final User user;
  const SetupCheckWrapper({super.key, required this.user});

  @override
  State<SetupCheckWrapper> createState() => _SetupCheckWrapperState();
}

class _SetupCheckWrapperState extends State<SetupCheckWrapper> {
  Destination _destination = Destination.loading; // State awal

  @override
  void initState() {
    super.initState();
    _determineDestination(); // Mulai proses penentuan tujuan
  }

  Future<void> _determineDestination() async {
    Destination determinedDestination;

    try {
      DocumentSnapshot? userDocSnap = await AuthService.getUserDoc(widget.user.uid);
      if (userDocSnap != null && userDocSnap.exists && userDocSnap.data() != null) {
        final userData = userDocSnap.data() as Map<String, dynamic>;
        final bool setupComplete = userData['setupComplete'] ?? false;
        final String? seedKey = userData['seedKey'];
        final String? selectedPlant = userData['selectedPlant'];

        if (kDebugMode) {
          print("[SetupCheckWrapper] Firesstore dataL UID=${widget.user.uid}, setupComplete=$setupComplete, seedKey=$seedKey");
        }

        if (setupComplete) {
          determinedDestination = Destination.portal;
        } else {
          if (seedKey == null || seedKey.isEmpty) {
            determinedDestination = Destination.seedKeySetup;
          } else if (selectedPlant == null || selectedPlant.isEmpty) {
            determinedDestination = Destination.plantSetup;
          } else {
            determinedDestination = Destination.espSetup;
          }
        } 
      } else {
        if (kDebugMode) {
          print("[SetupCheckWrapper] Document not found");
        }

        await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).set({
          'uid': widget.user.uid,
          'email': widget.user.email,
          'displayName': widget.user.displayName?? 'Farms',
          'createdAt': Timestamp.now(),
          'setupComplete': false,
          'seedKey': null,
          'selectedPlant': null
        }, SetOptions(merge: true));

        determinedDestination = Destination.seedKeySetup;
    }
  } catch (e) {
    if (kDebugMode) {
      print("[SetupCheckWrapper] Error when locating destination: $e");
    }
    determinedDestination = Destination.seedKeySetup;
  }

  if (mounted) {
    setState(() {
      _destination = determinedDestination;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    switch (_destination) {
      case Destination.loading:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case Destination.seedKeySetup:
        if (kDebugMode) {
          print("[Build] Destination decided: seedKey");
        }
        return SeedKey();
      case Destination.plantSetup:
        return SetupPlant();
      case Destination.espSetup:
        return WiFiConnSetup();
      case Destination.portal:
        // Jika tujuan adalah portal utama
        if (kDebugMode) {
          print("[Build] Destination decided: PortalScreen");
        }
        return const PortalScreen();
    }
  }
}

