class User {
  final String token;
  final String type;
  final String id;
  final String username;
  final String roles;
  final int blockcode;
  final String districtcode;
  final String blockname;
  final String districtname;

  User({
    required this.token,
    required this.type,
    required this.id,
    required this.username,
    required this.roles,
    required this.blockcode,
    required this.districtcode,
    required this.blockname,
    required this.districtname,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      token: json['token'],
      type: json['type'],
      id: json['id'],
      username: json['username'],
      roles: json['roles'],
      blockcode: json['blockcode'],
      districtcode: json['districtcode'],
      blockname: json['blockname'].toString(),
      districtname: json['districtname'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'type': type, 'id': id, 'username': username, 'roles': roles, 'blockcode': blockcode, 'districtcode': districtcode, 'blockname': blockname, 'districtname': districtname};
  }
}
