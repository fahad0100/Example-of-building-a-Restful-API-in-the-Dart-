class PostModel {
  String id;
  String idUser;
  String title;
  String content;
  int createAt;

  PostModel({
    required this.id,
    required this.idUser,
    required this.title,
    required this.content,
    required this.createAt,
  });

  factory PostModel.fromJson(Map json) {
    return PostModel(
      id: json["_id"],
      idUser: json["idUser"],
      title: json["title"],
      content: json["content"],
      createAt: json["createAt"] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "idUser": idUser,
      "title": title,
      "content": content,
      "createAt": createAt as int,
    };
  }
}
