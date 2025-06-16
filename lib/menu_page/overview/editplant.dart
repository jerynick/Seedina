import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seedina/provider/rtdb_handler.dart';
import 'package:seedina/utils/rewidgets/global/editingplant/presetparam.dart';
import 'package:seedina/utils/rewidgets/global/myappbar.dart';
import 'package:seedina/utils/rewidgets/global/editingplant/manualparam.dart';
import 'package:seedina/utils/style/gcolor.dart';

class EditPlants extends StatefulWidget {
  const EditPlants({super.key});

  @override
  State<EditPlants> createState() => _EditPlantsState();
}

class _EditPlantsState extends State<EditPlants> {

  String? _localSelectedPlantForDropdown;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<HandlingProvider>(context, listen: false);

      if (provider.draftSelectedPlantForEditing.isNotEmpty) {
        setState(() {
          _localSelectedPlantForDropdown = provider.draftSelectedPlantForEditing;
        });
      } else if (provider.activeSelectedPlant.isNotEmpty) {

        provider.selectPlantForEditingPage(provider.activeSelectedPlant);
        setState(() {
          _localSelectedPlantForDropdown = provider.activeSelectedPlant;
        });
      } else {

        String firstPlant = provider.parameters.keys.first;
        provider.selectPlantForEditingPage(firstPlant);
        setState(() {
          _localSelectedPlantForDropdown = firstPlant;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HandlingProvider>(
      builder: (context, provider, child) {

        final plantsList = provider.parameters.keys.toList();
        String? valueForDropdown = _localSelectedPlantForDropdown;

        if (!plantsList.contains(valueForDropdown) && plantsList.isNotEmpty) {
          valueForDropdown = plantsList.first;

          if (_localSelectedPlantForDropdown != valueForDropdown) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if(mounted && valueForDropdown != null){
                setState(() {
                  _localSelectedPlantForDropdown = valueForDropdown;
                });
                provider.selectPlantForEditingPage(valueForDropdown);
              }
            });
          }
        }

        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Color(0XFF5B913B),
          appBar: CustomAppBar(
              title: Text(
                'Edit Parameter Tanaman',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Quicksand',
                    color: GColors.myKuning),
              ),
              actions: [],
              showBackButton: true),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16)
                    ),
                    child: DropdownButtonFormField<String>(
                      value: valueForDropdown,
                      items: plantsList
                          .map((plant) => DropdownMenuItem(
                                value: plant,
                                child: Text(plant),
                              ))
                          .toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            _localSelectedPlantForDropdown = newValue;
                          });
                          provider.selectPlantForEditingPage(newValue);
                        }
                      },
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down, color: GColors.myBiru,),
                      decoration: InputDecoration(
                        labelText: 'Pilih Tanaman Anda',
                        labelStyle: TextStyle(color: GColors.myBiru.withOpacity(0.9)),
                        border: InputBorder.none,
                      ),
                    ),
                ),
              ),
              SizedBox(height: 8),

              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16 + MediaQuery.of(context).viewInsets.bottom), // UI Lama: Padding
                      child: Column(
                        children: [
                          if (provider.isLoading && _localSelectedPlantForDropdown == null)
                            Center(child: CircularProgressIndicator())
                          else if (_localSelectedPlantForDropdown == 'Kustom')
                            EditInfo()
                          else if (_localSelectedPlantForDropdown != null && _localSelectedPlantForDropdown!.isNotEmpty)
                            PresetParameter()
                          else
                            Center(child: Text("Pilih tanaman dari dropdown.", style: TextStyle(color: Colors.grey)))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}