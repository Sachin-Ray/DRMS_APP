import 'package:flutter/material.dart';
import 'beneficiary_models.dart';

class AmountWidget extends StatelessWidget {
  final AssistanceDetails model;

  const AmountWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _required("Eligible Amount (₹)"),
        const SizedBox(height: 8),

        ValueListenableBuilder<double>(
          valueListenable: model.amountNotifier,
          builder: (context, amount, child) {
            return TextFormField(
              readOnly: true,
              decoration: _input("0"),
              controller: TextEditingController(
                text: amount.toStringAsFixed(0),
              ),
            );
          },
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
  );

  Widget _required(String label) => Row(
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      const Text("*", style: TextStyle(color: Colors.red)),
    ],
  );
}
