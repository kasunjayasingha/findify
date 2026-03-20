class PostModel {
  String postId;
  String userId;
  String type; // LOST or FOUND
  String description;
  String location;
  String imageUrl;
  DateTime createdAt;
  String status;
  String postCode;

  PostModel({
    required this.postId,
    required this.userId,
    required this.type,
    required this.description,
    required this.location,
    required this.imageUrl,
    required this.createdAt,
    this.status = 'ACTIVE',
    this.postCode = '',
  });

  Map<String, dynamic> toJson() => {
    "postId": postId,
    "userId": userId,
    "type": type,
    "description": description,
    "location": location,
    "imageUrl": imageUrl,
    "createdAt": createdAt.toIso8601String(),
    "status": status,
    "postCode": postCode,
  };

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
    postId: json["postId"] ?? '',
    userId: json["userId"] ?? '',
    type: json["type"] ?? 'LOST',
    description: json["description"] ?? '',
    location: json["location"] ?? '',
    imageUrl: json["imageUrl"] ?? '',
    createdAt: json["createdAt"] != null
        ? DateTime.parse(json["createdAt"])
        : DateTime.now(),
    status: json["status"] ?? 'ACTIVE',
    postCode: json["postCode"] ?? '',
  );
}
