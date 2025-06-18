import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:seedina/provider/rtdb_handler.dart';
import 'package:seedina/utils/style/gcolor.dart';
// import 'package:flutter/foundation.dart'; // Sudah ada di provider

class EditInfo extends StatefulWidget {
  const EditInfo({super.key});

  @override
  State<EditInfo> createState() => _EditInfoState();
}

class _EditInfoState extends State<EditInfo> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _latinController;
  late TextEditingController _waktuSiramController;
  late TextEditingController _jedaSiramController;
  late TextEditingController _suhuAirMinController;
  late TextEditingController _suhuAirMaxController;
  late TextEditingController _nutrisiMinController;
  late TextEditingController _nutrisiMaxController;
  late TextEditingController _suhuLingMinController;
  late TextEditingController _suhuLingMaxController;
  late TextEditingController _humiLingMinController;
  late TextEditingController _humiLingMaxController;

  bool _isSaving = false;
  bool _isLoadingForm = true; // State lokal untuk loading form

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _latinController = TextEditingController();
    _waktuSiramController = TextEditingController();
    _jedaSiramController = TextEditingController();
    _suhuAirMinController = TextEditingController();
    _suhuAirMaxController = TextEditingController();
    _nutrisiMinController = TextEditingController();
    _nutrisiMaxController = TextEditingController();
    _suhuLingMinController = TextEditingController();
    _suhuLingMaxController = TextEditingController();
    _humiLingMinController = TextEditingController();
    _humiLingMaxController = TextEditingController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadParametersFromProviderDraft();
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadParametersFromProviderDraft();
  }


  void _loadParametersFromProviderDraft() {
    if (!mounted) return;
    setState(() { _isLoadingForm = true; });

    final provider = Provider.of<HandlingProvider>(context, listen: false);
    Map<String, dynamic> params = provider.draftParametersForEditing;

    if (params.isEmpty && provider.draftSelectedPlantForEditing == "Kustom") {
        params = provider.parameters["Kustom"]!;
    }
    
    String titleToSet = params['title']?.toString() ?? provider.parameters['Kustom']!['title'].toString();
    String latinToSet = params['latin']?.toString() ?? provider.parameters['Kustom']!['latin'].toString();

    bool isTitlePreset = provider.parameters.keys.any((key) => key != "Kustom" && key == titleToSet);
    if (isTitlePreset) {
        titleToSet = provider.parameters['Kustom']!['title'].toString();
        latinToSet = provider.parameters['Kustom']!['latin'].toString();
    }


    _titleController.text = titleToSet;
    _latinController.text = latinToSet;
    _waktuSiramController.text = params['waktu_siram']?.toString() ?? '';
    _jedaSiramController.text = params['jeda_siram']?.toString() ?? '';
    _suhuAirMinController.text = params['min_suhuair']?.toString() ?? '';
    _suhuAirMaxController.text = params['max_suhuair']?.toString() ?? '';
    _nutrisiMinController.text = params['min_tdsair']?.toString() ?? '';
    _nutrisiMaxController.text = params['max_tdsair']?.toString() ?? '';
    _suhuLingMinController.text = params['min_suhuling']?.toString() ?? '';
    _suhuLingMaxController.text = params['max_suhuling']?.toString() ?? '';
    _humiLingMinController.text = params['min_humiling']?.toString() ?? '';
    _humiLingMaxController.text = params['max_humiling']?.toString() ?? '';
    
    if (mounted) {
        setState(() { _isLoadingForm = false; });
    }
  }

  Future<void> _submitCustomParameters() async {
    if (!_formKey.currentState!.validate()) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap perbaiki semua error pada form.'), backgroundColor: Colors.orangeAccent),
        );
      }
      return;
    }
    if(!mounted) return;
    setState(() => _isSaving = true);

    final provider = Provider.of<HandlingProvider>(context, listen: false);

    Map<String, dynamic> parametersToSaveFromForm = {
      'title': _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : provider.parameters['Kustom']!['title'],
      'latin': _latinController.text.trim(),
      'waktu_siram': int.tryParse(_waktuSiramController.text) ?? 0,
      'jeda_siram': int.tryParse(_jedaSiramController.text) ?? 0,
      'min_suhuair': double.tryParse(_suhuAirMinController.text) ?? 0.0,
      'max_suhuair': double.tryParse(_suhuAirMaxController.text) ?? 0.0,
      'min_tdsair': int.tryParse(_nutrisiMinController.text) ?? 0,
      'max_tdsair': int.tryParse(_nutrisiMaxController.text) ?? 0,
      'min_suhuling': double.tryParse(_suhuLingMinController.text) ?? 0.0,
      'max_suhuling': double.tryParse(_suhuLingMaxController.text) ?? 0.0,
      'min_humiling': int.tryParse(_humiLingMinController.text) ?? 0,
      'max_humiling': int.tryParse(_humiLingMaxController.text) ?? 0,

    };
    
    bool success = await provider.applyCustomDraftToActive(context, parametersToSaveFromForm);
    
    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _latinController.dispose();
    _waktuSiramController.dispose();
    _jedaSiramController.dispose();
    _suhuAirMinController.dispose();
    _suhuAirMaxController.dispose();
    _nutrisiMinController.dispose();
    _nutrisiMaxController.dispose();
    _suhuLingMinController.dispose();
    _suhuLingMaxController.dispose();
    _humiLingMinController.dispose();
    _humiLingMaxController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  String? _validateInt(String? value, String fieldName, {int? minValAbs, int? maxValAbs, bool allowZero = true}) {
    String? requiredError = _validateRequired(value, fieldName);
    if (requiredError != null) return requiredError;
    final val = int.tryParse(value!);
    if (val == null) return '$fieldName harus berupa angka bulat';
    if (!allowZero && val == 0) return '$fieldName tidak boleh nol';
    if (val < 0 && !allowZero && (minValAbs == null || minValAbs >=0) ) return '$fieldName tidak boleh negatif';
    if (minValAbs != null && val < minValAbs) return '$fieldName minimal $minValAbs';
    if (maxValAbs != null && val > maxValAbs) return '$fieldName maksimal $maxValAbs';
    return null;
  }

  String? _validateDouble(String? value, String fieldName, {double? minValAbs, double? maxValAbs}) {
    String? requiredError = _validateRequired(value, fieldName);
    if (requiredError != null) return requiredError;
    final val = double.tryParse(value!);
    if (val == null) return '$fieldName harus berupa angka desimal';
    if (fieldName.toLowerCase().contains("kelembapan") && (val < 0.0 || val > 100.0)) return 'Kelembapan harus antara 0.0 - 100.0';
    if (minValAbs != null && val < minValAbs) return '$fieldName minimal $minValAbs';
    if (maxValAbs != null && val > maxValAbs) return '$fieldName maksimal $maxValAbs';
    return null;
  }

  Widget _buildSingleTextFormField({
    required String label,
    required TextEditingController controller,
    required String unit,
    bool isDecimal = false,
    num? absoluteMin, 
    num? absoluteMax,
    bool allowZeroForInt = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isDecimal
            ? const TextInputType.numberWithOptions(decimal: true, signed: true)
            : TextInputType.number,
        inputFormatters: isDecimal
            ? [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))]
            : [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: label,
          suffixText: unit,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          isDense: true, 
          helperText: isDecimal ? "Gunakan '.' untuk desimal" : "Angka bulat",
          helperStyle: TextStyle(fontSize: 11, color: Colors.grey.shade600) 
        ),
        validator: (value) {
          return isDecimal
              ? _validateDouble(value, label, minValAbs: absoluteMin?.toDouble(), maxValAbs: absoluteMax?.toDouble())
              : _validateInt(value, label, minValAbs: absoluteMin?.toInt(), maxValAbs: absoluteMax?.toInt(), allowZero: allowZeroForInt);
        },
      ),
    );
  }

  Widget _buildMinMaxTextFormFieldRow({
    required String label,
    required TextEditingController minController,
    required TextEditingController maxController,
    required String unit,
    bool isDecimal = false,
    num? absoluteMin,
    num? absoluteMax,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: minController,
                  keyboardType: isDecimal
                      ? const TextInputType.numberWithOptions(decimal: true, signed: true)
                      : TextInputType.number,
                  inputFormatters: isDecimal
                      ? [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))]
                      : [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: "Min",
                    hintText: "Nilai Min",
                    suffixText: unit,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  validator: (value) { /* ... (Validasi sama seperti sebelumnya) ... */
                    String? commonError = isDecimal 
                        ? _validateDouble(value, "Min $label", minValAbs: absoluteMin?.toDouble(), maxValAbs: absoluteMax?.toDouble())
                        : _validateInt(value, "Min $label", minValAbs: absoluteMin?.toInt(), maxValAbs: absoluteMax?.toInt());
                    if (commonError != null) return commonError;
                    final maxStr = maxController.text;
                    if (maxStr.isNotEmpty && value != null && value.isNotEmpty) {
                       final currentMin = isDecimal ? double.tryParse(value) : int.tryParse(value);
                       final currentMax = isDecimal ? double.tryParse(maxStr) : int.tryParse(maxStr);
                       if (currentMin != null && currentMax != null && currentMin > currentMax) {
                         return 'Min harus <= Maks';
                       }
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: maxController,
                  keyboardType: isDecimal
                      ? const TextInputType.numberWithOptions(decimal: true, signed: true)
                      : TextInputType.number,
                  inputFormatters: isDecimal
                      ? [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))]
                      : [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: "Maks",
                    hintText: "Nilai Maks",
                    suffixText: unit,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  validator: (value) { /* ... (Validasi sama seperti sebelumnya) ... */
                    String? commonError = isDecimal 
                        ? _validateDouble(value, "Maks $label", minValAbs: absoluteMin?.toDouble(), maxValAbs: absoluteMax?.toDouble())
                        : _validateInt(value, "Maks $label", minValAbs: absoluteMin?.toInt(), maxValAbs: absoluteMax?.toInt());
                    if (commonError != null) return commonError;
                    final minStr = minController.text;
                    if (minStr.isNotEmpty && value != null && value.isNotEmpty) {
                      final currentMin = isDecimal ? double.tryParse(minStr) : int.tryParse(minStr);
                      final currentMax = isDecimal ? double.tryParse(value) : int.tryParse(value);
                      if (currentMin != null && currentMax != null && currentMin > currentMax) {
                        return 'Maks harus >= Min';
                      }
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
           if (isDecimal) Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text("Gunakan '.' untuk desimal", style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ) else Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text("Angka bulat", style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: GColors.myBiru)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final providerForImage = Provider.of<HandlingProvider>(context, listen: false);
    final plantInfoForImage = providerForImage.draftPlantInfoForEditingPage;

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration( 
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: GColors.shadowColor.withOpacity(0.15),
                blurRadius: 6,
                spreadRadius: 2,
                offset: const Offset(0, 3))
          ]),
      child: Padding(
        padding: const EdgeInsets.all(16.0), 
        child: _isLoadingForm 
            ? Center(child: CircularProgressIndicator()) 
            : SingleChildScrollView( 
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      Row( 
                        children: [
                          Container( 
                            width: 80, height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                  image: AssetImage(plantInfoForImage['thumbnail'] ?? 'assets/myicon/unknown.png'),
                                  fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded( 
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField( 
                                  controller: _titleController,
                                  decoration: const InputDecoration(
                                    labelText: "Nama Tanaman Kustom",
                                    border: UnderlineInputBorder(),
                                  ),
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                                  validator: (value) { /* ... (Validasi sama) ... */
                                    String? requiredError = _validateRequired(value, "Nama Tanaman");
                                    if (requiredError != null) return requiredError;
                                    final p = Provider.of<HandlingProvider>(context, listen: false);
                                    if (p.parameters.keys.any((key) => key != "Kustom" && key.toLowerCase() == value!.trim().toLowerCase())) {
                                        return "'$value' adalah nama preset.";
                                    }
                                    return null;
                                  }
                                ),
                                TextFormField( 
                                  controller: _latinController,
                                   decoration: const InputDecoration(
                                    labelText: "Nama Latin/Deskripsi",
                                     border: UnderlineInputBorder(),
                                  ),
                                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const Divider(height: 32, thickness: 1), 
                     
                      _buildSectionTitle("Pengaturan Penyiraman"), 
                      _buildSingleTextFormField( 
                          label: "Waktu Siram",
                          controller: _waktuSiramController,
                          unit: "Menit",
                          isDecimal: false,
                          absoluteMin: 1, 
                          allowZeroForInt: false,
                      ),
                      _buildSingleTextFormField( 
                          label: "Jeda Siram",
                          controller: _jedaSiramController,
                          unit: "Menit",
                          isDecimal: false,
                          absoluteMin: 1, 
                          allowZeroForInt: false,
                      ),

                      _buildSectionTitle("Parameter Air"), 
                      _buildMinMaxTextFormFieldRow( 
                          label: "Nutrisi (TDS)",
                          minController: _nutrisiMinController,
                          maxController: _nutrisiMaxController,
                          unit: "ppm",
                          isDecimal: false,
                          absoluteMin: 0),
                      _buildMinMaxTextFormFieldRow( 
                          label: "Suhu Air",
                          minController: _suhuAirMinController,
                          maxController: _suhuAirMaxController,
                          unit: "°C",
                          isDecimal: true),
                     
                      _buildSectionTitle("Parameter Lingkungan"), 
                       _buildMinMaxTextFormFieldRow( 
                          label: "Suhu Lingkungan",
                          minController: _suhuLingMinController,
                          maxController: _suhuLingMaxController,
                          unit: "°C",
                          isDecimal: true),
                      _buildMinMaxTextFormFieldRow( 
                          label: "Kelembapan Udara",
                          minController: _humiLingMinController,
                          maxController: _humiLingMaxController,
                          unit: "%",
                          isDecimal: false, 
                          absoluteMin: 0,
                          absoluteMax: 100
                      ),
                      const SizedBox(height: 24), 
                      ElevatedButton( 
                        onPressed: _isSaving ? null : _submitCustomParameters,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: GColors.myBiru,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        child: _isSaving
                            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save_alt_outlined),
                                  SizedBox(width: 8),
                                  Text('Simpan Parameter Kustom', style: TextStyle(fontSize: 16))
                                ],
                              ),
                      ),
                      const SizedBox(height: 16), 
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}