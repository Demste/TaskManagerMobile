  //role 1 admin

class User {
  int id;
  int? role;
  String? name;
  String? surname;
  String? url;


  User({
    required this.id,
    this.role,
    this.name,
    this.surname,
    this.url,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'], // Default value if null
      name: json['name'], // Default empty string if null
      surname: json['surname'] , // Default empty string if null
      url: json['url'], // Keep as nullable
      role: json['role'], // Keep as nullable
    );
  }
  //direkt çıkartarak yollamıyorsun
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'url': url,
      'role': role,

    };
  }

  @override
  String toString() {
    return 'User(id: $id,  name: $name, surname: $surname, role: $role,url:$url)';
  }
}
