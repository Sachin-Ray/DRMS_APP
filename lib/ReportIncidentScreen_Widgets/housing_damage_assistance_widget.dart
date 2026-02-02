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
  bool houseDamageSelected = false;
  bool cattleShedSelected = false;

  String? selectedHouseType;

  bool loadingSubtypes = false;
  List<Map<String, dynamic>> houseSubtypes = [];

  int? selectedNormCode;

  bool loadingNorm = false;
  double normValue = 0;

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
      normValue = 0;

      // ✅ Reset Pucca/Kutcha
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

    // Hut Auto Select
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

    cattleNormCode = normCode;

    final normData = await APIService.instance.getNormByNormCode(normCode);

    setState(() {
      cattleNormValue =
          double.tryParse(normData?.value?.toString() ?? "0") ?? 0;
      loadingCattleNorm = false;
    });

    updateTotalAmount();
  }

  // ======================================================
  // ✅ UPDATE TOTAL + STORE CORRECT PAYLOAD VALUES
  // ======================================================
  void updateTotalAmount() {
    double total = 0;

    if (selectedNormCode != null) total += normValue;
    if (cattleShedSelected) total += cattleNormValue;

    widget.model.amountNotifier.value = total;

    // ==============================
    // ✅ normSelect should contain ONLY main norm
    // ==============================
    widget.model.normCodes.clear();

    if (selectedNormCode != null) {
      widget.model.normCodes.add(selectedNormCode!);
    }

    // ==============================
    // ✅ Store Pucca/Kutcha separately
    // ==============================
    if (selectedHouseType != null &&
        houseSubtypes.isNotEmpty &&
        selectedNormCode != null) {
      widget.model.isPuccaOrKutcha = selectedNormCode;
    }

    // ==============================
    // ✅ Print Debug
    // ==============================
    debugPrint("====================================");
    debugPrint("🏠 Housing normSelect = ${widget.model.normCodes}");
    debugPrint("🏠 Pucca/Kutcha = ${widget.model.isPuccaOrKutcha}");
    debugPrint("🏠 TOTAL HOUSING AMOUNT = ₹$total");
    debugPrint("====================================");
  }

  // ======================================================
  // UI BUILD (UNCHANGED)
  // ======================================================
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _requiredLabel("Assistance Type"),
        const SizedBox(height: 12),

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
                normValue = 0;
                widget.model.isPuccaOrKutcha = null;
              }

              updateTotalAmount();
            });
          },
        ),

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
      ],
    );
  }

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
                if (val != null) selectSubtype(val);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

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
