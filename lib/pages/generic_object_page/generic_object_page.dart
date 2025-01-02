import 'package:flutter/material.dart';
import 'package:flutter_app/pages/generic_object_page/components/object_card.dart';
import 'package:flutter_app/pages/generic_object_page/components/object_class.dart';
import '../../databases_manager/database_service.dart';
import '../../user_manager/auth_service.dart';
import '../../pages/generic_object_page/components/object_form.dart';
import '../../pages/generic_object_page/components/object_viewer.dart';

class GenericObjectPage extends StatefulWidget {
  final String token;
  final String dbName;

  GenericObjectPage({required this.token, required this.dbName});

  @override
  _GenericObjectPageState createState() => _GenericObjectPageState();
}

class _GenericObjectPageState extends State<GenericObjectPage> {
  List<GenericObject> objects = [];
  List<GenericObject> filteredObjects = [];
  String searchQuery = '';
  Map<String, String> filters = {};
  final String collectionName = 'generic_objects';

  @override
  void initState() {
    super.initState();
    _ensureCollectionExists();
  }

  Future<void> _ensureCollectionExists() async {
    try {
      final databaseService = DatabaseService();
      final authService = AuthService();

      final user = await authService.fetchCurrentUser(widget.token);
      final dbName = '${user.username}-${widget.dbName}';

      final collections = await databaseService.fetchCollections(dbName, widget.token);
      final collectionNames = collections.map((collection) => collection.name).toList();

      if (!collectionNames.contains(collectionName)) {
        await databaseService.createCollection(dbName, collectionName, widget.token);
        print("Collezione '$collectionName' creata.");
      }

      _loadObjectsFromDatabase();
    } catch (e) {
      print("Errore durante il controllo/creazione della collezione: $e");
    }
  }

  Future<void> _loadObjectsFromDatabase() async {
    try {
      final databaseService = DatabaseService();
      final authService = AuthService();

      final user = await authService.fetchCurrentUser(widget.token);
      final dbName = '${user.username}-${widget.dbName}';

      final objectsData = await databaseService.fetchCollectionData(
        dbName,
        collectionName,
        widget.token,
      );

      setState(() {
        objects = objectsData.map((json) => GenericObject.fromJson(json)).toList();
        _applyFilters();
      });
    } catch (e) {
      print("Errore durante il caricamento degli oggetti: $e");
    }
  }

  Future<void> _saveObjectToDatabase(GenericObject object) async {
    try {
      final databaseService = DatabaseService();
      final authService = AuthService();

      final user = await authService.fetchCurrentUser(widget.token);
      final dbName = '${user.username}-${widget.dbName}';

      if (object.id.isEmpty) {
        final response = await databaseService.addDataToCollection(
          dbName,
          collectionName,
          object.toJson(),
          widget.token,
        );
        final newId = response['id'];
        final newObject = object.copyWith(id: newId);

        setState(() {
          objects.add(newObject);
          _applyFilters();
        });
      } else {
        await databaseService.updateCollectionData(
          dbName,
          collectionName,
          object.id,
          object.toJson(),
          widget.token,
        );

        setState(() {
          final index = objects.indexWhere((o) => o.id == object.id);
          if (index != -1) {
            objects[index] = object;
            _applyFilters();
          }
        });
      }
    } catch (e) {
      print("Errore durante il salvataggio dell'oggetto: $e");
    }
  }

  Future<void> _deleteObjectFromDatabase(GenericObject object) async {
    try {
      final databaseService = DatabaseService();
      final authService = AuthService();

      final user = await authService.fetchCurrentUser(widget.token);
      final dbName = '${user.username}-${widget.dbName}';

      await databaseService.deleteCollectionData(
        dbName,
        collectionName,
        object.id,
        widget.token,
      );

      setState(() {
        objects.removeWhere((o) => o.id == object.id);
        _applyFilters();
      });
    } catch (e) {
      print("Errore durante l'eliminazione dell'oggetto: $e");
    }
  }

  void _duplicateObject(GenericObject object) {
    final duplicatedObject = object.copyWith(
      id: '',
      name: '${object.name} (Duplicato)',
    );
    _saveObjectToDatabase(duplicatedObject);
  }

  void _applyFilters() {
    setState(() {
      filteredObjects = objects.where((object) {
        final matchesQuery = object.name.toLowerCase().contains(searchQuery.toLowerCase());
        final matchesFilters = filters.entries.every((entry) {
          final field = entry.key;
          final value = entry.value.toLowerCase();
          if (field == 'description') {
            return object.description.toLowerCase().contains(value);
          }
          return true;
        });
        return matchesQuery && matchesFilters;
      }).toList();
    });
  }

  void _navigateToAddObjectPage(BuildContext context, {GenericObject? object}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ObjectForm(
          onAddOrUpdateObject: (newObject) => _saveObjectToDatabase(newObject),
          existingObject: object,
        ),
      ),
    );
  }

  void _viewObject(GenericObject object) {
    showDialog(
      context: context,
      builder: (context) {
        return ObjectViewer(object: object);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestione Oggetti'),
        actions: [
          ElevatedButton.icon(
            icon: Icon(Icons.add),
            label: Text('Nuovo Oggetto'),
            onPressed: () => _navigateToAddObjectPage(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Cerca per nome',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _applyFilters();
                });
              },
            ),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                labelText: 'Filtra per descrizione',
                prefixIcon: Icon(Icons.filter_alt),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  filters['description'] = value;
                  _applyFilters();
                });
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredObjects.length,
                itemBuilder: (context, index) {
                  final object = filteredObjects[index];
                  return GenericObjectCard(
                    object: object,
                    onEdit: () => _navigateToAddObjectPage(context, object: object),
                    onDelete: () => _deleteObjectFromDatabase(object),
                    onDuplicate: () => _duplicateObject(object),
                    onView: () => _viewObject(object),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}