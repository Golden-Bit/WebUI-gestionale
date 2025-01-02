import 'package:flutter/material.dart';
import 'package:flutter_app/pages/generic_object_page/components/object_class.dart';

class ObjectForm extends StatefulWidget {
  final Function(GenericObject) onAddOrUpdateObject;
  final GenericObject? existingObject;

  ObjectForm({required this.onAddOrUpdateObject, this.existingObject});

  @override
  _ObjectFormState createState() => _ObjectFormState();
}

class _ObjectFormState extends State<ObjectForm> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingObject != null) {
      nameController.text = widget.existingObject!.name;
      descriptionController.text = widget.existingObject!.description;
    }
  }

  void _saveObject() {
    final object = GenericObject(
      id: widget.existingObject?.id ?? '',
      name: nameController.text,
      description: descriptionController.text,
    );
    widget.onAddOrUpdateObject(object);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingObject != null ? 'Modifica Oggetto' : 'Nuovo Oggetto'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton.icon(
            //icon: Icon(Icons.add),
            label: Text('Salva'),
            onPressed: _saveObject,
          ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informazioni Oggetto',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Nome'),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Descrizione'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
