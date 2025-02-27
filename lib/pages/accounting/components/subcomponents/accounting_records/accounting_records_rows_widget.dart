import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_app/pages/accounting/components/accounting_records/accounting_records_editor.dart';

// Elenco di opzioni per "Conto"
const List<String> contoOptions = [
  "110100 Costi di impianto",
  "110600 Software",
  "110800 Avviamento",
  "111100 Fondo ammortamento costi di impianto",
  "111600 Fondo ammortamento software",
  "111800 Fondo ammortamento avviamento",
  "120100 Fabbricati",
  "120200 Impianti e macchinari",
  "120400 Attrezzature commerciali",
  "120500 Macchine d'ufficio",
];

// Elenco di opzioni per "Griglie imposte"
const List<String> imposteOptions = [
  "+02 Imposte Italia",
  "-03 Imposte Italia",
  "+03 Imposte Italia",
  "-4v Imposte Italia",
  "+4v Imposte Italia",
  "-5v Imposte Italia",
  "+5v Imposte Italia",
  "-vp7 Imposte Italia",
  "+vp7 Imposte Italia",
  "-vp8 Imposte Italia",
];

// Elenco di opzioni per "Partner" (nuova colonna)
const List<String> partnerOptions = [
  "Partner 1",
  "Partner 2",
  "Partner 3",
  "Partner XYZ",
];

/// Widget che mostra una tabella stile “movimenti contabili”:
/// - Colonne ridimensionabili
/// - Drag & drop delle righe (tranne la riga finale di totali, che resta sempre ultima)
/// - Filtraggio delle colonne (CheckboxListTile)
/// - Righe speciali (section/note) con un solo campo di testo
/// - Una riga finale che mostra i totali di Dare, Avere e Sconto.
class AccountingRowsWidget extends StatefulWidget {
  /// Lista di righe con i campi (per righe "normal"):
  ///  - type? = "normal"/"section"/"note"
  ///  - Conto (String)
  ///  - Partner (String)
  ///  - Etichetta (String)
  ///  - Scadenze (DateTime?)
  ///  - Imposte (double)
  ///  - Dare (double)
  ///  - Avere (double)
  ///  - Data di sconto (DateTime?)
  ///  - Importo dello sconto (double)
  ///  - Griglie imposte (String)
  ///
  /// "type" = null o "normal" => riga normale
  /// "type" = "section" => riga sezione (un solo campo di testo)
  /// "type" = "note" => riga nota (un solo campo di testo)
  final List<Map<String, dynamic>> rows;

  /// Callback invocata su qualunque modifica (aggiunta, reorder, modifica campi)
  final ValueChanged<List<Map<String, dynamic>>> onRowsChanged;

  const AccountingRowsWidget({
    Key? key,
    required this.rows,
    required this.onRowsChanged,
  }) : super(key: key);

  @override
  _AccountingRowsWidgetState createState() => _AccountingRowsWidgetState();
}

class _AccountingRowsWidgetState extends State<AccountingRowsWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // preserva lo stato in tab

  final ScrollController _horizontalScrollController = ScrollController();
  bool _resizerHovering = false;

  /// Tutti i campi disponibili (ordine desiderato)
  final List<String> allColumnsOrder = [
    "Conto",
    "Partner",
    "Etichetta",
    "Scadenze",
    "Imposte",
    "Dare",
    "Avere",
    "Data di sconto",
    "Importo dello sconto",
    "Griglie imposte",
  ];

  /// Set di campi attualmente visibili (filtrabili)
  Set<String> visibleFields = {
    "Conto",
    "Partner",
    "Etichetta",
    "Scadenze",
    "Imposte",
    "Dare",
    "Avere",
    "Data di sconto",
    "Importo dello sconto",
    "Griglie imposte",
  };

  late Map<String, double> columnWidths;

  @override
  void initState() {
    super.initState();
    // Inizializza larghezze in base a dimensioni schermo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      final totalCols =
          allColumnsOrder.length + 1; // +1 per drag handle + filtri
      final defaultWidth = (screenWidth - 128) / totalCols * 0.67;
      setState(() {
        columnWidths = {for (var col in allColumnsOrder) col: defaultWidth};
      });
    });
  }

  /// Ritorna l’elenco di colonne visibili (applica il filtro)
  List<String> _getOrderedFields() {
    return allColumnsOrder.where((col) => 
  visibleFields.contains(col) || col == "Conto" || col == "Dare" || col == "Avere"
).toList();

  }

  /// Aggiunge riga normale
  void _addNormalRow() {
    final newRows = List<Map<String, dynamic>>.from(widget.rows);
    newRows.add({
      'id': UniqueKey(),
      'type': 'normal',
      'Conto': contoOptions[0],
      'Partner': partnerOptions[0],
      'Etichetta': '',
      'Scadenze': null,
      'Imposte': 0.0,
      'Dare': 0.0,
      'Avere': 0.0,
      'Data di sconto': null,
      'Importo dello sconto': 0.0,
      'Griglie imposte': imposteOptions[0],
    });
    widget.onRowsChanged(newRows);
  }

  /// Elimina riga
  void _deleteRow(int index) {
    final newRows = List<Map<String, dynamic>>.from(widget.rows);
    newRows.removeAt(index);
    widget.onRowsChanged(newRows);
  }

  /// Reorder: sposta righe “normali” e speciali, ma non la riga finale di totali
  /// se si tenta di trascinare una riga oltre l’ultima (totali), la riga totali rimane in fondo.
  void _onReorder(int oldIndex, int newIndex) {
    final isTotalsRow = (oldIndex == widget.rows.length);
    if (isTotalsRow) {
      // La riga di totali non è reorderable, annulla
      return;
    }
    if (newIndex >= widget.rows.length) {
      // Se l'utente cerca di spostare una riga oltre l'ultima, forziamo newIndex = last-1
      newIndex = widget.rows.length - 1;
    }

    final newRows = List<Map<String, dynamic>>.from(widget.rows);
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = newRows.removeAt(oldIndex);
    newRows.insert(newIndex, moved);
    widget.onRowsChanged(newRows);
  }

  /// Finestra per filtrare le colonne
  void _showFieldFilterDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Seleziona campi visibili"),
              content: SingleChildScrollView(
                child: Column(
children: allColumnsOrder.map((field) {
  return CheckboxListTile(
    title: Text(field),
    value: visibleFields.contains(field),
    onChanged: (field == "Conto" || field == "Dare" || field == "Avere") ? null : (bool? checked) {
      setStateDialog(() {
        if (checked == true) {
          visibleFields.add(field);
        } else {
          visibleFields.remove(field);
        }
      });
      setState(() {});
    },
  );
}).toList(),

                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text("Chiudi"),
                )
              ],
            );
          },
        );
      },
    );
  }

  /// Calcola i totali di Dare, Avere, Importo sconto
  Map<String, double> _calculateTotals() {
    double totalDare = 0.0;
    double totalAvere = 0.0;
    double totalSconto = 0.0;
    for (var row in widget.rows) {
      if (row['type'] == null || row['type'] == 'normal') {
        double dareVal =
            row['Dare'] is num ? (row['Dare'] as num).toDouble() : 0.0;
        double avereVal =
            row['Avere'] is num ? (row['Avere'] as num).toDouble() : 0.0;
        double scontoVal = row['Importo dello sconto'] is num
            ? (row['Importo dello sconto'] as num).toDouble()
            : 0.0;
        totalDare += dareVal;
        totalAvere += avereVal;
        totalSconto += scontoVal;
      }
    }
    return {
      'Dare': totalDare,
      'Avere': totalAvere,
      'Sconto': totalSconto,
    };
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin
    final visibleCols = _getOrderedFields();
    // Larghezza totale delle colonne visibili + 100 (40 handle, 60 filtri)
    double sumCols = 0.0;
    for (var c in visibleCols) {
      sumCols += (columnWidths[c] ?? 60.0);
    }
    final totalTableWidth = sumCols + 100;

    // riga totali = ultima riga => itemCount = widget.rows.length + 1
    final totals = _calculateTotals();

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(children: [
        LayoutBuilder(
          builder: (ctx, constraints) {
            return Container(
              width: constraints.maxWidth,
              child: Scrollbar(
                controller: _horizontalScrollController,
                thumbVisibility: true,
                trackVisibility: true,
                thickness: 8.0,
                radius: const Radius.circular(4),
                scrollbarOrientation: ScrollbarOrientation.bottom,
                child: SingleChildScrollView(
                  controller: _horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: math.max(totalTableWidth, constraints.maxWidth),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Intestazione
                        _buildTableHeaderRow(visibleCols),
                        const Divider(),

                        // ReorderableListView con riga finale di totali
                        ReorderableListView.builder(
                          buildDefaultDragHandles: false,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          onReorder: _onReorder,
                          proxyDecorator: (child, index, animation) {
                            return Material(elevation: 8, child: child);
                          },
                          itemCount: widget.rows.length + 1,
                          itemBuilder: (context, index) {
                            // Se index == widget.rows.length => riga totali
                            if (index == widget.rows.length) {
                              return _buildTotalsRow(
                                  totals, visibleCols, Key("__totals_row__"));
                            } else {
                              // riga standard o sezione/nota
                              final row = widget.rows[index];
                              final rowKey = row['id'] ?? UniqueKey();
                              return _buildSingleRow(
                                  row, index, rowKey, visibleCols);
                            }
                          },
                        ),

                        // Pulsante in basso (solo "Aggiungi riga")
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const SizedBox(width: 40),
                            TextButton(
                              onPressed: _addNormalRow,
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: const Text(
                                "Aggiungi riga",
                                style: TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16)
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 400), // Spazio di 400 px
      ]),
    );
  }

  /// Intestazione tabella
  Widget _buildTableHeaderRow(List<String> visibleCols) {
    List<Widget> headerCells = [Container(width: 40)]; // colonna drag handle
    for (String column in visibleCols) {
      headerCells.add(_buildColumnHeaderCell(column));
    }
    // Pulsante filtri
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

  Widget _buildColumnHeaderCell(String column) {
    return Container(
      width: columnWidths[column],
      child: Stack(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Text(column,
                style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    double newW = columnWidths[column]! + details.delta.dx;
                    if (newW < 50) newW = 50;
                    columnWidths[column] = newW;
                  });
                },
                child: Container(
                  width: 5,
                  color: _resizerHovering ? Colors.grey : Colors.transparent,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// Crea una riga “normale” (o “section”/“note”) con drag handle, a meno che non sia la riga di totali
  Widget _buildSingleRow(
      Map<String, dynamic> row, int index, Key key, List<String> visibleCols) {
    // Calcolo larghezza
    double totalWidth = 0.0;
    for (var col in visibleCols) {
      totalWidth += (columnWidths[col] ?? 60.0);
    }
    totalWidth += 100;

    // Se sezione o nota
    if (row['type'] == 'section' || row['type'] == 'note') {
      return Container(
        key: key,
        width: totalWidth,
        color: (index % 2 == 0) ? Colors.white : Colors.grey[200]!,
        child: Row(
          children: [
            // Drag handle
            Container(
              width: 40,
              alignment: Alignment.center,
              child: ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.menu),
              ),
            ),
            // Campo di testo su (totalWidth - 100)
            Container(
              width: totalWidth - 100,
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: (row['type'] == 'section') ? "Sezione" : "Nota",
                  border: InputBorder.none,
                ),
                controller: _getTextController(row),
                maxLines: null,
                onChanged: (val) {
                  setState(() => row['text'] = val);
                  widget.onRowsChanged(widget.rows);
                },
              ),
            ),
            Container(
              alignment: Alignment.center,
              width: 60,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteRow(index),
              ),
            ),
          ],
        ),
      );
    }

    // Riga normal
    return Container(
      key: key,
      color: (index % 2 == 0) ? Colors.white : Colors.grey[200]!,
      child: Row(
        children: [
          Container(
            width: 40,
            alignment: Alignment.center,
            child: ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.menu),
            ),
          ),
          // Celle
          ...visibleCols.map((col) {
            return Container(
              width: columnWidths[col],
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: _buildCellInput(col, row, index),
            );
          }).toList(),
          // Icona delete
          Container(
            alignment: Alignment.center,
            width: 60,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteRow(index),
            ),
          ),
        ],
      ),
    );
  }

  /// Ritorna un TextController per le righe speciali (section/note)
TextEditingController _getTextController(Map<String, dynamic> row) {
  if (!row.containsKey('textController')) {
    row['textController'] = TextEditingController(text: row['text'] ?? '');
  }
  return row['textController'] as TextEditingController;
}

  /// Crea la riga finale di totali. Non è reorderable né eliminabile.
  /// Solo Dare, Avere, e Importo dello sconto vanno popolati, le altre colonne restano vuote.
  Widget _buildTotalsRow(
      Map<String, double> totals, List<String> visibleCols, Key key) {
    // Stessa larghezza di riga
    double totalWidth = 0.0;
    for (var col in visibleCols) {
      totalWidth += (columnWidths[col] ?? 60.0);
    }
    totalWidth += 100;

    return Container(
      key: key,
      width: totalWidth,
      color: Colors.grey[300],
      child: Row(
        children: [
          // colonna per handle (vuoto, no reorder)
          Container(width: 40),
          // Per ogni colonna
          ...visibleCols.map((col) {
            return Container(
              width: columnWidths[col],
              alignment: Alignment.centerLeft,
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: _buildTotalsCell(col, totals),
            );
          }).toList(),
          // colonna pulsante delete (vuoto)
          Container(width: 60),
        ],
      ),
    );
  }

  /// Restituisce la cella di totali. Se colonna == Dare/Avere/Importo dello sconto => mostra valore,
  /// altrimenti vuoto.
  Widget _buildTotalsCell(String col, Map<String, double> totals) {
    if (col == "Dare") {
      return Text(
        "${totals['Dare']?.toStringAsFixed(2) ?? '0.00'} €",
        style: const TextStyle(fontWeight: FontWeight.bold),
      );
    } else if (col == "Avere") {
      return Text(
        "${totals['Avere']?.toStringAsFixed(2) ?? '0.00'} €",
        style: const TextStyle(fontWeight: FontWeight.bold),
      );
    } else if (col == "Importo dello sconto") {
      final sconto = totals['Sconto'] ?? 0.0;
      return Text(
        "${sconto.toStringAsFixed(2)} €",
        style: const TextStyle(fontWeight: FontWeight.bold),
      );
    } else {
      // Le altre colonne rimangono vuote
      return const SizedBox();
    }
  }

  /// Costruisce la cella input per righe normal (non allineiamo più a destra, uniformiamo)
  Widget _buildCellInput(String col, Map<String, dynamic> row, int index) {
    switch (col) {
      case "Conto":
        return CustomDropdown(
          items: contoOptions,
          value: row['Conto'] ?? contoOptions[0],
          onChanged: (val) {
            setState(() => row['Conto'] = val);
            widget.onRowsChanged(widget.rows);
          },
        );

      case "Partner":
        return CustomDropdown(
          items: partnerOptions,
          value: row['Partner'] ?? partnerOptions[0],
          onChanged: (val) {
            setState(() => row['Partner'] = val);
            widget.onRowsChanged(widget.rows);
          },
        );

      case "Etichetta":
        final textVal = row['Etichetta'] ?? '';
        final textCtrl = TextEditingController(text: textVal)
          ..selection = TextSelection.collapsed(offset: textVal.length);
        return TextField(
          decoration: const InputDecoration(border: InputBorder.none),
          controller: textCtrl,
          onChanged: (val) {
            setState(() => row['Etichetta'] = val);
            widget.onRowsChanged(widget.rows);
          },
        );

      case "Scadenze":
        final currentDate = row['Scadenze'] as DateTime?;
        return InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: currentDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() => row['Scadenze'] = picked);
              widget.onRowsChanged(widget.rows);
            }
          },
          child: Text(
            currentDate != null
                ? "${currentDate.day}/${currentDate.month}/${currentDate.year}"
                : "Seleziona data",
          ),
        );

      case "Imposte":
      case "Dare":
      case "Avere":
      case "Importo dello sconto":
        final val = (row[col] is num) ? row[col].toString() : "";
        // Creiamo un controller e spostiamo il cursore a destra
        final textCtrl = TextEditingController(text: val)
          ..selection = TextSelection.collapsed(offset: val.length);

        return TextField(
          controller: textCtrl,
          // tolto textAlign: TextAlign.right => allineamento di default (sinistra)
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(border: InputBorder.none),
          onChanged: (value) {
            setState(() {
              row[col] = double.tryParse(value) ?? 0.0;
            });
            widget.onRowsChanged(widget.rows);
          },
        );

      case "Data di sconto":
        final discountDate = row['Data di sconto'] as DateTime?;
        return InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: discountDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() => row['Data di sconto'] = picked);
              widget.onRowsChanged(widget.rows);
            }
          },
          child: Text(
            discountDate != null
                ? "${discountDate.day}/${discountDate.month}/${discountDate.year}"
                : "Seleziona data",
          ),
        );

      case "Griglie imposte":
        return CustomDropdown(
          items: imposteOptions,
          value: row['Griglie imposte'] ?? imposteOptions[0],
          onChanged: (newVal) {
            setState(() => row['Griglie imposte'] = newVal);
            widget.onRowsChanged(widget.rows);
          },
        );

      default:
        return const SizedBox();
    }
  }
}
