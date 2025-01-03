import 'package:flutter/material.dart';
import 'package:flutter_app/pages/generic_object_page/components/multiselect_dialog.dart';
import 'package:flutter_app/pages/generic_object_page/components/object_class.dart';
import 'package:flutter_app/pages/generic_object_page/components/form_config.dart';

class ObjectForm extends StatefulWidget {
  final Function(GenericObject) onAddOrUpdateObject;
  final GenericObject? existingObject;

  ObjectForm({required this.onAddOrUpdateObject, this.existingObject});

  @override
  _ObjectFormState createState() => _ObjectFormState();
}

class _ObjectFormState extends State<ObjectForm> {
  final Map<String, TextEditingController> controllers = {};

@override
void initState() {
  super.initState();
  _initializeControllers(formConfig);
  if (widget.existingObject != null) {
    _populateControllers(widget.existingObject!);
  }
}

void _initializeControllers(Map<String, dynamic> config) {
  void traverseConfig(Map<String, dynamic> config) {
    if (config["type"] == "field" && config.containsKey("controllerKey")) {
      final fieldType = config["fieldType"];
      if (fieldType == "date") {
        controllers[config["controllerKey"]] = TextEditingController();
      } else if (fieldType == "number") {
        controllers[config["controllerKey"]] = TextEditingController();
      } else {
        controllers[config["controllerKey"]] = TextEditingController();
      }
    }
    if (config.containsKey("children")) {
      for (var child in config["children"]) {
        traverseConfig(child);
      }
    }
  }

  traverseConfig(config);
}


void _populateControllers(GenericObject existingObject) {
  void traverseConfig(Map<String, dynamic> config) {
    if (config["type"] == "field" && config.containsKey("controllerKey")) {
      final controllerKey = config["controllerKey"];
      final label = config["label"];
      if (controllers.containsKey(controllerKey) && label != null) {
        controllers[controllerKey]?.text = existingObject.getAttribute(label)?.toString() ?? '';
      }
    }
    if (config.containsKey("children")) {
      for (var child in config["children"]) {
        traverseConfig(child);
      }
    }
  }

  traverseConfig(formConfig);
}


void _saveObject() {
  final attributes = _collectAttributes(formConfig);

  final object = GenericObject(
    id: widget.existingObject?.id,
    attributes: attributes,
  );
  widget.onAddOrUpdateObject(object);
  Navigator.of(context).pop();
}

Map<String, String> _collectAttributes(Map<String, dynamic> config) {
  final attributes = <String, String>{};

  void traverseConfig(Map<String, dynamic> config) {
    if (config["type"] == "field" && config.containsKey("label") && config.containsKey("controllerKey")) {
      final key = config["label"];
      final controllerKey = config["controllerKey"];
      if (controllers.containsKey(controllerKey)) {
        final fieldType = config["fieldType"];
        if (fieldType == "date") {
          attributes[key] = controllers[controllerKey]!.text; // Already ISO format
        } else if (fieldType == "number") {
          attributes[key] = double.tryParse(controllers[controllerKey]!.text)?.toString() ?? "0";
        } else {
          attributes[key] = controllers[controllerKey]!.text;
        }
      }
    }
    if (config.containsKey("children")) {
      for (var child in config["children"]) {
        traverseConfig(child);
      }
    }
  }

  traverseConfig(config);
  return attributes;
}


  Widget _buildForm(Map<String, dynamic> config) {
    if (config["type"] == "column") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: (config["children"] as List)
            .map<Widget>((childConfig) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _buildForm(childConfig),
                ))
            .toList(),
      );
    } else if (config["type"] == "row") {
      return Row(
        children: (config["children"] as List)
            .map<Widget>((childConfig) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: _buildForm(childConfig),
                  ),
                ))
            .toList(),
      );
    } else if (config["type"] == "section") {
      return Container(
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
                      child: _buildForm(childConfig),
                    ))),
          ],
        ),
      );
    } else if (config["type"] == "field") {
  final fieldType = config["fieldType"];
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    padding: const EdgeInsets.all(8.0),
    //decoration: BoxDecoration(
    //  border: Border.all(color: Colors.grey),
    //  borderRadius: BorderRadius.circular(8.0),
    //),
    child: _buildFieldWidget(config, fieldType),
  );
}
    return SizedBox.shrink();
  }
Widget _buildFieldWidget(Map<String, dynamic> config, String? fieldType) {
  final controller = controllers[config["controllerKey"]];
  switch (fieldType) {
    case "date":
      return TextField(
        controller: controller,
        readOnly: true,
        onTap: () async {
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );

          if (pickedDate != null) {
            final pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );

            if (pickedTime != null) {
              final dateTime = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );
              controller?.text = dateTime.toIso8601String();
            }
          }
        },
        decoration: InputDecoration(
          labelText: config["label"],
          suffixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
        ),
      );
    case "number":
      return TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: config["label"],
          border: OutlineInputBorder(),
        ),
      );
    case "categorical":
      final options = List<String>.from(config["options"] ?? []);
      return DropdownButtonFormField<String>(
        value: controller?.text.isNotEmpty == true ? controller?.text : null,
        items: options
            .map((option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                ))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            controller?.text = value;
          }
        },
        decoration: InputDecoration(
          labelText: config["label"],
          border: OutlineInputBorder(),
        ),
        isExpanded: true,
        menuMaxHeight: MediaQuery.of(context).size.height * 0.5, // Altezza massima al 50% dello schermo
      );
    case "multicategorical":
      final options = List<String>.from(config["options"] ?? []);
      final selectedValues = controller?.text.isNotEmpty == true
          ? controller!.text.split(", ")
          : <String>[];
      return GestureDetector(
        onTap: () async {
          final selected = await showDialog<List<String>>(
            context: context,
            builder: (context) {
              return MultiSelectDialog(
                title: config["label"] ?? "Seleziona",
                options: options,
                selectedValues: selectedValues,
              );
            },
          );
          if (selected != null) {
            controller?.text = selected.join(", ");
            setState(() {});
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: config["label"],
            border: OutlineInputBorder(),
          ),
          child: Text(
            selectedValues.isNotEmpty ? selectedValues.join(", ") : "Nessuna selezione",
          ),
        ),
      );
    default:
      return TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: config["label"],
          border: OutlineInputBorder(),
        ),
      );
  }
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
  void dispose() {
    controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
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
            icon: Icon(Icons.save),
            label: Text('Salva Oggetto'),
            onPressed: _saveObject,
          ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: _buildForm(formConfig),
        ),
      ),
    );
  }
}
