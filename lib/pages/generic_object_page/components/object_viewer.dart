import 'package:flutter/material.dart';
import 'package:flutter_app/pages/generic_object_page/components/object_class.dart';

class ObjectViewer extends StatelessWidget {
  final GenericObject object;

  ObjectViewer({required this.object});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Dettagli Oggetto'),
      content: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sezione Dettagli',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 8),
            Text('Nome: ${object.name}'),
            Text('Descrizione: ${object.description}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Chiudi'),
        ),
      ],
    );
  }
}
