class BlogsModel {
  late String id, title, description, image , name;

  BlogsModel(
      {required this.description,
      required this.title,
      required this.id,
      required this.image,
      required this.name,
      });

  BlogsModel.fromJson(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    description = map['description'];
    image = map['img'];
    name = map['name'];
  }
}
