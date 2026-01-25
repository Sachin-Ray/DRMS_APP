import 'package:drms/ReportIncidentScreen_Widgets/accordion_section.dart';
import 'package:drms/ReportIncidentScreen_Widgets/amount_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/assistance_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/bank_details_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/beneficiary_details_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/beneficiary_documents_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/beneficiary_models.dart';
import 'package:drms/model/Block.dart';
import 'package:drms/model/Village.dart';
import 'package:flutter/material.dart';

class AddBeneficiaryDialog extends StatefulWidget {
  final List<Block> blocks;
  final List<Village> villages;
  final Function(Map<String, dynamic>) onSave;

  const AddBeneficiaryDialog({
    super.key,
    required this.blocks,
    required this.villages,
    required this.onSave,
  });

  @override
  State<AddBeneficiaryDialog> createState() => _AddBeneficiaryDialogState();
}

class _AddBeneficiaryDialogState extends State<AddBeneficiaryDialog> {
  final _formKey = GlobalKey<FormState>();

  // MODELS
  final BeneficiaryDetails beneficiary = BeneficiaryDetails();
  final AssistanceDetails assistance = AssistanceDetails();
  final BankDetails bank = BankDetails();
  final BeneficiaryDocuments documents = BeneficiaryDocuments();

  // ACCORDION STATE
  bool b1 = true;
  bool b2 = false;
  bool b3 = false;
  bool b4 = false;
  bool b5 = false;

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
              // HEADER
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xff001E3C),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Add Beneficiary",
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

              // BODY
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
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

                      AccordionSection(
                        title: "Select Assistance",
                        expanded: b2,
                        onToggle: () => setState(() => b2 = !b2),
                        children: [
                          AssistanceWidget(model: assistance),
                        ],
                      ),

                      AccordionSection(
                        title: "Amount Eligible As Per SDRF Norms",
                        expanded: b3,
                        onToggle: () => setState(() => b3 = !b3),
                        children: [
                          AmountWidget(model: assistance),
                        ],
                      ),

                      AccordionSection(
                        title: "Beneficiary Bank Account Details",
                        expanded: b4,
                        onToggle: () => setState(() => b4 = !b4),
                        children: [
                          BankDetailsWidget(model: bank),
                        ],
                      ),

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

              // FOOTER BUTTONS
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
                        onPressed: _saveBeneficiary,
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

  void _saveBeneficiary() {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        b1 = true;
      });
      return;
    }

    final payload = {
      "beneficiary": beneficiary.toJson(),
      "assistance": assistance.toJson(),
      "bank": bank.toJson(),
      "documents": documents.files
          .map(
            (f) => {
              "filename": f.path.split('/').last,
              "path": f.path,
            },
          )
          .toList(),
    };

    widget.onSave(payload);
    Navigator.pop(context);
  }
}
