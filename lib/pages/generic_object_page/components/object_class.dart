
class GenericObject {
  final String id;
  final String name;
  final String description;

  GenericObject({this.id = '', required this.name, required this.description});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
      };

  factory GenericObject.fromJson(Map<String, dynamic> json) {
    return GenericObject(
      id: json['_id'] ?? '',
      name: json['name'],
      description: json['description'],
    );
  }

  GenericObject copyWith({String? id, String? name, String? description}) {
    return GenericObject(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}
