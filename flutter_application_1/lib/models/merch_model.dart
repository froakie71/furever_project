class MerchModel {
  final String? id;
  final String name;
  final String description;
  final String category;
  final String imageUrl;
  final String url;

  MerchModel({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.url,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'url': url,
    };
  }

  factory MerchModel.fromMap(String id, Map<String, dynamic> map) {
    return MerchModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      url: map['url'] ?? '',
    );
  }
}
