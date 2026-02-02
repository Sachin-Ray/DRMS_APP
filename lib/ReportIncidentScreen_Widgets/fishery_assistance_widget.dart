import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/beneficiary_models.dart';
import '../services/APIService.dart';

class FisheryAssistanceWidget extends StatefulWidget {
  final AssistanceDetails model;

  const FisheryAssistanceWidget({super.key, required this.model});

  @override
  State<FisheryAssistanceWidget> createState() =>
      _FisheryAssistanceWidgetState();
}

class _FisheryAssistanceWidgetState extends State<FisheryAssistanceWidget> {
  bool boatSelected = false;
  bool netSelected = false;

  bool loadingBoat = false;
  List<Map<String, dynamic>> boatNorms = [];
  List<int> selectedBoatNormCodes = [];

  Map<int, TextEditingController> boatControllers = {};
  Map<int, double> boatCalculatedAmounts = {};

  bool loadingNet = false;
  List<Map<String, dynamic>> netNorms = [];
  List<int> selectedNetNormCodes = [];

  Map<int, TextEditingController> netControllers = {};
  Map<int, double> netCalculatedAmounts = {};

  // ======================================================
  // FETCH NORMS
  // ======================================================
  Future<void> fetchSubtypeNorms(String subtype) async {
    if (subtype == "SUBTYPE5") {
      setState(() {
        loadingBoat = true;
        boatNorms.clear();
      });
    } else {
      setState(() {
        loadingNet = true;
        netNorms.clear();
      });
    }

    final result = await APIService.instance.getNormBySubtype(subtype);

    setState(() {
      if (subtype == "SUBTYPE5") {
        boatNorms = result;
        loadingBoat = false;
      } else {
        netNorms = result;
        loadingNet = false;
      }
    });
  }

  // ======================================================
  // ✅ UPDATE TOTAL + STORE NORM CODES + COUNTS
  // ======================================================
  void updateGrandTotal() {
    double total = 0;

    boatCalculatedAmounts.forEach((_, amt) => total += amt);
    netCalculatedAmounts.forEach((_, amt) => total += amt);

    widget.model.amountNotifier.value = total;

    // ✅ Store norm codes
    widget.model.normCodes.clear();
    widget.model.normCodes.addAll([
      ...selectedBoatNormCodes,
      ...selectedNetNormCodes,
    ]);

    // ✅ Store counts properly
    widget.model.noOfRepairBoat =
        int.tryParse(boatControllers[31]?.text ?? "0") ?? 0;

    widget.model.noOfReplacementBoat =
        int.tryParse(boatControllers[32]?.text ?? "0") ?? 0;

    widget.model.noOfRepairNet =
        int.tryParse(netControllers[33]?.text ?? "0") ?? 0;

    widget.model.noOfReplacementNet =
        int.tryParse(netControllers[34]?.text ?? "0") ?? 0;

    debugPrint("🎣 Fishery Norm Codes = ${widget.model.normCodes}");
    debugPrint("🚤 Repair Boat = ${widget.model.noOfRepairBoat}");
    debugPrint("🚤 Replace Boat = ${widget.model.noOfReplacementBoat}");
    debugPrint("🎣 Repair Net = ${widget.model.noOfRepairNet}");
    debugPrint("🎣 Replace Net = ${widget.model.noOfReplacementNet}");
    debugPrint("✅ Total Fishery Amount = ₹$total");
  }

  // ======================================================
  // CALCULATE BOAT AMOUNT
  // ======================================================
  void calculateBoat(int normCode, double value) {
    final count = double.tryParse(boatControllers[normCode]!.text) ?? 0;
    boatCalculatedAmounts[normCode] = count * value;
    updateGrandTotal();
  }

  // ======================================================
  // CALCULATE NET AMOUNT
  // ======================================================
  void calculateNet(int normCode, double value) {
    final count = double.tryParse(netControllers[normCode]!.text) ?? 0;
    netCalculatedAmounts[normCode] = count * value;
    updateGrandTotal();
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

        // 🚤 Boat Checkbox
        CheckboxListTile(
          value: boatSelected,
          title: const Text("Boat",
              style: TextStyle(fontWeight: FontWeight.w600)),
          onChanged: (val) {
            setState(() {
              boatSelected = val ?? false;

              if (boatSelected) {
                fetchSubtypeNorms("SUBTYPE5");
              } else {
                selectedBoatNormCodes.clear();
                boatControllers.clear();
                boatCalculatedAmounts.clear();
                boatNorms.clear();
                updateGrandTotal();
              }
            });
          },
        ),

        // 🎣 Net Checkbox
        CheckboxListTile(
          value: netSelected,
          title: const Text("Net",
              style: TextStyle(fontWeight: FontWeight.w600)),
          onChanged: (val) {
            setState(() {
              netSelected = val ?? false;

              if (netSelected) {
                fetchSubtypeNorms("SUBTYPE6");
              } else {
                selectedNetNormCodes.clear();
                netControllers.clear();
                netCalculatedAmounts.clear();
                netNorms.clear();
                updateGrandTotal();
              }
            });
          },
        ),

        if (boatSelected) _buildBoatSection(),
        if (netSelected) _buildNetSection(),
      ],
    );
  }

  // ======================================================
  // 🚤 BOAT SECTION
  // ======================================================
  Widget _buildBoatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text("Boat Details",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        if (loadingBoat)
          const Center(child: CircularProgressIndicator())
        else
          Column(
            children: boatNorms.map((norm) {
              final normCode = norm["normCode"];
              final value = double.tryParse(norm["value"].toString()) ?? 0;

              boatControllers.putIfAbsent(
                  normCode, () => TextEditingController());

              return Column(
                children: [
                  CheckboxListTile(
                    title: Text(norm["option"].toString().toUpperCase()),
                    value: selectedBoatNormCodes.contains(normCode),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          selectedBoatNormCodes.add(normCode);
                        } else {
                          selectedBoatNormCodes.remove(normCode);
                          boatCalculatedAmounts.remove(normCode);
                          boatControllers[normCode]!.clear();
                        }
                        updateGrandTotal();
                      });
                    },
                  ),

                  if (selectedBoatNormCodes.contains(normCode)) ...[
                    _requiredLabel("Total no. of boats"),
                    _numberField(
                      controller: boatControllers[normCode]!,
                      onChanged: (_) => calculateBoat(normCode, value),
                    ),
                  ],
                ],
              );
            }).toList(),
          ),
      ],
    );
  }

  // ======================================================
  // 🎣 NET SECTION
  // ======================================================
  Widget _buildNetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text("Net Details",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        if (loadingNet)
          const Center(child: CircularProgressIndicator())
        else
          Column(
            children: netNorms.map((norm) {
              final normCode = norm["normCode"];
              final value = double.tryParse(norm["value"].toString()) ?? 0;

              netControllers.putIfAbsent(
                  normCode, () => TextEditingController());

              return Column(
                children: [
                  CheckboxListTile(
                    title: Text(norm["option"].toString().toUpperCase()),
                    value: selectedNetNormCodes.contains(normCode),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          selectedNetNormCodes.add(normCode);
                        } else {
                          selectedNetNormCodes.remove(normCode);
                          netCalculatedAmounts.remove(normCode);
                          netControllers[normCode]!.clear();
                        }
                        updateGrandTotal();
                      });
                    },
                  ),

                  if (selectedNetNormCodes.contains(normCode)) ...[
                    _requiredLabel("Total no. of nets"),
                    _numberField(
                      controller: netControllers[normCode]!,
                      onChanged: (_) => calculateNet(normCode, value),
                    ),
                  ],
                ],
              );
            }).toList(),
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
            style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(width: 4),
        const Text("*", style: TextStyle(color: Colors.red)),
      ],
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
