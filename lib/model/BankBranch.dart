class BankBranch {
  final String bankName;
  final String branchCode;
  final String branchAddress;

  BankBranch({
    required this.bankName,
    required this.branchCode,
    required this.branchAddress,
  });

  factory BankBranch.fromJson(Map<String, dynamic> json) {
    return BankBranch(
      bankName: json['BankName'],
      branchCode: json['BranchCode'],
      branchAddress: json['BranchAddress'],
    );
  }
}
