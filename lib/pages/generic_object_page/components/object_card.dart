import 'package:flutter/material.dart';
import 'package:flutter_app/pages/generic_object_page/components/object_class.dart';
import 'package:flutter_app/pages/generic_object_page/components/form_config.dart';

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

  Widget _buildCardContent(Map<String, dynamic> config) {
    if (config["type"] == "column") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: (config["children"] as List)
            .map<Widget>((childConfig) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _buildCardContent(childConfig),
                ))
            .toList(),
      );
    } else if (config["type"] == "row") {
      return Row(
        children: (config["children"] as List)
            .map<Widget>((childConfig) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: _buildCardContent(childConfig),
                  ),
                ))
            .toList(),
      );
    } else if (config["type"] == "section") {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: _getColor(config["borderColor"]),
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (config["title"] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  config["title"]!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                ),
              ),
            ...((config["children"] as List)
                .map<Widget>((childConfig) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: _buildCardContent(childConfig),
                    ))),
          ],
        ),
      );
    } else if (config["type"] == "field" && config["fieldType"] == "categorical") {
  final value = _getFieldValue(config["label"]);
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    padding: const EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Text(
      '${config["label"]}: $value',
      style: const TextStyle(fontSize: 14.0),
    ),
  );
}
else if (config["type"] == "field") {
  final value = _getFieldValue(config["label"]); // Passa il valore del label
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    padding: const EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Text(
      '${config["label"]}: $value',
      style: const TextStyle(fontSize: 14.0),
    ),
  );
}
    return SizedBox.shrink();
  }

String _getFieldValue(String? label) {
  if (label != null) {
    final value = widget.object.getAttribute(label)?.toString() ?? "N/A";

    // Controlla se il valore è di tipo data (ISO 8601 format)
    if (DateTime.tryParse(value) != null) {
      final dateTime = DateTime.parse(value);
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} "
          "- ${dateTime.hour}:${dateTime.minute}"; //:${dateTime.second})";
    }

    return value;
  }
  return "N/A";
}


  Color _getColor(String? color) {
    switch (color) {
      case "blue":
        return Colors.blue;
      case "green":
        return Colors.green;
      case "red":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card(
        child: Column(
          children: [
            ListTile(
              title: Text(widget.object.getAttribute("Nome")),
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
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                padding: const EdgeInsets.all(8.0),
                //decoration: BoxDecoration(
                  //border: Border.all(color: Colors.grey),
                  //borderRadius: BorderRadius.circular(8.0),
                //),
                child: _buildCardContent(formConfig),
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
