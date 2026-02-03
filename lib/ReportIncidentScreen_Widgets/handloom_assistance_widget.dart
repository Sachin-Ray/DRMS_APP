import 'package:flutter/material.dart';
import 'package:drms/services/APIService.dart';
import '../model/beneficiary_models.dart';

class HandloomAssistanceWidget extends StatefulWidget {
  final AssistanceDetails model;

  const HandloomAssistanceWidget({super.key, required this.model});

  @override
  State<HandloomAssistanceWidget> createState() =>
      _HandloomAssistanceWidgetState();
}

class _HandloomAssistanceWidgetState extends State<HandloomAssistanceWidget> {
  bool selected36 = false;
  bool selected37 = false;

  double value36 = 0;
  double value37 = 0;

  bool loading = false;

  /// Fetch Norm Value and update amount
  Future<void> _fetchNorm(int code, bool checked) async {
    setState(() => loading = true);

    final norm = await APIService.instance.getNormByNormCode(code);

    /// ✅ Correct Null Check
    if (norm != null) {
      double amount = (norm.value ?? 0).toDouble();

      // ===================================================
      // ✅ STORE SELECTED NORM CODES FOR HANDLOOM
      // ===================================================
      if (checked) {
        if (!widget.model.normCodes.contains(code)) {
          widget.model.normCodes.add(code);
        }
      } else {
        widget.model.normCodes.remove(code);
      }

      // ===================================================
      // ✅ AMOUNT CALCULATION (Same as your code)
      // ===================================================
      if (code == 36) {
        value36 = checked ? amount : 0;
      }

      if (code == 37) {
        value37 = checked ? amount : 0;
      }
    } else {
      debugPrint("Norm not found for code: $code");
    }

    /// Total Amount
    double total = value36 + value37;

    /// ✅ Update Amount Notifier
    widget.model.amountNotifier.value = total;

    /// Save assistanceType
    widget.model.assistanceType = "Handloom & Handicrafts";

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _requiredLabel("Assistance Type"),
        const SizedBox(height: 10),

        /// ✅ Checkbox NormCode 36
        CheckboxListTile(
          value: selected36,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text(
            "replacement of damaged main functional tools or equipments",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          onChanged: (v) {
            setState(() => selected36 = v!);

            /// ✅ FIX HERE
            _fetchNorm(36, v!);
          },
        ),

        /// ✅ Checkbox NormCode 37
        CheckboxListTile(
          value: selected37,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text(
            "loss of raw material or goods in process or finished goods",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          onChanged: (v) {
            setState(() => selected37 = v!);

            /// ✅ FIX HERE
            _fetchNorm(37, v!);
          },
        ),

        // ===================================================
        // ✅ Show Selected Norm Codes (Optional Debug)
        // ===================================================
        // if (widget.model.normCodes.isNotEmpty)
        //   Padding(
        //     padding: const EdgeInsets.only(top: 6),
        //     child: Text(
        //       "Selected Norms: ${widget.model.normCodes.join(", ")}",
        //       style: const TextStyle(fontSize: 12, color: Colors.green),
        //     ),
        //   ),

        if (loading)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              "Loading norm amount...",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
      ],
    );
  }

  /// Required Label
  Widget _requiredLabel(String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      const SizedBox(width: 4),
      const Text("*", style: TextStyle(color: Colors.red)),
    ],
  );
}
