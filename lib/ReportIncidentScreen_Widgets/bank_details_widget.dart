import 'package:drms/model/BankBranch.dart';
import 'package:flutter/material.dart';
import 'package:drms/services/APIService.dart';
import 'beneficiary_models.dart';

class BankDetailsWidget extends StatefulWidget {
  final BankDetails model;

  const BankDetailsWidget({super.key, required this.model});

  @override
  State<BankDetailsWidget> createState() => _BankDetailsWidgetState();
}

class _BankDetailsWidgetState extends State<BankDetailsWidget> {
  final TextEditingController ifscController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();

  final TextEditingController accountController = TextEditingController();
  final TextEditingController confirmAccountController =
      TextEditingController();

  List<BankBranch> branches = [];
  BankBranch? selectedBranch;

  bool loading = false;

  Future<void> fetchBankDetails(String ifsc) async {
    if (ifsc.length < 8) return;

    setState(() {
      loading = true;
      branches.clear();
      selectedBranch = null;
      bankNameController.clear();
    });

    final result = await APIService.instance.getBankByIFSC(ifsc);

    if (result.isNotEmpty) {
      // Auto fill Bank Name
      bankNameController.text = result.first.bankName;
      widget.model.bankName = result.first.bankName;

      branches = result;

      // Auto select branch if only 1
      if (branches.length == 1) {
        selectedBranch = branches.first;
        widget.model.branchName = selectedBranch!.branchCode;
      }
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _required("IFSC Code"),
        const SizedBox(height: 6),

        TextFormField(
          controller: ifscController,
          decoration: _input("Enter IFSC Code"),
          onChanged: (v) {
            widget.model.ifsc = v;
            fetchBankDetails(v);
          },
          validator: (v) =>
              v == null || v.isEmpty ? "IFSC Code is required" : null,
        ),

        const SizedBox(height: 16),

        _required("Bank Name"),
        const SizedBox(height: 6),

        TextFormField(
          controller: bankNameController,
          readOnly: true,
          decoration: _input("Auto Bank Name"),
        ),

        const SizedBox(height: 16),

        _required("Branch Name"),
        const SizedBox(height: 6),

        DropdownButtonFormField<BankBranch>(
          initialValue: selectedBranch,
          decoration: _input(loading ? "Loading..." : "Select Branch"),

          items: branches.map((b) {
            // ✅ Show only name before "-"
            String displayName = b.branchCode.split("-").first;

            return DropdownMenuItem<BankBranch>(
              value: b,
              child: Text(displayName),
            );
          }).toList(),

          onChanged: (v) {
            setState(() {
              selectedBranch = v;

              // ✅ Store full branchCode
              widget.model.branchName = v?.branchCode;
            });
          },

          validator: (v) => v == null ? "Branch selection required" : null,
        ),

        const SizedBox(height: 16),

        _required("Bank A/C Number"),
        const SizedBox(height: 6),

        TextFormField(
          controller: accountController,
          keyboardType: TextInputType.number,
          decoration: _input("Enter account number"),
          onChanged: (v) {
            widget.model.accountNumber = v;
            setState(() {}); // refresh match message
          },
          validator: (v) {
            if (v == null || v.isEmpty) {
              return "Account number is required";
            }
            if (v.length < 6) {
              return "Account number is too short";
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        _required("Verify Bank A/C Number"),
        const SizedBox(height: 6),

        TextFormField(
          controller: confirmAccountController,
          keyboardType: TextInputType.number,
          decoration: _input("Re-enter account number"),
          onChanged: (v) {
            widget.model.confirmAccountNumber = v;
            setState(() {});
          },
          validator: (v) {
            if (v == null || v.isEmpty) {
              return "Please verify account number";
            }

            if (v != accountController.text) {
              return "Account number does not match";
            }

            return null;
          },
        ),

        const SizedBox(height: 6),

        if (confirmAccountController.text.isNotEmpty &&
            confirmAccountController.text != accountController.text)
          const Text(
            "❌ Account numbers are not matching",
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),

        if (confirmAccountController.text.isNotEmpty &&
            confirmAccountController.text == accountController.text)
          const Text(
            "✅ Account numbers match",
            style: TextStyle(color: Colors.green, fontSize: 12),
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
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      const SizedBox(width: 4),
      const Text(
        "*",
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
    ],
  );
}
