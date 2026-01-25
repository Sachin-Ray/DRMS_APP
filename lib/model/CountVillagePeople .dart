class CountVillagePeople {
  final int peopleCount;
  final int villageCount;

  CountVillagePeople({
    required this.peopleCount,
    required this.villageCount,
  });

  factory CountVillagePeople.fromJson(Map<String, dynamic> json) {
    return CountVillagePeople(
      peopleCount: json['peopleCount'] ?? 0,
      villageCount: json['villageCount'] ?? 0,
    );
  }
}
