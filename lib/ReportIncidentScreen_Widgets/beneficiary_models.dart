import 'dart:io';

class BeneficiaryDetails {
  String? name;
  String? ageCategory;
  String? gender;
  int? blockCode;
  String? village;

  BeneficiaryDetails({
    this.name,
    this.ageCategory,
    this.gender,
    this.blockCode,
    this.village,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "ageCategory": ageCategory,
        "gender": gender,
        "blockCode": blockCode,
        "village": village,
      };
}

class AssistanceDetails {
  String? assistanceType;
  double? amount;

  Map<String, dynamic> toJson() => {
        "assistanceType": assistanceType,
        "amount": amount,
      };
}

class BankDetails {
  String? accountHolder;
  String? accountNumber;
  String? ifsc;
  String? bankName;

  Map<String, dynamic> toJson() => {
        "accountHolder": accountHolder,
        "accountNumber": accountNumber,
        "ifsc": ifsc,
        "bankName": bankName,
      };
}

class BeneficiaryDocuments {
  List<File> files;

  BeneficiaryDocuments({this.files = const []});
}
