import 'package:drms/ReportIncidentScreen_Widgets/beneficiary_models.dart';
import 'package:flutter/material.dart';

class AmountWidget extends StatelessWidget {
  final AssistanceDetails model;

  const AmountWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _required("Eligible Amount (₹)"),
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: _input("Enter amount"),
          onChanged: (v) => model.amount = double.tryParse(v),
          validator: (v) => v!.isEmpty ? "Required" : null,
        ),
        const SizedBox(height: 6),
        const Text(
          "As per SDRF guidelines",
          style: TextStyle(fontSize: 12, color: Color(0xff6B7280)),
        ),
      ],
    );
  }

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

  Widget _required(String label) => Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Text("*", style: TextStyle(color: Colors.red)),
        ],
      );
}
