import 'package:flutter/material.dart';
import '../model/beneficiary_models.dart';
import '../services/APIService.dart';

class HousingDamageAssistanceWidget extends StatefulWidget {
  final AssistanceDetails model;

  const HousingDamageAssistanceWidget({
    super.key,
    required this.model,
  });

  @override
  State<HousingDamageAssistanceWidget> createState() =>
      _HousingDamageAssistanceWidgetState();
}

class _HousingDamageAssistanceWidgetState
    extends State<HousingDamageAssistanceWidget> {
  // ======================================================
  // MAIN CHECKBOX SELECTION
  // ======================================================
  bool houseDamageSelected = false;
  bool cattleShedSelected = false;

  // ======================================================
  // HOUSE DAMAGE TYPE RADIO
  // ======================================================
  String? selectedHouseType;

  // ======================================================
  // HOUSE SUBTYPE LIST FROM API
  // ======================================================
  bool loadingSubtypes = false;
  List<Map<String, dynamic>> houseSubtypes = [];

  int? selectedNormCode;

  // ======================================================
  // ✅ Additional Info (Pucca/Kutcha) NormCode
  // ======================================================
  int? additionalInfoNormCode;

  // ======================================================
  // HOUSING NORM AMOUNT
  // ======================================================
  bool loadingNorm = false;
  double normValue = 0;

  // ======================================================
  // CATTLE SHED AMOUNT
  // ======================================================
  bool loadingCattleNorm = false;
  double cattleNormValue = 0;
  int? cattleNormCode;

  // ======================================================
  // FETCH HOUSE SUBTYPES
  // ======================================================
  Future<void> fetchHouseSubtypes(String houseType) async {
    setState(() {
      loadingSubtypes = true;
      houseSubtypes.clear();
      selectedNormCode = null;
      additionalInfoNormCode = null;
      normValue = 0;

      // Reset Model Values
      widget.model.normCodes.clear();
      widget.model.isPuccaOrKutcha = null;
    });

    final result = await APIService.instance.getHouseSubtypeByHouseType(
      subType: "SUBTYPE7",
      houseType: houseType,
    );

    setState(() {
      houseSubtypes = result;
      loadingSubtypes = false;
    });

    // ✅ Hut Auto Select
    if (houseType == "Hut" && houseSubtypes.isNotEmpty) {
      final autoNorm = houseSubtypes.first["norm_code"];
      selectSubtype(autoNorm);
    }
  }

  // ======================================================
  // FETCH NORM DETAILS
  // ======================================================
  Future<void> selectSubtype(int normCode) async {
    setState(() {
      selectedNormCode = normCode;
      loadingNorm = true;
      normValue = 0;
    });

    final normData = await APIService.instance.getNormByNormCode(normCode);

    setState(() {
      normValue = double.tryParse(normData?.value?.toString() ?? "0") ?? 0;
      loadingNorm = false;
    });

    updateTotalAmount();
  }

  // ======================================================
  // FETCH CATTLE SHED NORM
  // ======================================================
  Future<void> fetchCattleShedNorm() async {
  setState(() {
    loadingCattleNorm = true;
    cattleNormValue = 0;
    cattleNormCode = null;
  });

  final normCode =
      await APIService.instance.getNormCodeByHousingAssistType("SUBTYPE8");

  if (normCode == null) {
    setState(() => loadingCattleNorm = false);
    return;
  }

  // ✅ Ensure state updates
  setState(() {
    cattleNormCode = normCode;
  });

  final normData = await APIService.instance.getNormByNormCode(normCode);

  setState(() {
    cattleNormValue =
        double.tryParse(normData?.value?.toString() ?? "0") ?? 0;
    loadingCattleNorm = false;
  });

  updateTotalAmount();
}


  // ======================================================
  // ✅ UPDATE TOTAL + STORE CORRECT VALUES
  // ======================================================
  void updateTotalAmount() {
  double total = 0;

  // ============================
  // Calculate Total Amount
  // ============================
  if (selectedNormCode != null) total += normValue;
  if (cattleShedSelected) total += cattleNormValue;

  widget.model.amountNotifier.value = total;

  // ============================
  // Reset Stored Values
  // ============================
  widget.model.normCodes.clear();
  widget.model.isPuccaOrKutcha = null;

  // ============================
  // ✅ Store House Damage Norm Codes
  // ============================

  // CASE 1: Fully Damaged
  if (selectedHouseType == "Fully Damaged/Severely Damaged") {
    if (selectedNormCode != null) {
      widget.model.normCodes.add(selectedNormCode!);
    }

    if (additionalInfoNormCode != null) {
      widget.model.isPuccaOrKutcha = additionalInfoNormCode;
    }
  }

  // CASE 2: Partially Damaged
  else if (selectedHouseType == "Partially Damaged") {
    if (selectedNormCode != null) {
      widget.model.normCodes.add(selectedNormCode!);
      widget.model.isPuccaOrKutcha = selectedNormCode!;
    }
  }

  // CASE 3: Hut
  else if (selectedHouseType == "Hut") {
    if (selectedNormCode != null) {
      widget.model.normCodes.add(selectedNormCode!);
    }

    widget.model.isPuccaOrKutcha = null;
  }

  // ============================
  // ✅ FIX: Store Cattle Shed Norm Code
  // ============================
  if (cattleShedSelected && cattleNormCode != null) {
    widget.model.normCodes.add(cattleNormCode!);
  }

  // ============================
  // DEBUG PRINT
  // ============================
  debugPrint("====================================");
  debugPrint("🏠 House Type = $selectedHouseType");
  debugPrint("🏠 House NormCodes = ${widget.model.normCodes}");
  debugPrint("🐄 Cattle NormCode = $cattleNormCode");
  debugPrint("🏠 IspuccaOrKutcha = ${widget.model.isPuccaOrKutcha}");
  debugPrint("💰 TOTAL HOUSING AMOUNT = ₹$total");
  debugPrint("====================================");
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

        // House Damage Checkbox
        CheckboxListTile(
          value: houseDamageSelected,
          title: const Text(
            "Fully/ Partially Damaged (House)/ Damaged hut",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          onChanged: (val) {
            setState(() {
              houseDamageSelected = val ?? false;

              if (!houseDamageSelected) {
                selectedHouseType = null;
                houseSubtypes.clear();
                selectedNormCode = null;
                additionalInfoNormCode = null;
                normValue = 0;
                widget.model.isPuccaOrKutcha = null;
              }

              updateTotalAmount();
            });
          },
        ),

        // Cattle Shed Checkbox
        CheckboxListTile(
          value: cattleShedSelected,
          title: const Text(
            "Cattle Shed",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          onChanged: (val) {
            setState(() {
              cattleShedSelected = val ?? false;

              if (cattleShedSelected) {
                fetchCattleShedNorm();
              } else {
                cattleNormValue = 0;
                cattleNormCode = null;
                updateTotalAmount();
              }
            });
          },
        ),

        const SizedBox(height: 16),

        if (houseDamageSelected) _buildHouseDamageSection(),
        if (cattleShedSelected) _buildCattleShedSection(),
      ],
    );
  }

  // ======================================================
  // HOUSE DAMAGE SECTION
  // ======================================================
  Widget _buildHouseDamageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 10),
        const Text(
          "Fully/ Partially Damaged (House)/ Damaged Hut Specific Details",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 12),

        _requiredLabel("House Damage Type"),
        const SizedBox(height: 8),

        _radioOption("Fully Damaged/Severely Damaged"),
        _radioOption("Hut"),
        _radioOption("Partially Damaged"),

        const SizedBox(height: 14),

        if (selectedHouseType != null) _buildSubtypeSection(),

        // ✅ Show Additional Info ONLY for Fully Damaged
        if (selectedHouseType == "Fully Damaged/Severely Damaged" &&
            selectedNormCode != null)
          _buildAdditionalInfoSection(),
      ],
    );
  }

  // ======================================================
  // HOUSE SUBTYPE SECTION
  // ======================================================
  Widget _buildSubtypeSection() {
    if (loadingSubtypes) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _requiredLabel("House Sub Type"),
        const SizedBox(height: 10),

        Column(
          children: houseSubtypes.map((sub) {
            final normCode = sub["norm_code"];

            return RadioListTile<int>(
              value: normCode,
              groupValue: selectedNormCode,
              title: Text(
                sub["sub_type_name"],
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              onChanged: (val) {
                if (val != null) {
                  selectSubtype(val);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // ======================================================
  // ✅ Additional Info Section (Pucca/Kutcha)
  // ======================================================
  Widget _buildAdditionalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        _requiredLabel("Additional Info (Pucca / Kutcha)"),
        const SizedBox(height: 8),

        RadioListTile<int>(
          value: 40,
          groupValue: additionalInfoNormCode,
          title: const Text("Pucca"),
          onChanged: (val) {
            setState(() {
              additionalInfoNormCode = val;
              updateTotalAmount();
            });
          },
        ),

        RadioListTile<int>(
          value: 41,
          groupValue: additionalInfoNormCode,
          title: const Text("Kutcha"),
          onChanged: (val) {
            setState(() {
              additionalInfoNormCode = val;
              updateTotalAmount();
            });
          },
        ),
      ],
    );
  }

  // ======================================================
  // CATTLE SHED SECTION
  // ======================================================
  Widget _buildCattleShedSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                "Amount for cattle shed damage (₹)",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            loadingCattleNorm
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    "₹ ${cattleNormValue.toStringAsFixed(0)}",
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

  // ======================================================
  // RADIO OPTION BUILDER
  // ======================================================
  Widget _radioOption(String value) {
    return RadioListTile<String>(
      value: value,
      groupValue: selectedHouseType,
      title: Text(value),
      onChanged: (val) {
        setState(() {
          selectedHouseType = val;
          fetchHouseSubtypes(val!);
        });
      },
    );
  }

  // ======================================================
  // REQUIRED LABEL
  // ======================================================
  Widget _requiredLabel(String label) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(width: 4),
        const Text("*", style: TextStyle(color: Colors.red)),
      ],
    );
  }
}
