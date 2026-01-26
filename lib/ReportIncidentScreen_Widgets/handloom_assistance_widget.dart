import 'package:flutter/material.dart';
import 'package:drms/services/APIService.dart';
import 'beneficiary_models.dart';

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

    if (norm != null) {
      if (code == 36) {
        value36 = checked ? norm.value.toDouble() : 0;
      }

      if (code == 37) {
        value37 = checked ? norm.value.toDouble() : 0;
      }
    }

    /// Total Amount = Addition
    double total = value36 + value37;

    /// ✅ Update Amount Notifier (Auto Updates AmountWidget)
    widget.model.amountNotifier.value = total;

    /// Optional: Save assistanceType text
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
            _fetchNorm(37, v!);
          },
        ),

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
