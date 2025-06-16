import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seedina/provider/rtdb_handler.dart';
import 'package:seedina/utils/rewidgets/global/editingplant/presetparamsetup.dart';
import 'package:seedina/utils/style/gcolor.dart';

class SetupPlant extends StatefulWidget {
  const SetupPlant({super.key});

  @override
  State<SetupPlant> createState() => _SetupPlantState();
}

class _SetupPlantState extends State<SetupPlant> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<HandlingProvider>(context, listen: false);

      //If current selected plant is empty or "Kustom", force the value to be a preset parameter
      if (provider.draftSelectedPlantForEditing.isEmpty || provider.draftSelectedPlantForEditing == "Kustom") {
        String firstPreset = provider.parameters.keys.firstWhere((k) => k != "Kustom", orElse: () {
          return provider.parameters.keys.isNotEmpty ? provider.parameters.keys.first : "";
        });

        if (firstPreset.isNotEmpty) {

          if (provider.draftSelectedPlantForEditing != firstPreset) {
            provider.selectPlantForEditingPage(firstPreset);
          }

        }

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HandlingProvider>(
      builder: (context, provider, child) {
        // Get plant list from 'parameters' map from provider, except "Kustom"
        final List<String> plantsForDropdown = provider.parameters.keys.where((k) => k != "Kustom").toList();
        
        String? currentSelectedPlantInDropdown = provider.draftSelectedPlantForEditing;

        // error handling for "If user in previous login session has selected custom"
        if ((currentSelectedPlantInDropdown == "Kustom" || !plantsForDropdown.contains(currentSelectedPlantInDropdown)) && plantsForDropdown.isNotEmpty) {
            currentSelectedPlantInDropdown = plantsForDropdown.first;

            if (provider.draftSelectedPlantForEditing != currentSelectedPlantInDropdown) {
                 WidgetsBinding.instance.addPostFrameCallback((_) {
                    if(mounted && currentSelectedPlantInDropdown != null) {
                        provider.selectPlantForEditingPage(currentSelectedPlantInDropdown);
                    }
                });
            }
        }


        return Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [GColors.myBiru, GColors.myHijau],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent, // UI Lama
              elevation: 0,                      // UI Lama
              automaticallyImplyLeading: false,  // UI Lama
              actions: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/wifiSetup', (route) => false);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text(
                      'Lewati',
                      style: TextStyle(
                          color: GColors.myKuning,
                          fontSize: 16,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.transparent, // UI Lama
            body: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // UI Lama
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // UI Lama
                    children: [
                      SizedBox( // UI Lama
                        height: 288,
                        width: 288,
                        child: Image.asset('assets/illustration/ill_plant.png'),
                      ),
                      Text( // UI Lama
                        'Keren! Kamu telah bergabung',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 20), // UI Lama
                      Text( // UI Lama
                        'Untuk memulai menjalankan sistem otomatisasi penjadwalan penyiraman, pemberian nutrisi, dan lainnya, pilih tanaman yang kamu inginkan di Bawah ini ya Farms!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      SizedBox(height: 20), // UI Lama
                      
                      if (plantsForDropdown.isEmpty && provider.isLoading)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      else if (plantsForDropdown.isEmpty)
                         Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Text("Tidak ada pilihan tanaman preset.", style: TextStyle(color: Colors.white70)),
                        )
                      else
                        Container( // UI Lama untuk Dropdown
                          width: MediaQuery.of(context).size.width,
                          child: DropdownButtonFormField<String>(
                            value: currentSelectedPlantInDropdown,
                            items: plantsForDropdown
                                .map((plant) => DropdownMenuItem(
                                      value: plant,
                                      child: Text(plant), // Style teks bisa ditambahkan jika ada di UI lama
                                    ))
                                .toList(),
                            onChanged: (newValue) {
                              if (newValue != null) {
                                provider.selectPlantForEditingPage(newValue); // Panggil method provider yang baru
                              }
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: GColors.myBiru,
                            ),
                            decoration: InputDecoration( // UI Lama untuk dekorasi Dropdown
                                filled: true,
                                fillColor: Colors.white70,
                                labelText: 'Pilih Tanaman Anda',
                                labelStyle: TextStyle(
                                  color: Colors.black
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: GColors.myKuning, width: 2),
                                    borderRadius: BorderRadius.circular(16)),
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: GColors.myKuning, width: 2),
                                    borderRadius: BorderRadius.circular(16))),
                          ),
                        ),
                      SizedBox(height: 24), // UI Lama
                      // PresetParamSetup akan menggunakan provider.draftSelectedPlantForEditing
                      // dan provider.draftParametersForEditing
                      PresetParamSetup() 
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}