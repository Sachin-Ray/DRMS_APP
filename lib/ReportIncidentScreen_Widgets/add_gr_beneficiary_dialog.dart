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

  final BeneficiaryDetails beneficiary = BeneficiaryDetails();
  final AssistanceDetails assistance = AssistanceDetails();
  final BankDetails bank = BankDetails();

  bool b1 = true;
  bool b2 = false;
  bool b3 = false;
  bool b4 = false;
  bool b5 = false;
  bool b6 = false;

  bool isSubmitting = false;
  bool uploadingDocs = false;

  bool freezeForm = false;

  String? generatedBeneficiaryId;

  bool showRequiredDocs = false;
  List<RequiredDocument> requiredDocs = [];

  Map<int, File?> uploadedDocs = {};

  @override
  void dispose() {
    assistance.amountNotifier.dispose();
    super.dispose();
  }

  // ==========================================================
  // CONFIRMATION DIALOG
  // ==========================================================
  Future<bool?> _showConfirmDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Confirmation"),
        content: const Text(
          "Are you sure you want to save beneficiary details?\n"
          "After saving, you can upload enclosures.",
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

      // ✅ Assistance Head should come dynamically later
      "assistanceHead": "AH-GR",

      "normSelect": [assistance.normCode],
    };

    final result = await APIService.instance.submitSaveAssistanceForm(payload);

    setState(() => isSubmitting = false);

    if (result != null && result["status"] == "SUCCESS") {
      // ✅ Beneficiary ID from response
      generatedBeneficiaryId = result["data"]["body"].toString().trim();

      debugPrint("✅ Beneficiary ID Generated: $generatedBeneficiaryId");

      // ✅ Fetch Required Documents
      requiredDocs = await APIService.instance.fetchDocuments(
        assistance.normCode!,
        widget.firNo,
      );

      // ✅ Freeze Form + Open Upload Section
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

  Future<void> _uploadEnclosures() async {
    if (generatedBeneficiaryId == null) {
      _showErrorDialog("Beneficiary ID not found.");
      return;
    }

    if (uploadedDocs.isEmpty) {
      _showErrorDialog("Please upload at least one enclosure.");
      return;
    }

    setState(() => uploadingDocs = true);

    List<Map<String, dynamic>> docsPayload = [];

    for (final entry in uploadedDocs.entries) {
      final documentCode = entry.key;
      final file = entry.value!;

      final doc = requiredDocs.firstWhere(
        (d) => d.documentCode == documentCode,
      );

      final bytes = await file.readAsBytes();

      final mimeType = lookupMimeType(file.path) ??
          "application/octet-stream";

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Beneficiary + Enclosures Uploaded Successfully"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
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

              // ================= BODY =================
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ✅ FORM SECTION (Frozen after Save)
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
                              children: [
                                AssistanceWidget(model: assistance),
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
                                  elevation: 1,
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

                            const SizedBox(height: 20),

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
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
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

                    // ✅ Save Button Hidden After Freeze
                    if (!freezeForm)
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
