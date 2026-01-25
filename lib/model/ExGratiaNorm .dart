import 'package:drms/model/AssistanceHeadCode.dart';
import 'package:drms/model/RequiredDocument.dart';

class ExGratiaNorm {
  final int normCode;
  final String description;
  final String losstype;
  final String option;
  final int value;
  final int minimumValue;
  final int maximumValue;
  final String farmerType;
  final String subAssistanceType;
  final AssistanceHeadCode assistanceHeadCode;
  final List<RequiredDocument> doctype;

  ExGratiaNorm({
    required this.normCode,
    required this.description,
    required this.losstype,
    required this.option,
    required this.value,
    required this.minimumValue,
    required this.maximumValue,
    required this.farmerType,
    required this.subAssistanceType,
    required this.assistanceHeadCode,
    required this.doctype,
  });

  factory ExGratiaNorm.fromJson(Map<String, dynamic> json) {
    return ExGratiaNorm(
      normCode: json['normCode'],
      description: json['description'] ?? '',
      losstype: json['losstype'] ?? '',
      option: json['option'] ?? '',
      value: json['value'] ?? 0,
      minimumValue: json['minimum_value'] ?? 0,
      maximumValue: json['maximum_value'] ?? 0,
      farmerType: json['farmerType'] ?? '',
      subAssistanceType: json['subAssistanceType'] ?? '',
      assistanceHeadCode:
          AssistanceHeadCode.fromJson(json['assistanceHeadCode']),
      doctype: (json['doctype'] as List<dynamic>)
          .map((e) => RequiredDocument.fromJson(e))
          .toList(),
    );
  }
}
