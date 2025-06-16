import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:seedina/provider/rtdb_handler.dart';
import 'package:seedina/services/chartdata_service.dart';
import 'package:seedina/services/spreadsheet_service.dart';
import 'package:seedina/utils/rewidgets/contentbox/for_charts/chart_box.dart';
import 'package:seedina/utils/rewidgets/global/myappbar.dart';
import 'package:seedina/utils/rewidgets/graph/dailysum_card.dart';
import 'package:seedina/utils/style/gcolor.dart';

class MainCharts extends StatefulWidget {
  const MainCharts({super.key});

  @override
  State<MainCharts> createState() => _MainChartState();
}

class _MainChartState extends State<MainCharts> {
  final ChartsDataService _chartsService = ChartsDataService();
  final SpreadsheetService _spreadsheetService = SpreadsheetService();

  bool _isLoading = true;
  String _errorMessage = '';
  DateTime _selectedDate = DateTime.now();

  List<num> _ecData = List.filled(8, 0.0);
  List<num> _tdsData = List.filled(8, 0.0);
  List<num> _tinggiAirData = List.filled(8, 0.0);
  List<num> _suhuAirData = List.filled(8, 0.0);
  List<num> _suhuLingData = List.filled(8, 0.0);
  List<num> _humiLingData = List.filled(8, 0.0);
  Map<String, dynamic>? _dailySummaryData;

  final List<String> _intervalKeys = const [
    "00:00-03:00", "03:00-06:00", "06:00-09:00", "09:00-12:00",
    "12:00-15:00", "15:00-18:00", "18:00-21:00", "21:00-24:00"
  ];
  final String _laporanHarianCollectionName = "laporanHarianAeroponic_U10325P1";

  @override
  void initState() {
    super.initState();
    _loadDataForSelectedDate();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Future<void> _loadDataForSelectedDate() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _dailySummaryData = null;
      _ecData = List.filled(8, 0.0);
      _tdsData = List.filled(8, 0.0);
      _tinggiAirData = List.filled(8, 0.0);
      _suhuAirData = List.filled(8, 0.0);
      _suhuLingData = List.filled(8, 0.0);
      _humiLingData = List.filled(8, 0.0);
    });

    try {
      final handlingProvider = Provider.of<HandlingProvider>(context, listen: false);
      final String? seedKey = handlingProvider.currentUserSeedKey;

      final fetchedIntervalData = await _chartsService.fetchChartIntervalData(
        dateToFetch: _selectedDate,
        seedKey: seedKey,
        laporanHarianCollectionName: _laporanHarianCollectionName,
      );

      _ecData = fetchedIntervalData['ec'] ?? List.filled(8, 0.0);
      _tdsData = fetchedIntervalData['tds'] ?? List.filled(8, 0.0);
      _tinggiAirData = fetchedIntervalData['tinggiAir'] ?? List.filled(8, 0.0);
      _suhuAirData = fetchedIntervalData['suhuAir'] ?? List.filled(8, 0.0);
      _suhuLingData = fetchedIntervalData['suhuLing'] ?? List.filled(8, 0.0);
      _humiLingData = fetchedIntervalData['humiLing'] ?? List.filled(8, 0.0);

      if (!_isToday(_selectedDate)) {
        _dailySummaryData = await _chartsService.fetchDailySummary(
          dateToFetch: _selectedDate,
          laporanHarianCollectionName: _laporanHarianCollectionName,
        );
      }

      bool hasAnyValidData = _ecData.any((d) => d != 0.0) ||
                              _tdsData.any((d) => d != 0.0) ||
                              _tinggiAirData.any((d) => d != 0.0) ||
                              _suhuAirData.any((d) => d != 0.0) ||
                              _suhuLingData.any((d) => d != 0.0) ||
                              _humiLingData.any((d) => d != 0.0);

      if (!hasAnyValidData && (_dailySummaryData == null || _dailySummaryData!.isEmpty)) {
        _errorMessage = _isToday(_selectedDate)
            ? 'Data untuk hari ini belum tersedia.'
            : 'Tidak ada laporan untuk tanggal ${DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate)}. Pastikan ESP32 menyimpan laporan dengan ID "YYYY-MM-DD".';
      }

    } catch (e) {
      print('UI Error di _loadDataForSelectedDate: $e');
      _errorMessage = 'Gagal memuat data: ${e.toString().length > 70 ? e.toString().substring(0,70)+"..." : e.toString()}';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null && picked != _selectedDate) {
      if (mounted) {
        setState(() {
          _selectedDate = picked;
        });
        _loadDataForSelectedDate();
      }
    }
  }

  Future<void> _generateAndOpenSpreadsheet() async {
    if (_isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap tunggu, data sedang dimuat.')),
      );
      return;
    }
    bool hasAnyValidData = _ecData.any((d) => d != 0.0) ||
                            _tdsData.any((d) => d != 0.0) ||
                            _tinggiAirData.any((d) => d != 0.0) ||
                            _suhuAirData.any((d) => d != 0.0) ||
                            _suhuLingData.any((d) => d != 0.0) ||
                            _humiLingData.any((d) => d != 0.0);

    if (!hasAnyValidData && (_dailySummaryData == null || _dailySummaryData!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage.isNotEmpty && _errorMessage.startsWith("Tidak ada laporan") ? _errorMessage : 'Tidak ada data valid untuk dibuat spreadsheet.')),
      );
      return;
    }

    final rows = _spreadsheetService.prepareCsvRows(
      intervalKeys: _intervalKeys,
      ecData: _ecData,
      tdsData: _tdsData,
      tinggiAirData: _tinggiAirData,
      suhuAirData: _suhuAirData,
      suhuLingData: _suhuLingData,
      humiLingData: _humiLingData,
      dailySummary: _dailySummaryData,
      selectedDate: _selectedDate,
    );

    await _spreadsheetService.createAndOpenCsvFile(
      csvRows: rows,
      selectedDate: _selectedDate,
      context: context,
      fieldDelimiter: ';', // Menggunakan titik koma (;) sebagai delimiter
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GColors.myHijau,
      appBar: CustomAppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Grafik Data Sensor',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Quicksand',
                  color: GColors.myKuning),
            ),
            Text(
              DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_selectedDate),
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: GColors.myKuning.withOpacity(0.85)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: GColors.myKuning, size: 22),
            onPressed: _isLoading ? null : () => _selectDate(context),
            tooltip: 'Pilih Tanggal',
          ),
          IconButton(
            icon: Icon(Icons.table_chart_outlined, color: GColors.myKuning, size: 24),
            onPressed: _isLoading ? null : _generateAndOpenSpreadsheet,
            tooltip: 'Buka Data sebagai Spreadsheet (CSV)',
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: GColors.myKuning, size: 24),
            onPressed: _isLoading ? null : _loadDataForSelectedDate,
            tooltip: 'Muat Ulang Data',
          ),
        ],
        showBackButton: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: GColors.myKuning))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade300, size: 40),
                        const SizedBox(height: 15),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red.shade300, fontSize: 15),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Coba Lagi'),
                          onPressed: _loadDataForSelectedDate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GColors.myKuning,
                            foregroundColor: GColors.myBiru,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    if (_dailySummaryData != null && _dailySummaryData!.isNotEmpty)
                      DailySummaryCard(summaryData: _dailySummaryData!, date: _selectedDate),
                    Expanded(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: (_dailySummaryData != null && _dailySummaryData!.isNotEmpty)
                            ? const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))
                            : BorderRadius.circular(16),
                        ),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                if (_isToday(_selectedDate) && (_dailySummaryData == null || _dailySummaryData!.isEmpty))
                                  const SizedBox(height: 8),
                                BarGraphBox(
                                  title: 'Grafik Data TDS Air (ppm)', maxDataGraph: 2000,
                                  dataPertama: _tdsData[0], dataKedua: _tdsData[1], dataKetiga: _tdsData[2], dataKeempat: _tdsData[3],
                                  dataKelima: _tdsData[4], dataKeenam: _tdsData[5], dataKetujuh: _tdsData[6], dataKedelapan: _tdsData[7],
                                  graphColor: GColors.tdsGraphColor,
                                  description: "Rata-rata TDS Air (ppm) per 3 jam (${DateFormat('dd MMM yy', 'id_ID').format(_selectedDate)})",
                                ),
                                BarGraphBox(
                                  title: 'Grafik Data Tinggi Air (cm)', maxDataGraph: 50,
                                  dataPertama: _tinggiAirData[0], dataKedua: _tinggiAirData[1], dataKetiga: _tinggiAirData[2], dataKeempat: _tinggiAirData[3],
                                  dataKelima: _tinggiAirData[4], dataKeenam: _tinggiAirData[5], dataKetujuh: _tinggiAirData[6], dataKedelapan: _tinggiAirData[7],
                                  graphColor: GColors.waterHeightGraphColor,
                                  description: "Rata-rata Tinggi Air (cm) per 3 jam (${DateFormat('dd MMM yy', 'id_ID').format(_selectedDate)})",
                                ),
                                BarGraphBox(
                                  title: 'Grafik Data Suhu Air (°C)', maxDataGraph: 40,
                                  dataPertama: _suhuAirData[0], dataKedua: _suhuAirData[1], dataKetiga: _suhuAirData[2], dataKeempat: _suhuAirData[3],
                                  dataKelima: _suhuAirData[4], dataKeenam: _suhuAirData[5], dataKetujuh: _suhuAirData[6], dataKedelapan: _suhuAirData[7],
                                  graphColor: GColors.waterTempGraphColor,
                                  description: "Rata-rata Suhu Air (°C) per 3 jam (${DateFormat('dd MMM yy', 'id_ID').format(_selectedDate)})",
                                ),
                                BarGraphBox(
                                  title: 'Grafik Data Suhu Lingk. (°C)', maxDataGraph: 50,
                                  dataPertama: _suhuLingData[0], dataKedua: _suhuLingData[1], dataKetiga: _suhuLingData[2], dataKeempat: _suhuLingData[3],
                                  dataKelima: _suhuLingData[4], dataKeenam: _suhuLingData[5], dataKetujuh: _suhuLingData[6], dataKedelapan: _suhuLingData[7],
                                  graphColor: GColors.tempGraphColor,
                                  description: "Rata-rata Suhu Lingk. (°C) per 3 jam (${DateFormat('dd MMM yy', 'id_ID').format(_selectedDate)})",
                                ),
                                BarGraphBox(
                                  title: 'Grafik Data Kelembaban Udara (%)', maxDataGraph: 100,
                                  dataPertama: _humiLingData[0], dataKedua: _humiLingData[1], dataKetiga: _humiLingData[2], dataKeempat: _humiLingData[3],
                                  dataKelima: _humiLingData[4], dataKeenam: _humiLingData[5], dataKetujuh: _humiLingData[6], dataKedelapan: _humiLingData[7],
                                  graphColor: GColors.humiGraphColor,
                                  description: "Rata-rata Kelembaban Udara (%) per 3 jam (${DateFormat('dd MMM yy', 'id_ID').format(_selectedDate)})",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
    );
  }
}