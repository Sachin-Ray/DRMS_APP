import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/beneficiary_models.dart';
import '../services/APIService.dart';

class AnimalHusbandryAssistanceWidget extends StatefulWidget {
  final AssistanceDetails model;

  const AnimalHusbandryAssistanceWidget({
    super.key,
    required this.model,
  });

  @override
  State<AnimalHusbandryAssistanceWidget> createState() =>
      _AnimalHusbandryAssistanceWidgetState();
}

class _AnimalHusbandryAssistanceWidgetState
    extends State<AnimalHusbandryAssistanceWidget> {
  // ======================================================
  // MAIN CHECKBOX SELECTION
  // ======================================================
  bool milchOrDraughtSelected = false;
  bool poultrySelected = false;

  // ======================================================
  // RADIO BUTTON SELECTION
  // ======================================================
  String? selectedAnimalType; // Milch / Draught

  // ======================================================
  // SUBTYPE LIST FROM API
  // ======================================================
  bool loadingSubtypes = false;
  List<Map<String, dynamic>> animalSubtypes = [];

  // Selected Norm Codes (Large / Small / Poultry)
  List<int> selectedAnimalNormCodes = [];

  // ======================================================
  // DETAIL DATA FOR EACH NORM
  // ======================================================
  Map<int, Map<String, dynamic>> normDetails = {};

  // Controllers + Calculations
  Map<int, TextEditingController> controllers = {};
  Map<int, double> calculatedAmounts = {};

  // ======================================================
  // POULTRY DATA
  // ======================================================
  bool loadingPoultry = false;
  int? poultryNormCode;
  double poultryValue = 0;

  TextEditingController poultryController = TextEditingController();
  double poultryCalculated = 0;

  // ======================================================
  // FETCH SUBTYPES BASED ON RADIO
  // ======================================================
  Future<void> fetchAnimalSubtypes(String animalType) async {
    setState(() {
      loadingSubtypes = true;
      animalSubtypes.clear();
      selectedAnimalNormCodes.clear();
      normDetails.clear();
      controllers.clear();
      calculatedAmounts.clear();
    });

    final result =
        await APIService.instance.getAnimalSubtypeByAnimalType(animalType);

    setState(() {
      animalSubtypes = result;
      loadingSubtypes = false;
    });

    updateModel();
  }

  // ======================================================
  // FETCH NORM DETAIL (Large/Small)
  // ======================================================
  Future<void> fetchNormDetail(int normCode) async {
    final detail = await APIService.instance.getNormByNormCode(normCode);

    if (detail == null) return;

    setState(() {
      normDetails[normCode] = {
        "value": detail.value,
        "option": detail.option,
      };

      controllers.putIfAbsent(normCode, () => TextEditingController());
      calculatedAmounts[normCode] = 0;
    });

    updateGrandTotal();
  }

  // ======================================================
  // FETCH POULTRY NORM
  // ======================================================
  Future<void> fetchPoultryNorm() async {
    setState(() {
      loadingPoultry = true;
      poultryNormCode = null;
      poultryValue = 0;
      poultryController.clear();
      poultryCalculated = 0;
    });

    // Step 1: Get NormCode by AssistanceType
    final normCodeResult = await APIService.instance
        .getNormCodeByAssistanceType("SUBTYPE4");

    if (normCodeResult == null) {
      setState(() => loadingPoultry = false);
      return;
    }

    poultryNormCode = normCodeResult;

    // Step 2: Get Norm Details
    final detail =
        await APIService.instance.getNormByNormCode(poultryNormCode!);

    if (detail != null) {
      poultryValue = detail.value.toDouble();
    }

    // Add normCode in list
    if (!selectedAnimalNormCodes.contains(poultryNormCode)) {
      selectedAnimalNormCodes.add(poultryNormCode!);
    }

    setState(() => loadingPoultry = false);

    updateModel();
  }

  // ======================================================
  // CALCULATE AMOUNT FOR EACH SUBTYPE
  // ======================================================
  void calculateAmount(int normCode) {
    final count = double.tryParse(controllers[normCode]!.text) ?? 0;
    final value = normDetails[normCode]?["value"] ?? 0;

    calculatedAmounts[normCode] = count * value;

    updateGrandTotal();
  }

  // ======================================================
  // CALCULATE POULTRY
  // ======================================================
  void calculatePoultry() {
    final count = double.tryParse(poultryController.text) ?? 0;
    poultryCalculated = count * poultryValue;
    updateGrandTotal();
  }

  // ======================================================
  // UPDATE GRAND TOTAL
  // ======================================================
  void updateGrandTotal() {
    double total = 0;

    calculatedAmounts.forEach((_, amt) => total += amt);

    // Poultry amount
    total += poultryCalculated;

    widget.model.amountNotifier.value = total;

    widget.model.selectedNormCodes.clear();
    widget.model.selectedNormCodes.addAll(selectedAnimalNormCodes);

    debugPrint("✅ TOTAL Animal Husbandry Amount = ₹$total");
  }

  // ======================================================
  // UPDATE MODEL VALUES
  // ======================================================
  void updateModel() {
    widget.model.assistanceTypeList.clear();

    if (milchOrDraughtSelected) {
      widget.model.assistanceTypeList.add("SUBTYPE3");
    }

    if (poultrySelected) {
      widget.model.assistanceTypeList.add("SUBTYPE4");
    }

    widget.model.selectedNormCodes.clear();
    widget.model.selectedNormCodes.addAll(selectedAnimalNormCodes);

    updateGrandTotal();
  }

  // ======================================================
  // CLAIM LIMIT BASED ON TYPE
  // ======================================================
  int getMaxLimit(int normCode) {
    if (selectedAnimalType == "Milch") {
      if (normCode == 25) return 3;
      if (normCode == 28) return 30;
    }

    if (selectedAnimalType == "Draught") {
      if (normCode == 24) return 3;
      if (normCode == 27) return 6;
    }

    return 0;
  }

  // ======================================================
  // UI BUILD
  // ======================================================
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _requiredLabel("Assistance Type"),
        const SizedBox(height: 12),

        // Milch/Draught Checkbox
        CheckboxListTile(
          value: milchOrDraughtSelected,
          title: const Text(
            "Milch or Draught Animal",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          onChanged: (val) {
            setState(() {
              milchOrDraughtSelected = val ?? false;

              if (!milchOrDraughtSelected) {
                selectedAnimalType = null;
                animalSubtypes.clear();
                selectedAnimalNormCodes.removeWhere(
                    (code) => code != poultryNormCode);
              }

              updateModel();
            });
          },
        ),

        // Poultry Checkbox
        CheckboxListTile(
          value: poultrySelected,
          title: const Text(
            "Poultry",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          onChanged: (val) async {
            setState(() {
              poultrySelected = val ?? false;
            });

            if (poultrySelected) {
              await fetchPoultryNorm();
            } else {
              poultryCalculated = 0;
              poultryController.clear();

              if (poultryNormCode != null) {
                selectedAnimalNormCodes.remove(poultryNormCode);
              }
              updateModel();
            }
          },
        ),

        const SizedBox(height: 14),

        // Hidden Milch/Draught Section
        if (milchOrDraughtSelected) _buildMilchDraughtSection(),

        // Hidden Poultry Section
        if (poultrySelected) _buildPoultrySection(),
      ],
    );
  }

  // ======================================================
  // MILCH / DRAUGHT SECTION
  // ======================================================
  Widget _buildMilchDraughtSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 10),
        const Text(
          "Milch or Draught Animal Specific Details",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 12),

        _requiredLabel("Animal Type"),

        RadioListTile<String>(
          value: "Milch",
          groupValue: selectedAnimalType,
          title: const Text("Milch"),
          onChanged: (val) {
            setState(() {
              selectedAnimalType = val;
              fetchAnimalSubtypes("Milch");
            });
          },
        ),

        RadioListTile<String>(
          value: "Draught",
          groupValue: selectedAnimalType,
          title: const Text("Draught"),
          onChanged: (val) {
            setState(() {
              selectedAnimalType = val;
              fetchAnimalSubtypes("Draught");
            });
          },
        ),

        if (loadingSubtypes)
          const Center(child: CircularProgressIndicator())
        else
          Column(
            children: animalSubtypes.map((sub) {
              final normCode = sub["normCode"];

              return Column(
                children: [
                  CheckboxListTile(
                    value: selectedAnimalNormCodes.contains(normCode),
                    title: Text(
                      "${sub["subTypeName"]} (${sub["description"]})",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onChanged: (val) async {
                      if (val == true) {
                        selectedAnimalNormCodes.add(normCode);
                        await fetchNormDetail(normCode);
                      } else {
                        selectedAnimalNormCodes.remove(normCode);
                        controllers.remove(normCode);
                        calculatedAmounts.remove(normCode);
                      }

                      updateModel();
                    },
                  ),

                  if (selectedAnimalNormCodes.contains(normCode))
                    _buildNormFields(normCode),
                ],
              );
            }).toList(),
          ),
      ],
    );
  }

  // ======================================================
  // POULTRY SECTION
  // ======================================================
  Widget _buildPoultrySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 10),

        const Text(
          "Poultry Specific Details",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 12),

        if (loadingPoultry)
          const Center(child: CircularProgressIndicator())
        else ...[
          _requiredLabel("Total no. of birds"),

          _numberField(
            controller: poultryController,
            max: 100,
            onChanged: (_) => calculatePoultry(),
          ),

          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              "Claim limit: Maximum 100 birds animals.",
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),

          _readonlyField(
            "Amount for poultry (₹)",
            poultryValue.toStringAsFixed(0),
          ),

          _readonlyField(
            "Calculated amount eligible (₹)",
            poultryCalculated.toStringAsFixed(0),
          ),
        ]
      ],
    );
  }

  // ======================================================
  // Hidden Norm Fields UI
  // ======================================================
  Widget _buildNormFields(int normCode) {
    final value = normDetails[normCode]?["value"] ?? 0;
    final maxLimit = getMaxLimit(normCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _requiredLabel("Total no. of animal"),

        _numberField(
          controller: controllers[normCode]!,
          max: maxLimit,
          onChanged: (_) => calculateAmount(normCode),
        ),

        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            "Claim limit: Maximum $maxLimit animals allowed.",
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ),

        _readonlyField("Amount per animal (₹)", value.toStringAsFixed(0)),

        _readonlyField(
          "Calculated Eligible Amount (₹)",
          (calculatedAmounts[normCode] ?? 0).toStringAsFixed(0),
        ),
      ],
    );
  }

  // ======================================================
  // HELPERS
  // ======================================================
  Widget _requiredLabel(String label) {
    return Row(
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(width: 4),
        const Text("*",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _readonlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            Text(
              "₹ $value",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required int max,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (val) {
          final num = int.tryParse(val) ?? 0;
          if (num > max) {
            controller.text = max.toString();
            controller.selection = TextSelection.fromPosition(
              TextPosition(offset: controller.text.length),
            );
          }
          onChanged(controller.text);
        },
      ),
    );
  }
}
