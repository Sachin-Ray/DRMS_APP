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
  String? assistanceType;

  // Agriculture specific
  String? landHolding;

  double? baseAmount;
  int victimCount = 1;

  // Live amount notifier
  ValueNotifier<double> amountNotifier = ValueNotifier(0);

  // Victim names list
  List<String> victimNames = [];

  String? remarks;

  Map<String, dynamic> toJson() => {
    "normCode": normCode,
    "assistanceType": assistanceType,
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
  String? branchName;
  String? accountNumber;
  String? confirmAccountNumber;

  Map<String, dynamic> toJson() => {
    "ifsc": ifsc,
    "bankName": bankName,
    "branchName": branchName,
    "accountNumber": accountNumber,
  };
}

class BeneficiaryDocuments {
  List<File> files;

  BeneficiaryDocuments({this.files = const []});
}
