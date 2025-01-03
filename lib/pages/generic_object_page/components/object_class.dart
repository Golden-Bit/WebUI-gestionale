
class GenericObject {
  final String? id;
  final Map<String, dynamic> attributes;

  GenericObject({this.id, required this.attributes});
  //GenericObject({required this.attributes});

  /// Convert GenericObject to JSON
  Map<String, dynamic> toJson() {
    final json = Map<String, dynamic>.from(attributes);
    if (id != null) {
      json['_id'] = id;
    }
    return json;
  } 

  /// Create GenericObject from JSON
  factory GenericObject.fromJson(Map<String, dynamic> json) {
    final id = json['_id'];
    final attributes = Map<String, dynamic>.from(json)..remove('_id');

    return GenericObject(id: id, attributes: attributes);
  }

  /// Create a copy of GenericObject with updated fields
  GenericObject copyWith({String? id, Map<String, dynamic>? updatedAttributes}) {
    return GenericObject(
      id: id ?? this.id,
      attributes: {...attributes, if (updatedAttributes != null) ...updatedAttributes},
    );
  }

  /// Access a specific attribute
  dynamic getAttribute(String key) {
    return attributes[key];
  }
}
