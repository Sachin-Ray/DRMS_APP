import 'dart:convert';

class Calamity {
  final String calamityId;
  final String calamityName;

  Calamity({
    required this.calamityId,
    required this.calamityName,
  });

  Calamity copyWith({
    String? calamityId,
    String? calamityName,
  }) {
    return Calamity(
      calamityId: calamityId ?? this.calamityId,
      calamityName: calamityName ?? this.calamityName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'calamityId': calamityId,
      'calamity_name': calamityName,
    };
  }

  factory Calamity.fromMap(Map<String, dynamic> map) {
    return Calamity(
      calamityId: map['calamityId']?.toString() ?? '',
      calamityName: map['calamity_name'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Calamity.fromJson(String source) =>
      Calamity.fromMap(json.decode(source));

  @override
  String toString() =>
      'Calamity(calamityId: $calamityId, calamityName: $calamityName)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Calamity &&
        other.calamityId == calamityId &&
        other.calamityName == calamityName;
  }

  @override
  int get hashCode => calamityId.hashCode ^ calamityName.hashCode;
}
