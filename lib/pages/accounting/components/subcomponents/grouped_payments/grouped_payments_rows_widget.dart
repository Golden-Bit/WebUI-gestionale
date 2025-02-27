import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget che mostra una tabella stile “pagamenti avvenuti” con:
/// - Colonne ridimensionabili
/// - Scorrimento orizzontale e verticale
/// - 6 colonne base: Numero, Data, Cliente/Fornitore, Promemoria, Metodo di pagamento, Importo
/// - Possibilità di filtrare quali colonne visualizzare (tranne le colonne fisse)
/// - Un pulsante “Aggiungi riga” che apre un dialog con un elenco di pagamenti
///   selezionabili tramite checkbox (con "seleziona tutti").
class PaymentRowsWidget extends StatefulWidget {
  /// Lista di righe correnti nella tabella. Ogni riga è una mappa con i campi:
  /// - "Numero" (numero pagamento)
  /// - "Data" (DateTime)
  /// - "Cliente/Fornitore" (String)
  /// - "Promemoria" (String)
  /// - "Metodo di pagamento" (String)
  /// - "Importo" (double)
  final List<Map<String, dynamic>> rows;

  /// Callback invocato quando le righe cambiano (aggiunta, modifica, rimozione).
  final ValueChanged<List<Map<String, dynamic>>> onRowsChanged;

  const PaymentRowsWidget({
    Key? key,
    required this.rows,
    required this.onRowsChanged,
  }) : super(key: key);

  @override
  _PaymentRowsWidgetState createState() => _PaymentRowsWidgetState();
}

class _PaymentRowsWidgetState extends State<PaymentRowsWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ScrollController _horizontalScrollController = ScrollController();
  bool _resizerHovering = false;

  // Elenco di tutte le colonne (in ordine)
  final List<String> allColumns = [
    "Numero",
    "Data",
    "Cliente/Fornitore",
    "Promemoria",
    "Metodo di pagamento",
    "Importo",
  ];

  // Colonne che vogliamo sempre mostrare (non filtrabili)
  final List<String> fixedColumns = [
    "Importo",
  ];

  // Insieme delle colonne filtrabili inizialmente visibili
  // (quelle non in fixedColumns).
  // L'utente può (de)selezionarle dal dialog di filtro.
  late Set<String> visibleFields;

  late Map<String, double> columnWidths;

  @override
  void initState() {
    super.initState();

    // Inizializziamo visibleFields con tutte le colonne (tranne le fisse).
    visibleFields = {
      for (var col in allColumns)
        if (!fixedColumns.contains(col)) col
    };

    // Inizializza le larghezze delle colonne dopo il primo frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      // Calcoliamo la larghezza di default in base al numero di colonne + una per l'icona "X"
      // (ma contiamo solo quelle "attualmente" possibili, cioè allColumns + colonna X)
      final totalCols = allColumns.length + 1;
      final defaultWidth = (screenWidth) / totalCols * 0.67;
      setState(() {
        columnWidths = {for (var col in allColumns) col: defaultWidth};
      });
    });
  }

  /// Restituisce l'elenco di colonne da mostrare, unendo i campi fissi e i campi
  /// inclusi in `visibleFields`, rispettando l'ordine di `allColumns`.
  List<String> _getOrderedColumns() {
    return allColumns.where((col) {
      // Mostra se è una colonna fissa o se si trova in visibleFields
      return fixedColumns.contains(col) || visibleFields.contains(col);
    }).toList();
  }

  /// Dialog per aggiungere pagamenti.
  Future<void> _showAddPaymentsDialog() async {
    // Simulazione di pagamenti disponibili (questi dati potrebbero provenire da un'API)
    final List<Map<String, dynamic>> availablePayments = [
      {
        "Numero": 1001,
        "Data": DateTime(2025, 3, 1),
        "Cliente/Fornitore": "Cliente A",
        "Promemoria": "Pagamento mensile",
        "Metodo di pagamento": "Bonifico",
        "Importo": 1500.00,
      },
      {
        "Numero": 1002,
        "Data": DateTime(2025, 3, 5),
        "Cliente/Fornitore": "Fornitore B",
        "Promemoria": "Pagamento fornitura",
        "Metodo di pagamento": "Carta di credito",
        "Importo": 2500.50,
      },
      {
        "Numero": 1003,
        "Data": DateTime(2025, 3, 10),
        "Cliente/Fornitore": "Cliente C",
        "Promemoria": "Acconto progetto",
        "Metodo di pagamento": "Contanti",
        "Importo": 800.75,
      },
      {
        "Numero": 1004,
        "Data": DateTime(2025, 3, 15),
        "Cliente/Fornitore": "Fornitore D",
        "Promemoria": "Pagamento trimestrale",
        "Metodo di pagamento": "Bonifico",
        "Importo": 3200.00,
      },
    ];

    // Set per la selezione multipla (memorizza gli indici reali di availablePayments)
    final Set<int> selectedIndexes = {};

    // Supporto per la ricerca
    String searchQuery = "";
    List<Map<String, dynamic>> filteredPayments = List.from(availablePayments);

    await showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          child: Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.7,
            child: StatefulBuilder(
              builder: (context, setStateDialog) {
                void _applyFilter(String query) {
                  searchQuery = query.toLowerCase();
                  filteredPayments = availablePayments.where((payment) {
                    final combined =
                        "${payment["Numero"]} ${payment["Cliente/Fornitore"]} ${payment["Promemoria"]} ${payment["Metodo di pagamento"]}"
                            .toLowerCase();
                    return combined.contains(searchQuery);
                  }).toList();
                  setStateDialog(() {});
                }

                // Formatta la data in dd/MM/yyyy
                String _formatDate(DateTime dt) {
                  return "${dt.day.toString().padLeft(2, '0')}/"
                      "${dt.month.toString().padLeft(2, '0')}/"
                      "${dt.year}";
                }

                // Formatta l'importo con due decimali e simbolo €
                String _formatImporto(dynamic val) {
                  if (val is num) {
                    return "${val.toStringAsFixed(2)} €";
                  }
                  return "";
                }

                bool _areAllFilteredSelected() {
                  if (filteredPayments.isEmpty) return false;
                  return filteredPayments.every((payment) {
                    final realIndex = availablePayments.indexOf(payment);
                    return selectedIndexes.contains(realIndex);
                  });
                }

                void _toggleSelectAll(bool selectAll) {
                  if (selectAll) {
                    for (var payment in filteredPayments) {
                      final realIndex = availablePayments.indexOf(payment);
                      selectedIndexes.add(realIndex);
                    }
                  } else {
                    for (var payment in filteredPayments) {
                      final realIndex = availablePayments.indexOf(payment);
                      selectedIndexes.remove(realIndex);
                    }
                  }
                  setStateDialog(() {});
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Riga superiore: Titolo e pulsante per chiudere
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Aggiungi: Pagamenti avvenuti",
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
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    // Tabella dei pagamenti disponibili
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
                            const DataColumn(label: Text("Numero")),
                            const DataColumn(label: Text("Data")),
                            const DataColumn(label: Text("Cliente/Fornitore")),
                            const DataColumn(label: Text("Promemoria")),
                            const DataColumn(label: Text("Metodo di pagamento")),
                            const DataColumn(label: Text("Importo")),
                          ],
                          rows: List.generate(filteredPayments.length, (index) {
                            final payment = filteredPayments[index];
                            final realIndex =
                                availablePayments.indexOf(payment);
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
                                DataCell(Text(payment["Numero"].toString())),
                                DataCell(Text(_formatDate(payment["Data"]))),
                                DataCell(
                                    Text(payment["Cliente/Fornitore"] ?? "")),
                                DataCell(Text(payment["Promemoria"] ?? "")),
                                DataCell(
                                    Text(payment["Metodo di pagamento"] ?? "")),
                                DataCell(Text(_formatImporto(payment["Importo"]))),
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
                                      final payment = availablePayments[i];
                                      newRows.add({
                                        "Numero": payment["Numero"],
                                        "Data": payment["Data"],
                                        "Cliente/Fornitore":
                                            payment["Cliente/Fornitore"],
                                        "Promemoria": payment["Promemoria"],
                                        "Metodo di pagamento":
                                            payment["Metodo di pagamento"],
                                        "Importo": payment["Importo"],
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
      },
    );
  }

  /// Rimuove una riga dalla tabella
  void _deleteRow(int index) {
    final newRows = List<Map<String, dynamic>>.from(widget.rows);
    newRows.removeAt(index);
    widget.onRowsChanged(newRows);
  }

  /// Dialog di configurazione delle colonne
  /// Permette all'utente di selezionare/deselezionare le colonne (tranne quelle fisse).
  void _showColumnFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        // Uso un StatefulBuilder per gestire lo stato locale del dialog
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Seleziona colonne da visualizzare"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: allColumns
                      .where((col) => !fixedColumns.contains(col)) // escludi col fissi
                      .map((col) {
                    return CheckboxListTile(
                      title: Text(col),
                      value: visibleFields.contains(col),
                      onChanged: (bool? checked) {
                        setStateDialog(() {
                          if (checked == true) {
                            visibleFields.add(col);
                          } else {
                            visibleFields.remove(col);
                          }
                        });
                        // Aggiorna l'interfaccia principale
                        setState(() {});
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Chiudi"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Determina quali colonne mostrare
    final usedColumns = _getOrderedColumns();

    // Calcoliamo la larghezza complessiva in base alle colonne usate
    double sumCols = 0.0;
    for (var c in usedColumns) {
      sumCols += (columnWidths[c] ?? 60.0);
    }
    final totalTableWidth = sumCols + 60; // 60 per la colonna dell'icona "X"

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
                          _buildTableHeaderRow(usedColumns),
                          const Divider(),
                          // Elenco righe
                          ...List.generate(widget.rows.length, (index) {
                            final row = widget.rows[index];
                            return _buildSingleRow(row, index, usedColumns);
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
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                onPressed: _showAddPaymentsDialog,
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

  /// Costruisce la riga di intestazione (solo per le colonne in usedColumns)
  /// più una colonna finale vuota per la "X" e l'icona di filtro.
  Widget _buildTableHeaderRow(List<String> usedColumns) {
    final List<Widget> headerCells = [];
    for (String col in usedColumns) {
      headerCells.add(_buildColumnHeaderCell(col));
    }
    // Colonna per l'icona di cancellazione (vuota) + icona di filtro
    headerCells.add(Container(
      alignment: Alignment.center,
      width: 60,
      child: IconButton(
        icon: const Icon(Icons.tune, color: Colors.teal),
        onPressed: _showColumnFilterDialog,
      ),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Text(
              column,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
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

  /// Crea una singola riga della tabella, mostrando solo le colonne in usedColumns,
  /// più una colonna finale per l'icona "X" (rimozione riga).
  Widget _buildSingleRow(
    Map<String, dynamic> row,
    int index,
    List<String> usedColumns,
  ) {
    return Container(
      color: (index % 2 == 0) ? Colors.white : Colors.grey[200],
      child: Row(
        children: [
          // Celle per le colonne filtrate
          ...usedColumns.map((col) {
            return Container(
              width: columnWidths[col],
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: _buildCellInput(col, row, index),
            );
          }).toList(),
          // Icona "X" per rimuovere la riga
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

  /// Crea l'input per ciascuna cella in base al nome della colonna.
  Widget _buildCellInput(String col, Map<String, dynamic> row, int index) {
    switch (col) {
      case "Data":
        final dt = row["Data"] as DateTime?;
        return InkWell(
          /*onTap: () async {
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
          },*/
          child: Text(dt != null ? _formatDate(dt) : "Seleziona data"),
        );

      case "Numero":
        final val = (row["Numero"] != null) ? row["Numero"].toString() : "";
        return Text(val);

      case "Cliente/Fornitore":
        final val = row["Cliente/Fornitore"] ?? "";
        return Text(val);

      case "Promemoria":
        final val = row["Promemoria"] ?? "";
        return Text(val);

      case "Metodo di pagamento":
        final val = row["Metodo di pagamento"] ?? "";
        return Text(val);

      case "Importo":
        final val = (row["Importo"] != null) ? row["Importo"].toString() : "";
        return Text(val);

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
