import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drms/ReportIncidentScreen_Widgets/pdf_viewer_page.dart';
import 'package:drms/model/ExGratiaBeneficiary.dart';
import 'package:drms/services/APIService.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';

class ExGratiaBeneficiaryList extends StatelessWidget {
  final List<ExGratiaBeneficiary> list;
  final Function(ExGratiaBeneficiary) onEdit;
  final Function(ExGratiaBeneficiary) onDelete;
  final IconData icon;

  // Needed for SOP API
  final String firNo;
  final String assistanceHead;

  final Future<void> Function() onRefreshBeneficiaries;

  const ExGratiaBeneficiaryList({
    super.key,
    required this.list,
    required this.onEdit,
    required this.onDelete,
    required this.icon,

    // Add these
    required this.firNo,
    required this.assistanceHead,
    required this.onRefreshBeneficiaries,
  });

  static const String _docApiBase =
      "https://relief.megrevenuedm.gov.in/liveapi/drms/v-1/app/api/fetchFile";

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text("No records found")),
      );
    }

    return Column(
      children: [
        // Existing List View
        isMobile ? _mobileView(context) : _tableView(context),

        const SizedBox(height: 25),

        // ============================================================
        // Draft Proposal Button (Image 1)
        // ============================================================
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.description, color: Colors.white),
          label: const Text(
            "Draft Proposal",
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),

          // UPDATED LOGIC HERE
          onPressed: () {
            if (!_allBeneficiariesHaveDocuments()) {
              _showMissingDocMessage(context);
              return;
            }

            _openDraftProposalModal(context);
          },
        ),

        const SizedBox(height: 15),
      ],
    );
  }

  Widget _tableView(BuildContext context) {
    return Column(
      children: [
        _tableHeader(),
        const Divider(height: 1),
        ...list.asMap().entries.map((e) {
          final index = e.key + 1;
          final b = e.value;
          return _tableRow(context, index, b);
        }),
      ],
    );
  }

  bool _allBeneficiariesHaveDocuments() {
    return list.every((b) => b.documents.isNotEmpty);
  }

  void _showMissingDocMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade700,
        content: const Text(
          "❌ Please upload documents for all beneficiaries before drafting proposal.",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _tableHeader() {
    return Container(
      color: const Color(0xffDBEAFE),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: const Row(
        children: [
          _HCell("#", 1),
          _HCell("Beneficiary", 2),
          _HCell("Village", 2),
          _HCell("Assistance", 4),
          _HCell("Amount", 2),
          _HCell("Enclosures", 4),
          _HCell("Action", 2),
        ],
      ),
    );
  }

  Widget _tableRow(BuildContext context, int index, ExGratiaBeneficiary b) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      color: index.isEven ? Colors.grey.shade100 : Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cell(index.toString(), 1),
          _cell(b.beneficiaryName, 2),
          _cell(b.village, 2),
          _cell(b.assistance, 4),
          _cell("₹${b.amount}", 2),

          _documentsCell(context, b),
          _actionCell(b),
        ],
      ),
    );
  }

  Widget _mobileView(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final b = list[index];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.blue.shade50,
                          child: const Icon(
                            Icons.person,
                            color: Colors.blue,
                            size: 28,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.blue.shade600,
                            child: Text(
                              "${index + 1}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        b.beneficiaryName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    // Amount Badge FIXED
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        "₹${b.amount}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                _detailCard(
                  icon: Icons.location_on,
                  title: "Village",
                  value: b.village,
                ),

                const SizedBox(height: 12),

                _detailCard(
                  icon: icon,
                  title: "Assistance",
                  value: b.assistance,
                ),

                const SizedBox(height: 14),

                // Enclosures Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Enclosures",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (b.documents.isEmpty)
                        Text(
                          "No documents uploaded",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        )
                      else
                        ...b.documents.map(
                          (d) => InkWell(
                            onTap: () =>
                                _showDocOptions(context, d, b.beneficiaryName),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.attach_file,
                                    size: 18,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      d.documentName,
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openDraftProposalModal(BuildContext context) {
    // ✅ Unique Village Count
    final uniqueVillages = list.map((e) => e.village).toSet().length;

    // ✅ Household Count
    final households = list.length;

    final TextEditingController familyCtrl = TextEditingController();
    final TextEditingController remarksCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.green.shade100,
                      child: const Icon(
                        Icons.description,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "Draft Proposal",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _modernReadonlyField(
                        label: "Villages",
                        value: uniqueVillages.toString(),
                        icon: Icons.location_city,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _modernReadonlyField(
                        label: "Households",
                        value: households.toString(),
                        icon: Icons.house,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _modernInputField(
                  controller: familyCtrl,
                  label: "Family Members Affected",
                  icon: Icons.groups,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 14),

                _modernInputField(
                  controller: remarksCtrl,
                  label: "Remarks before forwarding",
                  icon: Icons.edit_note,
                  keyboardType: TextInputType.text,
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Freeze & Close",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
  if (familyCtrl.text.trim().isEmpty ||
      int.tryParse(familyCtrl.text.trim()) == null ||
      int.parse(familyCtrl.text.trim()) <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade700,
        content: const Text(
          "❌ Please enter valid family members affected.",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
    return;
  }

  if (remarksCtrl.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade700,
        content: const Text(
          "❌ Remarks are mandatory before forwarding.",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
    return;
  }

  Navigator.pop(context);

  _confirmFreezeDialog(
    context,
    uniqueVillages,
    households,
    familyCtrl.text.trim(),
    remarksCtrl.text.trim(),
  );
},

                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _modernReadonlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modernInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.green),
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.green, width: 1.5),
        ),
      ),
    );
  }


  void _confirmFreezeDialog(
    BuildContext context,
    int villages,
    int households,
    String familyCount,
    String remarks,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Confirmation"),
          content: const Text(
            "Are you sure you want to freeze and close?\n\n"
            "This action is final and cannot be undone.",
          ),
          actions: [
            TextButton(
              child: const Text("NO"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("YES"),
              onPressed: () async {
                Navigator.pop(context);

                final success = await _submitGenerateSOP(
                  remarks: remarks,
                  villages: villages,
                  households: households,
                  familyAffected: int.tryParse(familyCount) ?? 0,
                );

                debugPrint("📌 SOP Generation Result: $success");

                _showResultDialog(context, success);
              },
            ),
          ],
        );
      },
    );
  }


  Future<bool> _submitGenerateSOP({
    required String remarks,
    required int villages,
    required int households,
    required int familyAffected,
  }) async {
    debugPrint("📤 Generating SOP...");

    final result = await APIService.instance.generateSOPReport(
      firNo: firNo,
      remarks: remarks,
      villages: villages,
      households: households,
      familyAffected: familyAffected,
      assistanceHead: assistanceHead,
    );

    debugPrint("📌 SOP Result: $result");

    if (result != null && result["status"] == "SUCCESS") {
      debugPrint("✅ SOP Generated Successfully");

      // Refresh Beneficiary List from Parent Screen
      await onRefreshBeneficiaries();

      return true;
    }

    debugPrint("❌ SOP Generation Failed");
    return false;
  }


  void _showResultDialog(BuildContext context, bool success) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(success ? "Success" : "Error"),
          content: Text(
            success
                ? "✅ Proposal Drafted Successfully!"
                : "❌ Failed to Draft Proposal. Please try again.",
          ),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> _fetchBase64Doc(String docCode) async {
    final url = "$_docApiBase?doc=$docCode";
    final response = await Dio().get(url);
    return response.data["data"];
  }

  Uint8List _decodeBase64(String base64String) {
    return base64Decode(
      base64String
          .replaceAll("\n", "")
          .replaceAll("\r", "")
          .replaceAll(" ", "")
          .split(",")
          .last,
    );
  }

  String _getExtension(String mimeType) {
    if (mimeType.contains("pdf")) return ".pdf";
    if (mimeType.contains("jpeg")) return ".jpg";
    if (mimeType.contains("png")) return ".png";
    if (mimeType.contains("msword")) return ".doc";
    if (mimeType.contains("officedocument")) return ".docx";
    return "";
  }

  void _showDocOptions(BuildContext context, doc, String beneficiaryName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                doc.documentName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              ListTile(
                leading: const Icon(Icons.visibility, color: Colors.blue),
                title: const Text("Preview in App"),
                onTap: () async {
                  Navigator.pop(context);
                  await _previewBase64(context, doc.documentCode);
                },
              ),
              ListTile(
                leading: const Icon(Icons.download, color: Colors.orange),
                title: const Text("Download File"),
                onTap: () async {
                  Navigator.pop(context);
                  await _downloadBase64(
                    context,
                    doc.documentCode,
                    beneficiaryName,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _previewBase64(BuildContext context, String docCode) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final data = await _fetchBase64Doc(docCode);

      Navigator.pop(context);

      final filename = data["filename"];
      final mimeType = data["documentType"];
      final base64Data = data["base64Data"];

      Uint8List bytes = _decodeBase64(base64Data);

      if (mimeType.startsWith("image/")) {
        showDialog(
          context: context,
          builder: (_) =>
              Dialog(child: InteractiveViewer(child: Image.memory(bytes))),
        );
      } else if (mimeType == "application/pdf") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PdfViewerPage.fromBytes(bytes: bytes, title: filename),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Cannot preview file type: $mimeType")),
        );
      }
    } catch (e) {
      Navigator.pop(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Failed to load document: $e")));
    }
  }

  Future<void> _downloadBase64(
    BuildContext context,
    String docCode,
    String beneficiaryName,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final data = await _fetchBase64Doc(docCode);

      Navigator.pop(context);

      final filename = data["filename"];
      final mimeType = data["documentType"];
      final base64Data = data["base64Data"];

      Uint8List bytes = _decodeBase64(base64Data);

      final ext = _getExtension(mimeType);

      String safeName = filename.replaceAll(" ", "_").replaceAll("/", "_");

      if (!safeName.endsWith(ext)) {
        safeName += ext;
      }

      String folder = beneficiaryName.replaceAll(" ", "_").toUpperCase();

      final directory = Directory(
        "/storage/emulated/0/Download/DRMS_Beneficiaries/$folder",
      );

      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      final savePath = "${directory.path}/$safeName";

      File file = File(savePath);
      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.shade700,
          content: Text("✅ Downloaded Successfully!\nSaved at:\n$savePath"),
        ),
      );
    } catch (e) {
      Navigator.pop(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Download failed: $e")));
    }
  }

  Widget _cell(String text, int flex) =>
      Expanded(flex: flex, child: Text(text));

  Widget _documentsCell(BuildContext context, ExGratiaBeneficiary b) {
    return Expanded(
      flex: 4,
      child: b.documents.isEmpty
          ? const Text("No documents available")
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: b.documents.map((d) {
                return InkWell(
                  onTap: () => _showDocOptions(context, d, b.beneficiaryName),
                  child: Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.attach_file),
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _actionCell(ExGratiaBeneficiary b) {
    return Expanded(
      flex: 2,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.green),
            onPressed: () => onEdit(b),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => onDelete(b),
          ),
        ],
      ),
    );
  }

  Widget _detailCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blue.shade100,
            child: Icon(icon, size: 18, color: Colors.blue.shade700),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _HCell extends StatelessWidget {
  final String text;
  final int flex;

  const _HCell(this.text, this.flex);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
