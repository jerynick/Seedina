import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seedina/services/auth_service.dart';

class HandlingProvider extends ChangeNotifier {
  Map<String, dynamic> _activeParameters = {};
  String _activeSelectedPlant = '';

  int humiLing = 0;
  int tdsAir = 0;
  double ecAir = 0.0;
  double tinggiAir = 0.0;
  double suhuAir = 0.0;
  double suhuLing = 0.0;

  String namaTanaman = 'Pilih Tanaman';
  String namaLatin = '...';
  String gambar = 'assets/myicon/unknown.png';
  double idealWaktuSiram = 0.0;
  double idealJedaSiram = 0.0;
  double idealSuhu = 0.0;
  double idealNutrisi = 0.0;
  double idealEC = 0.0;

  Map<String, dynamic> _draftParametersForEditing = {};
  String _draftSelectedPlantForEditing = '';

  String? _userSeedkey;
  bool _isInitialized = false;
  bool _isLoading = true;
  bool _isSeedKeyReady = false;

  double? onDemandPhValue;
  bool isPhMeasuring = false;
  String? phMeasurementError;

  StreamSubscription<DatabaseEvent>? _monitoringSubscription;
  StreamSubscription<DatabaseEvent>? _parameterSubscription;
  StreamSubscription<DatabaseEvent>? _onDemandPhSubscription;
  StreamSubscription<User?>? _authSubscription;

  final Map<String, Map<String, dynamic>> parameters = {
    'Selada Romaine': {
      'title': 'Selada Romaine',
      'latin': 'Lactuca sativa L. var. longifolia',
      'thumbnail': 'assets/plants/lettuce.png',
      'jeda_siram': 25,
      'waktu_siram': 3,
      'min_suhuair': 18.0,
      'max_suhuair': 24.0,
      'min_suhuling': 15.0,
      'max_suhuling': 25.0,
      'min_tdsair': 560,
      'max_tdsair': 840,
      'min_humiling': 50,
      'max_humiling': 70,
    },
    'Bayam': {
      'title': 'Bayam',
      'latin': 'Amaranthus sp.',
      'thumbnail': 'assets/plants/spinach.png',
      'jeda_siram': 30,
      'waktu_siram': 2,
      'min_suhuair': 18.0,
      'max_suhuair': 28.0,
      'min_suhuling': 18.0,
      'max_suhuling': 30.0,
      'min_tdsair': 1260,
      'max_tdsair': 1610,
      'min_humiling': 60,
      'max_humiling': 80,
    },
    'Kangkung': {
      'title': 'Kangkung',
      'latin': 'Ipomoea aquatica',
      'thumbnail': 'assets/plants/water-spinach.png',
      'jeda_siram': 10,
      'waktu_siram': 1,
      'min_suhuair': 20.0,
      'max_suhuair': 30.0,
      'min_suhuling': 20.0,
      'max_suhuling': 30.0,
      'min_tdsair': 1050,
      'max_tdsair': 1400,
      'min_humiling': 70,
      'max_humiling': 90,
    },
    'Kustom': {
      'title': 'Tanaman Lain',
      'latin': 'Parameter Kustom',
      'thumbnail': 'assets/myicon/unknown.png',
      'jeda_siram': 30,
      'waktu_siram': 5,
      'min_suhuair': 15.0,
      'max_suhuair': 35.0,
      'min_suhuling': 15.0,
      'max_suhuling': 35.0,
      'min_tdsair': 350,
      'max_tdsair': 2100,
      'min_humiling': 30,
      'max_humiling': 90,
    }
  };

  String get activeSelectedPlant => _activeSelectedPlant;
  Map<String, dynamic> get activeParameters => _activeParameters; 

  String get draftSelectedPlantForEditing => _draftSelectedPlantForEditing;
  Map<String, dynamic> get draftParametersForEditing => _draftParametersForEditing;

  Map<String, String> get draftPlantInfoForEditingPage {
     if (_draftSelectedPlantForEditing.isEmpty || _draftParametersForEditing.isEmpty) {
      return {'title': 'Pilih Tanaman', 'latin': '...', 'thumbnail': 'assets/myicon/unknown.png'};
    }
    return {
      'title': _draftParametersForEditing['title'] as String? ?? _draftSelectedPlantForEditing,
      'latin': _draftParametersForEditing['latin'] as String? ?? '...',
      'thumbnail': _draftParametersForEditing['thumbnail'] as String? ?? 'assets/myicon/unknown.png',
    };
  }

  double get idealWaktuSiramForEditingPage => _parseToDouble(_draftParametersForEditing['waktu_siram']);
  double get idealJedaSiramForEditingPage => _parseToDouble(_draftParametersForEditing['jeda_siram']);
  double get idealSuhuForEditingPage {
    if (_draftParametersForEditing.isEmpty) return 0.0;
    return ((_parseToDouble(_draftParametersForEditing['min_suhuair']) + _parseToDouble(_draftParametersForEditing['max_suhuair'])) / 2);
  }
  double get idealNutrisiForEditingPage {
    if (_draftParametersForEditing.isEmpty) return 0.0;
    return ((_parseToDouble(_draftParametersForEditing['min_tdsair']) + _parseToDouble(_draftParametersForEditing['max_tdsair'])) / 2);
  }
  double get idealECForEditingPage {
     if (_draftParametersForEditing.isEmpty) return 0.0;
    double minECVal = (_parseToDouble(_draftParametersForEditing['min_tdsair']) / 700.0);
    double maxECVal = (_parseToDouble(_draftParametersForEditing['max_tdsair']) / 700.0);
    return (minECVal + maxECVal) / 2;
  }


  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get currentUserSeedKey => _userSeedkey;
  bool get isSeedKeyReady => _isSeedKeyReady;

  DatabaseReference? get _baseRef {
    if (!_isSeedKeyReady || _userSeedkey == null || _userSeedkey!.isEmpty) return null;
    return FirebaseDatabase.instance.ref().child(_userSeedkey!);
  }
  DatabaseReference? get _monitoringDataRef => _baseRef?.child('monitoring');
  DatabaseReference? get _activeParameterDataRef => _baseRef?.child('parameter');
  DatabaseReference? get _phRequestRef => _baseRef?.child('commands/ph_request');
  DatabaseReference? get _phResultRef => _baseRef?.child('ph_ondemand');


  HandlingProvider() {
    _authSubscription = AuthService.authStateChanges.listen((user) {
      final currentAuthUid = user?.uid;
      if (currentAuthUid == null) {
        _resetAllStates();
        if (hasListeners) notifyListeners();
      } else {
        AuthService.getUserDoc(currentAuthUid).then((userDoc) {
          String? firestoreSeedKey;
          if (userDoc != null && userDoc.exists) {
            firestoreSeedKey = (userDoc.data() as Map<String, dynamic>?)?['seedKey'];
          }
          if (!_isInitialized || _userSeedkey != firestoreSeedKey || !_isSeedKeyReady) {
            _userSeedkey = firestoreSeedKey;
            _initializeProviderStates();
          } else if (_isLoading) {
            _isLoading = false;
            if (hasListeners) notifyListeners();
          }
        }).catchError((e) {
          if (kDebugMode) print("Error fetching user doc: $e");
          if (!_isInitialized || _userSeedkey == null) {
            _initializeProviderStates();
          }
        });
      }
    });
    if (AuthService.currentUser == null && !_isInitialized) {
      _initializeProviderStates();
    }
  }

  void _resetAllStates() {
    _activeParameters = {};
    _activeSelectedPlant = '';
    _draftParametersForEditing = {};
    _draftSelectedPlantForEditing = '';

    humiLing = 0; tdsAir = 0; ecAir = 0.0; tinggiAir = 0.0; suhuAir = 0.0; suhuLing = 0.0;
    _updateDisplayParametersFromActiveData(); 

    _userSeedkey = null;
    _isSeedKeyReady = false;
    _isInitialized = true; 
    _isLoading = false;

    onDemandPhValue = null; isPhMeasuring = false; phMeasurementError = null;

    _monitoringSubscription?.cancel(); _monitoringSubscription = null;
    _parameterSubscription?.cancel(); _parameterSubscription = null;
    _onDemandPhSubscription?.cancel(); _onDemandPhSubscription = null;
  }

  Future<void> _initializeProviderStates() async {
    if (!_isLoading) {
      _isLoading = true;
      if (hasListeners) notifyListeners();
    }
    _isInitialized = false;

    final currentUser = AuthService.currentUser;
    if (currentUser == null) {
      _resetAllStates();
      return;
    }

    DocumentSnapshot? userDoc = await AuthService.getUserDoc(currentUser.uid);
    String? firestoreSelectedPlant;
    if (userDoc != null && userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>?;
      _userSeedkey = data?['seedKey']; // Update seedkey juga di sini
      _isSeedKeyReady = _userSeedkey != null && _userSeedkey!.isNotEmpty;
      firestoreSelectedPlant = data?['selectedPlant'];
    }

    if (firestoreSelectedPlant != null && firestoreSelectedPlant.isNotEmpty) {
      _activeSelectedPlant = firestoreSelectedPlant;
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? prefPlant = prefs.getString('selectedPlant');
      if (prefPlant != null && prefPlant.isNotEmpty) {
        _activeSelectedPlant = prefPlant;
      } else {
        _activeSelectedPlant = parameters.keys.firstWhere((k) => k != "Kustom", orElse: () => "Kustom");
      }
    }

    if (_isSeedKeyReady && _baseRef != null) {
      await _setupFirebaseListenersAndInitialLoad();
    } else {
      if (parameters.containsKey(_activeSelectedPlant)) {
        _activeParameters = Map.from(parameters[_activeSelectedPlant]!);
      } else { 
        _activeSelectedPlant = "Kustom";
        _activeParameters = Map.from(parameters["Kustom"]!);
      }
      _updateDisplayParametersFromActiveData();
      _initializeDraftParametersFromActive(); 
      _isLoading = false;
    }
    
    _isInitialized = true;

    if (hasListeners) notifyListeners();
  }
  
  Future<void> _setupFirebaseListenersAndInitialLoad() async {
    await _monitoringSubscription?.cancel(); _monitoringSubscription = null;
    await _parameterSubscription?.cancel(); _parameterSubscription = null;
    await _onDemandPhSubscription?.cancel(); _onDemandPhSubscription = null;

    final monitoringRef = _monitoringDataRef;
    final activeParameterRef = _activeParameterDataRef;
    final onDemandPhRef = _phResultRef;

    if (monitoringRef == null || activeParameterRef == null || onDemandPhRef == null) {
      if (kDebugMode) print("[HandlingProvider] Firebase refs not ready, using local defaults for active params.");

      if (parameters.containsKey(_activeSelectedPlant)) {
        _activeParameters = Map.from(parameters[_activeSelectedPlant]!);
      } else {
        _activeSelectedPlant = "Kustom";
        _activeParameters = Map.from(parameters["Kustom"]!);
      }
      _updateDisplayParametersFromActiveData();
      _initializeDraftParametersFromActive();
      if (_isLoading) _isLoading = false;
      if (hasListeners) notifyListeners();
      return;
    }

    bool initialMonitoringLoaded = false;
    bool initialParameterLoaded = false;

    void checkInitialLoadComplete() {
      if (initialMonitoringLoaded && initialParameterLoaded) {
        _initializeDraftParametersFromActive();
        if (_isLoading) {
          _isLoading = false;
          if (hasListeners) notifyListeners();
        }
      }
    }

    try {
      DatabaseEvent initialParameterEvent = await activeParameterRef.once().timeout(const Duration(seconds: 7));
      _handleActiveParameterData(initialParameterEvent);
    } catch (e) {
      if (kDebugMode) print("[HandlingProvider] Error loading initial active parameters from RTDB: $e. Using local based on _activeSelectedPlant: $_activeSelectedPlant");

      if (parameters.containsKey(_activeSelectedPlant)) {
        _activeParameters = Map.from(parameters[_activeSelectedPlant]!);
      } else {
        _activeSelectedPlant = "Kustom";
        _activeParameters = Map.from(parameters["Kustom"]!);
      }
      _updateDisplayParametersFromActiveData();
    } finally {
      initialParameterLoaded = true;
      checkInitialLoadComplete();
    }

    try {
      DatabaseEvent initialMonitoringEvent = await monitoringRef.once().timeout(const Duration(seconds: 7));
      _handleMonitoringData(initialMonitoringEvent);
    } catch (e) {
      _resetSensorValues();
    } finally {
      initialMonitoringLoaded = true;
      checkInitialLoadComplete();
    }

    _monitoringSubscription = monitoringRef.onValue.listen(_handleMonitoringData, onError: (e) => _handleListenerError("Monitoring", e));
    _parameterSubscription = activeParameterRef.onValue.listen(_handleActiveParameterData, onError: (e) => _handleListenerError("ActiveParameter", e));
    _onDemandPhSubscription = onDemandPhRef.onValue.listen(_handlePhResult, onError: (e) => _handleListenerError("OnDemandPHResult", e));
  }
  
  void _resetSensorValues() {
    humiLing = 0; tdsAir = 0; ecAir = 0.0; tinggiAir = 0.0; suhuAir = 0.0; suhuLing = 0.0;
  }

  void _handleActiveParameterData(DatabaseEvent event) {
    final dynamic data = event.snapshot.value;
    bool needsDisplayUpdate = false;

    if (data != null && data is Map && data.isNotEmpty) {
      Map<String, dynamic> paramsFromRTDB = Map.from(data);
      String determinedPlantType = _activeSelectedPlant;

      final String? rtdbTitle = paramsFromRTDB['title'] as String?;
      if (rtdbTitle != null && rtdbTitle.isNotEmpty) {
        if (parameters.containsKey(rtdbTitle)) {
          determinedPlantType = rtdbTitle;
        } else {
          bool hasKustomStructure = paramsFromRTDB.containsKey('jeda_siram') && paramsFromRTDB.containsKey('waktu_siram');
          if (hasKustomStructure) {
            determinedPlantType = "Kustom";
            Map<String,dynamic> tempKustom = Map.from(parameters["Kustom"]!);
            tempKustom.addAll(paramsFromRTDB);
            paramsFromRTDB = tempKustom;
          }
        }
      } else { 
        bool hasKustomStructure = paramsFromRTDB.containsKey('jeda_siram') && paramsFromRTDB.containsKey('waktu_siram');
        if (hasKustomStructure) {
          determinedPlantType = "Kustom";
          paramsFromRTDB['title'] = parameters['Kustom']!['title']; // Beri title default
          paramsFromRTDB.putIfAbsent('latin', () => parameters['Kustom']!['latin']);
          paramsFromRTDB.putIfAbsent('thumbnail', () => parameters['Kustom']!['thumbnail']);
        }
      }

      if (!mapEquals(_activeParameters, paramsFromRTDB) || _activeSelectedPlant != determinedPlantType) {
        _activeParameters = paramsFromRTDB;
        _activeSelectedPlant = determinedPlantType;
        needsDisplayUpdate = true;

        SharedPreferences.getInstance().then((prefs) => prefs.setString('selectedPlant', _activeSelectedPlant));
      }
    } else {
      if (kDebugMode) print("[HandlingProvider] Active parameter data from RTDB is null/empty. Using local for '$_activeSelectedPlant'.");
      Map<String,dynamic> fallbackParams;
      if (parameters.containsKey(_activeSelectedPlant)) {
        fallbackParams = Map.from(parameters[_activeSelectedPlant]!);
      } else {
        _activeSelectedPlant = "Kustom";
        fallbackParams = Map.from(parameters["Kustom"]!);
      }
      if (!mapEquals(_activeParameters, fallbackParams)){
        _activeParameters = fallbackParams;
        needsDisplayUpdate = true;
      }
    }

    if (needsDisplayUpdate) {
      _updateDisplayParametersFromActiveData();
    }
  }
  
  void _updateDisplayParametersFromActiveData() {
    if (_activeParameters.isEmpty && _activeSelectedPlant.isNotEmpty && parameters.containsKey(_activeSelectedPlant)) {

       _activeParameters = Map.from(parameters[_activeSelectedPlant]!);
    } else if (_activeParameters.isEmpty) {

      _activeParameters = Map.from(parameters["Kustom"]!);
      _activeSelectedPlant = "Kustom";
    }


    namaTanaman = (_activeParameters['title'] as String?) ?? (_activeSelectedPlant.isNotEmpty ? _activeSelectedPlant : 'Tanaman');
    namaLatin = (_activeParameters['latin'] as String?) ?? '...';
    gambar = (_activeParameters['thumbnail'] as String?) ?? 'assets/myicon/unknown.png';

    idealWaktuSiram = _parseToDouble(_activeParameters['waktu_siram']);
    idealJedaSiram = _parseToDouble(_activeParameters['jeda_siram']);
    idealSuhu = ((_parseToDouble(_activeParameters['min_suhuair']) + _parseToDouble(_activeParameters['max_suhuair'])) / 2);
    idealNutrisi = ((_parseToDouble(_activeParameters['min_tdsair']) + _parseToDouble(_activeParameters['max_tdsair'])) / 2);
    double minECVal = (_parseToDouble(_activeParameters['min_tdsair']) / 700.0);
    double maxECVal = (_parseToDouble(_activeParameters['max_tdsair']) / 700.0);
    idealEC = (minECVal + maxECVal) / 2;

    if (hasListeners) notifyListeners();
  }
  
  void _initializeDraftParametersFromActive() {
    if (_activeSelectedPlant.isNotEmpty) {
      _draftSelectedPlantForEditing = _activeSelectedPlant;
      _draftParametersForEditing = Map.from(_activeParameters.isNotEmpty ? _activeParameters : parameters[_activeSelectedPlant] ?? parameters["Kustom"]!);
    } else if (parameters.isNotEmpty) {
      _draftSelectedPlantForEditing = parameters.keys.first;
      _draftParametersForEditing = Map.from(parameters[_draftSelectedPlantForEditing]!);
    } else {
      _draftSelectedPlantForEditing = "Kustom";
      _draftParametersForEditing = Map.from(parameters["Kustom"]!);
    }
    if (kDebugMode) print("[HandlingProvider] Draft parameters initialized from active: $_draftSelectedPlantForEditing");
    if (hasListeners) notifyListeners(); 
  }

  void selectPlantForEditingPage(String plantNameFromDropdown) {
    _draftSelectedPlantForEditing = plantNameFromDropdown;

    if (plantNameFromDropdown == "Kustom") {

      _draftParametersForEditing = Map.from(_activeParameters.isNotEmpty ? _activeParameters : parameters["Kustom"]!);
      
      _draftParametersForEditing['title'] = parameters['Kustom']!['title']; // "Tanaman Lain"
      _draftParametersForEditing['latin'] = parameters['Kustom']!['latin']; // "Parameter Kustom"
      _draftParametersForEditing['thumbnail'] = parameters['Kustom']!['thumbnail'];
      if (kDebugMode) print("[HandlingProvider] Switched draft to Kustom, initialized from active params. Draft title: ${_draftParametersForEditing['title']}");

    } else if (parameters.containsKey(plantNameFromDropdown)) {
      _draftParametersForEditing = Map.from(parameters[plantNameFromDropdown]!);
       if (kDebugMode) print("[HandlingProvider] Switched draft to preset: $plantNameFromDropdown");
    } else {
      _draftSelectedPlantForEditing = parameters.keys.first;
      _draftParametersForEditing = Map.from(parameters[_draftSelectedPlantForEditing]!);
      if (kDebugMode) print("[HandlingProvider] Fallback draft to: $_draftSelectedPlantForEditing");
    }
    notifyListeners();
  }

  Future<bool> applyDraftPresetToActive(BuildContext context) async {
    if (_draftSelectedPlantForEditing == "Kustom" || !parameters.containsKey(_draftSelectedPlantForEditing)) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih preset yang valid untuk diterapkan.")));
      return false;
    }

    _activeParameters = Map.from(_draftParametersForEditing);
    _activeSelectedPlant = _draftSelectedPlantForEditing;

    bool firestoreSuccess = await _saveActiveSelectedPlantToFirestore(context);
    bool rtdbSuccess = false;
    if (firestoreSuccess) {
      rtdbSuccess = await _saveActiveParametersToRTDB(context: context);
    } else {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menyimpan pilihan tanaman ke server.")));
    }

    if (rtdbSuccess) {
      _updateDisplayParametersFromActiveData();
      if (kDebugMode) print("[HandlingProvider] Applied preset '$_activeSelectedPlant' to active and RTDB.");
    }
    return rtdbSuccess && firestoreSuccess;
  }


  Future<bool> applyCustomDraftToActive(BuildContext context, Map<String, dynamic> customParamsFromForm) async {
    _draftParametersForEditing = Map.from(parameters['Kustom']!);
    _draftParametersForEditing.addAll(customParamsFromForm);
    _draftSelectedPlantForEditing = "Kustom";


    _activeParameters = Map.from(_draftParametersForEditing);
    _activeSelectedPlant = "Kustom";

    bool firestoreSuccess = await _saveActiveSelectedPlantToFirestore(context);
    bool rtdbSuccess = false;
    if (firestoreSuccess) {
        rtdbSuccess = await _saveActiveParametersToRTDB(context: context, forceParams: _activeParameters);
    } else {
         if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menyimpan pilihan 'Kustom' ke server.")));
    }


    if (rtdbSuccess) {
      _updateDisplayParametersFromActiveData();
      if (kDebugMode) print("[HandlingProvider] Applied custom parameters (title: '${_activeParameters['title']}') to active and RTDB.");
    }
    return rtdbSuccess && firestoreSuccess;
  }

  Future<bool> _saveActiveSelectedPlantToFirestore(BuildContext context) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return false;
    if (_activeSelectedPlant.isEmpty) return false;

    return await AuthService.updateUserDocument(uid, {'selectedPlant': _activeSelectedPlant}, context);
  }

  Future<bool> _saveActiveParametersToRTDB({BuildContext? context, Map<String, dynamic>? forceParams}) async {
    if (!_isSeedKeyReady || _userSeedkey == null || _userSeedkey!.isEmpty || _activeParameterDataRef == null) {
      if (context?.mounted ?? false) ScaffoldMessenger.of(context!).showSnackBar(const SnackBar(content: Text("SeedKey/Referensi DB belum siap.")));
      return false;
    }

    Map<String, dynamic> paramsToSave = forceParams ?? _activeParameters;

    if (paramsToSave.isEmpty) {
      if (context?.mounted ?? false) ScaffoldMessenger.of(context!).showSnackBar(const SnackBar(content: Text("Tidak ada parameter untuk disimpan.")));
      return false;
    }
    
    String plantKeyForMeta = _activeSelectedPlant;
    if (_activeSelectedPlant == "Kustom" && (forceParams != null || paramsToSave['title'] == parameters['Kustom']!['title'])) {
        plantKeyForMeta = "Kustom";
    } else if (!parameters.containsKey(_activeSelectedPlant)) {
        plantKeyForMeta = "Kustom";
    }

    paramsToSave.putIfAbsent('title', () => parameters[plantKeyForMeta]!['title']);
    paramsToSave.putIfAbsent('latin', () => parameters[plantKeyForMeta]!['latin']);
    paramsToSave.putIfAbsent('thumbnail', () => parameters[plantKeyForMeta]!['thumbnail']);


    try {
      await _activeParameterDataRef!.set(paramsToSave);
      if (kDebugMode) print("[HandlingProvider] Parameters for '${paramsToSave['title']}' saved to RTDB.");
      if (context?.mounted ?? false) {
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text("Parameter untuk '${paramsToSave['title']}' berhasil diupdate ke sistem."),
          backgroundColor: Colors.green,
        ));
      }
      return true;
    } catch (e) {
      if (kDebugMode) print("[HandlingProvider] Failed to save parameters to RTDB: $e");
      if (context?.mounted ?? false) {
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(content: Text("Gagal update parameter ke RTDB: ${e.toString()}")));
      }
      return false;
    }
  }

  void _handleListenerError(String listenerName, Object error) {
    if (kDebugMode) print("[$runtimeType] Firebase Listener Error ($listenerName): $error");
    if (listenerName == "OnDemandPHResult") {
      phMeasurementError = "Gagal membaca hasil pH. Coba lagi.";
      isPhMeasuring = false;
    }
    if (listenerName == "ActiveParameter" && (_activeParameters.isEmpty || _activeSelectedPlant.isEmpty)) {
        String plantToUse = _activeSelectedPlant.isNotEmpty && parameters.containsKey(_activeSelectedPlant) ? _activeSelectedPlant : parameters.keys.first;
        _activeSelectedPlant = plantToUse;
        _activeParameters = Map.from(parameters[plantToUse]!);
        _updateDisplayParametersFromActiveData();
        _initializeDraftParametersFromActive();
    }
    if(hasListeners) notifyListeners();
  }

  double _parseToDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
  int _parseToInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  void _handleMonitoringData(DatabaseEvent event) {
    final dynamic data = event.snapshot.value;
    if (data == null || data is! Map) {
      _resetSensorValues();
    } else {
      ecAir = _parseToDouble(data['ec_air']);
      tdsAir = _parseToInt(data['tds_air']);
      tinggiAir = _parseToDouble(data['tinggi_air']);
      suhuAir = _parseToDouble(data['suhu_air']);
      suhuLing = _parseToDouble(data['suhu_ling']);
      humiLing = _parseToInt(data['humi_ling']);
    }
    if (hasListeners) notifyListeners();
  }
  
  void _handlePhResult(DatabaseEvent event) {
    final dynamic data = event.snapshot.value;
    if (data !=null && data is Map) {
      final resultData = Map<String, dynamic>.from(data);
      onDemandPhValue = _parseToDouble(resultData['ph_val']);
      phMeasurementError = null;
    } else if (data == null) {
      // Keep current onDemandPhValue
    } else {
        phMeasurementError = "Format hasil pH tidak valid.";
    }
    isPhMeasuring = false;
    if(hasListeners) notifyListeners();
  }

  Future<void> requestPhMeasurement(BuildContext context) async {
    if (!_isSeedKeyReady || _phRequestRef == null) {
      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sistem belum siap untuk pengukuran pH."),
          backgroundColor: Colors.orange),
        );
      }
      return;
    }
    if (isPhMeasuring) {
        if(context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Pengukuran pH sedang berlangsung..."), backgroundColor: Colors.blueAccent),
          );
        }
        return;
    }

    try {
      isPhMeasuring = true;
      onDemandPhValue = null;
      phMeasurementError = null;
      if(hasListeners) notifyListeners();

      await _phRequestRef!.set(true);
       if(context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Permintaan pengukuran pH terkirim. Mohon tunggu..."), backgroundColor: Colors.green),
          );
       }
    } catch (e) {
      phMeasurementError = "Gagal mengirim permintaan pH: ${e.toString()}";
      isPhMeasuring = false;
      if(hasListeners) notifyListeners();
      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(phMeasurementError!), backgroundColor: Colors.redAccent),
        );
      }
    }
  }
  
   Future<void> updateUserSeedKey(String seedKey) async {
    final newSeedKeyValue = seedKey.isNotEmpty ? seedKey : null;
    
    if (_userSeedkey == newSeedKeyValue) return;
   
    await _monitoringSubscription?.cancel(); _monitoringSubscription = null;
    await _parameterSubscription?.cancel(); _parameterSubscription = null;
    await _onDemandPhSubscription?.cancel(); _onDemandPhSubscription = null;

    _userSeedkey = newSeedKeyValue;
    _isSeedKeyReady = newSeedKeyValue != null && newSeedKeyValue.isNotEmpty;
    
    _isLoading = true;
    _isInitialized = false; 
    if(hasListeners) notifyListeners();

    await _initializeProviderStates();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _monitoringSubscription?.cancel();
    _parameterSubscription?.cancel();
    _onDemandPhSubscription?.cancel();
    super.dispose();
  }
}