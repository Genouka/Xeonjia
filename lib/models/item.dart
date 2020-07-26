// Item in story mode (eg key, potion, stone, gem, ...)
class Item {
  // Item name
  String name;

  // Item description
  String description;

  // Item location (tmx file)
  String location;

  Item(Map<String, dynamic> json)
      : name = json['name'],
        description = json['description'],
        location = json['location'];
}
