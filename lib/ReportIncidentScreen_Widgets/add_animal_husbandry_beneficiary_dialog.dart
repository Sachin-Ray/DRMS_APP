import 'dart:convert';
import 'dart:io';

import 'package:drms/ReportIncidentScreen_Widgets/accordion_section.dart';
import 'package:drms/ReportIncidentScreen_Widgets/amount_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/animal_husbandry_assistance_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/bank_details_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/beneficiary_details_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/remarks_widget.dart';

import 'package:drms/model/Block.dart';
import 'package:drms/model/RequiredDocument.dart';
import 'package:drms/model/Village.dart';
import 'package:drms/model/beneficiary_models.dart';
import 'package:drms/services/APIService.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

class AddAnimalHusbandryBeneficiaryDialog extends StatefulWidget {
  final List<Block> blocks;
  final List<Village> villages;
  final String firNo;

  const AddAnimalHusbandryBeneficiaryDialog({
    super.key,
    required this.blocks,
    required this.villages,
    required this.firNo,
  });

  @override
  State<AddAnimalHusbandryBeneficiaryDialog> createState() =>
      _AddAnimalHusbandryBeneficiaryDialogState();
}

class _AddAnimalHusbandryBeneficiaryDialogState
    extends State<AddAnimalHusbandryBeneficiaryDialog> {
  final _formKey = GlobalKey<FormState>();

  // MODELS
  final BeneficiaryDetails beneficiary = BeneficiaryDetails();
  final AssistanceDetails assistance = AssistanceDetails();
  final BankDetails bank = BankDetails();

  // Accordion States
  bool b1 = true;
  bool b2 = false;
  bool b3 = false;
  bool b4 = false;
  bool b5 = false;
  bool b6 = false;

  bool isSubmitting = false;
  bool uploadingDocs = false;

  bool freezeForm = false;
  bool showRequiredDocs = false;

  String? generatedBeneficiaryId;

  List<RequiredDocument> requiredDocs = [];
  Map<int, File?> uploadedDocs = {};

  @override
  void dispose() {
    assistance.amountNotifier.dispose();
    super.dispose();
  }

  // ======================================================
  // SUBMIT BENEFICIARY
  // ======================================================
  Future<void> _submitBeneficiary() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => b1 = true);
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

      // ✅ Animal Husbandry Assistance Head
      "assistanceHead": "AH-AH",

      // Norm Selected
      "normSelect": [assistance.normCode],

      // Bank
      "ifsc": bank.ifsc,
      "bankName": bank.bankName,
      "branchCode": bank.branchCode,
      "acNumber": bank.accountNumber,

      // Remarks
      "remarks": assistance.remarks,
    };

    final result = await APIService.instance.submitSaveAssistanceForm(payload);

    setState(() => isSubmitting = false);

    if (result != null && result["status"] == "SUCCESS") {
      generatedBeneficiaryId = result["data"]["body"].toString().trim();

      debugPrint("✅ Animal Husbandry Beneficiary ID: $generatedBeneficiaryId");

      // Fetch Required Docs
      requiredDocs = await APIService.instance.fetchDocuments(
        assistance.normCode!,
        widget.firNo,
      );

      setState(() {
        freezeForm = true;
        showRequiredDocs = true;
        b5 = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "✅ Beneficiary Saved ($generatedBeneficiaryId). Upload Enclosures Now.",
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _showError("Submission Failed");
    }
  }

  // ======================================================
  // PICK FILE
  // ======================================================
  Future<void> _pickFile(int docCode) async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
    );

    if (picked != null && picked.files.single.path != null) {
      setState(() {
        uploadedDocs[docCode] = File(picked.files.single.path!);
      });
    }
  }

  // ======================================================
  // UPLOAD ENCLOSURES
  // ======================================================
  Future<void> _uploadEnclosures() async {
    if (generatedBeneficiaryId == null) {
      _showError("Beneficiary ID not found.");
      return;
    }

    if (uploadedDocs.isEmpty) {
      _showError("Please upload at least one document.");
      return;
    }

    setState(() => uploadingDocs = true);

    List<Map<String, dynamic>> docsPayload = [];

    for (final entry in uploadedDocs.entries) {
      final docCode = entry.key;
      final file = entry.value!;

      final doc = requiredDocs.firstWhere(
        (d) => d.documentCode == docCode,
      );

      final bytes = await file.readAsBytes();
      final mimeType =
          lookupMimeType(file.path) ?? "application/octet-stream";

      docsPayload.add({
        "filename": doc.documentName,
        "contentType": mimeType,
        "base64Data": base64Encode(bytes),
        "documentType": "ENCLOSURE",
        "documentCode": doc.documentCode,
      });
    }

    final success = await APIService.instance.uploadBeneficiaryDocuments(
      beneficiaryId: generatedBeneficiaryId!,
      documents: docsPayload,
    );

    setState(() => uploadingDocs = false);

    if (success) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Enclosures Uploaded Successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _showError("Upload Failed");
    }
  }

  // ======================================================
  // ERROR POPUP
  // ======================================================
  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  // ======================================================
  // UI BUILD
  // ======================================================
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
                padding: const EdgeInsets.all(16),
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
                        "Add Animal Husbandry Beneficiary",
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
                    )
                  ],
                ),
              ),

              // ================= BODY =================
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      AbsorbPointer(
                        absorbing: freezeForm,
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
                                )
                              ],
                            ),

                            AccordionSection(
                              title: "Select Assistance",
                              expanded: b2,
                              onToggle: () => setState(() => b2 = !b2),
                              children: [
                                AnimalHusbandryAssistanceWidget(model:assistance),
                              ],
                            ),

                            AccordionSection(
                              title: "Amount Eligible",
                              expanded: b3,
                              onToggle: () => setState(() => b3 = !b3),
                              children: [
                                AmountWidget(model: assistance),
                              ],
                            ),

                            AccordionSection(
                              title: "Bank Account Details",
                              expanded: b4,
                              onToggle: () => setState(() => b4 = !b4),
                              children: [
                                BankDetailsWidget(model: bank),
                              ],
                            ),

                            AccordionSection(
                              title: "Remarks",
                              expanded: b6,
                              onToggle: () => setState(() => b6 = !b6),
                              children: [
                                RemarksWidget(model: assistance),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ================= UPLOAD SECTION =================
                      if (showRequiredDocs)
                        AccordionSection(
                          title: "Upload Enclosures",
                          expanded: b5,
                          onToggle: () => setState(() => b5 = !b5),
                          children: [
                            Column(
                              children: requiredDocs.map((doc) {
                                final file = uploadedDocs[doc.documentCode];

                                return Card(
                                  child: ListTile(
                                    title: Text(doc.documentName),
                                    subtitle: file == null
                                        ? const Text("No file selected")
                                        : Text(
                                            file.path.split("/").last,
                                            style: const TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                    trailing: ElevatedButton(
                                      onPressed: () =>
                                          _pickFile(doc.documentCode),
                                      child: Text(
                                        file == null ? "Choose" : "Change",
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 16),

                            ElevatedButton.icon(
                              icon: const Icon(Icons.cloud_upload),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 20,
                                ),
                              ),
                              label: uploadingDocs
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text("Upload Enclosures"),
                              onPressed:
                                  uploadingDocs ? null : _uploadEnclosures,
                            )
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              // ================= FOOTER =================
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
                    if (!freezeForm)
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              isSubmitting ? null : _submitBeneficiary,
                          child: isSubmitting
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text("Save Beneficiary"),
                        ),
                      ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
