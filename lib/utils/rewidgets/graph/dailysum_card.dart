import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seedina/utils/style/gcolor.dart'; // Pastikan path ini benar untuk GColors Anda

class DailySummaryCard extends StatelessWidget {
  final Map<String, dynamic> summaryData;
  final DateTime date;

  const DailySummaryCard({
    super.key,
    required this.summaryData,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    if (summaryData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GColors.myBiru.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GColors.myKuning.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Ringkasan Harian (${DateFormat('dd MMM yyyy', 'id_ID').format(date)}):",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: GColors.myKuning,
                fontSize: 14),
          ),
          const SizedBox(height: 6),
          _buildSummaryRow("EC Air Rata-rata", summaryData['avg_daily_ec_air']?.toStringAsFixed(1) ?? '-'),
          _buildSummaryRow("TDS Air Rata-rata", "${summaryData['avg_daily_tds_air']?.toStringAsFixed(0) ?? '-'} ppm"),
          _buildSummaryRow("Tinggi Air Rata-rata", "${summaryData['avg_daily_tinggi_air']?.toStringAsFixed(1) ?? '-'} cm"),
          _buildSummaryRow("Suhu Air Rata-rata", "${summaryData['avg_daily_suhu_air']?.toStringAsFixed(1) ?? '-'}°C"),
          _buildSummaryRow("Suhu Air Minimal", "${summaryData['min_daily_suhu_air']?.toStringAsFixed(1) ?? '-'}°C"),
          _buildSummaryRow("Suhu Air Maksimal", "${summaryData['max_daily_suhu_air']?.toStringAsFixed(1) ?? '-'}°C"),
          _buildSummaryRow("Suhu Lingk. Rata-rata", "${summaryData['avg_daily_suhu_ling']?.toStringAsFixed(1) ?? '-'}°C"),
          _buildSummaryRow("Suhu Lingk. Minimal", "${summaryData['min_daily_suhu_ling']?.toStringAsFixed(1) ?? '-'}°C"),
          _buildSummaryRow("Suhu Lingk. Maksimal", "${summaryData['max_daily_suhu_ling']?.toStringAsFixed(1) ?? '-'}°C"),
          _buildSummaryRow("Kelembaban Rata-rata", "${summaryData['avg_daily_humi_ling']?.toStringAsFixed(1) ?? '-'}%"),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("  $label:", style: TextStyle(fontSize: 11, color: GColors.myKuning)),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GColors.myKuning)),
        ],
      ),
    );
  }
}