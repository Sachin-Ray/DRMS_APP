import 'package:drms/ReportIncidentScreen_Widgets/accordion_section.dart';
import 'package:drms/ReportIncidentScreen_Widgets/amount_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/bank_details_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/beneficiary_details_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/beneficiary_documents_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/housing_damage_assistance_widget.dart';
import 'package:drms/ReportIncidentScreen_Widgets/remarks_widget.dart';

import 'package:drms/model/Block.dart';
import 'package:drms/model/Village.dart';
import 'package:drms/services/APIService.dart';
import 'package:flutter/material.dart';

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

  // ✅ MODELS
  final BeneficiaryDetails beneficiary = BeneficiaryDetails();
  final AssistanceDetails assistance = AssistanceDetails();
  final BankDetails bank = BankDetails();
  final BeneficiaryDocuments documents = BeneficiaryDocuments();

  // ✅ Accordion states
  bool b1 = true;
  bool b2 = false;
  bool b3 = false;
  bool b4 = false;
  bool b5 = false;
  bool b6 = false;

  @override
  void initState() {
    super.initState();
    _saveHousingBeneficiary();
  }

  @override
  void dispose() {
    assistance.amountNotifier.dispose();
    super.dispose();
  }

  

  // ======================================================
  // SAVE FUNCTION
  // ======================================================
  void _saveHousingBeneficiary() async{
    // if (!_formKey.currentState!.validate()) {
    //   setState(() => b1 = true);
    //   return;
    // }

    // if (assistance.assistanceTypeList.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text("Please select at least one Housing Assistance type"),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    //   return;
    // }

    // final payload = {
    //   "beneficiary": beneficiary.toJson(),
    //   "assistance": assistance.toJson(),
    //   "bank": bank.toJson(),
    //   "documents": documents.files
    //       .map((f) => {"filename": f.path.split('/').last, "path": f.path})
    //       .toList(),
    // };
    
    final payload = {
  "beneficiaryName": "Ajnabi",
  "ageCategory": "adult",
  "gender": "M",
  "blockcode": 7183,
  "villagecode": 278072,
  "ifsc": "SBIN0000054",
  "bankName": "STATE BANK OF INDIA",
  "branchCode": "SBIN00054",
  "acNumber": "12345678901",
  "remarks": "Relief assistance for flood damage",
  "firNo": "PR-EWKH-MAIRANG-20250325-1",
  "assistanceHead": "AH-HU",
  "normSelect": [38],
  "IspuccaOrKutcha":40
};

     debugPrint("Fishery Beneficiary Payload: $payload");

    final result = await APIService.instance.submitSaveAssistanceForm(payload);

    
    if (result != null && result["status"] == "SUCCESS") {
      debugPrint("Housing Damage Beneficiary saved successfully.");
      Navigator.pop(context, true);

    } else {
      debugPrint("Error saving Housing Damage Beneficiary: ${result?["message"]}");
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
            mainAxisSize: MainAxisSize.min,
            children: [
              // ================= HEADER =================
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ✅ Beneficiary Details
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

                      // ✅ Housing Assistance
                      AccordionSection(
                        title: "Housing Assistance Specific Details",
                        expanded: b2,
                        onToggle: () => setState(() => b2 = !b2),
                        children: [
                          HousingDamageAssistanceWidget(model: assistance),
                        ],
                      ),

                      // ✅ Amount
                      AccordionSection(
                        title: "Amount Eligible As Per SDRF Norms",
                        expanded: b3,
                        onToggle: () => setState(() => b3 = !b3),
                        children: [
                          AmountWidget(model: assistance),
                        ],
                      ),

                      // ✅ Bank Details
                      AccordionSection(
                        title: "Beneficiary Bank Account Details",
                        expanded: b4,
                        onToggle: () => setState(() => b4 = !b4),
                        children: [
                          BankDetailsWidget(model: bank),
                        ],
                      ),

                      // ✅ Remarks
                      AccordionSection(
                        title: "Remarks",
                        expanded: b6,
                        onToggle: () => setState(() => b6 = !b6),
                        children: [
                          RemarksWidget(model: assistance),
                        ],
                      ),

                      // ✅ Documents
                      AccordionSection(
                        title: "Documents",
                        expanded: b5,
                        onToggle: () => setState(() => b5 = !b5),
                        children: [
                          BeneficiaryDocumentsWidget(model: documents),
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
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveHousingBeneficiary,
                        child: const Text("Save"),
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
