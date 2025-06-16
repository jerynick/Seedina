import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class SpreadsheetService {
  String _escapeCsvField(String field, String delimiter) {
    if (field.contains(delimiter) || field.contains('"') || field.contains('\n') || field.contains('\r')) {
      String escapedField = field.replaceAll('"', '""');
      return '"$escapedField"';
    }
    return field;
  }

  String manualConvertToCsvString(List<List<dynamic>> rows, {String fieldDelimiter = ';', String eol = '\r\n'}) {
    StringBuffer sb = StringBuffer();
    for (var row in rows) {
      List<String> stringRow = [];
      for (var item in row) {
        stringRow.add(_escapeCsvField(item?.toString() ?? '', fieldDelimiter));
      }
      sb.write(stringRow.join(fieldDelimiter));
      sb.write(eol);
    }
    return sb.toString();
  }

  List<List<dynamic>> prepareCsvRows({
    required List<String> intervalKeys,
    required List<num> ecData,
    required List<num> tdsData,
    required List<num> tinggiAirData,
    required List<num> suhuAirData,
    required List<num> suhuLingData,
    required List<num> humiLingData,
    Map<String, dynamic>? dailySummary,
    required DateTime selectedDate,
  }) {
    List<List<dynamic>> rows = [];

    rows.add(["Laporan Data Sensor Aplikasi SeedIna"]);
    rows.add(["Tanggal Data:", DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(selectedDate)]);
    rows.add([]); 

    rows.add([
      "Interval Waktu",
      "EC Air (mS/cm) (Rata-rata)",
      "TDS Air (ppm) (Rata-rata)",
      "Tinggi Air (cm) (Rata-rata)",
      "Suhu Air (°C) (Rata-rata)",
      "Suhu Lingkungan (°C) (Rata-rata)",
      "Kelembaban Udara (%) (Rata-rata)"
    ]);

    for (int i = 0; i < intervalKeys.length; i++) {
      rows.add([
        intervalKeys[i],
        ecData.length > i && ecData[i] != 0.0 ? ecData[i].toStringAsFixed(2) : 'N/A',
        tdsData.length > i && tdsData[i] != 0 ? tdsData[i].toStringAsFixed(0) : 'N/A',
        tinggiAirData.length > i && tinggiAirData[i] != 0.0 ? tinggiAirData[i].toStringAsFixed(1) : 'N/A',
        suhuAirData.length > i && suhuAirData[i] != 0.0 ? suhuAirData[i].toStringAsFixed(1) : 'N/A',
        suhuLingData.length > i && suhuLingData[i] != 0.0 ? suhuLingData[i].toStringAsFixed(1) : 'N/A',
        humiLingData.length > i && humiLingData[i] != 0.0 ? humiLingData[i].toStringAsFixed(1) : 'N/A',
      ]);
    }

    if (dailySummary != null && dailySummary.isNotEmpty) {
      rows.add([]); 
      rows.add(["Ringkasan Harian (${DateFormat('dd MMM yyyy', 'id_ID').format(selectedDate)})"]);
      rows.add([]); 
      
      void addSummaryRow(String label, dynamic value, {int decimalPlaces = 1, String unit = ""}) {
         String valueString = 'N/A';
         if (value != null && value is num) {
            valueString = value.toStringAsFixed(decimalPlaces) + unit;
         } else if (value != null) {
            valueString = value.toString() + unit;
         }
        rows.add([label, valueString]);
      }
      
      addSummaryRow("Rata-rata EC Air Harian", dailySummary['avg_daily_ec_air']);
      addSummaryRow("Rata-rata TDS Air Harian", dailySummary['avg_daily_tds_air'], decimalPlaces: 0, unit: " ppm");
      addSummaryRow("Rata-rata Tinggi Air Harian", dailySummary['avg_daily_tinggi_air'], unit: " cm");
      addSummaryRow("Rata-rata Suhu Air Harian", dailySummary['avg_daily_suhu_air'], unit: " °C");
      addSummaryRow("Min Suhu Air Harian", dailySummary['min_daily_suhu_air'], unit: " °C");
      addSummaryRow("Maks Suhu Air Harian", dailySummary['max_daily_suhu_air'], unit: " °C");
      addSummaryRow("Rata-rata Suhu Lingkungan Harian", dailySummary['avg_daily_suhu_ling'], unit: " °C");
      addSummaryRow("Min Suhu Lingkungan Harian", dailySummary['min_daily_suhu_ling'], unit: " °C");
      addSummaryRow("Maks Suhu Lingkungan Harian", dailySummary['max_daily_suhu_ling'], unit: " °C");
      addSummaryRow("Rata-rata Kelembaban Harian", dailySummary['avg_daily_humi_ling'], unit: " %");
    }
    return rows;
  }

  Future<void> createAndOpenCsvFile({
    required List<List<dynamic>> csvRows,
    required DateTime selectedDate,
    required BuildContext context,
    String fieldDelimiter = ';', 
    String eol = '\r\n' 
  }) async {
    String finalFilePath;
    try {
      final String csvString = manualConvertToCsvString(csvRows, fieldDelimiter: fieldDelimiter, eol: eol);

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'SeedIna_Data_${DateFormat('yyyyMMdd').format(selectedDate)}_${DateFormat('HHmmss').format(DateTime.now())}.csv';
      finalFilePath = '${directory.path}/$fileName';
      final file = File(finalFilePath);

      await file.writeAsString(csvString);
      print('Servis: File CSV disimpan di: $finalFilePath');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Spreadsheet CSV dibuat: $fileName'),
            action: SnackBarAction(
              label: 'Buka',
              onPressed: () {
                OpenFilex.open(finalFilePath);
              },
            ),
            duration: const Duration(seconds: 7),
          ),
        );
      }

      final result = await OpenFilex.open(finalFilePath);

      if (result.type != ResultType.done) {
        print('Servis: Gagal membuka file secara otomatis: ${result.message}');
        if (context.mounted && result.type != ResultType.permissionDenied) {
           if (!ScaffoldMessenger.of(context).mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('Gagal membuka spreadsheet: ${result.message}. Coba buka manual.')),
            );
        }
      } else {
        print('Servis: File CSV berhasil dibuka atau perintah buka dikirim.');
      }

    } catch (e) {
      print('Servis: Error saat membuat atau membuka file CSV: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memproses spreadsheet: ${e.toString()}')),
        );
      }
    }
  }
}