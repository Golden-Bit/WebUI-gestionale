import 'package:flutter/material.dart';
import '../../pages/generic_object_page/components/object_card.dart';
import '../../pages/generic_object_page/components/object_class.dart';
import '../../databases_manager/database_service.dart';
import '../../user_manager/auth_service.dart';
import '../../pages/generic_object_page/components/object_form.dart';
import '../../pages/generic_object_page/components/object_viewer.dart';
import '../../pages/generic_object_page/components/filters_widget.dart';
import '../../pages/generic_object_page/components/form_config.dart';

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
        objects = objectsData.map((json) {
          final genericObject = GenericObject.fromJson(json);
          final attributes = {
            'Nome': genericObject.getAttribute('Nome') ?? '',
            'Descrizione': genericObject.getAttribute('Descrizione') ?? '',
            ...genericObject.attributes,
          };
          return GenericObject(id: genericObject.id, attributes: attributes);
        }).toList();
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

      if (object.id == null || object.id == "") {
        
        var json_object = object.toJson();
        json_object.remove('_id');

        final response = await databaseService.addDataToCollection(
          dbName,
          collectionName,
          json_object,
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
          object.id!,
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
        object.id!,
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
    final duplicatedObject = object.copyWith(id: "");
    
    print('${duplicatedObject.toJson()}');

    _saveObjectToDatabase(duplicatedObject);
  }

  void _applyFilters() {
    setState(() {
      filteredObjects = objects.where((object) {
        return filters.entries.every((entry) {
          final field = entry.key;
          final value = entry.value.toLowerCase();
          final attributeValue = object.getAttribute(field)?.toString().toLowerCase();
          if (attributeValue != null) {
            return attributeValue.contains(value);
          }
          return false;
        });
      }).toList();
    });
  }

  void _onFilterChanged(String field, String value) {
    setState(() {
      filters[field] = value;
      _applyFilters();
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
            FiltersWidget(
              formConfig: formConfig,
              filters: filters,
              onFilterChanged: _onFilterChanged,
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
