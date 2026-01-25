class AssistanceHeadCode {
  final String assistanceHeadCode;
  final String description;
  final String subWindow;
  final String formId;
  final String damaged;
  final bool isActive;
  final bool postFacto;
  final bool isDBT;
  final bool isVMT;

  AssistanceHeadCode({
    required this.assistanceHeadCode,
    required this.description,
    required this.subWindow,
    required this.formId,
    required this.damaged,
    required this.isActive,
    required this.postFacto,
    required this.isDBT,
    required this.isVMT,
  });

  factory AssistanceHeadCode.fromJson(Map<String, dynamic> json) {
    return AssistanceHeadCode(
      assistanceHeadCode: json['assistanceHeadCode'],
      description: json['description'] ?? '',
      subWindow: json['sub_window'] ?? '',
      formId: json['formId'] ?? '',
      damaged: json['damaged'] ?? '',
      isActive: json['isactive'] ?? false,
      postFacto: json['postFacto'] ?? false,
      isDBT: json['isDBT'] ?? false,
      isVMT: json['isVMT'] ?? false,
    );
  }
}
