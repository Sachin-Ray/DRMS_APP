import 'dart:convert';

class Infrastructure {
  final int infrastructureId;
  final String infrastructureName;

  Infrastructure({
    required this.infrastructureId,
    required this.infrastructureName,
  });

  factory Infrastructure.fromMap(Map<String, dynamic> map) {
    return Infrastructure(
      infrastructureId: map['infrastructure_id'],
      infrastructureName: map['infrastructure_name'],
    );
  }

  Map<String, dynamic> toMap() => {
        'infrastructure_id': infrastructureId,
        'infrastructure_name': infrastructureName,
      };

  String toJson() => json.encode(toMap());
}
