import 'package:drms/model/ExGratiaBeneficiary.dart';

class PaginatedBeneficiaryResponse {
  final int total;
  final List<ExGratiaBeneficiary> data;

  PaginatedBeneficiaryResponse({
    required this.total,
    required this.data,
  });
}