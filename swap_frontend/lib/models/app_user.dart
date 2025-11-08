class SkillEntry {
  final String name;
  final String category;
  final String level;

  SkillEntry({required this.name, required this.category, required this.level});

  Map<String, dynamic> toMap() => {
    'name': name,
    'category': category,
    'level': level,
  };

  factory SkillEntry.fromMap(Map<String, dynamic> map) => SkillEntry(
    name: map['name'] as String,
    category: map['category'] as String,
    level: map['level'] as String,
  );
}

class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final String? fullName;
  final String? username;
  final String? bio;
  final String? city;
  final String? timezone;
  final List<SkillEntry>? skillsToOffer;
  final List<SkillEntry>? servicesNeeded;
  final bool? dmOpen;
  final bool? emailUpdates;
  final bool? showCity;

  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.fullName,
    this.username,
    this.bio,
    this.city,
    this.timezone,
    this.skillsToOffer,
    this.servicesNeeded,
    this.dmOpen,
    this.emailUpdates,
    this.showCity,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'createdAt': createdAt.toIso8601String(),
    'fullName': fullName,
    'username': username,
    'bio': bio,
    'city': city,
    'timezone': timezone,
    'skillsToOffer': skillsToOffer?.map((s) => s.toMap()).toList(),
    'servicesNeeded': servicesNeeded?.map((s) => s.toMap()).toList(),
    'dmOpen': dmOpen,
    'emailUpdates': emailUpdates,
    'showCity': showCity,
  };
}
