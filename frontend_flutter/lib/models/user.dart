class User {
  final String id;
  final String username;
  final String email;
  final List<String> roles;
  final String? token;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.roles,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'roles': roles,
      if (token != null) 'token': token,
    };
  }
}
