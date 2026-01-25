import 'package:drms/ReportIncidentScreen_Widgets/beneficiary_models.dart';
import 'package:flutter/material.dart';

class BankDetailsWidget extends StatelessWidget {
  final BankDetails model;

  const BankDetailsWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _required("Account Holder Name"),
        TextFormField(
          decoration: _input("Account holder name"),
          onChanged: (v) => model.accountHolder = v,
          validator: (v) => v!.isEmpty ? "Required" : null,
        ),
        const SizedBox(height: 12),

        _required("Account Number"),
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: _input("Account number"),
          onChanged: (v) => model.accountNumber = v,
          validator: (v) => v!.isEmpty ? "Required" : null,
        ),
        const SizedBox(height: 12),

        _required("IFSC Code"),
        TextFormField(
          decoration: _input("IFSC code"),
          onChanged: (v) => model.ifsc = v,
          validator: (v) => v!.isEmpty ? "Required" : null,
        ),
        const SizedBox(height: 12),

        _required("Bank Name"),
        TextFormField(
          decoration: _input("Bank name"),
          onChanged: (v) => model.bankName = v,
          validator: (v) => v!.isEmpty ? "Required" : null,
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
