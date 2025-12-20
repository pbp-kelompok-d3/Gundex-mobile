class Artikel {
  final String id;
  final String title;
  final String description;
  final String? image;
  final int views;
  final int likes;
  final DateTime createdAt;

  Artikel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.views,
    required this.likes,
    required this.createdAt,
  });

  factory Artikel.fromJson(Map<String, dynamic> json) {
    return Artikel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      image: json['image'] == "" ? null : json['image'],
      views: json['views'] as int,
      likes: json['likes'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Menghasilkan URL proxy agar gambar local Django bisa dibuka Flutter Web
  String proxied(String baseUrl) {
    if (image == null || image!.isEmpty) return "";
    final encoded = Uri.encodeFull(image!);
    return "$baseUrl/artikel/proxy/?url=$encoded";
  }

}
