import 'package:flutter/material.dart';

class FiltersWidget extends StatefulWidget {
  final Map<String, dynamic> formConfig;
  final Map<String, String> filters;
  final Function(String, String) onFilterChanged;

  FiltersWidget({
    required this.formConfig,
    required this.filters,
    required this.onFilterChanged,
  });

  @override
  _FiltersWidgetState createState() => _FiltersWidgetState();
}

class _FiltersWidgetState extends State<FiltersWidget> {
  List<Widget> _generateFilters(Map<String, dynamic> config) {
    List<Widget> filterWidgets = [];

    void traverseConfig(Map<String, dynamic> config) {
      if (config["type"] == "field" && config["filter"]?["enabled"] == true) {
        final filterType = config["filter"]["type"];
        final label = config["label"];
        switch (filterType) {
          case "text":
            filterWidgets.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Filtra per $label',
                    prefixIcon: Icon(Icons.filter_alt),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    widget.onFilterChanged(label, value);
                  },
                ),
              ),
            );
            break;

          case "dropdown":
            final options = List<String>.from(config["options"] ?? []);
            final dropdownOptions = ["Nessun filtro", ...options];
            filterWidgets.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Filtra per $label',
                    border: OutlineInputBorder(),
                  ),
                  value: widget.filters[label] ?? "Nessun filtro",
                  onChanged: (value) {
                    if (value != null) {
                      widget.onFilterChanged(label, value == "Nessun filtro" ? "" : value);
                    }
                  },
                  items: dropdownOptions
                      .map((option) => DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          ))
                      .toList(),
                ),
              ),
            );
            break;

          // Aggiungi ulteriori tipi di filtro se necessario
        }
      }
      if (config.containsKey("children")) {
        for (var child in config["children"]) {
          traverseConfig(child);
        }
      }
    }

    traverseConfig(widget.formConfig);
    return filterWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _generateFilters(widget.formConfig),
    );
  }
}
