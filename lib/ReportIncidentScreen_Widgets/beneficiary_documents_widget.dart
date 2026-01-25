import 'dart:io';

import 'package:drms/ReportIncidentScreen_Widgets/beneficiary_models.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BeneficiaryDocumentsWidget extends StatefulWidget {
  final BeneficiaryDocuments model;

  const BeneficiaryDocumentsWidget({super.key, required this.model});

  @override
  State<BeneficiaryDocumentsWidget> createState() =>
      _BeneficiaryDocumentsWidgetState();
}

class _BeneficiaryDocumentsWidgetState
    extends State<BeneficiaryDocumentsWidget> {
  final ImagePicker picker = ImagePicker();

  Future<void> pickDocs() async {
    final files = await picker.pickMultiImage();
    if (files.isNotEmpty) {
      setState(() {
        widget.model.files
            .addAll(files.map((e) => File(e.path)).take(5));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.upload_file),
          label: const Text("Upload Documents"),
          onPressed: pickDocs,
        ),
        const SizedBox(height: 8),
        ...widget.model.files.map(
          (f) => ListTile(
            leading: const Icon(Icons.description),
            title: Text(f.path.split('/').last),
            trailing: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                setState(() => widget.model.files.remove(f));
              },
            ),
          ),
        ),
      ],
    );
  }
}
