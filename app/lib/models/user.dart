class User {
  String id;
  String email;
  String hashedPassword;

  User({required this.id, required this.email, required this.hashedPassword});

  factory User.fromMap(String id, Map<String, dynamic> map) {
    return User(
      id: id,
      email: map["email"],
      hashedPassword: map["hashedPassword"],
    );
  }
}
