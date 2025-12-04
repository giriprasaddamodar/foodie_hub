class User {
  final int? id;
  final String name;
  final String gender;
  final String email;
  final String password;
  final String phone;
  final String city;

  User({
    this.id,
    required this.name,
    required this.gender,
    required this.email,
    required this.password,
    required this.phone,
    required this.city,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'email': email,
      'password': password,
      'phone': phone,
      'city': city,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      gender: map['gender'],
      email: map['email'],
      password: map['password'],
      phone: map['phone'],
      city: map['city'],
    );
  }
}
