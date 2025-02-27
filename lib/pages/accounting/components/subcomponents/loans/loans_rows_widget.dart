import 'package:flutter/material.dart';
import 'dart:math' as math;

// In caso tu abbia import specifici per altre parti del progetto, mantienili o adattali.
// import 'package:flutter_app/pages/accounting/components/invoice/invoice_editor.dart'; // Esempio di import

/// Widget che mostra una tabella stile “prestiti/rate”:
/// - Colonne ridimensionabili
/// - Drag & drop delle righe (ad eccezione dell’ultima riga di totali)
/// - Filtraggio delle colonne (CheckboxListTile)
/// - Righe speciali (section/note) con un solo campo di testo
/// - Una riga finale che mostra i totali (somme) delle colonne monetarie.
class AccountingRowsWidget extends StatefulWidget {
  /// Lista di righe:
  /// - type? = "normal"/"section"/"note" (per righe speciali)
  /// - '#' (int) => fisso a 1
  /// - 'Data' (DateTime?)
  /// - 'Capitali' (double)
  /// - 'Interessi' (double)
  /// - 'Pagamenti' (double)
  /// - 'Saldo scoperto' (double)
  /// - 'Lungo termine' (double)
  /// - 'Breve termine' (double)
  final List<Map<String, dynamic>> rows;

  /// Callback invocata su qualunque modifica (aggiunta, reorder, modifica campi, etc.)
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

  /// Campi/colonne (ordine desiderato)
  final List<String> allColumnsOrder = [
    "#",
    "Data",
    "Capitali",
    "Interessi",
    "Pagamenti",
    "Saldo scoperto",
    "Lungo termine",
    "Breve termine",
  ];

  /// Set di campi attualmente visibili (filtrabili)
  Set<String> visibleFields = {
    "#",
    "Data",
    "Capitali",
    "Interessi",
    "Pagamenti",
    "Saldo scoperto",
    "Lungo termine",
    "Breve termine",
  };

  late Map<String, double> columnWidths;

  @override
  void initState() {
    super.initState();
    // Inizializza le larghezze delle colonne dopo il primo frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      // +1 per la colonna handle drag e +1 per i filtri => in totale 2 colonne extra
      final totalCols = allColumnsOrder.length + 1; 
      final defaultWidth = (screenWidth - 128) / totalCols * 0.67;
      setState(() {
        columnWidths = {for (var col in allColumnsOrder) col: defaultWidth};
      });
    });
  }

  /// Filtra le colonne in base a quelle visibili
  List<String> _getOrderedFields() {
    return allColumnsOrder
        .where((col) => visibleFields.contains(col) || col == "#")
        .toList();
  }

  /// Aggiunge riga normale (tipo "normal")
  void _addNormalRow() {
    final newRows = List<Map<String, dynamic>>.from(widget.rows);
    newRows.add({
      'id': UniqueKey(),
      'type': 'normal',
      '#': 1, // Fisso a 1
      'Data': null,
      'Capitali': 0.0,
      'Interessi': 0.0,
      'Pagamenti': 0.0,
      'Saldo scoperto': 0.0,
      'Lungo termine': 0.0,
      'Breve termine': 0.0,
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
  void _onReorder(int oldIndex, int newIndex) {
    // Se l'index corrisponde alla riga dei totali (ultima), non spostarla
    if (oldIndex == widget.rows.length) {
      return; // Non reorder la riga di totali
    }
    if (newIndex >= widget.rows.length) {
      // Se si trascina oltre l'ultima, la forziamo subito prima dell'ultima
      newIndex = widget.rows.length - 1;
    }
    final newRows = List<Map<String, dynamic>>.from(widget.rows);
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = newRows.removeAt(oldIndex);
    newRows.insert(newIndex, moved);
    widget.onRowsChanged(newRows);
  }

void _showFieldFilterDialog() {
  // Solo queste colonne saranno effettivamente filtrabili/toggle-abili
  final Set<String> filterableFields = {"#", "Lungo termine", "Breve termine"};

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
                  // Verifichiamo se la colonna corrente è filtrabile
                  final bool isFilterable = filterableFields.contains(field);

                  return CheckboxListTile(
                    // Se la colonna non è filtrabile, la scritta diventa grigia
                    title: Text(
                      field,
                      style: TextStyle(
                        color: isFilterable ? Colors.black : Colors.grey,
                      ),
                    ),
                    // Se la colonna è visibile in `visibleFields`, la checkbox è spuntata
                    value: visibleFields.contains(field),

                    // Se NON è filtrabile, onChanged = null => disabilitata
                    onChanged: isFilterable
                        ? (bool? checked) {
                            setStateDialog(() {
                              if (checked == true) {
                                visibleFields.add(field);
                              } else {
                                visibleFields.remove(field);
                              }
                            });
                            // Aggiorniamo anche lo stato del widget padre
                            setState(() {});
                          }
                        : null,
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


  /// Calcola i totali delle colonne monetarie
  /// (Capitali, Interessi, Pagamenti, Saldo scoperto, Lungo termine, Breve termine)
  Map<String, double> _calculateTotals() {
    double totalCapitali = 0.0;
    double totalInteressi = 0.0;
    double totalPagamenti = 0.0;
    double totalScoperto = 0.0;
    double totalLungo = 0.0;
    double totalBreve = 0.0;

    for (var row in widget.rows) {
      if (row['type'] == null || row['type'] == 'normal') {
        totalCapitali += (row['Capitali'] is num) ? row['Capitali'] : 0.0;
        totalInteressi += (row['Interessi'] is num) ? row['Interessi'] : 0.0;
        totalPagamenti += (row['Pagamenti'] is num) ? row['Pagamenti'] : 0.0;
        totalScoperto += (row['Saldo scoperto'] is num)
            ? row['Saldo scoperto']
            : 0.0;
        totalLungo += (row['Lungo termine'] is num)
            ? row['Lungo termine']
            : 0.0;
        totalBreve += (row['Breve termine'] is num)
            ? row['Breve termine']
            : 0.0;
      }
    }

    return {
      'Capitali': totalCapitali,
      'Interessi': totalInteressi,
      'Pagamenti': totalPagamenti,
      'Saldo scoperto': totalScoperto,
      'Lungo termine': totalLungo,
      'Breve termine': totalBreve,
    };
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin
    final visibleCols = _getOrderedFields();

    // Sommiamo le larghezze di colonna + 100 (40 handle drag, 60 filtri)
    double sumCols = 0.0;
    for (var c in visibleCols) {
      sumCols += (columnWidths[c] ?? 60.0);
    }
    final totalTableWidth = sumCols + 100;

    // riga totali = ultima riga => itemCount = widget.rows.length + 1
    final totals = _calculateTotals();

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (ctx, constraints) {
              return SizedBox(
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
                                  totals,
                                  visibleCols,
                                  Key("__totals_row__"),
                                );
                              } else {
                                // riga standard o sezione/nota
                                final row = widget.rows[index];
                                final rowKey = row['id'] ?? UniqueKey();
                                return _buildSingleRow(
                                  row,
                                  index,
                                  rowKey,
                                  visibleCols,
                                );
                              }
                            },
                          ),

                          // Pulsante in basso (esempio: "Aggiungi riga")
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
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Spazio extra per evitare che l'ultima parte venga coperta
          const SizedBox(height: 400),
        ],
      ),
    );
  }

  /// Intestazione tabella
  Widget _buildTableHeaderRow(List<String> visibleCols) {
    List<Widget> headerCells = [
      Container(width: 40), // colonna drag handle
    ];
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
          ),
        ],
      ),
    );
  }

  /// Crea una riga “normale” (o “section”/“note”) con drag handle, a meno che non sia la riga di totali
  Widget _buildSingleRow(
    Map<String, dynamic> row,
    int index,
    Key key,
    List<String> visibleCols,
  ) {
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
            // Campo di testo
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

  /// Crea la riga finale di totali (non reorderabile, non eliminabile)
  Widget _buildTotalsRow(
    Map<String, double> totals,
    List<String> visibleCols,
    Key key,
  ) {
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

  /// Restituisce la cella di totali per le colonne monetarie.
  /// Le colonne “Data” o “#” non vengono sommate, quindi restano vuote.
  Widget _buildTotalsCell(String col, Map<String, double> totals) {
    // Sommiamo solo Capitali, Interessi, Pagamenti, Saldo scoperto, Lungo termine, Breve termine
    if (col == "Capitali" ||
        col == "Interessi" ||
        col == "Pagamenti" ||
        col == "Saldo scoperto" ||
        col == "Lungo termine" ||
        col == "Breve termine") {
      final val = totals[col] ?? 0.0;
      return Text(
        "${val.toStringAsFixed(2)} €",
        style: const TextStyle(fontWeight: FontWeight.bold),
      );
    }
    // Per '#' e 'Data' (o altri campi non monetari) lasciamo vuoto
    return const SizedBox();
  }

  /// Costruisce la cella di input per le righe normali
  Widget _buildCellInput(String col, Map<String, dynamic> row, int index) {
    switch (col) {
      case "#":
        // Campo fisso a 1 (o readOnly)
        return Text(
          "${row['#'] ?? 1}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        );

      case "Data":
        final currentDate = row['Data'] as DateTime?;
        return InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: currentDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() => row['Data'] = picked);
              widget.onRowsChanged(widget.rows);
            }
          },
          child: Text(
            currentDate != null
                ? "${currentDate.day}/${currentDate.month}/${currentDate.year}"
                : "Seleziona data",
          ),
        );

      // Campi monetari (double)
      case "Capitali":
      case "Interessi":
      case "Pagamenti":
      case "Saldo scoperto":
      case "Lungo termine":
      case "Breve termine":
        final val = (row[col] is num) ? row[col].toString() : "";
        final textCtrl = TextEditingController(text: val)
          ..selection = TextSelection.collapsed(offset: val.length);
        return TextField(
          controller: textCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(border: InputBorder.none),
          onChanged: (value) {
            setState(() {
              row[col] = double.tryParse(value) ?? 0.0;
            });
            widget.onRowsChanged(widget.rows);
          },
        );

      default:
        return const SizedBox();
    }
  }
}
