import 'package:drms/ReportIncidentScreen_Widgets/accordion_section.dart';
import 'package:drms/ReportIncidentScreen_Widgets/amount_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/bank_details_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/beneficiary_details_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/beneficiary_documents_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/remarks_widget.dart';

import 'package:drms/ReportIncidentScreen_Widgets/handloom_assistance_widget.dart';

import 'package:drms/model/beneficiary_models.dart';
import 'package:drms/model/Block.dart';
import 'package:drms/model/Village.dart';
import 'package:flutter/material.dart';

class AddHandloomBeneficiaryDialog extends StatefulWidget {
  final List<Block> blocks;
  final List<Village> villages;
  final Function(Map<String, dynamic>) onSave;

  const AddHandloomBeneficiaryDialog({
    super.key,
    required this.blocks,
    required this.villages,
    required this.onSave,
  });

  @override
  State<AddHandloomBeneficiaryDialog> createState() =>
      _AddHandloomBeneficiaryDialogState();
}

class _AddHandloomBeneficiaryDialogState
    extends State<AddHandloomBeneficiaryDialog> {
  final _formKey = GlobalKey<FormState>();

  // ✅ MODELS
  final BeneficiaryDetails beneficiary = BeneficiaryDetails();
  final AssistanceDetails assistance = AssistanceDetails();
  final BankDetails bank = BankDetails();
  final BeneficiaryDocuments documents = BeneficiaryDocuments();

  // ✅ Accordion States
  bool b1 = true;
  bool b2 = false;
  bool b3 = false;
  bool b4 = false;
  bool b5 = false;
  bool b6 = false;

  @override
  void dispose() {
    assistance.amountNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ================= HEADER =================
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xff001E3C),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Add Handloom & Handicrafts Beneficiary",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // ================= BODY =================
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ✅ Beneficiary Details
                      AccordionSection(
                        title: "Beneficiary Details",
                        expanded: b1,
                        onToggle: () => setState(() => b1 = !b1),
                        children: [
                          BeneficiaryDetailsWidget(
                            model: beneficiary,
                            blocks: widget.blocks,
                            villages: widget.villages,
                          ),
                        ],
                      ),

                      // ✅ Handloom Assistance (Checkbox Based)
                      AccordionSection(
                        title: "Select Assistance",
                        expanded: b2,
                        onToggle: () => setState(() => b2 = !b2),
                        children: [HandloomAssistanceWidget(model: assistance)],
                      ),

                      // ✅ Amount Widget (Auto Updates)
                      AccordionSection(
                        title: "Amount Eligible As Per SDRF Norms",
                        expanded: b3,
                        onToggle: () => setState(() => b3 = !b3),
                        children: [AmountWidget(model: assistance)],
                      ),

                      // ✅ Bank Details Widget
                      AccordionSection(
                        title: "Beneficiary Bank Account Details",
                        expanded: b4,
                        onToggle: () => setState(() => b4 = !b4),
                        children: [BankDetailsWidget(model: bank)],
                      ),

                      // ✅ Remarks Widget
                      AccordionSection(
                        title: "Remarks",
                        expanded: b6,
                        onToggle: () => setState(() => b6 = !b6),
                        children: [RemarksWidget(model: assistance)],
                      ),

                      // ✅ Documents Widget
                      AccordionSection(
                        title: "Documents",
                        expanded: b5,
                        onToggle: () => setState(() => b5 = !b5),
                        children: [
                          BeneficiaryDocumentsWidget(model: documents),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ================= FOOTER BUTTONS =================
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveHandloomBeneficiary,
                        child: const Text("Save"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= SAVE FUNCTION =================

  void _saveHandloomBeneficiary() {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        b1 = true;
      });
      return;
    }

    // ✅ Ensure at least one checkbox selected
    if (assistance.amountNotifier.value == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one assistance type"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final payload = {
      "beneficiary": beneficiary.toJson(),
      "assistance": assistance.toJson(),
      "bank": bank.toJson(),
      "documents": documents.files
          .map((f) => {"filename": f.path.split('/').last, "path": f.path})
          .toList(),
    };

    widget.onSave(payload);
    Navigator.pop(context);
  }
}
