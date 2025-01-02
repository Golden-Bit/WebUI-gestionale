import 'package:flutter/material.dart';
import 'package:flutter_app/pages/generic_object_page/components/object_class.dart';

class GenericObjectCard extends StatefulWidget {
  final GenericObject object;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final VoidCallback onView;

  GenericObjectCard({
    required this.object,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
    required this.onView,
  });

  @override
  _GenericObjectCardState createState() => _GenericObjectCardState();
}

class _GenericObjectCardState extends State<GenericObjectCard> with SingleTickerProviderStateMixin {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card(
        child: Column(
          children: [
            ListTile(
              title: Text(widget.object.name),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'modifica') {
                    widget.onEdit();
                  } else if (value == 'elimina') {
                    widget.onDelete();
                  } else if (value == 'duplica') {
                    widget.onDuplicate();
                  } else if (value == 'visualizza') {
                    widget.onView();
                  }
                },
                itemBuilder: (context) => [
                                    PopupMenuItem(
                    value: 'visualizza',
                    child: Text('Visualizza'),
                  ),
                  PopupMenuItem(
                    value: 'modifica',
                    child: Text('Modifica'),
                  ),
                  PopupMenuItem(
                    value: 'elimina',
                    child: Text('Elimina'),
                  ),
                  PopupMenuItem(
                    value: 'duplica',
                    child: Text('Duplica'),
                  ),

                ],
              ),
            ),
            if (isExpanded)
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dettagli Oggetto',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('ID: ${widget.object.id}'),
                    Text('Nome: ${widget.object.name}'),
                    Text('Descrizione: ${widget.object.description}'),
                  ],
                ),
              ),
            Align(
              alignment: Alignment.center,
              child: IconButton(
                icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
