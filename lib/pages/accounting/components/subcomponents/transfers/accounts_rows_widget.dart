import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget che mostra una tabella stile “movimenti contabili”:
/// - Colonne ridimensionabili
/// - Scorrimento orizzontale e verticale
/// - 6 colonne fisse: Data, Codice, Nome conto, Tipologia, Dare, Avere
/// - Un pulsante “Aggiungi riga” che apre un dialog con un elenco di movimenti contabili
///   selezionabili tramite checkbox (anche “seleziona tutti”).
///   Al click su “Seleziona”, le righe vengono aggiunte alla tabella.
/// - Un’icona “X” alla fine di ogni riga per rimuoverla dalla tabella.
/// - Niente drag-and-drop, niente filtraggio colonne.
class AccountingRowsWidget extends StatefulWidget {
  /// Lista di righe correnti nella tabella. Ogni riga è una mappa con i campi:
  /// - "Data" (DateTime)
  /// - "Codice" (numero, es. 111600)
  /// - "Nome conto" (Stringa)
  /// - "Tipologia" (Stringa)
  /// - "Dare" (double)
  /// - "Avere" (double)
  final List<Map<String, dynamic>> rows;

  /// Callback invocato quando le righe cambiano (aggiunta, modifica, rimozione).
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
  bool get wantKeepAlive => true; // preserva stato in tab

  final ScrollController _horizontalScrollController = ScrollController();
  bool _resizerHovering = false;

  /// Colonne fisse (ordine e nomi)
  final List<String> columns = [
    "Data",
    "Codice",
    "Nome conto",
    "Tipologia",
    "Dare",
    "Avere",
  ];

  late Map<String, double> columnWidths;

  @override
  void initState() {
    super.initState();
    // Inizializza larghezze dopo il primo frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      // Calcoliamo il defaultWidth in base al numero di colonne + la colonna per l'icona X
      final totalCols = columns.length + 1;
      final defaultWidth = (screenWidth) / totalCols * 0.80 * 0.5;
      setState(() {
        columnWidths = {for (var col in columns) col: defaultWidth};
      });
    });
  }

  /// Dialog per aggiungere movimenti contabili
  Future<void> _showAddMovementsDialog() async {
    // Esempio di movimenti disponibili (da API o altrove)
    final List<Map<String, dynamic>> availableMovements = [
      {
        "Data": DateTime(2025, 2, 13),
        "Codice": 111600,
        "Nome conto": "Costi di impianto",
        "Tipologia": "28% M",
        "Saldo": 0.0,
      },
      {
        "Data": DateTime(2025, 1, 29),
        "Codice": 161000,
        "Nome conto": "Credito IVA",
        "Tipologia": "22% M",
        "Saldo": -26.40,
      },
      {
        "Data": DateTime(2025, 1, 27),
        "Codice": 161000,
        "Nome conto": "Credito IVA",
        "Tipologia": "22% M",
        "Saldo": -24.90,
      },
    ];

    // Selezione multipla (gli indici reali in availableMovements)
    final Set<int> selectedIndexes = {};

    // Supporto per la ricerca
    String searchQuery = "";
    List<Map<String, dynamic>> filteredMovs = List.from(availableMovements);

    await showDialog(
        context: context,
        builder: (ctx) {
          return Dialog(
            // Angoli arrotondati a 4
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            child: Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.7,
              child: StatefulBuilder(
                builder: (context, setStateDialog) {
                  // Applica filtro sui campi: "Codice", "Nome conto", "Tipologia"
                  void _applyFilter(String query) {
                    searchQuery = query.toLowerCase();
                    filteredMovs = availableMovements.where((mov) {
                      final dataStr =
                          "${mov["Codice"]} ${mov["Nome conto"]} ${mov["Tipologia"]}"
                              .toLowerCase();
                      return dataStr.contains(searchQuery);
                    }).toList();
                    setStateDialog(() {});
                  }

                  // Formatta la data in dd/MM/yyyy
                  String _formatDate(DateTime dt) {
                    return "${dt.day.toString().padLeft(2, '0')}/"
                        "${dt.month.toString().padLeft(2, '0')}/"
                        "${dt.year}";
                  }

                  // Formatta il saldo con due decimali e simbolo €
                  String _formatSaldo(dynamic val) {
                    if (val is num) {
                      return "${val.toStringAsFixed(2)} €";
                    }
                    return "";
                  }

                  // Determina se TUTTI i movimenti filtrati sono selezionati
                  bool _areAllFilteredSelected() {
                    if (filteredMovs.isEmpty) return false;
                    return filteredMovs.every((mov) {
                      final realIndex = availableMovements.indexOf(mov);
                      return selectedIndexes.contains(realIndex);
                    });
                  }

                  // Seleziona/deseleziona tutti i movimenti filtrati
                  void _toggleSelectAll(bool selectAll) {
                    if (selectAll) {
                      for (var mov in filteredMovs) {
                        final realIndex = availableMovements.indexOf(mov);
                        selectedIndexes.add(realIndex);
                      }
                    } else {
                      for (var mov in filteredMovs) {
                        final realIndex = availableMovements.indexOf(mov);
                        selectedIndexes.remove(realIndex);
                      }
                    }
                    setStateDialog(() {});
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Riga superiore: Titolo + icona per chiudere
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Aggiungi: Movimenti contabili",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                          ],
                        ),
                      ),
                      const Divider(thickness: 1, color: Colors.grey),
                      // Barra di ricerca
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 400,
                            child: TextField(
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search),
                                hintText: 'Ricerca...',
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              onChanged: (val) => _applyFilter(val),
                            ),
                          ),
                        ),
                      ),
                      // Tabella dei movimenti
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            columns: [
                              // Colonna per la selezione globale
                              DataColumn(
                                label: Row(
                                  children: [
                                    Checkbox(
                                      value: _areAllFilteredSelected(),
                                      onChanged: (bool? checked) {
                                        _toggleSelectAll(checked == true);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const DataColumn(label: Text("Data")),
                              const DataColumn(label: Text("Codice")),
                              const DataColumn(label: Text("Nome conto")),
                              const DataColumn(label: Text("Tipologia")),
                              const DataColumn(label: Text("Saldo")),
                            ],
                            rows: List.generate(filteredMovs.length, (index) {
                              final mov = filteredMovs[index];
                              final realIndex = availableMovements.indexOf(mov);
                              final isSelected =
                                  selectedIndexes.contains(realIndex);
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Checkbox(
                                      value: isSelected,
                                      onChanged: (bool? checked) {
                                        if (checked == true) {
                                          selectedIndexes.add(realIndex);
                                        } else {
                                          selectedIndexes.remove(realIndex);
                                        }
                                        setStateDialog(() {});
                                      },
                                    ),
                                  ),
                                  DataCell(Text(_formatDate(mov["Data"]))),
                                  DataCell(Text(mov["Codice"].toString())),
                                  DataCell(Text(mov["Nome conto"] ?? "")),
                                  DataCell(Text(mov["Tipologia"] ?? "")),
                                  DataCell(Text(_formatSaldo(mov["Saldo"]))),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                      // Riga inferiore: pulsanti "Seleziona" e "Chiudi"
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6B3A5B),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                              ),
                              onPressed: selectedIndexes.isEmpty
                                  ? null
                                  : () {
                                      final newRows = [...widget.rows];
                                      for (var i in selectedIndexes) {
                                        final mov = availableMovements[i];
                                        newRows.add({
                                          "Data": mov["Data"],
                                          "Codice": mov["Codice"],
                                          "Nome conto": mov["Nome conto"],
                                          "Tipologia": mov["Tipologia"],
                                          "Dare": (mov["Saldo"] != null &&
                                                  mov["Saldo"] > 0)
                                              ? mov["Saldo"]
                                              : 0.0,
                                          "Avere": (mov["Saldo"] != null &&
                                                  mov["Saldo"] < 0)
                                              ? mov["Saldo"]
                                              : 0.0,
                                        });
                                      }
                                      widget.onRowsChanged(newRows);
                                      Navigator.of(ctx).pop();
                                    },
                              child: const Text(
                                "Seleziona",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                side: const BorderSide(color: Colors.grey),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                              ),
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text(
                                "Chiudi",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        });
  }

  /// Rimuove una riga dalla tabella
  void _deleteRow(int index) {
    final newRows = List<Map<String, dynamic>>.from(widget.rows);
    newRows.removeAt(index);
    widget.onRowsChanged(newRows);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double sumCols = 0.0;
    for (var c in columns) {
      sumCols += (columnWidths[c] ?? 60.0);
    }
    final totalTableWidth = sumCols + 60; // 60 per colonna "X"

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          // Tabella
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
                        maxWidth:
                            math.max(totalTableWidth, constraints.maxWidth),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Intestazione
                          _buildTableHeaderRow(),
                          const Divider(),
                          // Elenco righe
                          ...List.generate(widget.rows.length, (index) {
                            final row = widget.rows[index];
                            return _buildSingleRow(row, index);
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Pulsante "Aggiungi riga"
          Row(
            children: [
              const SizedBox(width: 16),
              TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: _showAddMovementsDialog,
                child: const Text(
                  "Aggiungi riga",
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 400),
        ],
      ),
    );
  }

  /// Costruisce la riga di intestazione (colonne + colonna "X" vuota).
  Widget _buildTableHeaderRow() {
    final List<Widget> headerCells = [];
    for (String col in columns) {
      headerCells.add(_buildColumnHeaderCell(col));
    }
    // colonna "X"
    headerCells.add(Container(
      alignment: Alignment.center,
      width: 60,
    ));
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

  /// Crea una singola riga di tabella
  Widget _buildSingleRow(Map<String, dynamic> row, int index) {
    return Container(
      color: (index % 2 == 0) ? Colors.white : Colors.grey[200],
      child: Row(
        children: [
          // Celle
          ...columns.map((col) {
            return Container(
              width: columnWidths[col],
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: _buildCellInput(col, row, index),
            );
          }).toList(),
          // Icona "X" per rimuovere
          Container(
            alignment: Alignment.center,
            width: 60,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => _deleteRow(index),
            ),
          ),
        ],
      ),
    );
  }

  /// Crea l'input per la cella in base al nome della colonna
  Widget _buildCellInput(String col, Map<String, dynamic> row, int index) {
    switch (col) {
      case "Data":
        final dt = row["Data"] as DateTime?;
        return InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: dt ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              final newRows = List<Map<String, dynamic>>.from(widget.rows);
              newRows[index]["Data"] = picked;
              widget.onRowsChanged(newRows);
            }
          },
          child: Text(dt != null ? _formatDate(dt) : "Seleziona data"),
        );

      case "Codice":
        final val = (row["Codice"] != null) ? row["Codice"].toString() : "";
        final textCtrl = TextEditingController(text: val)
          ..selection = TextSelection.collapsed(offset: val.length);
        return TextField(
          controller: textCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(border: InputBorder.none),
          onChanged: (value) {
            final newRows = List<Map<String, dynamic>>.from(widget.rows);
            newRows[index]["Codice"] = int.tryParse(value) ?? 0;
            widget.onRowsChanged(newRows);
          },
        );

      case "Nome conto":
        final val = row["Nome conto"] ?? "";
        final textCtrl = TextEditingController(text: val)
          ..selection = TextSelection.collapsed(offset: val.length);
        return TextField(
          controller: textCtrl,
          decoration: const InputDecoration(border: InputBorder.none),
          onChanged: (value) {
            final newRows = List<Map<String, dynamic>>.from(widget.rows);
            newRows[index]["Nome conto"] = value;
            widget.onRowsChanged(newRows);
          },
        );

      case "Tipologia":
        final val = row["Tipologia"] ?? "";
        final textCtrl = TextEditingController(text: val)
          ..selection = TextSelection.collapsed(offset: val.length);
        return TextField(
          controller: textCtrl,
          decoration: const InputDecoration(border: InputBorder.none),
          onChanged: (value) {
            final newRows = List<Map<String, dynamic>>.from(widget.rows);
            newRows[index]["Tipologia"] = value;
            widget.onRowsChanged(newRows);
          },
        );

      case "Dare":
      case "Avere":
        final valNum = (row[col] is num) ? row[col].toString() : "";
        final textCtrl = TextEditingController(text: valNum)
          ..selection = TextSelection.collapsed(offset: valNum.length);
        return TextField(
          controller: textCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(border: InputBorder.none),
          onChanged: (value) {
            final newRows = List<Map<String, dynamic>>.from(widget.rows);
            newRows[index][col] = double.tryParse(value) ?? 0.0;
            widget.onRowsChanged(newRows);
          },
        );

      default:
        return const SizedBox();
    }
  }

  /// Utility per formattare la data in "dd/MM/yyyy"
  String _formatDate(DateTime? dt) {
    if (dt == null) return "";
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
  }
}
