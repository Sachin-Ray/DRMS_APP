import 'package:drms/ReportIncidentScreen_Widgets/beneficiary_models.dart';
import 'package:drms/model/ExGratiaNorm%20.dart';
import 'package:drms/services/APIService.dart';
import 'package:flutter/material.dart';

class AssistanceWidget extends StatefulWidget {
  final AssistanceDetails model;

  const AssistanceWidget({super.key, required this.model});

  @override
  State<AssistanceWidget> createState() => _AssistanceWidgetState();
}

class _AssistanceWidgetState extends State<AssistanceWidget> {
  static const Color primaryPurple = Color(0xff6C63FF);

  List<ExGratiaNorm> norms = [];
  ExGratiaNorm? selectedNorm;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNorms();
  }

  Future<void> _loadNorms() async {
    final result = await APIService.instance.getExGratiaNorms();
    if (!mounted) return;

    setState(() {
      norms = result ?? [];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _required("Type of Assistance"),
        const SizedBox(height: 8),

        DropdownButtonFormField<ExGratiaNorm>(
          value: selectedNorm,
          isExpanded: true,
          decoration: _inputDecoration(isLoading?"Loading...":"Select Assistance Type"),
          items: norms.map((norm) {
            return DropdownMenuItem<ExGratiaNorm>(
              value: norm,
              child: Text(
                _buildNormLabel(norm),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (v) {
            setState(() {
              selectedNorm = v;
            });
          },
          validator: (v) => v == null ? "Required" : null,
        ),
      ],
    );
  }

  // 🔹 Input Decoration (same as ReportIncidentScreen)
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xffF5F5F7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryPurple, width: 2),
      ),
    );
  }

  // 🔹 Required Label
  Widget _required(String label) => Row(
    children: const [
      Text(
        "Type of Assistance",
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      SizedBox(width: 4),
      Text("*", style: TextStyle(color: Colors.red)),
    ],
  );

  String _buildNormLabel(ExGratiaNorm norm) {
    final List<String> parts = [];

    if (norm.description.isNotEmpty) {
      parts.add(norm.description);
    }

    if (norm.losstype.isNotEmpty) {
      parts.add(_capitalize(norm.losstype));
    }

    if (norm.option.isNotEmpty && norm.option != 'NA') {
      parts.add(norm.option);
    }

    return parts.join(' ');
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
