import 'package:flutter/material.dart';
import 'package:flutter_app/pages/generic_object_page/components/object_class.dart';
import 'package:flutter_app/pages/generic_object_page/components/form_config.dart';

class ObjectViewer extends StatelessWidget {
  final GenericObject object;

  ObjectViewer({required this.object});

  Widget _buildViewContent(Map<String, dynamic> config, GenericObject object) {
    if (config["type"] == "column") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: (config["children"] as List)
            .map<Widget>((childConfig) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _buildViewContent(childConfig, object),
                ))
            .toList(),
      );
    } else if (config["type"] == "row") {
      return Row(
        children: (config["children"] as List)
            .map<Widget>((childConfig) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: _buildViewContent(childConfig, object),
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
                      child: _buildViewContent(childConfig, object),
                    ))),
          ],
        ),
      );
    } else if (config["type"] == "field") {
  final value = _getFieldValue(config["label"], object);
  final fieldType = config["fieldType"];
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    padding: const EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Text(
      '${config["label"]}: ${_formatValue(fieldType, value)}',
      style: const TextStyle(fontSize: 14.0),
    ),
  );
}
    return SizedBox.shrink();
  }
String _formatValue(String? fieldType, String value) {
  if (fieldType == "date") {
    final date = DateTime.tryParse(value);
    if (date != null) {
      return "${date.day}/${date.month}/${date.year}";
    }
  }
  return value;
}

  String _getFieldValue(String? label, GenericObject object) {
  if (label != null) {
    final value = object.getAttribute(label)?.toString() ?? "N/A";

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
    return AlertDialog(
      title: Text('Dettagli Oggetto'),
      content: SingleChildScrollView(
        child: _buildViewContent(formConfig, object),
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
