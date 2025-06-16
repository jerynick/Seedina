import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seedina/provider/rtdb_handler.dart';
import 'package:seedina/utils/rewidgets/contentbox/for_monitoring/infocolumn.dart';
import 'package:seedina/utils/style/gcolor.dart';
import 'package:flutter/foundation.dart';

class PresetParameter extends StatefulWidget {
  const PresetParameter({
    super.key,
  });

  @override
  State<PresetParameter> createState() => _PresetParameterState();
}

class _PresetParameterState extends State<PresetParameter> {
  bool _isSaving = false;

  Future<void> _applyAndSaveChanges(BuildContext context) async {
    if (!mounted) return;
    setState(() => _isSaving = true);

    final provider = Provider.of<HandlingProvider>(context, listen: false);
    bool success = await provider.applyDraftPresetToActive(context);

    if (mounted) {
      setState(() => _isSaving = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HandlingProvider>(context);

    // Kondisi untuk menampilkan loading atau pesan jika draft tidak siap
    if (provider.isLoading && provider.draftSelectedPlantForEditing.isEmpty) {
        return Center(child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ));
    }
    if (provider.draftSelectedPlantForEditing.isEmpty || 
        provider.draftSelectedPlantForEditing == "Kustom" || // PresetParameter bukan untuk Kustom
        provider.draftParametersForEditing.isEmpty ||
        !provider.parameters.containsKey(provider.draftSelectedPlantForEditing) ) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text("Pilih tanaman preset dari dropdown.", style: TextStyle(color: Colors.grey.shade700)),
      ));
    }
    
    final plantInfoToDisplay = provider.draftPlantInfoForEditingPage;
    final String idealECDisplay = provider.idealECForEditingPage.toStringAsFixed(1);
    final String idealNutrisiDisplay = provider.idealNutrisiForEditingPage.toStringAsFixed(1);
    final String idealSuhuAirDisplay = provider.idealSuhuForEditingPage.toStringAsFixed(1);
    final String idealWaktuSiramDisplay = provider.idealWaktuSiramForEditingPage.toStringAsFixed(1);

    // Mengembalikan UI Lama
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration( // UI Lama
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
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
        padding: const EdgeInsets.all(12), // UI Lama
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row( // UI Lama
              children: [
                SizedBox( // UI Lama
                  width: 100,
                  height: 100,
                  child: Image.asset(plantInfoToDisplay['thumbnail'] ?? 'assets/myicon/unknown.png'),
                ),
                const SizedBox(width: 12),
                Expanded( // Ditambahkan agar teks tidak overflow jika panjang
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plantInfoToDisplay['title'] ?? 'Tanaman',
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
            const Divider(), // UI Lama
            const SizedBox(height: 10), // UI Lama
            Column( // UI Lama
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: InfoColumn( // UI Lama (menggunakan Expanded agar rapi)
                      title: 'Waktu Siram',
                      fontSize: 16,
                      space: 8,
                      value: '$idealWaktuSiramDisplay Menit',
                    )),
                    SizedBox(width: 8),
                    Expanded(child: InfoColumn( // UI Lama
                      title: 'Suhu Ideal',
                      fontSize: 16,
                      space: 8,
                      value: '$idealSuhuAirDisplay °C',
                    )),
                  ],
                ),
                const Divider(), // UI Lama
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Expanded(child:InfoColumn( // UI Lama
                      title: 'EC Ideal',
                      fontSize: 16,
                      space: 8,
                      value: '$idealECDisplay mS/cm',
                    )),
                    SizedBox(width: 8),
                    Expanded(child:InfoColumn( // UI Lama
                      title: 'Nutrisi Ideal',
                      fontSize: 16,
                      space: 8,
                      value: '$idealNutrisiDisplay ppm',
                    )),
                  ],
                ),
              ],
            ),
            const Divider(), // UI Lama
            ElevatedButton( // UI Lama
              onPressed: _isSaving ? null : () => _applyAndSaveChanges(context),
              style: ElevatedButton.styleFrom( // UI Lama
                backgroundColor: GColors.myBiru,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 48)
              ),
              child: _isSaving 
              ? const SizedBox(height:20, width:20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5,))
              : const Row( // UI Lama
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload), // Sesuaikan dengan ikon UI Lama
                  SizedBox(width: 8),
                  Text("Update Parameter ke Sistem") // Teks UI Lama
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}