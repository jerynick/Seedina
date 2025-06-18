import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seedina/provider/rtdb_handler.dart';
import 'package:seedina/utils/rewidgets/contentbox/for_monitoring/infocolumn.dart'; // Pastikan path ini benar jika digunakan
import 'package:seedina/utils/style/gcolor.dart';

class PresetParamSetup extends StatefulWidget {
  const PresetParamSetup({super.key});
  @override
  State<PresetParamSetup> createState() => _PresetParamSetupState();
}

class _PresetParamSetupState extends State<PresetParamSetup> {
  bool _isSaving = false;

  Future<void> _applyAndFinish(BuildContext context) async {
    if (!mounted) return;
    setState(() => _isSaving = true);

    final provider = Provider.of<HandlingProvider>(context, listen: false);

    // Validasi dilakukan terhadap DRAFT yang dipilih
    if (provider.draftSelectedPlantForEditing.isEmpty || provider.draftSelectedPlantForEditing == "Kustom") {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih tanaman preset yang valid untuk diterapkan.')),
        );
      }
      setState(() => _isSaving = false);
      return;
    }
    
    bool success = await provider.applyDraftPresetToActive(context);

    if (mounted) {
      if (success) {
        Navigator.of(context).pushNamedAndRemoveUntil('/wifiSetup', (route) => false);
      }
      setState(() => _isSaving = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<HandlingProvider>(
      builder: (context, provider, child) {
        final String currentDraftPlant = provider.draftSelectedPlantForEditing;
        final Map<String, dynamic> currentDraftParams = provider.draftParametersForEditing;
        if (currentDraftPlant.isEmpty || 
            currentDraftPlant == "Kustom" || 
            currentDraftParams.isEmpty ||
            !provider.parameters.containsKey(currentDraftPlant)) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
            alignment: Alignment.center,
            child: Text(
              "Pilih tanaman preset dari daftar di atas untuk melihat detail dan melanjutkan.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontStyle: FontStyle.italic, fontSize: 14),
            ),
          );
        }
        
        // Ambil info dari DRAFT parameters
        final plantInfoToDisplay = provider.draftPlantInfoForEditingPage; 
        // Nilai ideal juga dari getter draft
        final String idealECDisplay = provider.idealECForEditingPage.toStringAsFixed(1);
        final String idealNutrisiDisplay = provider.idealNutrisiForEditingPage.toStringAsFixed(1);
        final String idealSuhuAirDisplay = provider.idealSuhuForEditingPage.toStringAsFixed(1);
        final String idealWaktuSiramDisplay = provider.idealWaktuSiramForEditingPage.toStringAsFixed(1);


        return Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration( 
            borderRadius: BorderRadius.circular(16),
            color: Colors.white70,
            boxShadow: [
              BoxShadow(
                color: GColors.shadowColor,
                blurRadius: 4,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.asset(plantInfoToDisplay['thumbnail'] ?? 'assets/myicon/unknown.png'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plantInfoToDisplay['title'] ?? 'Tanaman Preset',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            plantInfoToDisplay['latin'] ?? '...',
                            style: const TextStyle(
                                fontSize: 8, fontStyle: FontStyle.italic),
                             overflow: TextOverflow.ellipsis,
                             maxLines: 2,
                          )
                        ],
                      ),
                    )
                  ],
                ),
                const Divider(), //: Divider
                const SizedBox(height: 10), //: SizedBox
                Column( //: Kolom untuk parameter InfoColumn
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: InfoColumn( // Menggunakan InfoColumn seperti di UI lama
                            title: 'Waktu Siram',
                            fontSize: 16,
                            space: 8,
                            value: '$idealWaktuSiramDisplay Menit',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InfoColumn(
                            title: 'Suhu Ideal',
                            fontSize: 16,
                            space: 8,
                            value: '$idealSuhuAirDisplay °C',
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: InfoColumn(
                            title: 'EC Ideal',
                            fontSize: 16,
                            space: 8,
                            value: '$idealECDisplay mS/cm',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InfoColumn(
                            title: 'Nutrisi Ideal',
                            fontSize: 16,
                            space: 8,
                            value: '$idealNutrisiDisplay ppm',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(), //: Divider
                ElevatedButton( //: Tombol
                  onPressed: _isSaving ? null : () => _applyAndFinish(context),
                  style: ElevatedButton.styleFrom( // Mengembalikan style tombol dari UI lama jika ada, atau default ini
                    backgroundColor: GColors.myBiru, // Sesuaikan dengan UI lama
                    foregroundColor: Colors.white,    // Sesuaikan dengan UI lama
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white, // Sesuaikan dengan UI lama
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Row( // Teks dan ikon tombol UI lama
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline), // Sesuaikan ikon UI lama
                            SizedBox(width: 8),
                            Text("Terapkan & Selesai") // Teks tombol UI lama
                          ],
                        ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}