import 'package:flutter/material.dart';
import 'beneficiary_models.dart';

class RemarksWidget extends StatelessWidget {
  final AssistanceDetails model;

  const RemarksWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Remarks"),
        const SizedBox(height: 8),

        TextFormField(
          decoration: _input("Enter remarks"),
          onChanged: (v) => model.remarks = v,
          maxLines: 1,
        ),
      ],
    );
  }

  // UI Helpers
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

  Widget _label(String label) => Text(
    label,
    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
  );
}
