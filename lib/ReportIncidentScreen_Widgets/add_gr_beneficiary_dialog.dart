import 'dart:io';

import 'package:drms/ReportIncidentScreen_Widgets/accordion_section.dart';
import 'package:drms/ReportIncidentScreen_Widgets/amount_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/assistance_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/bank_details_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/beneficiary_details_widget.dart';
import 'package:drms/model/beneficiary_models.dart';
import 'package:drms/ReportIncidentScreen_Widgets/remarks_widget.dart';

import 'package:drms/model/Block.dart';
import 'package:drms/model/ExGratiaBeneficiary.dart';
import 'package:drms/model/RequiredDocument.dart';
import 'package:drms/model/Village.dart';
import 'package:drms/services/APIService.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddBeneficiaryDialog extends StatefulWidget {
  final List<Block> blocks;
  final List<Village> villages;
  final String firNo;
  final ExGratiaBeneficiary? existingBeneficiary;

  const AddBeneficiaryDialog({
    super.key,
    required this.blocks,
    required this.villages,
    required this.firNo,
    this.existingBeneficiary,
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
  bool b6 = false;

  // SUBMISSION STATE
  bool isSubmitting = false;

  // REQUIRED DOCUMENTS
  bool showRequiredDocs = false;
  List<RequiredDocument> requiredDocs = [];
  Map<int, File?> uploadedDocs = {};
  Map<int, File?> selectedFiles = {};

  @override
  void dispose() {
    assistance.amountNotifier.dispose();
    super.dispose();
    final b = widget.existingBeneficiary;
    if (b == null) return;

    beneficiary.name = b.beneficiaryName;
    beneficiary.gender = b.gender;
    beneficiary.ageCategory = b.age;
    beneficiary.blockCode = b.blockCode;
    beneficiary.village = b.villageCode;

    bank.bankName = b.bankName;
    bank.branchCode = b.branchCode;
    bank.ifsc = b.ifscCode;
    bank.accountNumber = b.accountNumber;

    assistance.normCode = b.normCode.first;
    assistance.victimNames = b.documents.isEmpty
        ? []
        : b.documents.map((e) => e.documentName).toList();
  }

  Future<bool?> _showConfirmDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: const [
              Icon(Icons.help, color: Colors.green),
              SizedBox(width: 8),
              Text("Confirmation"),
            ],
          ),
          content: const Text(
            "Are you sure you want to add beneficiary details?\n"
            "You will be able to edit later on.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("NO"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("YES"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSuccessDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text("Success"),
            ],
          ),
          content: const Text(
            "Beneficiary Details has been added successfully.",
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showErrorDialog(String msg) {
    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(msg),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitBeneficiary() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => b1 = true);
      return;
    }

    final confirm = await _showConfirmDialog();
    if (confirm != true) return;

    setState(() => isSubmitting = true);

    final payload = {
      "beneficiaryName": beneficiary.name,
      "ageCategory": beneficiary.ageCategory,
      "gender": beneficiary.gender,

      "blockcode": beneficiary.blockCode,
      "villagecode": beneficiary.village,
      "victimNames": assistance.victimNames,
      "ifsc": bank.ifsc,
      "bankName": bank.bankName,
      "branchCode": bank.branchCode,
      "acNumber": bank.accountNumber,
      "remarks": assistance.remarks,
      "firNo": widget.firNo,
      "assistanceHead": "AH-GR",
      "normSelect": [assistance.normCode],
    };

    debugPrint("GRATUITOUS RELIEF PAYLOAD: $payload");
    final result = await APIService.instance.submitSaveAssistanceForm(payload);

    setState(() => isSubmitting = false);

    if (result != null && result["status"] == "SUCCESS") {
      await _showSuccessDialog();
      final normCode = assistance.selectedNormCodes.first;
      final firNo = widget.firNo;

      requiredDocs = await APIService.instance.fetchDocuments(normCode, firNo);
      setState(() {
        showRequiredDocs = true;
        b5 = true;
      });
    } else {
      _showErrorDialog("Submission failed. Please try again.");
    }
  }

  // ----------------------------------------------------------
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                        children: [AssistanceWidget(model: assistance)],
                      ),

                      AccordionSection(
                        title: "Amount Eligible As Per SDRF Norms",
                        expanded: b3,
                        onToggle: () => setState(() => b3 = !b3),
                        children: [AmountWidget(model: assistance)],
                      ),

                      AccordionSection(
                        title: "Beneficiary Bank Account Details",
                        expanded: b4,
                        onToggle: () => setState(() => b4 = !b4),
                        children: [BankDetailsWidget(model: bank)],
                      ),

                      AccordionSection(
                        title: "Remarks",
                        expanded: b6,
                        onToggle: () => setState(() => b6 = !b6),
                        children: [RemarksWidget(model: assistance)],
                      ),

                      // ✅ Upload Enclosures Dynamic Section
                      if (showRequiredDocs)
                        AccordionSection(
                          title: "Upload Enclosures",
                          expanded: b5,
                          onToggle: () => setState(() => b5 = !b5),
                          children: [
                            Column(
                              children: requiredDocs.map((doc) {
                                final file = uploadedDocs[doc.documentCode];

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      color: Colors.grey.shade50,
                                    ),
                                    child: Row(
                                      children: [
                                        // Document Name
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            doc.documentName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),

                                        // Choose File Button
                                        Expanded(
                                          flex: 2,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              final picked = await ImagePicker()
                                                  .pickImage(
                                                    source: ImageSource.gallery,
                                                  );

                                              if (picked != null) {
                                                setState(() {
                                                  uploadedDocs[doc
                                                      .documentCode] = File(
                                                    picked.path,
                                                  );
                                                });
                                              }
                                            },
                                            child: const Text("UPLOAD"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 10),

                            // Show Selected Files Preview
                            ...uploadedDocs.entries.map((entry) {
                              final docName = requiredDocs
                                  .firstWhere(
                                    (d) => d.documentCode == entry.key,
                                  )
                                  .documentName;

                              return ListTile(
                                leading: const Icon(Icons.attach_file),
                                title: Text(docName),
                                subtitle: Text(
                                  entry.value!.path.split("/").last,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.close,  
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      uploadedDocs.remove(entry.key);
                                    });
                                  },
                                ),
                              );
                            }).toList(),
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
                        onPressed: isSubmitting ? null : _submitBeneficiary,
                        child: isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Save Beneficiary Details"),
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
