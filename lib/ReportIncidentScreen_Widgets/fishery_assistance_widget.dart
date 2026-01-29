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
  // ======================================================
  // MAIN SELECTION
  // ======================================================
  bool boatSelected = false;
  bool netSelected = false;

  // ======================================================
  // BOAT NORMS
  // ======================================================
  bool loadingBoat = false;
  List<Map<String, dynamic>> boatNorms = [];

  List<int> selectedBoatNormCodes = [];

  Map<int, TextEditingController> boatControllers = {};
  Map<int, double> boatCalculatedAmounts = {};

  // ======================================================
  // NET NORMS
  // ======================================================
  bool loadingNet = false;
  List<Map<String, dynamic>> netNorms = [];

  List<int> selectedNetNormCodes = [];

  Map<int, TextEditingController> netControllers = {};
  Map<int, double> netCalculatedAmounts = {};

  // ======================================================
  // FETCH NORMS FROM API
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
  // UPDATE GRAND TOTAL AMOUNT
  // ======================================================
  void updateGrandTotal() {
    double total = 0;

    boatCalculatedAmounts.forEach((_, amt) => total += amt);
    netCalculatedAmounts.forEach((_, amt) => total += amt);

    widget.model.amountNotifier.value = total;

    widget.model.selectedNormCodes.clear();
    widget.model.selectedNormCodes
        .addAll([...selectedBoatNormCodes, ...selectedNetNormCodes]);

    debugPrint("✅ TOTAL Fishery Amount = ₹$total");
  }

  // ======================================================
  // CALCULATE BOAT OPTION AMOUNT
  // ======================================================
  void calculateBoat(int normCode, double value) {
    final count = double.tryParse(boatControllers[normCode]!.text) ?? 0;
    boatCalculatedAmounts[normCode] = count * value;
    updateGrandTotal();
  }

  // ======================================================
  // CALCULATE NET OPTION AMOUNT
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

        // ======================================================
        // 🚤 Boat Checkbox
        // ======================================================
        CheckboxListTile(
          value: boatSelected,
          title: const Text(
            "Boat",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          onChanged: (val) {
            setState(() {
              boatSelected = val ?? false;

              if (boatSelected) {
                widget.model.assistanceTypeList.add("SUBTYPE5");
                fetchSubtypeNorms("SUBTYPE5");
              } else {
                widget.model.assistanceTypeList.remove("SUBTYPE5");

                selectedBoatNormCodes.clear();
                boatControllers.clear();
                boatCalculatedAmounts.clear();
                boatNorms.clear();
                updateGrandTotal();
              }
            });
          },
        ),

        // ======================================================
        // 🎣 Net Checkbox
        // ======================================================
        CheckboxListTile(
          value: netSelected,
          title: const Text(
            "Net",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          onChanged: (val) {
            setState(() {
              netSelected = val ?? false;

              if (netSelected) {
                widget.model.assistanceTypeList.add("SUBTYPE6");
                fetchSubtypeNorms("SUBTYPE6");
              } else {
                widget.model.assistanceTypeList.remove("SUBTYPE6");

                selectedNetNormCodes.clear();
                netControllers.clear();
                netCalculatedAmounts.clear();
                netNorms.clear();
                updateGrandTotal();
              }
            });
          },
        ),

        // ======================================================
        // 🚤 Boat Specific Details
        // ======================================================
        if (boatSelected) _buildBoatSection(),

        // ======================================================
        // 🎣 Net Specific Details
        // ======================================================
        if (netSelected) _buildNetSection(),

        const SizedBox(height: 15),

        // ======================================================
        // ✅ Total Eligible Amount Display
        // ======================================================
        // Container(
        //   padding: const EdgeInsets.all(14),
        //   decoration: BoxDecoration(
        //     color: Colors.green.shade50,
        //     borderRadius: BorderRadius.circular(12),
        //     border: Border.all(color: Colors.green),
        //   ),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       const Text(
        //         "Total Eligible Amount",
        //         style: TextStyle(fontWeight: FontWeight.bold),
        //       ),
        //       ValueListenableBuilder<double>(
        //         valueListenable: widget.model.amountNotifier,
        //         builder: (_, value, __) => Text(
        //           "₹ ${value.toStringAsFixed(0)}",
        //           style: const TextStyle(
        //             fontWeight: FontWeight.bold,
        //             fontSize: 16,
        //             color: Colors.green,
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      
      ],
    );
  }

  // ======================================================
  // 🚤 BOAT SECTION UI
  // ======================================================
  Widget _buildBoatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 8),
        const Text(
          "Boat Specific Details",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 10),

        if (loadingBoat)
          const Center(child: CircularProgressIndicator())
        else
          Column(
            children: boatNorms.map((norm) {
              final normCode = norm["normCode"];
              final value = double.tryParse(norm["value"].toString()) ?? 0;

              boatControllers.putIfAbsent(
                normCode,
                () => TextEditingController(),
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxListTile(
                    title: Text(
                      norm["option"].toString().toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
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
                    _requiredLabel("Total no. of boats (${norm["option"]})"),
                    _numberField(
                      controller: boatControllers[normCode]!,
                      onChanged: (_) => calculateBoat(normCode, value),
                    ),
                    _readonlyField(
                      "Amount per boat",
                      value.toStringAsFixed(0),
                    ),
                    _readonlyField(
                      "Calculated Eligible Amount",
                      (boatCalculatedAmounts[normCode] ?? 0)
                          .toStringAsFixed(0),
                    ),
                  ],

                  const SizedBox(height: 12),
                ],
              );
            }).toList(),
          ),
      ],
    );
  }

  // ======================================================
  // 🎣 NET SECTION UI
  // ======================================================
  Widget _buildNetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 8),
        const Text(
          "Fishing Net Specific Details",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 10),

        if (loadingNet)
          const Center(child: CircularProgressIndicator())
        else
          Column(
            children: netNorms.map((norm) {
              final normCode = norm["normCode"];
              final value = double.tryParse(norm["value"].toString()) ?? 0;

              netControllers.putIfAbsent(
                normCode,
                () => TextEditingController(),
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxListTile(
                    title: Text(
                      norm["option"].toString().toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
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
                    _requiredLabel("Total no. of nets (${norm["option"]})"),
                    _numberField(
                      controller: netControllers[normCode]!,
                      onChanged: (_) => calculateNet(normCode, value),
                    ),
                    _readonlyField(
                      "Amount per net",
                      value.toStringAsFixed(0),
                    ),
                    _readonlyField(
                      "Calculated Eligible Amount",
                      (netCalculatedAmounts[normCode] ?? 0)
                          .toStringAsFixed(0),
                    ),
                  ],

                  const SizedBox(height: 12),
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
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(width: 4),
        const Text("*", style: TextStyle(color: Colors.red)),
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
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
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
        onChanged: onChanged,
      ),
    );
  }
}
