class Board {
  final String id;
  final String name;
  final String? color; // Aggiungi il campo colore
  final String description;
  String? databaseId; // ID specifico del documento MongoDB

  Board({
    required this.id,
    required this.name,
    this.color,
    required this.description,
    this.databaseId,
  });

  // Metodo per serializzare la board in formato JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'description': description,
    };
  }

  // Factory per deserializzare una board da JSON
  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      description: json['description'],
      databaseId: json['_id'], // Leggi l'ID del documento MongoDB
    );
  }
}
