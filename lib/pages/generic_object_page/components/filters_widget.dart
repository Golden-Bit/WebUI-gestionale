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
  final Map<String, TextEditingController> _dateControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers(widget.formConfig);
  }
void _initializeControllers(Map<String, dynamic> config) {
  void traverseConfig(Map<String, dynamic> config) {
    // Verifica che il campo sia di tipo "field" e che il filtro sia abilitato
    if (config["type"] == "field" && config["filter"]?["enabled"] == true) {
      final filterType = config["filter"]["type"];
      final label = config["label"];

      // Gestione dei filtri di tipo dateRange
      if (filterType == "dateRange") {
        // Inizializza i controller per start e end date
        _dateControllers.putIfAbsent(
          '${label}_start',
          () => TextEditingController(
            text: widget.filters['${label}_start'] ?? '',
          ),
        );
        _dateControllers.putIfAbsent(
          '${label}_end',
          () => TextEditingController(
            text: widget.filters['${label}_end'] ?? '',
          ),
        );
      }
    }

    // Se il nodo corrente ha figli, traversali ricorsivamente
    if (config.containsKey("children")) {
      for (var child in config["children"]) {
        traverseConfig(child);
      }
    }
  }

  // Avvia la traversata della configurazione
  traverseConfig(config);
}


  @override
  void dispose() {
    _dateControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

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

          case "range":
            filterWidgets.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Filtra per $label (Range)'),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Min',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              widget.onFilterChanged('${label}_min', value);
                            },
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Max',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              widget.onFilterChanged('${label}_max', value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
            break;

case "dateRange":
  final startController = _dateControllers['${label}_start'];
  final endController = _dateControllers['${label}_end'];

  filterWidgets.add(
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filtra per $label (Intervallo Date)'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: startController,
                  decoration: InputDecoration(
                    labelText: 'Da',
                    border: OutlineInputBorder(),
                    suffixIcon: startController?.text.isNotEmpty == true
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              startController?.clear();
                              widget.onFilterChanged('${label}_start', ''); // Imposta filtro vuoto
                            },
                          )
                        : null,
                  ),
                  readOnly: true,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      startController?.text = picked.toIso8601String();
                      widget.onFilterChanged('${label}_start', picked.toIso8601String());
                    }
                  },
                ),
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: TextField(
                  controller: endController,
                  decoration: InputDecoration(
                    labelText: 'A',
                    border: OutlineInputBorder(),
                    suffixIcon: endController?.text.isNotEmpty == true
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              endController?.clear();
                              widget.onFilterChanged('${label}_end', ''); // Imposta filtro vuoto
                            },
                          )
                        : null,
                  ),
                  readOnly: true,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      endController?.text = picked.toIso8601String();
                      widget.onFilterChanged('${label}_end', picked.toIso8601String());
                    }
                  },
                ),
              ),
            ],
          ),
        ],
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

    traverseConfig(config);
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
