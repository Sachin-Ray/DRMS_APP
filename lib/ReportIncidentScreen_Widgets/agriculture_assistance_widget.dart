import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drms/services/APIService.dart';
import 'beneficiary_models.dart';

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

  String? selectedType;

  bool isLandEligible = true;

  // Land Norm Dropdown Data
  bool loadingNorms = false;

  List<Map<String, dynamic>> landNorms = [];
  Map<String, dynamic>? selectedLandNorm;

  double normAmount = 0;
  double calculatedAmount = 0;

  bool landAreaError = false;

  // ================= FETCH LAND NORMS =================
  Future<void> fetchLandNorms() async {
    setState(() {
      loadingNorms = true;
      landNorms.clear();
      selectedLandNorm = null;
      normAmount = 0;
      calculatedAmount = 0;
    });

    final result = await APIService.instance.fetchLandNorms(
      farmertype: "TYPE1",
      subtype: "SUBTYPE1",
    );

    if (result != null) {
      setState(() {
        landNorms = result;
      });
    }

    setState(() => loadingNorms = false);
  }

  // ================= CALCULATION =================
  void calculateFinalAmount() {
    double affected = double.tryParse(affectedController.text) ?? 0;

    calculatedAmount = normAmount * affected;

    // Send to Amount Widget
    widget.model.amountNotifier.value = calculatedAmount;
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    double landValue = double.tryParse(landController.text) ?? 0;

    // Eligibility check
    isLandEligible = landValue <= 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==========================================================
        // 1️⃣ Agriculture Assistance Specific Details
        // ==========================================================
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
            setState(() {
              double val = double.tryParse(v) ?? 0;

              if (val > 2 && selectedType == "SUBTYPE1") {
                selectedType = null;
              }
            });
          },

          validator: (v) {
            if (v == null || v.isEmpty) return "Landholding is required";

            final val = double.tryParse(v) ?? 0;
            if (val <= 0) return "Landholding must be greater than 0";

            return null;
          },
        ),

        const SizedBox(height: 10),

        // Eligibility Message
        if (landController.text.isNotEmpty && landValue <= 2)
          _infoBox(
            icon: Icons.check_circle_outline,
            color: Colors.green,
            message:
                "Farmer is classified under Small/Marginal category.\nEligible for both Land Assistance and Crop Loss (Input Subsidy).",
          ),

        if (landController.text.isNotEmpty && landValue > 2)
          _infoBox(
            icon: Icons.warning_amber_rounded,
            color: Colors.red,
            message:
                "Farmer is classified under Semi-medium/Medium/Large category.\nEligible ONLY for Crop Loss (Input Subsidy).",
          ),

        const SizedBox(height: 18),

        // Assistance Type
        _requiredLabel("Assistance Type"),
        const SizedBox(height: 10),

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

                    fetchLandNorms(); // Load dropdown
                  });
                }
              : null,
        ),

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
            });
          },
        ),

        if (landController.text.isNotEmpty && landValue > 2)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _infoBox(
              icon: Icons.block,
              color: Colors.red,
              message:
                  "Land Assistance option is disabled because landholding exceeds 2 hectares.",
            ),
          ),

        const SizedBox(height: 20),

        // ==========================================================
        // 2️⃣ Landloss Specific Details (ONLY SUBTYPE1)
        // ==========================================================
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

          // Dropdown Land Types
          _requiredLabel("Land Types"),
          const SizedBox(height: 8),

          DropdownButtonFormField<Map<String, dynamic>>(
            value: selectedLandNorm,
            decoration: _input(loadingNorms ? "Loading..." : "--Select--"),

            items: landNorms.map((e) {
              return DropdownMenuItem<Map<String, dynamic>>(
                value: e,
                child: Text(e["losstype"] ?? ""),
              );
            }).toList(),

            onChanged: (v) {
              if (v == null) return;

              setState(() {
                selectedLandNorm = v;

                normAmount = double.tryParse(v["value"].toString()) ?? 0;

                calculateFinalAmount();
              });
            },

            validator: (v) => v == null ? "Land Type selection required" : null,
          ),

          const SizedBox(height: 16),

          // Amount readonly
          _requiredLabel("Amount (in ₹)"),
          const SizedBox(height: 6),

          TextFormField(
            readOnly: true,
            decoration: _readonlyInput(normAmount.toStringAsFixed(0)),
          ),

          const SizedBox(height: 6),

          const Text(
            "The assessed amount above adheres to SDRF norms for agriculture payment.",
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          // Land area affected
          _requiredLabel("Land area affected (in hectares)"),
          const SizedBox(height: 6),

          TextFormField(
            controller: affectedController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),

            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],

            decoration: _input("Enter affected land area"),

            onChanged: (v) {
              double affected = double.tryParse(v) ?? 0;
              double holding = double.tryParse(landController.text) ?? 0;

              setState(() {
                landAreaError = affected > holding;

                if (!landAreaError) {
                  calculateFinalAmount();
                } else {
                  widget.model.amountNotifier.value = 0;
                }
              });
            },
          ),

          if (landAreaError)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                "Land area affected exceeds landholding area. Please ensure it is not more than landholding value.",
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Calculated Amount
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

  // ===================== UI HELPERS =====================

  InputDecoration _input(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0xffF5F5F7),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xffE5E7EB)),
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

  Widget _requiredLabel(String label) => Row(
    children: [
      Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
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
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: color,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
