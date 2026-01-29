import 'dart:io';
import 'package:flutter/material.dart';

class BeneficiaryDetails {
  String? name;
  String? ageCategory;
  String? gender;
  int? blockCode;
  String? village;

  Map<String, dynamic> toJson() => {
        "name": name,
        "ageCategory": ageCategory,
        "gender": gender,
        "blockCode": blockCode,
        "village": village,
      };
}

class AssistanceDetails {
  int? normCode;

  /// Single assistance type (used in Agriculture etc.)
  String? assistanceType;

  /// ✅ Multiple assistance types (used in Fishery Boat + Net)
  List<String> assistanceTypeList = [];

  // Agriculture specific
  String? landHolding;

  double? baseAmount;
  int victimCount = 1;

  // Live amount notifier
  ValueNotifier<double> amountNotifier = ValueNotifier(0);

  /// Selected Norm Codes
  List<int> get selectedNormCodes => normCode != null ? [normCode!] : [];

  // Victim names list
  List<String> victimNames = [];

  String? remarks;

  Map<String, dynamic> toJson() => {
        "normCode": normCode,

        // Single type
        "assistanceType": assistanceType,

        // ✅ Multi type (Fishery)
        "assistanceTypeList": assistanceTypeList,

        "landHolding": landHolding,
        "victimCount": victimCount,
        "amount": amountNotifier.value,
        "victimNames": victimNames,
        "remarks": remarks,
      };
}

class BankDetails {
  String? ifsc;
  String? bankName;
  String? branchCode;
  String? accountNumber;
  String? confirmAccountNumber;

  Map<String, dynamic> toJson() => {
        "ifsc": ifsc,
        "bankName": bankName,
        "branchCode": branchCode,
        "accountNumber": accountNumber,
      };
}

class BeneficiaryDocuments {
  List<File> files;

  BeneficiaryDocuments({this.files = const []});
}
