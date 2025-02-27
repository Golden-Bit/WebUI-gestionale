import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Widget che mostra la tabella dei dati (ad esempio pagamenti) in modo dinamico,
/// generando header e righe in base allo schema fornito. 
/// La colonna "Select" viene sempre visualizzata come prima colonna (con checkbox per la selezione)
/// e i valori booleani di selezione non sono mostrati come testo.
class PaymentsListWidget extends StatefulWidget {
  /// Lista dei dati, ciascuno rappresentato come mappa.
  final List<Map<String, dynamic>> paymentsList;
  /// Callback invocata quando la lista cambia (ad es. selezione/deselezione tramite checkbox).
  final ValueChanged<List<Map<String, dynamic>>> onPaymentsChanged;
  /// Schema JSON per generare dinamicamente header e formattazione delle celle.
  /// Lo schema è una mappa dove ogni chiave corrisponde a un campo e il valore è una mappa con proprietà (es. "type", "label").
  final Map<String, dynamic> schema;

  const PaymentsListWidget({
    Key? key,
    required this.paymentsList,
    required this.onPaymentsChanged,
    required this.schema,
  }) : super(key: key);

  @override
  _PaymentsListWidgetState createState() => _PaymentsListWidgetState();
}

class _PaymentsListWidgetState extends State<PaymentsListWidget> {
  final ScrollController _horizontalScrollController = ScrollController();

  // Le colonne fisse che non possono essere nascoste.
  final List<String> fixedFields = ["Select", "Stato"];

  // Inizialmente, le colonne visibili saranno tutte quelle presenti nello schema.
  Set<String> visibleFields = {};

  // Mappa per memorizzare le larghezze delle colonne.
  late Map<String, double> columnWidths;

  // Stato del master checkbox.
  bool _masterCheckbox = false;

  bool _resizerHovering = false;

  @override
  void initState() {
    super.initState();
    // Inizializza visibleFields con tutte le chiavi dello schema.
    visibleFields = widget.schema.keys.toSet();
    // Assicurati che "Select" sia sempre presente.
    visibleFields.add("Select");
    // Inizializza le larghezze in base all'ordine delle colonne.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      final orderedFields = _getOrderedFields();
      final totalCols = orderedFields.length;
      final defaultWidth = screenWidth / totalCols;
      setState(() {
        columnWidths = {
          for (var col in orderedFields)
            col: defaultWidth.clamp(70.0, 300.0),
        };
        // Imposta larghezze specifiche per le colonne fisse.
        columnWidths["Select"] = 50;
        columnWidths["Stato"] = 120;
      });
    });
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  /// Calcola l'elenco ordinato delle colonne da mostrare.
  /// Forza "Select" ad essere la prima colonna.
  List<String> _getOrderedFields() {
    // Inizia con le chiavi dello schema.
    List<String> keys = widget.schema.keys.toList();
    // Rimuovi eventuali occorrenze di "Select" (per evitare duplicazioni).
    keys.removeWhere((k) => k.toLowerCase() == "select" || k.toLowerCase() == "selected");
    // Costruisci l'ordine: "Select" come prima colonna, poi il resto.
    List<String> ordered = ["Select"]..addAll(keys);
    // Filtra in base a visibleFields o fixedFields.
    return ordered.where((col) => visibleFields.contains(col) || fixedFields.contains(col)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            width: constraints.maxWidth,
            child: Scrollbar(
              controller: _horizontalScrollController,
              thumbVisibility: true,
              trackVisibility: true,
              thickness: 8.0,
              scrollbarOrientation: ScrollbarOrientation.bottom,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _horizontalScrollController,
                child: _buildTable(constraints.maxWidth),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTable(double maxAvailableWidth) {
    List<String> orderedFields = _getOrderedFields();
    double tableWidth = orderedFields.fold(
      0.0,
      (sum, col) => sum + (columnWidths[col] ?? 70.0),
    );
    // Aggiunge 60 per la colonna extra (icone filtro).
    tableWidth += 60;
    if (tableWidth != maxAvailableWidth && tableWidth > 0) {
      double scaleFactor = maxAvailableWidth / tableWidth;
      for (var col in orderedFields) {
        double currentW = columnWidths[col] ?? 70.0;
        double newW = currentW * scaleFactor;
        newW = newW.clamp(50.0, 500.0);
        columnWidths[col] = newW;
      }
      tableWidth = maxAvailableWidth;
    }
    return SizedBox(
      width: tableWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(),
          const Divider(),
          ..._buildDataRows(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

 Widget _buildHeaderRow() {
  final orderedFields = _getOrderedFields();
  List<Widget> headerCells = [];
  for (var col in orderedFields) {
    headerCells.add(_buildHeaderCell(col));
  }
  // Colonna extra per il filtro (icona "tune")
  headerCells.add(
    Container(
      alignment: Alignment.center,
      width: 60,
      child: IconButton(
        icon: const Icon(Icons.tune, color: Colors.teal),
        onPressed: _showFieldFilterDialog,
      ),
    ),
  );
  return Row(children: headerCells);
}

Widget _buildHeaderCell(String column) {
  double width = columnWidths[column] ?? 70.0;
  Widget child;
  if (column.toLowerCase() == "select" || column.toLowerCase() == "selected") {
    // Mostra solo il master checkbox, senza testo.
    child = Checkbox(
      value: _masterCheckbox,
      onChanged: (val) {
        setState(() {
          _masterCheckbox = val ?? false;
          // Aggiorna la selezione di tutte le righe.
          for (var row in widget.paymentsList) {
            row["selected"] = _masterCheckbox;
          }
          widget.onPaymentsChanged(widget.paymentsList);
        });
      },
    );
  } else {
    // Usa il label dallo schema se disponibile, altrimenti il nome della colonna.
    String label = widget.schema[column]?["label"] ?? column;
    child = Text(label, style: const TextStyle(fontWeight: FontWeight.bold));
  }
  return Container(
    width: width,
    child: Stack(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: child,
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeLeftRight,
            onEnter: (_) => setState(() => _resizerHovering = true),
            onExit: (_) => setState(() => _resizerHovering = false),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: (details) {
                setState(() {
                  double newWidth = (columnWidths[column] ?? 70.0) + details.delta.dx;
                  newWidth = newWidth.clamp(50.0, 500.0);
                  columnWidths[column] = newWidth;
                });
              },
              child: Container(
                width: 5,
                color: _resizerHovering ? Colors.grey : Colors.transparent,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

List<Widget> _buildDataRows() {
  final orderedFields = _getOrderedFields();
  return widget.paymentsList.asMap().entries.map((entry) {
    final index = entry.key;
    final row = entry.value;
    final bgColor = index % 2 == 0 ? Colors.white : Colors.grey[100];
    List<Widget> cells = [];
    for (var col in orderedFields) {
      cells.add(_buildDataCell(col, row, index));
    }
    // Spazio per la colonna extra (icona "tune")
    cells.add(Container(width: 60));
    return Container(
      color: bgColor,
      child: Row(children: cells),
    );
  }).toList();
}

Widget _buildDataCell(String column, Map<String, dynamic> row, int index) {
  double width = columnWidths[column] ?? 70.0;
  Widget child;
  
  if (column.toLowerCase() == "select" || column.toLowerCase() == "selected") {
    // Visualizza solo il checkbox per la selezione.
    child = Checkbox(
      value: row["selected"] == true,
      onChanged: (val) {
        setState(() {
          row["selected"] = val ?? false;
          if (!row["selected"]) {
            _masterCheckbox = false;
          } else {
            _masterCheckbox = widget.paymentsList.isNotEmpty &&
                widget.paymentsList.every((r) => r["selected"] == true);
          }
          widget.onPaymentsChanged(widget.paymentsList);
        });
      },
    );
  } else {
    switch (column) {
      case "Data":
        DateTime? dt = row["Data"] as DateTime?;
        String txt = (dt != null)
            ? "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}"
            : "";
        child = Text(txt);
        break;
      case "Metodo pagamento":
        String currentVal = (row["Metodo pagamento"] as String?) ?? "";
        child = Text(currentVal);
        break;
      case "Pagamento aggregato":
        bool agg = row["Pagamento aggregato"] == true;
        child = Text(agg ? "Sì" : "No");
        break;
      case "Importo IVA inc.":
        double imp = row["Importo IVA inc."] ?? 0.0;
        child = Text("${imp.toStringAsFixed(2)} €");
        break;
      case "Saldo/Pagato":
        double saldo = row["Saldo/Pagato"] ?? 0.0;
        child = Text("${saldo.toStringAsFixed(2)} €");
        break;
      default:
        child = Text(row[column]?.toString() ?? "");
        break;
    }
  }
  
  return Container(
    width: width,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    alignment: Alignment.centerLeft,
    child: child,
  );
}


  void _showFieldFilterDialog() {
    // Usa le chiavi dello schema, escludendo quelle fisse.
    final filterableFields = widget.schema.keys.where((c) => !fixedFields.contains(c)).toList();
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Seleziona colonne da visualizzare"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    for (var field in filterableFields)
                      CheckboxListTile(
                        value: visibleFields.contains(field),
                        title: Text(widget.schema[field]?["label"] ?? field),
                        onChanged: (bool? value) {
                          setStateDialog(() {
                            if (value == true) {
                              visibleFields.add(field);
                            } else {
                              visibleFields.remove(field);
                            }
                          });
                          setState(() {});
                        },
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text("Chiudi"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
