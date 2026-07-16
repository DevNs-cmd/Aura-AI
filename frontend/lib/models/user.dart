class User {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
  });

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? map['name'] ?? '',
      avatarUrl: map['avatarUrl'],
    );
  }
}
