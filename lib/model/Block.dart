import 'dart:convert';

class Block {
  final int blockcode;
  final String blockname;
  final String districtCode;
  final String districtName;

  Block({
    required this.blockcode,
    required this.blockname,
    required this.districtCode,
    required this.districtName,
  });

  factory Block.fromMap(Map<String, dynamic> map) {
    return Block(
      blockcode: map['blockcode'],
      blockname: map['blockname'],
      districtCode: map['districtcodelgd']['districtcodelgd'],
      districtName: map['districtcodelgd']['districtname'],
    );
  }

  Map<String, dynamic> toMap() => {
        'blockcode': blockcode,
        'blockname': blockname,
        'districtCode': districtCode,
        'districtName': districtName,
      };

  String toJson() => json.encode(toMap());
}
