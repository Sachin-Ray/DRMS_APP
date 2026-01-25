import 'dart:convert';

class Village {
  final String villagecode;
  final String villagename;
  final int blockcode;
  final String blockname;

  Village({
    required this.villagecode,
    required this.villagename,
    required this.blockcode,
    required this.blockname,
  });

  factory Village.fromMap(Map<String, dynamic> map) {
    return Village(
      villagecode: map['villagecode'].toString(),
      villagename: map['villagename'],
      blockcode: map['blockcode']['blockcode'],
      blockname: map['blockcode']['blockname'],
    );
  }

  Map<String, dynamic> toMap() => {
        'villagecode': villagecode,
        'villagename': villagename,
        'blockcode': blockcode,
        'blockname': blockname,
      };

  String toJson() => json.encode(toMap());
}
