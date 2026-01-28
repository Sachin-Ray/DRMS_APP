import 'package:drms/model/ExGratiaNorm%20.dart';
import 'package:drms/services/APIService.dart';
import 'package:flutter/material.dart';
import '../model/beneficiary_models.dart';

class AssistanceWidget extends StatefulWidget {
  final AssistanceDetails model;

  const AssistanceWidget({super.key, required this.model});

  @override
  State<AssistanceWidget> createState() => _AssistanceWidgetState();
}

class _AssistanceWidgetState extends State<AssistanceWidget> {
  List<ExGratiaNorm> norms = [];
  ExGratiaNorm? selectedNorm;

  final TextEditingController victimCountController = TextEditingController();
  final TextEditingController eligibleController = TextEditingController();

  List<TextEditingController> victimControllers = [];

  @override
  void initState() {
    super.initState();
    _loadNorms();

    // Restore victim count
    victimCountController.text = widget.model.victimCount.toString();

    // Restore victim names
    victimControllers = widget.model.victimNames
        .map((name) => TextEditingController(text: name))
        .toList();
  }

  Future<void> _loadNorms() async {
    final result = await APIService.instance.getExGratiaNorms();

    if (!mounted) return;

    setState(() {
      norms = result ?? [];

      // Restore selected norm if already chosen
      if (widget.model.normCode != null) {
        selectedNorm = norms.firstWhere(
          (n) => n.normCode == widget.model.normCode,
        );

        eligibleController.text = selectedNorm!.value.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _requiredLabel("Type of Assistance"),
        const SizedBox(height: 8),

        DropdownButtonFormField<ExGratiaNorm>(
          value: selectedNorm,
          isExpanded: true,
          decoration: _inputDecoration("Select Assistance Type"),
          items: norms.map((norm) {
            return DropdownMenuItem(
              value: norm,
              child: Text(_buildNormLabel(norm)),
            );
          }).toList(),

          onChanged: (v) {
            setState(() {
              selectedNorm = v;

              widget.model.normCode = v!.normCode;
              widget.model.assistanceType = _buildNormLabel(v);

              widget.model.baseAmount = v.value.toDouble();

              // Initial amount
              widget.model.amountNotifier.value = widget.model.baseAmount ?? 0;

              eligibleController.text = v.value.toString();

              // Reset victims
              widget.model.victimCount = 1;
              widget.model.victimNames = [];
              victimCountController.text = "1";
              victimControllers.clear();
            });
          },
        ),

        const SizedBox(height: 20),

        // Only for deceased
        if (selectedNorm?.normCode == 1) ...[
          _requiredLabel("Eligible amount per deceased person (₹)"),
          const SizedBox(height: 8),

          TextFormField(
            controller: eligibleController,
            readOnly: true,
            decoration: _inputDecoration("Auto Amount"),
          ),

          const SizedBox(height: 20),

          _requiredLabel("No. of victims"),
          const SizedBox(height: 8),

          TextFormField(
            controller: victimCountController,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration("Enter number of victims"),
            onChanged: (val) {
              int count = int.tryParse(val) ?? 1;

              setState(() {
                widget.model.victimCount = count;

                // Multiply total amount
                widget.model.amountNotifier.value =
                    (widget.model.baseAmount ?? 0) * count;

                widget.model.victimNames = List.filled(count, "");

                victimControllers = List.generate(
                  count,
                  (_) => TextEditingController(),
                );
              });
            },
          ),

          const SizedBox(height: 20),

          ...List.generate(victimControllers.length, (index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _requiredLabel("Victim Name ${index + 1}"),
                const SizedBox(height: 8),

                TextFormField(
                  controller: victimControllers[index],
                  decoration: _inputDecoration("Enter victim name"),
                  onChanged: (v) {
                    widget.model.victimNames[index] = v;
                  },
                ),
                const SizedBox(height: 12),
              ],
            );
          }),
        ],
      ],
    );
  }

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
      Expanded(
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      const Text("*", style: TextStyle(color: Colors.red)),
    ],
  );

  String _buildNormLabel(ExGratiaNorm norm) =>
      "${norm.description} ${norm.losstype} ${norm.option != "NA" ? norm.option : ""}";
}
