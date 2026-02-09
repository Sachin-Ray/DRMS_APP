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
  bool milchOrDraughtSelected = false;
  bool poultrySelected = false;

  String? selectedAnimalType;

  bool loadingSubtypes = false;
  List<Map<String, dynamic>> animalSubtypes = [];

  // Selected Norm Codes
  List<int> selectedAnimalNormCodes = [];

  // Store all selected norms finally
  List<int> allSelectedAnimalNorms = [];
  Map<int, Map<String, dynamic>> normDetails = {};

  // Controllers + Calculations
  Map<int, TextEditingController> controllers = {};
  Map<int, double> calculatedAmounts = {};

  bool loadingPoultry = false;
  int? poultryNormCode;
  double poultryValue = 0;

  TextEditingController poultryController = TextEditingController();
  double poultryCalculated = 0;

  Future<void> fetchAnimalSubtypes(String animalType) async {
    setState(() {
      loadingSubtypes = true;
      animalSubtypes.clear();

      // Reset Milch/Draught Norms
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

  Future<void> fetchPoultryNorm() async {
    setState(() {
      loadingPoultry = true;
      poultryNormCode = null;
      poultryValue = 0;
      poultryController.clear();
      poultryCalculated = 0;
    });

    final normCodeResult = await APIService.instance
        .getNormCodeByAssistanceType("SUBTYPE4");

    if (normCodeResult == null) {
      setState(() => loadingPoultry = false);
      return;
    }

    poultryNormCode = normCodeResult;

    final detail =
        await APIService.instance.getNormByNormCode(poultryNormCode!);

    if (detail != null) {
      poultryValue = detail.value.toDouble();
    }

    setState(() => loadingPoultry = false);

    updateModel();
  }

  void calculateAmount(int normCode) {
    final count = double.tryParse(controllers[normCode]!.text) ?? 0;
    final value = normDetails[normCode]?["value"] ?? 0;

    calculatedAmounts[normCode] = count * value;

    updateGrandTotal();
  }

  void calculatePoultry() {
    final count = double.tryParse(poultryController.text) ?? 0;
    poultryCalculated = count * poultryValue;
    updateGrandTotal();
  }

  void updateGrandTotal() {
  double total = 0;

  // Milch/Draught total
  calculatedAmounts.forEach((_, amt) => total += amt);

  // Poultry total
  total += poultryCalculated;

  widget.model.amountNotifier.value = total;

  allSelectedAnimalNorms.clear();

  // Add Milch/Draught norms
  allSelectedAnimalNorms.addAll(selectedAnimalNormCodes);

  // Add Poultry norm separately
  if (poultrySelected && poultryNormCode != null) {
    allSelectedAnimalNorms.add(poultryNormCode!);
  }

  // Save into main model
  widget.model.normCodes.clear();
  widget.model.normCodes.addAll(allSelectedAnimalNorms);


  int largeAnimalCount = 0;
  int smallAnimalCount = 0;

  for (int code in selectedAnimalNormCodes) {
    int entered =
        int.tryParse(controllers[code]?.text ?? "0") ?? 0;

    // Milch Large OR Draught Large
    if (code == 25 || code == 24) {
      largeAnimalCount += entered;
    }

    // Milch Small OR Draught Small
    if (code == 28 || code == 27) {
      smallAnimalCount += entered;
    }
  }

  // Assign into model
  widget.model.noOfLargeAnimal = largeAnimalCount;
  widget.model.noOfSmallAnimal = smallAnimalCount;

  // Poultry Count
  widget.model.noOfPoultry =
      int.tryParse(poultryController.text) ?? 0;
}


  void updateModel() {
  widget.model.assistanceTypeList.clear();

  if (milchOrDraughtSelected) {
    widget.model.assistanceTypeList.add("SUBTYPE3");
  }

  if (poultrySelected) {
    widget.model.assistanceTypeList.add("SUBTYPE4");
  }

  if (milchOrDraughtSelected) {
    widget.model.animalType = selectedAnimalType;
  } else {
    widget.model.animalType = null;
  }

  updateGrandTotal();
}


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
  widget.model.animalType = null;

  animalSubtypes.clear();
  selectedAnimalNormCodes.clear();
  controllers.clear();
  calculatedAmounts.clear();
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
              poultryNormCode = null;
              poultryValue = 0;
              poultryCalculated = 0;
              poultryController.clear();

              updateModel();
            }
          },
        ),

        const SizedBox(height: 14),

        if (milchOrDraughtSelected) _buildMilchDraughtSection(),
        if (poultrySelected) _buildPoultrySection(),
      ],
    );
  }

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
              widget.model.animalType = val; 
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

          _readonlyField(
            "Amount per bird (₹)",
            poultryValue.toStringAsFixed(0),
          ),

          _readonlyField(
            "Calculated Eligible Amount (₹)",
            poultryCalculated.toStringAsFixed(0),
          ),
        ]
      ],
    );
  }

  Widget _buildNormFields(int normCode) {
    final value = normDetails[normCode]?["value"] ?? 0;
    final maxLimit = getMaxLimit(normCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _requiredLabel("Total no. of animals"),

        _numberField(
          controller: controllers[normCode]!,
          max: maxLimit,
          onChanged: (_) => calculateAmount(normCode),
        ),

        _readonlyField("Amount per animal (₹)", value.toStringAsFixed(0)),

        _readonlyField(
          "Calculated Eligible Amount (₹)",
          (calculatedAmounts[normCode] ?? 0).toStringAsFixed(0),
        ),
      ],
    );
  }

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
