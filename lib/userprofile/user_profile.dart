class UserProfile {
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String bio;
  final bool isAdmin;

  UserProfile({
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.bio,
    required this.isAdmin,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      bio: json['bio'] ?? '',
      isAdmin: json['is_admin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'bio': bio,
      'is_admin': isAdmin,
    };
  }

  String get fullName => '$firstName $lastName'.trim();
  
  String get displayName => fullName.isNotEmpty ? fullName : username;
}