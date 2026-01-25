import 'package:drms/model/BeneficiaryDocument.dart';
import 'package:drms/model/CountVillagePeople%20.dart';

class ExGratiaBeneficiary {
  final String beneficiaryName;
  final String beneficiaryId;
  final String formId;
  final String village;
  final String gender;
  final String age;
  final int blockCode;
  final String villageCode;

  final String bankName;
  final int bankId;
  final String branchName;
  final int branchId;
  final String? bankCode;
  final String branchCode;
  final String ifscCode;
  final String accountNumber;

  final int amount;
  final String block;
  final String district;
  final String dateOfIncidence;
  final String calamity;
  final String? victimName;
  final String remarks;
  final String assistance;

  final List<int> normCode;
  final String reportId;

  final double landArea;
  final double cropArea;
  final double landHoldingArea;
  final int numberOfVictims;

  final List<CountVillagePeople> countVillagePeople;
  final List<BeneficiaryDocument> documents;

  final bool draftProposal;

  ExGratiaBeneficiary({
    required this.beneficiaryName,
    required this.beneficiaryId,
    required this.formId,
    required this.village,
    required this.gender,
    required this.age,
    required this.blockCode,
    required this.villageCode,
    required this.bankName,
    required this.bankId,
    required this.branchName,
    required this.branchId,
    required this.bankCode,
    required this.branchCode,
    required this.ifscCode,
    required this.accountNumber,
    required this.amount,
    required this.block,
    required this.district,
    required this.dateOfIncidence,
    required this.calamity,
    required this.victimName,
    required this.remarks,
    required this.assistance,
    required this.normCode,
    required this.reportId,
    required this.landArea,
    required this.cropArea,
    required this.landHoldingArea,
    required this.numberOfVictims,
    required this.countVillagePeople,
    required this.documents,
    required this.draftProposal,
  });

  factory ExGratiaBeneficiary.fromJson(Map<String, dynamic> json) {
    return ExGratiaBeneficiary(
      beneficiaryName: json['beneficiaryName'] ?? '',
      beneficiaryId: json['beneficiaryId'] ?? '',
      formId: json['formId'] ?? '',
      village: json['village'] ?? '',
      gender: json['gender'] ?? '',
      age: json['age'] ?? '',
      blockCode: json['blockCode'] ?? 0,
      villageCode: json['villageCode'] ?? '',
      bankName: json['bankName'] ?? '',
      bankId: json['bankId'] ?? 0,
      branchName: json['branchName'] ?? '',
      branchId: json['branchId'] ?? 0,
      bankCode: json['bankCode'],
      branchCode: json['branchCode'] ?? '',
      ifscCode: json['ifscCode'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      amount: json['amount'] ?? 0,
      block: json['block'] ?? '',
      district: json['district'] ?? '',
      dateOfIncidence: json['dateOfIncidence'] ?? '',
      calamity: json['calamity'] ?? '',
      victimName: json['victimName'],
      remarks: json['remarks'] ?? '',
      assistance: json['assistance'] ?? '',
      normCode: List<int>.from(json['normCode'] ?? []),
      reportId: json['reportId'] ?? '',
      landArea: (json['landArea'] ?? 0).toDouble(),
      cropArea: (json['cropArea'] ?? 0).toDouble(),
      landHoldingArea: (json['landHoldingArea'] ?? 0).toDouble(),
      numberOfVictims: json['numberOfVictims'] ?? 0,
      countVillagePeople: (json['countVillagePeople'] as List? ?? [])
          .map((e) => CountVillagePeople.fromJson(e))
          .toList(),
      documents: (json['documents'] as List? ?? [])
          .map((e) => BeneficiaryDocument.fromJson(e))
          .toList(),
      draftProposal: json['draftProposal'] ?? false,
    );
  }

  /// ✅ helper
  bool get hasAllDocuments => documents.isNotEmpty;
}
