import 'dart:convert';
import 'dart:io';

import 'package:drms/ReportIncidentScreen_Widgets/accordion_section.dart';
import 'package:drms/ReportIncidentScreen_Widgets/agriculture_assistance_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/amount_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/bank_details_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/beneficiary_details_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/remarks_widget.dart';

import 'package:drms/model/beneficiary_models.dart';
import 'package:drms/model/Block.dart';
import 'package:drms/model/Village.dart';
import 'package:drms/model/RequiredDocument.dart';

import 'package:drms/services/APIService.dart';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';

class AddAgricultureBeneficiaryDialog extends StatefulWidget {
  final List<Block> blocks;
  final List<Village> villages;
  final String firNo;

  const AddAgricultureBeneficiaryDialog({
    super.key,
    required this.blocks,
    required this.villages,
    required this.firNo,
  });

  @override
  State<AddAgricultureBeneficiaryDialog> createState() =>
      _AddAgricultureBeneficiaryDialogState();
}

class _AddAgricultureBeneficiaryDialogState
    extends State<AddAgricultureBeneficiaryDialog> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  // ======================================================
  // MODELS
  // ======================================================
  final BeneficiaryDetails beneficiary = BeneficiaryDetails();
  final AssistanceDetails assistance = AssistanceDetails();
  final BankDetails bank = BankDetails();

  // Accordion Expand States
  bool b1 = true;
  bool b2 = true;
  bool b3 = true;
  bool b4 = true;
  bool b5 = true;
  bool b6 = true;

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
  // CONFIRMATION DIALOG
  // ======================================================
  Future<bool?> _showConfirmDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
  // ERROR POPUP
  // ======================================================
  Future<void> _showErrorDialog(String msg) {
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
  // SUBMIT AGRICULTURE BENEFICIARY
  // ======================================================
  Future<void> _submitAgricultureBeneficiary() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => b1 = true);
      return;
    }

    if (assistance.normCodes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one Agriculture norm."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await _showConfirmDialog();
    if (confirm != true) return;

    setState(() => isSubmitting = true);

    // ======================================================
    // ✅ PAYLOAD EXACTLY AS REQUIRED
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

      // ✅ Assistance Head
      "assistanceHead": "AH-AG",

      "normSelect": assistance.normCodes,

      "landarea": assistance.landAreaAffected,
      "cropsown": assistance.cropSownArea,
      "landHoldingArea": assistance.landHoldingArea,
    };

    debugPrint("=====================================");
    debugPrint("🌾 Agriculture Beneficiary Payload:");
    debugPrint(payload.toString());
    debugPrint("=====================================");

    final result = await APIService.instance.submitSaveAssistanceForm(payload);

    setState(() => isSubmitting = false);
    if (result != null && result["status"] == "SUCCESS") {
      generatedBeneficiaryId = result["data"]["body"].toString().trim();

      debugPrint("✅ Agriculture Beneficiary Saved ID = $generatedBeneficiaryId");

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

      // Auto Scroll Down
      await Future.delayed(const Duration(milliseconds: 300));

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    } else {
      _showErrorDialog("Submission Failed. Please try again.");
    }
  }

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
    return requiredDocs.every(
      (doc) => uploadedDocs[doc.documentCode] != null,
    );
  }

  Future<void> _uploadEnclosures() async {
    if (!allDocsUploaded) {
      _showErrorDialog("All enclosures are mandatory. Please upload all files.");
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
          content: Text("✅ Agriculture Beneficiary + Enclosures Uploaded"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _showErrorDialog("Upload Failed. Please try again.");
    }
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
                        "Add Agriculture Beneficiary",
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
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: const Text(
                            "✅ Beneficiary Saved Successfully! Upload enclosures below.",
                            style: TextStyle(fontWeight: FontWeight.w600),
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
                              title: "Select Agriculture Assistance",
                              expanded: b2,
                              onToggle: () => setState(() => b2 = !b2),
                              children: [
                                AgricultureAssistanceWidget(model: assistance),
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
                              title: "Bank Details",
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

                      if (showRequiredDocs)
                        AccordionSection(
                          title: "Upload Enclosures (Mandatory)",
                          expanded: b5,
                          onToggle: () => setState(() => b5 = !b5),
                          children: [
                            Column(
                              children: requiredDocs.map((doc) {
                                final file =
                                    uploadedDocs[doc.documentCode];

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
                                          file == null ? "Choose" : "Change"),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.cloud_upload),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                ),
                                label: uploadingDocs
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text("Upload All Enclosures"),
                                onPressed: uploadingDocs
                                    ? null
                                    : _uploadEnclosures,
                              ),
                            )
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        isSubmitting ? null : _submitAgricultureBeneficiary,
                    child: isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Save Agriculture Beneficiary"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
