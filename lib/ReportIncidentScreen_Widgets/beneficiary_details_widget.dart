import 'package:drms/model/beneficiary_models.dart';
import 'package:drms/model/Block.dart';
import 'package:drms/model/Village.dart';
import 'package:drms/services/APIService.dart';
import 'package:drms/services/session.dart';
import 'package:flutter/material.dart';

class BeneficiaryDetailsWidget extends StatefulWidget {
  final BeneficiaryDetails model;
  final List<Block> blocks;
  final List<Village> villages;

  const BeneficiaryDetailsWidget({
    super.key,
    required this.model,
    required this.blocks,
    required this.villages,
  });

  @override
  State<BeneficiaryDetailsWidget> createState() =>
      _BeneficiaryDetailsWidgetState();
}

class _BeneficiaryDetailsWidgetState extends State<BeneficiaryDetailsWidget> {
  static const Color primaryPurple = Color(0xff6C63FF);
  static const Color errorRed = Color(0xffE76F51);

  // Block data
  List<Block> blockList = [];
  Block? selectedBlock;
  bool isBlockLoading = false;

  // Village data
  List<Village> villageList = [];
  List<Village> selectedVillages = [];
  bool isVillageLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBlocksIfNeeded();
    _loadVillagesForBDO();
  }

  Future<void> _loadBlocksIfNeeded() async {
    final user = await Session.instance.getUserDetails();
    if (user == null) return;

    if (user.roles == 'ROLE_DEPT') {
      setState(() => isBlockLoading = true);

      final blocks = await APIService.instance.getAllBlocks(user.districtcode);

      if (!mounted) return;

      setState(() {
        blockList = blocks ?? [];
        isBlockLoading = false;
      });
    }
  }

  Future<void> _loadVillagesByBlock(int blockCode) async {
    setState(() {
      isVillageLoading = true;
      villageList.clear();
      selectedVillages.clear();
    });

    final villages = await APIService.instance.getAllVillages(blockCode);

    if (!mounted) return;

    setState(() {
      villageList = villages ?? [];
      isVillageLoading = false;
    });
  }

  Future<void> _loadVillagesForBDO() async {
    final user = await Session.instance.getUserDetails();
    if (user != null && user.roles == 'ROLE_BDO') {
      selectedBlock = Block(
        blockcode: user.blockcode,
        blockname: user.blockname,
        districtCode: user.districtcode,
        districtName: user.districtname,
      );
      _loadVillagesByBlock(user.blockcode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _required("Name of Beneficiary"),
        const SizedBox(height: 6),
        TextFormField(
          decoration: _input("Enter name"),
          onChanged: (v) => widget.model.name = v,
          validator: (v) => v == null || v.isEmpty ? "Required" : null,
        ),
        const SizedBox(height: 16),

        _required("Age Category"),
        const SizedBox(height: 8),
        Row(
          children: [
            _radioPill(
              label: "Adult",
              value: "adult",
              groupValue: widget.model.ageCategory,
              onChanged: (v) {
                setState(() => widget.model.ageCategory = v);
              },
            ),
            const SizedBox(width: 10),
            _radioPill(
              label: "Minor",
              value: "minor",
              groupValue: widget.model.ageCategory,
              onChanged: (v) {
                setState(() => widget.model.ageCategory = v);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),

        _required("Gender"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children:
              [
                {"label": "Male", "value": "M"},
                {"label": "Female", "value": "F"},
                {"label": "Others", "value": "O"},
              ].map((g) {
                return _radioPill(
                  label: g["label"]!,
                  value: g["value"]!,
                  groupValue: widget.model.gender,
                  onChanged: (v) {
                    setState(() => widget.model.gender = v);
                  },
                );
              }).toList(),
        ),

        const SizedBox(height: 16),

        _required("Block"),
        const SizedBox(height: 6),
        FutureBuilder(
          future: Session.instance.getUserDetails(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SizedBox();
            }

            final user = snapshot.data!;

            // For ROLE_BDO -> block comes from login
            if (user.roles == 'ROLE_BDO') {
              widget.model.blockCode = user.blockcode;
              return TextFormField(
                enabled: false,
                initialValue: user.blockname,
                decoration: _inputDecoration("Block name"),
                style: TextStyle(color: Color(0xff6B7280)),
              );
            }
            // For ROLE_DEPT -> fetch block list
            return DropdownButtonFormField<Block>(
              initialValue: selectedBlock,
              isExpanded: true,
              decoration: _inputDecoration(
                isBlockLoading ? "Loading Blocks..." : "Select Block",
              ),
              items: blockList
                  .map(
                    (b) => DropdownMenuItem<Block>(
                      value: b,
                      child: Text(b.blockname),
                    ),
                  )
                  .toList(),
              onChanged: isBlockLoading
                  ? null
                  : (v) {
                      setState(() {
                        selectedBlock = v;
                        widget.model.blockCode = v?.blockcode;
                      });

                      if (v != null) {
                        _loadVillagesByBlock(v.blockcode);
                      }
                    },

              validator: (v) => v == null ? "This field is required" : null,
            );
          },
        ),
        const SizedBox(height: 16),

        _required("Village"),
        const SizedBox(height: 6),

        DropdownButtonFormField<Village>(
          decoration: _inputDecoration(
            isVillageLoading
                ? "Loading Villages..."
                : selectedBlock == null
                ? "Select Block First"
                : "Select Village",
          ),
          isExpanded: true,
          items: villageList
              .map(
                (v) => DropdownMenuItem<Village>(
                  value: v,
                  child: Text(v.villagename),
                ),
              )
              .toList(),
          onChanged: isVillageLoading || selectedBlock == null
              ? null
              : (v) {
                  setState(() {
                    widget.model.village = v?.villagecode;
                  });
                },
          validator: (v) => v == null ? "Required" : null,
        ),
      ],
    );
  }

  // 🔘 Custom Radio Pill (Modern & Compact)
  Widget _radioPill({
    required String label,
    required String value,
    required String? groupValue,
    required Function(String) onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: value,
          groupValue: groupValue,
          onChanged: (v) => onChanged(v!),
          activeColor: const Color(0xff6C63FF),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Color(0xffF5F5F7),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xffE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: errorRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: errorRed, width: 2),
      ),
    );
  }

  InputDecoration _input(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0xffF5F5F7),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
      borderSide: const BorderSide(color: Color(0xff6C63FF), width: 2),
    ),
  );

  Widget _required(String label) => Row(
    children: [
      Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      const SizedBox(width: 4),
      const Text("*", style: TextStyle(color: Colors.red)),
    ],
  );
}
