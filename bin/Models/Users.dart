class UserModel {
  String? id;
  String? name;
  String? email;
  int? createAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.createAt,
  });

  factory UserModel.fromJson(Map json) {
    return UserModel(
      id: json["_id"],
      name: json["name"],
      email: json["email"],
      createAt: json["createAt"] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "email": email,
      "createAt": createAt as int,
    };
  }
}
