import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class ChartsDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> _defaultIntervalKeys = const [
    "00:00-03:00", "03:00-06:00", "06:00-09:00", "09:00-12:00",
    "12:00-15:00", "15:00-18:00", "18:00-21:00", "21:00-24:00"
  ];

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Future<Map<String, List<num>>> fetchChartIntervalData({
    required DateTime dateToFetch,
    required String? seedKey,
    required String laporanHarianCollectionName,
  }) async {
    if (seedKey == null || seedKey.isEmpty) {
      throw Exception('SeedKey tidak valid atau tidak ditemukan saat mengambil data grafik.');
    }

    Map<String, List<num>> chartData = {
      'ec': List.filled(_defaultIntervalKeys.length, 0.0),
      'tds': List.filled(_defaultIntervalKeys.length, 0.0),
      'tinggiAir': List.filled(_defaultIntervalKeys.length, 0.0),
      'suhuAir': List.filled(_defaultIntervalKeys.length, 0.0),
      'suhuLing': List.filled(_defaultIntervalKeys.length, 0.0),
      'humiLing': List.filled(_defaultIntervalKeys.length, 0.0),
    };

    DocumentSnapshot snapshot;
    bool rcFetchingToday = _isToday(dateToFetch);

    try {
      if (rcFetchingToday) {
        snapshot = await _firestore.collection('seedKeys').doc(seedKey).get();
      } else {
        String dateString = DateFormat('yyyy-MM-dd').format(dateToFetch);
        snapshot = await _firestore.collection(laporanHarianCollectionName).doc(dateString).get();
      }

      if (snapshot.exists) {
        final Object? snapshotDataObject = snapshot.data();
        if (snapshotDataObject != null && snapshotDataObject is Map<String, dynamic>) {
          final Map<String, dynamic> data = snapshotDataObject;

          for (int i = 0; i < _defaultIntervalKeys.length; i++) {
            String intervalKey = _defaultIntervalKeys[i];
            String firestoreIntervalKey = rcFetchingToday ? intervalKey : "interval_$intervalKey";

            if (data.containsKey(firestoreIntervalKey) && data[firestoreIntervalKey] is Map) {
              final intervalMap = data[firestoreIntervalKey] as Map<String, dynamic>;

              chartData['ec']![i] = (intervalMap['avg_ec_air'] ?? 0.0).toDouble();
              chartData['tds']![i] = (intervalMap['avg_tds_air'] ?? 0.0).toDouble();
              chartData['tinggiAir']![i] = (intervalMap['avg_tinggi_air'] ?? 0.0).toDouble();
              chartData['suhuAir']![i] = (intervalMap['avg_suhu_air'] ?? 0.0).toDouble();
              chartData['suhuLing']![i] = (intervalMap['avg_suhu_ling'] ?? 0.0).toDouble();
              chartData['humiLing']![i] = (intervalMap['avg_humi_ling'] ?? 0.0).toDouble();
            }
          }
        } else {
          if (kDebugMode) {
            print(rcFetchingToday
              ? 'Servis: Format data pada seedKeys/$seedKey tidak valid untuk hari ini.'
              : 'Servis: Format data pada $laporanHarianCollectionName/${DateFormat('yyyy-MM-dd').format(dateToFetch)} tidak valid.');
          }
        }
      } else {
        if (kDebugMode) {
          print(rcFetchingToday
            ? 'Servis: Dokumen seedKeys/$seedKey tidak ditemukan untuk hari ini.'
            : 'Servis: Dokumen $laporanHarianCollectionName/${DateFormat('yyyy-MM-dd').format(dateToFetch)} tidak ditemukan.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Servis: Error mengambil data interval grafik untuk $dateToFetch: $e");
      }
    }
    return chartData;
  }

  Future<Map<String, dynamic>?> fetchDailySummary({
    required DateTime dateToFetch,
    required String laporanHarianCollectionName,
  }) async {
    if (_isToday(dateToFetch)) {
      return null;
    }

    String dateString = DateFormat('yyyy-MM-dd').format(dateToFetch);
    try {
      final docSnap = await _firestore
          .collection(laporanHarianCollectionName)
          .doc(dateString)
          .get();

      if (docSnap.exists) {
        final Object? snapshotDataObject = docSnap.data();
        if (snapshotDataObject != null && snapshotDataObject is Map<String, dynamic>) {
          final Map<String, dynamic> data = snapshotDataObject;
          if (data.containsKey('ringkasan') && data['ringkasan'] is Map<String, dynamic>) {
            return data['ringkasan'] as Map<String, dynamic>;
          } else {
            if (kDebugMode) {
              print("Servis: Field 'ringkasan' tidak ditemukan atau bukan map di $laporanHarianCollectionName/$dateString");
            }
          }
        } else {
           if (kDebugMode) {
             print("Servis: Format data pada $laporanHarianCollectionName/$dateString tidak valid untuk ringkasan.");
           }
        }
      } else {
        if (kDebugMode) {
          print("Servis: Dokumen $laporanHarianCollectionName/$dateString tidak ditemukan untuk ringkasan.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Servis: Error mengambil ringkasan harian untuk $dateString: $e");
      }
    }
    return null;
  }
}