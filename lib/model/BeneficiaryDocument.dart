class BeneficiaryDocument {
  final String documentCode;
  final String? filestored;
  final String documentName;

  BeneficiaryDocument({
    required this.documentCode,
    required this.filestored,
    required this.documentName,
  });

  factory BeneficiaryDocument.fromJson(Map<String, dynamic> json) {
    return BeneficiaryDocument(
      documentCode: json['documentCode'] ?? '',
      filestored: json['filestored'],
      documentName: json['documentName'] ?? '',
    );
  }
}
