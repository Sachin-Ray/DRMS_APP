import 'dart:convert';
import 'dart:io';

import 'package:drms/ReportIncidentScreen_Widgets/accordion_section.dart';
import 'package:drms/ReportIncidentScreen_Widgets/amount_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/assistance_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/bank_details_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/beneficiary_details_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/remarks_widget.dart';

import 'package:drms/model/beneficiary_models.dart';
import 'package:drms/model/Block.dart';
import 'package:drms/model/RequiredDocument.dart';
import 'package:drms/model/Village.dart';
import 'package:drms/services/APIService.dart';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';

class AddBeneficiaryDialog extends StatefulWidget {
  final List<Block> blocks;
  final List<Village> villages;
  final String firNo;

  const AddBeneficiaryDialog({
    super.key,
    required this.blocks,
    required this.villages,
    required this.firNo,
  });

  @override
  State<AddBeneficiaryDialog> createState() => _AddBeneficiaryDialogState();
}

class _AddBeneficiaryDialogState extends State<AddBeneficiaryDialog> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  final BeneficiaryDetails beneficiary = BeneficiaryDetails();
  final AssistanceDetails assistance = AssistanceDetails();
  final BankDetails bank = BankDetails();

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

  Future<bool?> _showConfirmDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Confirmation"),
        content: const Text(
          "Are you sure you want to save beneficiary details?\n"
          "After saving, you must upload all enclosures.",
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
      "ifsc": bank.ifsc,
      "bankName": bank.bankName,
      "branchCode": bank.branchCode,
      "acNumber": bank.accountNumber,
      "remarks": assistance.remarks,
      "firNo": widget.firNo,
      "assistanceHead": "AH-GR",
      "normSelect": [assistance.normCode],
      if (assistance.normCode == 1) "victimNames": assistance.victimNames,
    };

    final result = await APIService.instance.submitSaveAssistanceForm(payload);

    setState(() => isSubmitting = false);

    if (result != null && result["status"] == "SUCCESS") {
      generatedBeneficiaryId = result["data"]["body"].toString().trim();

      requiredDocs = await APIService.instance.fetchDocuments(
        assistance.normCode!,
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
      _showErrorDialog("Submission failed. Please try again.");
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
    return requiredDocs.every((doc) => uploadedDocs[doc.documentCode] != null);
  }

  Future<void> _uploadEnclosures() async {
    if (!allDocsUploaded) {
      _showErrorDialog(
        "All enclosures are mandatory. Please upload all files.",
      );
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
          content: Text("✅ Beneficiary + Enclosures Uploaded Successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _showErrorDialog("Upload failed. Please try again.");
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
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                ),
              ),

              Flexible(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ✅ SUCCESS BANNER
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
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Beneficiary Saved Successfully! Upload all mandatory enclosures below.",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // FORM SECTION
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
                              title: "Select Assistance",
                              expanded: b2,
                              onToggle: () => setState(() => b2 = !b2),
                              children: [AssistanceWidget(model: assistance)],
                            ),
                            AccordionSection(
                              title: "Amount Eligible",
                              expanded: b3,
                              onToggle: () => setState(() => b3 = !b3),
                              children: [AmountWidget(model: assistance)],
                            ),
                            AccordionSection(
                              title: "Bank Account Details",
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
                                  elevation: 1,
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

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.cloud_upload),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                label: uploadingDocs
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        "Upload All Enclosures",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                onPressed: uploadingDocs
                                    ? null
                                    : _uploadEnclosures,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (!freezeForm)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : _submitBeneficiary,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Save Beneficiary Details",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
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
