import 'dart:io';

import 'package:drms/ReportIncidentScreen_Widgets/accordion_section.dart';
import 'package:drms/ReportIncidentScreen_Widgets/amount_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/bank_details_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/beneficiary_details_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/fishery_assistance_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/remarks_widget.dart';

import 'package:drms/model/Block.dart';
import 'package:drms/model/RequiredDocument.dart';
import 'package:drms/model/Village.dart';
import 'package:drms/model/beneficiary_models.dart';
import 'package:drms/services/APIService.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddFisheryBeneficiaryDialog extends StatefulWidget {
  final List<Block> blocks;
  final List<Village> villages;
  final String firNo;

  const AddFisheryBeneficiaryDialog({
    super.key,
    required this.blocks,
    required this.villages,
    required this.firNo,
  });

  @override
  State<AddFisheryBeneficiaryDialog> createState() =>
      _AddFisheryBeneficiaryDialogState();
}

class _AddFisheryBeneficiaryDialogState
    extends State<AddFisheryBeneficiaryDialog> {
  final _formKey = GlobalKey<FormState>();

  // MODELS
  final BeneficiaryDetails beneficiary = BeneficiaryDetails();
  final AssistanceDetails assistance = AssistanceDetails();
  final BankDetails bank = BankDetails();

  // Accordion State
  bool b1 = true;
  bool b2 = false;
  bool b3 = false;
  bool b4 = false;
  bool b5 = false;
  bool b6 = false;

  bool isSubmitting = false;

  // Required Docs
  bool showRequiredDocs = false;
  List<RequiredDocument> requiredDocs = [];
  Map<int, File?> uploadedDocs = {};

  // ============================================================
  // SUBMIT FISHERY BENEFICIARY
  // ============================================================
  Future<void> _submitBeneficiary() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => b1 = true);
      return;
    }

    if (assistance.assistanceTypeList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select Boat or Net")),
      );
      return;
    }

    setState(() => isSubmitting = true);

    final payload = {
      "beneficiaryName": beneficiary.name,
      "ageCategory": beneficiary.ageCategory,
      "gender": beneficiary.gender,
      "blockcode": beneficiary.blockCode,
      "villagecode": beneficiary.village,

      // FIR
      "firNo": widget.firNo,

      // ✅ Assistance Head for Fishery
      "assistanceHead": "AH-FS",

      // ✅ Boat/Net Subtypes
      "assistanceType": assistance.assistanceTypeList,

      // Norm Code (if needed later)
      "normSelect": assistance.selectedNormCodes,

      // Bank Details
      "ifsc": bank.ifsc,
      "bankName": bank.bankName,
      "branchCode": bank.branchCode,
      "acNumber": bank.accountNumber,

      // Remarks
      "remarks": assistance.remarks,
    };

    debugPrint("FISHERY PAYLOAD: $payload");

    final result = await APIService.instance.submitSaveAssistanceForm(payload);

    setState(() => isSubmitting = false);

    if (result != null && result["status"] == "SUCCESS") {
      final normCode = assistance.selectedNormCodes.isNotEmpty
          ? assistance.selectedNormCodes.first
          : 0;

      requiredDocs =
          await APIService.instance.fetchDocuments(normCode, widget.firNo);

      setState(() {
        showRequiredDocs = true;
        b5 = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fishery Beneficiary Added Successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Submission Failed")),
      );
    }
  }

  // ============================================================
  // UI BUILD
  // ============================================================
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(
                  color: Color(0xff001E3C),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Add Fishery Beneficiary",
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
                      // Beneficiary Details
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

                      // Fishery Assistance
                      AccordionSection(
                        title: "Fishery assistance specific details",
                        expanded: b2,
                        onToggle: () => setState(() => b2 = !b2),
                        children: [
                          FisheryAssistanceWidget(model: assistance),
                        ],
                      ),

                      // Amount
                      AccordionSection(
                        title: "Total Amount Eligible As Per SDRF Norms",
                        expanded: b3,
                        onToggle: () => setState(() => b3 = !b3),
                        children: [
                          AmountWidget(model: assistance),
                        ],
                      ),

                      // Bank Details
                      AccordionSection(
                        title: "Beneficiary Bank Details",
                        expanded: b4,
                        onToggle: () => setState(() => b4 = !b4),
                        children: [
                          BankDetailsWidget(model: bank),
                        ],
                      ),

                      // Remarks
                      AccordionSection(
                        title: "Remarks",
                        expanded: b6,
                        onToggle: () => setState(() => b6 = !b6),
                        children: [
                          RemarksWidget(model: assistance),
                        ],
                      ),

                      // Upload Docs
                      if (showRequiredDocs)
                        AccordionSection(
                          title: "Upload Enclosures",
                          expanded: b5,
                          onToggle: () => setState(() => b5 = !b5),
                          children: requiredDocs.map((doc) {
                            return ListTile(
                              title: Text(doc.documentName),
                              trailing: ElevatedButton(
                                child: const Text("UPLOAD"),
                                onPressed: () async {
                                  final picked = await ImagePicker().pickImage(
                                    source: ImageSource.gallery,
                                  );

                                  if (picked != null) {
                                    setState(() {
                                      uploadedDocs[doc.documentCode] =
                                          File(picked.path);
                                    });
                                  }
                                },
                              ),
                            );
                          }).toList(),
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
                        onPressed: isSubmitting ? null : _submitBeneficiary,
                        child: isSubmitting
                            ? const CircularProgressIndicator()
                            : const Text("Save Fishery Beneficiary"),
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
}
