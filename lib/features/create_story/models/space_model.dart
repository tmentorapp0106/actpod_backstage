class Space {
  String spaceId;
  String name;
  String description;
  String imageUrl;
  int storyCount;

  Space(this.spaceId, this.name, this.description, this.imageUrl, this.storyCount);

  factory Space.fromJson(Map<String, dynamic> json) {
    return Space(
        json["spaceId"],
        json["name"],
        json["description"],
        json["imageUrl"],
        json["storyCount"]
    );
  }

  Map toJson() => {
    'spaceId': spaceId,
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    "storyCount": storyCount
  };
}