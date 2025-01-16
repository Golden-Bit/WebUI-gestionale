import 'package:flutter/material.dart';
import 'package:flutter_app/databases_manager/database_model.dart';
import 'package:flutter_app/databases_manager/database_service.dart';
import 'package:flutter_app/user_manager/auth_service.dart';
import 'package:flutter_app/user_manager/user_model.dart';

class Workspace {
  final String id; // ID dello spazio di lavoro
  final String name; // Nome dello spazio di lavoro
  final String description; // Descrizione dello spazio di lavoro
  final String associatedDatabase; // Nome del database associato
  String? databaseId; // ID specifico dell'elemento nel database

  Workspace({
    required this.id,
    required this.name,
    required this.description,
    required this.associatedDatabase,
    this.databaseId,
  });

  /// Converti un oggetto JSON in un oggetto Workspace
  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      associatedDatabase: json['associatedDatabase'],
      databaseId: json['_id'], // Valore salvato nel database
    );
  }

  /// Converti un oggetto Workspace in JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'associatedDatabase': associatedDatabase,
    };
  }
}


/// Carica gli spazi di lavoro dal database
Future<List<Workspace>> loadWorkspacesFromDatabase(
  String token,
  String dbName,
) async {
  final databaseService = DatabaseService();
  final authService = AuthService();

  final user = await authService.fetchCurrentUser(token);
  final actualDbName = '${user.username}-$dbName';

  final workspacesData = await databaseService.fetchCollectionData(
    actualDbName,
    'workspaces',
    token,
  );

  return workspacesData
      .map<Workspace>((workspaceJson) => Workspace.fromJson(workspaceJson))
      .toList();
}

/// Salva uno spazio di lavoro nel database
Future<void> saveWorkspaceToDatabase(
  String token,
  String dbName,
  Workspace workspace,
) async {
  final databaseService = DatabaseService();
  final authService = AuthService();

  final user = await authService.fetchCurrentUser(token);
  final actualDbName = '${user.username}-$dbName';

  // Salva il nuovo workspace
  final response = await databaseService.addDataToCollection(
    actualDbName,
    'workspaces',
    workspace.toJson(),
    token,
  );

  // Aggiorna il databaseId nell'oggetto Workspace
  workspace.databaseId = response['id'];
}

/// Modifica uno spazio di lavoro nel database
Future<void> updateWorkspaceInDatabase(
  String token,
  String dbName,
  Workspace workspace,
) async {
  if (workspace.databaseId == null) {
    throw Exception("Errore: databaseId dello spazio di lavoro non trovato.");
  }

  final databaseService = DatabaseService();
  final authService = AuthService();

  final user = await authService.fetchCurrentUser(token);
  final actualDbName = '${user.username}-$dbName';

  await databaseService.updateCollectionData(
    actualDbName,
    'workspaces',
    workspace.databaseId!,
    workspace.toJson(),
    token,
  );
}

/// Elimina uno spazio di lavoro dal database
/*Future<void> deleteWorkspaceFromDatabase(
  String token,
  String dbName,
  Workspace workspace,
) async {
  if (workspace.databaseId == null) {
    throw Exception("Errore: databaseId dello spazio di lavoro non trovato.");
  }

  final databaseService = DatabaseService();
  final authService = AuthService();

  final user = await authService.fetchCurrentUser(token);
  final actualDbName = '${user.username}-$dbName';

  await databaseService.deleteCollectionData(
    actualDbName,
    'workspaces',
    workspace.databaseId!,
    token,
  );
}*/

/// Carica gli spazi di lavoro dal database
Future<List<Workspace>> loadWorkspaces({
  required String token,
  required String dbName,
}) async {
  try {
    final loadedWorkspaces = await loadWorkspacesFromDatabase(token, dbName);
    return loadedWorkspaces;
  } catch (error) {
    print("Errore durante il caricamento degli spazi di lavoro: $error");
    return [];
  }
}

/// Carica l'elenco dei database disponibili
Future<List<String>> loadAvailableDatabases({
  required List<Database> databases,
}) async {
  try {
    return databases.map((db) => db.dbName).toList();
  } catch (error) {
    print("Errore durante il caricamento dei database disponibili: $error");
    return [];
  }
}

/// Mostra un dialog per creare o modificare uno spazio di lavoro
Future<void> showWorkspaceDialog({
  required BuildContext context,
  Workspace? workspace,
  required List<String> availableDatabases,
  required User user,
  required String token,
  required Function() onWorkspaceSaved,
}) async {
  final nameController = TextEditingController(text: workspace?.name ?? '');
  final descriptionController = TextEditingController(text: workspace?.description ?? '');
  String? selectedDatabase = workspace?.associatedDatabase ?? (availableDatabases.isNotEmpty ? availableDatabases.first : null);

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(workspace == null ? "Crea Spazio di Lavoro" : "Modifica Spazio di Lavoro"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nome"),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Descrizione"),
            ),
            DropdownButtonFormField<String>(
              value: selectedDatabase,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
              decoration: const InputDecoration(labelText: "Database Associato"),
              dropdownColor: Colors.grey[200],
              items: availableDatabases.map((db) {
                return DropdownMenuItem<String>(
                    value:db.replaceFirst('${user.username}-', ''),
                    child: Text(
                      db.replaceFirst('${user.username}-', ''),
                      style: const TextStyle(color: Colors.black),
                    ),
                  );
              }).toList(),
              onChanged: (value) {
                selectedDatabase = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Annulla"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || selectedDatabase == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Nome e database associato sono obbligatori.")),
                );
                return;
              }
              final newWorkspace = Workspace(
                id: workspace?.id ?? UniqueKey().toString(),
                name: nameController.text,
                description: descriptionController.text,
                associatedDatabase: selectedDatabase!,
                databaseId: workspace?.databaseId,
              );

              if (workspace == null) {
                await saveWorkspaceToDatabase(token, 'appData', newWorkspace);
              } else {
                await updateWorkspaceInDatabase(token, 'appData', newWorkspace);
              }

              onWorkspaceSaved(); // Aggiorna lo stato degli spazi di lavoro
              Navigator.of(context).pop();
            },
            child: Text(workspace == null ? "Crea" : "Salva"),
          ),
        ],
      );
    },
  );
}