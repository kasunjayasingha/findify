class UserModel {
  final dynamic email;
  final dynamic name;
  final dynamic imgUrl;
  final dynamic description;
  final dynamic phone;
  final dynamic id;
  final dynamic address;
  final dynamic createdAt;

  UserModel({
    required this.email,
    required this.name,
    required this.imgUrl,
    required this.description,
    required this.phone,
    required this.id,
    this.address = '',
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      imgUrl: json['imgUrl'] ?? json['profileImageUrl'] ?? '',
      description: json['description'] ?? '',
      phone: json['phone'] ?? '',
      id: json['id'] ?? json['userId'] ?? '',
      address: json['address'] ?? '',
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'profileImageUrl': imgUrl,
      'description': description,
      'phone': phone,
      'userId': id,
      'address': address,
      'createdAt': createdAt ?? DateTime.now().toIso8601String(),
    };
  }
}
