class RequiredDocument {
  final int documentCode;
  final String description;
  final String documentName;
  final bool isSpecific;

  RequiredDocument({
    required this.documentCode,
    required this.description,
    required this.documentName,
    required this.isSpecific,
  });

  factory RequiredDocument.fromJson(Map<String, dynamic> json) {
    return RequiredDocument(
      documentCode: json['documentcode'],
      description: json['description'] ?? '',
      documentName: json['document_name'] ?? '',
      isSpecific: json['is_specific'] ?? false,
    );
  }
}
