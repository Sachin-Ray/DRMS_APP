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

  List<int> normCodes = [];
  String? assistanceType;
  List<String> assistanceTypeList = [];
  String? landHolding;
  double? baseAmount;
  int victimCount = 1;
  ValueNotifier<double> amountNotifier = ValueNotifier(0);

  int noOfRepairBoat = 0;
int noOfReplacementBoat = 0;
int noOfRepairNet = 0;
int noOfReplacementNet = 0;


int noOfLargeAnimal = 0;
String? animalType;
int noOfSmallAnimal = 0;
int noOfPoultry = 0;

 int? isPuccaOrKutcha;

 double? landAreaAffected;
double? cropSownArea;
double? landHoldingArea;


  /// Selected Norm Codes
  List<int> get selectedNormCodes {
  if (normCodes.isNotEmpty) return normCodes; // Handloom
  if (normCode != null) return [normCode!];   // GR
  return [];
}

  // Victim names list
  List<String> victimNames = [];

  String? remarks;

  Map<String, dynamic> toJson() => {
        "normCode": normCode,

        // Single type
        "assistanceType": assistanceType,

        // Multi type (Fishery)
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
