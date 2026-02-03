import 'dart:convert';
import 'dart:io';

import 'package:drms/ReportIncidentScreen_Widgets/accordion_section.dart';
import 'package:drms/ReportIncidentScreen_Widgets/amount_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/bank_details_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/beneficiary_details_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/housing_damage_assistance_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/remarks_widget.dart';

import 'package:drms/model/Block.dart';
import 'package:drms/model/Village.dart';
import 'package:drms/model/RequiredDocument.dart';
import 'package:drms/services/APIService.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

import '../model/beneficiary_models.dart';

class AddHousingDamageBeneficiaryDialog extends StatefulWidget {
  final String firNo;
  final List<Block> blocks;
  final List<Village> villages;

  const AddHousingDamageBeneficiaryDialog({
    super.key,
    required this.firNo,
    required this.blocks,
    required this.villages,
  });

  @override
  State<AddHousingDamageBeneficiaryDialog> createState() =>
      _AddHousingDamageBeneficiaryDialogState();
}

class _AddHousingDamageBeneficiaryDialogState
    extends State<AddHousingDamageBeneficiaryDialog> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  // MODELS
  final BeneficiaryDetails beneficiary = BeneficiaryDetails();
  final AssistanceDetails assistance = AssistanceDetails();
  final BankDetails bank = BankDetails();

  // Accordion
  bool b1 = true, b2 = true, b3 = true, b4 = true, b5 = true, b6 = true;

  bool isSubmitting = false;
  bool uploadingDocs = false;

  bool freezeForm = false;
  bool beneficiarySaved = false;

  String? generatedBeneficiaryId;

  bool showRequiredDocs = false;
  List<RequiredDocument> requiredDocs = [];

  Map<int, File?> uploadedDocs = {};

  @override
  void dispose() {
    assistance.amountNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ======================================================
  // CONFIRMATION POPUP
  // ======================================================
  Future<bool?> _showConfirmDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text(
          "Are you sure you want to save beneficiary details?\n"
          "After saving, you must upload all mandatory enclosures.",
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
      ),
    );
  }

  // ======================================================
  // ERROR DIALOG
  // ======================================================
  Future<void> _showError(String msg) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // SUBMIT HOUSING BENEFICIARY
  // ======================================================
  Future<void> _submitHousingBeneficiary() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => b1 = true);
      return;
    }

    // if (assistance.normCodes.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text("Please select at least one Housing Assistance type"),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    //   return;
    // }

    final confirm = await _showConfirmDialog();
    if (confirm != true) return;

    setState(() => isSubmitting = true);

    // ======================================================
    // ✅ HOUSING PAYLOAD (Backend Format)
    // ======================================================
    final payload = {
      "beneficiaryName": beneficiary.name,
      "ageCategory": beneficiary.ageCategory,
      "gender": beneficiary.gender,
      "blockcode": beneficiary.blockCode,
      "villagecode": beneficiary.village,

      "ifsc": bank.ifsc,
      "bankName": bank.bankName,
      "branchCode": bank.branchCode,
      "acNumber": bank.accountNumber,

      "remarks": assistance.remarks,
      "firNo": widget.firNo,

      // ✅ Housing Assistance Head
      "assistanceHead": "AH-HU",

      // ✅ Multi Norm Select
      "normSelect": assistance.normCodes,

      // ✅ Extra Housing Field (Pucca/Kutcha)
      "IspuccaOrKutcha": assistance.isPuccaOrKutcha,
    };

    debugPrint("🏠 HOUSING PAYLOAD = $payload");

    final result = await APIService.instance.submitSaveAssistanceForm(payload);

    setState(() => isSubmitting = false);

    if (result != null && result["status"] == "SUCCESS") {
      generatedBeneficiaryId = result["data"]["body"].toString().trim();

      // ======================================================
      // ✅ Fetch Required Docs for Multi Norms
      // ======================================================
      requiredDocs = await APIService.instance.fetchDocumentsMulti(
        assistance.normCodes,
        widget.firNo,
      );

      setState(() {
        freezeForm = true;
        beneficiarySaved = true;
        showRequiredDocs = true;
        b5 = true;
      });

      // Scroll to upload section
      await Future.delayed(const Duration(milliseconds: 300));

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    } else {
      _showError("Submission failed. Please try again.");
    }
  }

  // ======================================================
  // PICK FILE
  // ======================================================
  Future<void> _pickFile(int documentCode) async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
    );

    if (picked != null && picked.files.single.path != null) {
      setState(() {
        uploadedDocs[documentCode] = File(picked.files.single.path!);
      });
    }
  }

  bool get allDocsUploaded {
    return requiredDocs.every((doc) => uploadedDocs[doc.documentCode] != null);
  }

  // ======================================================
  // UPLOAD ENCLOSURES
  // ======================================================
  Future<void> _uploadEnclosures() async {
    if (!allDocsUploaded) {
      _showError("All enclosures are mandatory. Please upload all files.");
      return;
    }

    setState(() => uploadingDocs = true);

    List<Map<String, dynamic>> docsPayload = [];

    for (final doc in requiredDocs) {
      final file = uploadedDocs[doc.documentCode]!;
      final bytes = await file.readAsBytes();
      final mimeType = lookupMimeType(file.path) ?? "application/octet-stream";

      docsPayload.add({
        "filename": doc.documentName,
        "contentType": mimeType,
        "base64Data": base64Encode(bytes),
        "documentCode": doc.documentCode,
      });
    }

    final success = await APIService.instance.uploadBeneficiaryDocuments(
      beneficiaryId: generatedBeneficiaryId!,
      documents: docsPayload,
    );

    setState(() => uploadingDocs = false);

    if (success) {
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Housing Beneficiary + Enclosures Uploaded"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _showError("Upload failed. Please try again.");
    }
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
            children: [
              // ================= HEADER =================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xff001E3C),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Add Housing Damage Beneficiary",
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
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (beneficiarySaved)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "✅ Beneficiary Saved Successfully. Upload enclosures below.",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),

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
                                ),
                              ],
                            ),
                            AccordionSection(
                              title: "Housing Assistance",
                              expanded: b2,
                              onToggle: () => setState(() => b2 = !b2),
                              children: [
                                HousingDamageAssistanceWidget(
                                  model: assistance,
                                ),
                              ],
                            ),
                            AccordionSection(
                              title: "Amount Eligible",
                              expanded: b3,
                              onToggle: () => setState(() => b3 = !b3),
                              children: [AmountWidget(model: assistance)],
                            ),
                            AccordionSection(
                              title: "Bank Details",
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
                          ],
                        ),
                      ),

                      // ================= UPLOAD SECTION =================
                      if (showRequiredDocs)
                        AccordionSection(
                          title: "Upload Enclosures (Mandatory)",
                          expanded: b5,
                          onToggle: () => setState(() => b5 = !b5),
                          children: [
                            Column(
                              children: requiredDocs.map((doc) {
                                final file = uploadedDocs[doc.documentCode];

                                return Card(
                                  child: ListTile(
                                    title: Text("${doc.documentName} *"),
                                    subtitle: file == null
                                        ? const Text("No file selected")
                                        : Text(
                                            file.path.split("/").last,
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w600,
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
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.cloud_upload),
                              label: uploadingDocs
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text("Upload All Enclosures"),
                              onPressed: uploadingDocs
                                  ? null
                                  : _uploadEnclosures,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              // ================= FOOTER =================
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submitHousingBeneficiary,
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save Housing Beneficiary"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}