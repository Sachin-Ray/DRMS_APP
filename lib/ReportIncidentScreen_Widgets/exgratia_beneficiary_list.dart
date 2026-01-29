import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drms/ReportIncidentScreen_Widgets/pdf_viewer_page.dart';
import 'package:drms/model/ExGratiaBeneficiary.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';

class ExGratiaBeneficiaryList extends StatelessWidget {
  final List<ExGratiaBeneficiary> list;
  final Function(ExGratiaBeneficiary) onEdit;
  final Function(ExGratiaBeneficiary) onDelete;

  const ExGratiaBeneficiaryList({
    super.key,
    required this.list,
    required this.onEdit,
    required this.onDelete,
  });

  static const String _docApiBase =
      "http://10.179.2.219:8083/drms/v-1/app/api/fetchFile";

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text("No records found")),
      );
    }

    return isMobile ? _mobileView(context) : _tableView(context);
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
                // HEADER
                Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.blue.shade50,
                          child: const Icon(Icons.person,
                              color: Colors.blue, size: 28),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "₹${b.amount}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.green.shade800,
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
                  icon: Icons.volunteer_activism,
                  title: "Assistance",
                  value: b.assistance,
                ),

                const SizedBox(height: 14),

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
                            fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      if (b.documents.isEmpty)
                        Text(
                          "No documents uploaded",
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13),
                        )
                      else
                        ...b.documents.map(
                          (d) => InkWell(
                            onTap: () => _showDocOptions(context, d),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.attach_file,
                                      size: 18, color: Colors.blue),
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
                                  const Icon(Icons.more_vert,
                                      size: 18, color: Colors.grey),
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

  void _showDocOptions(BuildContext context, doc) {
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
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                title: const Text("Download & Open"),
                onTap: () async {
                  Navigator.pop(context);
                  await _downloadBase64(context, doc.documentCode);
                },
              ),
            ],
          ),
        );
      },
    );
  }


  Future<void> _previewBase64(BuildContext context, String docCode) async {
    final data = await _fetchBase64Doc(docCode);

    final filename = data["filename"];
    final mimeType = data["documentType"];
    final base64Data = data["base64Data"];

    Uint8List bytes = _decodeBase64(base64Data);

    // IMAGE
    if (mimeType.startsWith("image/")) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          child: InteractiveViewer(
            child: Image.memory(bytes),
          ),
        ),
      );
    }

    // PDF
    else if (mimeType == "application/pdf") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfViewerPage.fromBytes(
            bytes: bytes,
            title: filename,
          ),
        ),
      );
    }

    // OTHER
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cannot preview file type: $mimeType")),
      );
    }
  }

  Future<void> _downloadBase64(BuildContext context, String docCode) async {
    final data = await _fetchBase64Doc(docCode);

    final filename = data["filename"];
    final base64Data = data["base64Data"];

    Uint8List bytes = _decodeBase64(base64Data);

    final directory = Directory("/storage/emulated/0/Download");

    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    final savePath = "${directory.path}/$filename";

    File file = File(savePath);
    await file.writeAsBytes(bytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green.shade700,
        content: Text("✅ Saved at:\n$savePath"),
      ),
    );

    await OpenFilex.open(savePath);
  }

  Widget _cell(String text, int flex) =>
      Expanded(flex: flex, child: Text(text));

  Widget _documentsCell(BuildContext context, ExGratiaBeneficiary b) {
    return Expanded(
      flex: 4,
      child: b.documents.isEmpty
          ? const Text("No documents available")
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: b.documents.map(
                (d) => InkWell(
                  onTap: () => _showDocOptions(context, d),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      "• ${d.documentName}",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ).toList(),
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
                      fontSize: 14, fontWeight: FontWeight.w700),
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
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
