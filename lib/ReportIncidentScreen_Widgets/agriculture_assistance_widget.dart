import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drms/services/APIService.dart';
import '../model/beneficiary_models.dart';

class AgricultureAssistanceWidget extends StatefulWidget {
  final AssistanceDetails model;

  const AgricultureAssistanceWidget({super.key, required this.model});

  @override
  State<AgricultureAssistanceWidget> createState() =>
      _AgricultureAssistanceWidgetState();
}

class _AgricultureAssistanceWidgetState
    extends State<AgricultureAssistanceWidget> {
  final TextEditingController landController = TextEditingController();
  final TextEditingController affectedController = TextEditingController();
  final TextEditingController cropSownController = TextEditingController();

  String? selectedType;
  bool isLandEligible = true;

  String get farmerType {
    double land = double.tryParse(landController.text) ?? 0;
    return land <= 2 ? "TYPE1" : "TYPE2";
  }

  bool loadingLandNorms = false;
  List<Map<String, dynamic>> landNorms = [];
  Map<String, dynamic>? selectedLandNorm;
  double landNormAmount = 0;

  String? selectedCropCategory;

  bool loadingInputNorms = false;
  List<Map<String, dynamic>> inputNorms = [];

  int? selectedNormCode;
  double inputAmount = 0;

  bool landAreaError = false;
  bool cropAreaError = false;

  double calculatedAmount = 0;

  List<int> selectedAgricultureNorms = [];

  void updateSelectedNorm(int normCode) {
    selectedAgricultureNorms.clear();
    selectedAgricultureNorms.add(normCode);

    // Store in main model list also
    widget.model.normCodes.clear();
    widget.model.normCodes.addAll(selectedAgricultureNorms);

    debugPrint("=====================================");
    debugPrint("🌾 Selected Agriculture Norm Codes:");
    debugPrint(selectedAgricultureNorms.toString());
    debugPrint("=====================================");
  }

  // Dynamic Field Label
  String get dynamicFieldLabel {
    if (selectedCropCategory ==
        "agriculture, horticulture and annual crop") {
      return "Irrigation Types";
    }
    if (selectedCropCategory == "perinial crop") {
      return "Perennial Types";
    }
    if (selectedCropCategory == "sericulture crop") {
      return "Silkworm Types";
    }
    return "Types";
  }

  Future<void> fetchLandNorms() async {
    setState(() {
      loadingLandNorms = true;
      landNorms.clear();
      selectedLandNorm = null;
      landNormAmount = 0;
      widget.model.amountNotifier.value = 0;
    });

    final result = await APIService.instance.fetchLandNorms(
      farmertype: farmerType,
      subtype: "SUBTYPE1",
    );

    if (result != null) {
      setState(() => landNorms = result);
    }

    setState(() => loadingLandNorms = false);
  }

  Future<void> fetchInputSubsidyNorms(String losstype) async {
    setState(() {
      loadingInputNorms = true;
      inputNorms.clear();

      selectedNormCode = null;
      inputAmount = 0;

      cropSownController.clear();
      widget.model.amountNotifier.value = 0;
    });

    final result = await APIService.instance.fetchInputSubsidyNorms(
      farmertype: farmerType,
      subtype: "SUBTYPE2",
      losstype: losstype,
    );

    setState(() {
      inputNorms = result;
      loadingInputNorms = false;
    });
  }

  void calculateLandLossAmount() {
    double affected = double.tryParse(affectedController.text) ?? 0;
    calculatedAmount = landNormAmount * affected;
    widget.model.amountNotifier.value = calculatedAmount;
  }

  void calculateInputAmount() {
    double cropArea = double.tryParse(cropSownController.text) ?? 0;
    calculatedAmount = inputAmount * cropArea;
    widget.model.amountNotifier.value = calculatedAmount;
  }

  @override
  Widget build(BuildContext context) {
    double landValue = double.tryParse(landController.text) ?? 0;
    isLandEligible = landValue <= 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _requiredLabel("Landholding (area in hectare)"),
        const SizedBox(height: 8),

        TextFormField(
          controller: landController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          decoration: _input("Enter landholding area"),
          onChanged: (v) {
            widget.model.landHoldingArea = double.tryParse(v) ?? 0;
            setState(() {
              if (selectedType == "SUBTYPE1" && landValue > 2) {
                selectedType = null;
              }
            });
          },
        ),

        const SizedBox(height: 10),

        if (landController.text.isNotEmpty && landValue <= 2)
          _infoBox(
            icon: Icons.check_circle_outline,
            color: Colors.green,
            message:
                "Farmer is classified under Small/Marginal category.\nEligible for both Land Assistance and Input Subsidy.",
          ),

        if (landController.text.isNotEmpty && landValue > 2)
          _infoBox(
            icon: Icons.warning_amber_rounded,
            color: Colors.red,
            message:
                "Farmer is classified under Medium/Large category.\nEligible ONLY for Input Subsidy.",
          ),

        const SizedBox(height: 20),

        _requiredLabel("Assistance Type"),
        const SizedBox(height: 10),

        // SUBTYPE1
        RadioListTile<String>(
          value: "SUBTYPE1",
          groupValue: selectedType,
          title: Text(
            "Assistance for land and other loss",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isLandEligible ? Colors.black : Colors.grey,
            ),
          ),
          onChanged: isLandEligible
              ? (v) {
                  setState(() {
                    selectedType = v;
                    widget.model.assistanceType = v;
                    fetchLandNorms();
                  });
                }
              : null,
        ),

        // SUBTYPE2
        RadioListTile<String>(
          value: "SUBTYPE2",
          groupValue: selectedType,
          title: const Text(
            "Input subsidy where crop loss is 33 percent and above",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          onChanged: (v) {
            setState(() {
              selectedType = v;
              widget.model.assistanceType = v;

              selectedCropCategory = null;
              inputNorms.clear();
              selectedNormCode = null;
              inputAmount = 0;
              cropSownController.clear();
              widget.model.amountNotifier.value = 0;
            });
          },
        ),

        const SizedBox(height: 20),

        if (selectedType == "SUBTYPE1") ...[
          const Divider(),
          const SizedBox(height: 12),

          Text(
            "Landloss Specific Details",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade800,
            ),
          ),
          const SizedBox(height: 14),

          _requiredLabel("Land Types"),
          const SizedBox(height: 8),

          DropdownButtonFormField<Map<String, dynamic>>(
            value: selectedLandNorm,
            isExpanded: true,
            decoration: _inputDecoration(
              loadingLandNorms ? "Loading..." : "--Select--",
            ),
            items: landNorms.map((norm) {
              return DropdownMenuItem(
                value: norm,
                child: Text(norm["losstype"] ?? ""),
              );
            }).toList(),
            onChanged: loadingLandNorms
                ? null
                : (v) {
                    if (v == null) return;
                    setState(() {
                      selectedLandNorm = v;

                      landNormAmount =
                          double.tryParse(v["value"].toString()) ?? 0;

                      // ✅ Extract Norm Code
                      final normCode = v["normCode"];

                      // ✅ Store norm in model
                      widget.model.normCode = normCode;

                      // ✅ Print selected norms
                      updateSelectedNorm(normCode);

                      calculateLandLossAmount();
                    });
                  },
          ),

          const SizedBox(height: 16),

          _requiredLabel("Land area affected (in hectares)"),
          const SizedBox(height: 6),

          TextFormField(
            controller: affectedController,
            decoration: _input("Enter affected land area"),
            onChanged: (v) {
              double affected = double.tryParse(v) ?? 0;
              double holding = double.tryParse(landController.text) ?? 0;
              widget.model.landAreaAffected = double.tryParse(v) ?? 0;
              setState(() {
                landAreaError = affected > holding;
                if (!landAreaError) calculateLandLossAmount();
              });
            },
          ),

          if (landAreaError)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                "Land area affected cannot exceed Landholding.",
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],

        if (selectedType == "SUBTYPE2") ...[
          const Divider(),
          const SizedBox(height: 12),

          Text(
            "Input Subsidy Specific Details",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade800,
            ),
          ),
          const SizedBox(height: 14),

          _requiredLabel("Category of crop grown"),
          const SizedBox(height: 8),

          // Crop category radios
          RadioListTile(
            value: "agriculture, horticulture and annual crop",
            groupValue: selectedCropCategory,
            title: const Text("Agriculture / Horticulture / Annual Crop"),
            onChanged: (v) {
              setState(() => selectedCropCategory = v);
              fetchInputSubsidyNorms(v.toString());
            },
          ),

          RadioListTile(
            value: "perinial crop",
            groupValue: selectedCropCategory,
            title: const Text("Perinial Crop"),
            onChanged: (v) {
              setState(() => selectedCropCategory = v);
              fetchInputSubsidyNorms(v.toString());
            },
          ),

          RadioListTile(
            value: "sericulture crop",
            groupValue: selectedCropCategory,
            title: const Text("Sericulture Crop"),
            onChanged: (v) {
              setState(() => selectedCropCategory = v);
              fetchInputSubsidyNorms(v.toString());
            },
          ),

          const SizedBox(height: 14),

          // ✅ NEW RADIO TYPES FIELD
          if (selectedCropCategory != null) ...[
            _requiredLabel(dynamicFieldLabel),
            const SizedBox(height: 8),

            if (loadingInputNorms)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: inputNorms.map((norm) {
                  return RadioListTile<int>(
                    value: norm["normCode"],
                    groupValue: selectedNormCode,
                    title: Text(norm["option"] ?? ""),
                    onChanged: (val) {
                      setState(() {
                        selectedNormCode = val;
                        widget.model.normCode = val;

                        // ✅ Print selected norms
                        updateSelectedNorm(val!);

                        inputAmount =
                            double.tryParse(norm["value"].toString()) ?? 0;

                        calculateInputAmount();
                      });
                    },
                  );
                }).toList(),
              ),
          ],

          const SizedBox(height: 16),

          _requiredLabel("Crop sown area"),
          const SizedBox(height: 6),

          TextFormField(
            controller: cropSownController,
            decoration: _input("Enter crop sown area"),
            onChanged: (v) {
              double crop = double.tryParse(v) ?? 0;
              double holding = double.tryParse(landController.text) ?? 0;
              widget.model.cropSownArea = double.tryParse(v) ?? 0;
              setState(() {
                cropAreaError = crop > holding;
                if (!cropAreaError) calculateInputAmount();
              });
            },
          ),

          if (cropAreaError)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                "Crop sown area cannot exceed Landholding.",
                style: TextStyle(color: Colors.red),
              ),
            ),

          const SizedBox(height: 16),

          _requiredLabel("Calculated amount eligible (in ₹)"),
          const SizedBox(height: 6),

          ValueListenableBuilder<double>(
            valueListenable: widget.model.amountNotifier,
            builder: (context, value, _) {
              return TextFormField(
                readOnly: true,
                decoration: _readonlyInput(value.toStringAsFixed(0)),
              );
            },
          ),
        ],
      ],
    );
  }

  InputDecoration _input(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xffF5F5F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );

  InputDecoration _readonlyInput(String value) => InputDecoration(
        hintText: value,
        filled: true,
        fillColor: const Color(0xffECEFF1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xffF5F5F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );

  Widget _requiredLabel(String label) => Row(
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(width: 4),
          const Text("*", style: TextStyle(color: Colors.red)),
        ],
      );

  Widget _infoBox({
    required IconData icon,
    required Color color,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
