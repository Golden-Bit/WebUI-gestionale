import 'package:flutter/material.dart';

class InvoiceRowsWidget extends StatefulWidget {
  const InvoiceRowsWidget({Key? key}) : super(key: key);

  @override
  _InvoiceRowsWidgetState createState() => _InvoiceRowsWidgetState();
}

class _InvoiceRowsWidgetState extends State<InvoiceRowsWidget> {
  final ScrollController _horizontalScrollController = ScrollController();

  bool _resizerHovering = false;
  // Lista dinamica delle righe della tabella
  List<Map<String, dynamic>> invoiceRows = [];
  // Campi visibili configurati tramite il filtro (colonne filtrabili)
  Set<String> visibleFields = {
    'Prodotto',
    'Descrizione',
    'Etichetta',
    'Data inizio',
    'Data fine',
    'Quantità',
    'Sconto %',
    'Imposte',
  };
  double _getTotalTableWidth() {
    return _getOrderedFields()
        .fold<double>(0.0, (sum, field) => sum + columnWidths[field]!);
  }

  // Campi non filtrabili (sempre visibili)
  final List<String> fixedFields = ['Conto', 'Prezzo', 'Importo'];

  // Elenco di tutte le colonne nell'ordine desiderato
  final List<String> allColumnsOrder = [
    'Prodotto',
    'Descrizione', // NUOVO CAMPO
    'Conto',
    'Etichetta',
    'Data inizio',
    'Data fine',
    'Quantità',
    'Sconto %',
    'Imposte',
    'Prezzo',
    'Importo'
  ];

  // Mappa per memorizzare la larghezza di ogni colonna
  late Map<String, double> columnWidths;

double _calculateImponibile() {
  double imponibile = 0.0;
  for (var row in invoiceRows) {
    double prezzo = row['Prezzo'] ?? 0.0;
    int quantita = row['Quantità'] is int ? row['Quantità'] : 1;
    double discount = row['Sconto %'] ?? 0.0;
    double net = prezzo * quantita * (1 - discount / 100);
    imponibile += net;
  }
  return imponibile;
}

double _calculateTotale() {
  double total = _calculateImponibile();
  Map<double, double> taxTotals = _calculateTaxTotals();
  for (var tax in taxTotals.values) {
    total += tax;
  }
  return total;
}

double _calculateImporto(Map<String, dynamic> row) {
  double prezzo = row['Prezzo'] ?? 0.0;
  int quantita = row['Quantità'] is int ? row['Quantità'] : 1;
  double discount = row['Sconto %'] ?? 0.0;  // in percentuale
  double taxRate = row['Imposte'] ?? 0.0;      // in percentuale
  double net = prezzo * quantita * (1 - discount / 100);
  return net + (net * taxRate / 100);
}

  double _calculateImposte() {
    double imposte = 0.0;
    for (var row in invoiceRows) {
      double valoreImposte = row['Imposte'] ?? 0.0; // Default a 0.0
      if (valoreImposte.isFinite) {
        // Controllo su numeri validi
        imposte += valoreImposte;
      }
    }
    return imposte.isFinite ? imposte : 0.0; // Restituisci 0.0 se non valido
  }
Map<double, double> _calculateTaxTotals() {
  Map<double, double> taxTotals = {};
  for (var row in invoiceRows) {
    double prezzo = row['Prezzo'] ?? 0.0;
    int quantita = row['Quantità'] is int ? row['Quantità'] : 1;
    double discount = row['Sconto %'] ?? 0.0;
    double taxRate = row['Imposte'] ?? 0.0;
    double net = prezzo * quantita * (1 - discount / 100);
    double taxAmount = net * (taxRate / 100);
    if (taxTotals.containsKey(taxRate)) {
      taxTotals[taxRate] = taxTotals[taxRate]! + taxAmount;
    } else {
      taxTotals[taxRate] = taxAmount;
    }
  }
  return taxTotals;
}

  @override
  void initState() {
    super.initState();
    // Inizializza le larghezze delle colonne in base alla larghezza della finestra
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth =
          MediaQuery.of(context).size.width; // Larghezza finestra
      final totalColumns = allColumnsOrder.length + 1; // Numero di colonne
      final defaultWidth =
          screenWidth / totalColumns; // Larghezza equa iniziale
      setState(() {
        columnWidths = {for (var col in allColumnsOrder) col: defaultWidth};
      });
    });
  }

  // Restituisce le colonne da visualizzare, rispettando l'ordine fisso.
  // Una colonna è visibile se è fissa oppure è presente in visibleFields.
  List<String> _getOrderedFields() {
    return allColumnsOrder
        .where(
            (col) => fixedFields.contains(col) || visibleFields.contains(col))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Raggruppa header, righe e pulsanti in un'unica area orizzontale
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                  width: constraints.maxWidth,
                  child: Scrollbar(
                    controller: _horizontalScrollController,
                    thumbVisibility: true, // Mostra sempre il thumb
                    trackVisibility: true, // Mostra la track della scrollbar
                    thickness: 8.0, // Larghezza della scrollbar
                    radius: const Radius.circular(4), // Arrotonda gli angoli
                    scrollbarOrientation:
                        ScrollbarOrientation.bottom, // Scrollbar in basso
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _horizontalScrollController,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          //minWidth:
                          //    columnWidths.values
                          //              .reduce((a, b) => a + b) +
                          //          100,
                          maxWidth: columnWidths.values
                                        .reduce((a, b) => a + b) +
                                    100, // Larghezza totale della tabella
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Intestazione della tabella
                            _buildTableHeaderRow(),
                            const Divider(),
                            // Righe draggabili in un ConstrainedBox per garantire larghezza minima
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                //minWidth: columnWidths.values
                                //        .reduce((a, b) => a + b) +
                                //    100,
                                maxWidth: columnWidths.values
                                        .reduce((a, b) => a + b) +
                                    100,
                              ),
                              child: ReorderableListView(
                                proxyDecorator: (Widget child, int index,
                                    Animation<double> animation) {
                                  return Material(
                                    elevation: 8.0,
                                    color: Colors.white,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: index % 2 == 0
                                            ? Colors.white
                                            : Colors.grey[200],
                                        border: Border.all(
                                            color: Colors.teal, width: 2.0),
                                      ),
                                      child: child,
                                    ),
                                  );
                                },
                                buildDefaultDragHandles: false,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                onReorder: _onReorder,
                                padding: EdgeInsets.zero,
                                children:
                                    invoiceRows.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  Map<String, dynamic> row = entry.value;
                                  if (row['id'] == null) {
                                    row['id'] = UniqueKey();
                                  }
                                  return _buildDataRow(row, index,
                                      key: row['id']);
                                }).toList(),
                              ),
                            ),
                            // Pulsanti di azione (Aggiungi riga, sezione, nota, catalogo)
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                    width:
                                        40), // Allineamento con la colonna della maniglia
                                TextButton(
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  onPressed: _addInvoiceRow,
                                  child: const Text(
                                    "Aggiungi riga",
                                    style: TextStyle(
                                      color: Colors.teal,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  onPressed: () {
                                    // Logica per "Aggiungi sezione"
                                  },
                                  child: const Text(
                                    "Aggiungi sezione",
                                    style: TextStyle(
                                      color: Colors.teal,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  onPressed: () {
                                    // Logica per "Aggiungi nota"
                                  },
                                  child: const Text(
                                    "Aggiungi nota",
                                    style: TextStyle(
                                      color: Colors.teal,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  onPressed: () {
                                    // Logica per "Catalogo"
                                  },
                                  child: const Text(
                                    "Catalogo",
                                    style: TextStyle(
                                      color: Colors.teal,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16)
                          ],
                        ),
                      ),
                    ),
                  ));
            },
          ),
          const SizedBox(height: 20),
          // Footer (non scrollabile orizzontalmente)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lato sinistro: campo "Termini e condizioni"
              Expanded(
                flex: 3,
                child: TextField(
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    labelText: "Termini e condizioni",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(width: 20),
              // Lato destro: riepilogo dei totali
              Expanded(
  flex: 1,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      const Divider(height: 20, thickness: 1),
      _buildSummaryRow("Imponibile:", _calculateImponibile()),
      ..._calculateTaxTotals().entries.map((entry) =>
          _buildSummaryRow("IVA ${entry.key.toStringAsFixed(0)}%:", entry.value)
      ).toList(),
      const SizedBox(height: 8),
      _buildSummaryRow("Totale:", _calculateTotale(), isBold: true),
      const Divider(height: 20, thickness: 1),
      _buildSummaryRow("Importo dovuto:", _calculateTotale(), isBold: true),
    ],
  ),
),

            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 14.0,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "${value.toStringAsFixed(2)} €",
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }

  // Costruisce la riga di intestazione della tabella con colonne ridimensionabili
  Widget _buildTableHeaderRow() {
    List<String> orderedFields = _getOrderedFields();
    List<Widget> headerCells = [];
    // Spazio iniziale per la colonna della maniglia (drag handle)
    headerCells.add(Container(width: 40));
    // Per ogni colonna visibile, aggiungo una cella di intestazione con resizer
    for (int i = 0; i < orderedFields.length; i++) {
      String column = orderedFields[i];
      headerCells.add(_buildColumnHeaderCell(column));
    }
    // Colonna extra per l'icona del filtro
    headerCells.add(Container(
      alignment: Alignment.center,
      width: 60,
      child: IconButton(
        icon: const Icon(Icons.tune, color: Colors.teal),
        onPressed: _showFieldFilterDialog,
      ),
    ));
    return Row(children: headerCells);
  }

  // Costruisce una cella di intestazione per una colonna specifica, includendo il resizer
  Widget _buildColumnHeaderCell(String column) {
    return Container(
      width: columnWidths[column],
      child: Stack(
        children: [
          // Testo della cella (allineato a sinistra)
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Text(
              column,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          // Resizer: zona a 5 pixel posizionata al margine destro della cella.
          // Trascinando il resizer si modifica la larghezza della colonna.
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: MouseRegion(
              cursor:
                  SystemMouseCursors.resizeLeftRight, // Aggiungi questa linea
              onEnter: (_) => setState(() => _resizerHovering = true),
              onExit: (_) => setState(() => _resizerHovering = false),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragUpdate: (DragUpdateDetails details) {
                  setState(() {
                    double newWidth = columnWidths[column]! + details.delta.dx;
                    if (newWidth < 50) newWidth = 50;
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

  // Costruisce una riga dati della tabella, rendendola draggable
  Widget _buildDataRow(Map<String, dynamic> row, int index, {Key? key}) {
    return Container(
      key: key,
      color:
          index % 2 == 0 ? Colors.white : Colors.grey[200], // Sfondo alternato
      child: Row(
        children: [
          // Colonna per la maniglia di drag (icona a 3 linee posizionata a sinistra)
          Container(
            width: 40,
            alignment: Alignment.center,
            child: ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.menu),
            ),
          ),
          // Celle dati per ogni colonna visibile, con larghezza personalizzata
          ..._buildOrderedFieldInputs(row),
          // Colonna extra: icona per eliminare la riga
          Container(
            alignment: Alignment.center,
            width: 60,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteInvoiceRow(index),
            ),
          ),
        ],
      ),
    );
  }

  // Costruisce le celle dati per ogni colonna visibile, utilizzando la larghezza memorizzata
  List<Widget> _buildOrderedFieldInputs(Map<String, dynamic> row) {
    List<String> orderedFields = _getOrderedFields();
    return orderedFields.map((field) {
      return Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        width: columnWidths[field],
        child: _buildCellInput(field, row),
      );
    }).toList();
  }

  // Restituisce il widget per la cella in base al tipo di campo
  Widget _buildCellInput(String field, Map<String, dynamic> row) {
    switch (field) {
      case 'Prodotto':
      case 'Conto':
        return TextField(
          decoration: const InputDecoration(border: InputBorder.none),
          onChanged: (value) => setState(() {
            row[field] = value;
          }),
        );
      case 'Descrizione': // NUOVO CAMPO
        return TextField(
          decoration: const InputDecoration(border: InputBorder.none),
          onChanged: (value) => setState(() {
            row['Descrizione'] = value;
          }),
        );
      case 'Etichetta':
        return TextField(
          decoration: const InputDecoration(border: InputBorder.none),
          onChanged: (value) => setState(() {
            row['Etichetta'] = value;
          }),
        );
      case 'Data inizio':
      case 'Data fine':
        return InkWell(
          onTap: () async {
            DateTime? selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (selectedDate != null) {
              setState(() {
                row[field] = selectedDate;
              });
            }
          },
          child: Text(
            row[field] != null
                ? "${row[field].day}/${row[field].month}/${row[field].year}"
                : "Seleziona data",
          ),
        );
      case 'Quantità':
      case 'Sconto %':
      case 'Imposte':
      case 'Prezzo':
        return TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(border: InputBorder.none),
          onChanged: (value) => setState(() {
            row[field] = double.tryParse(value) ?? 0.0;
            // Ricalcola l'importo in base ai nuovi valori
            row['Importo'] = _calculateImporto(row);
          }),
        );
      case 'Importo':
        // Campo non editabile, visualizzato in grassetto
        return Text(
          "${row['Importo']?.toStringAsFixed(2) ?? '0.00'}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      default:
        return const Text("");
    }
  }

  // Mostra il dialog per selezionare i campi visibili,
  // aggiornando immediatamente i checkbox grazie a StatefulBuilder
  void _showFieldFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Seleziona campi da visualizzare"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    for (var field in [
                      'Prodotto',
                      'Descrizione',
                      'Etichetta',
                      'Data inizio',
                      'Data fine',
                      'Quantità',
                      'Sconto %',
                      'Imposte',
                    ])
                      CheckboxListTile(
                        value: visibleFields.contains(field),
                        title: Text(field),
                        onChanged: (bool? value) {
                          setStateDialog(() {
                            if (value == true) {
                              visibleFields.add(field);
                            } else {
                              visibleFields.remove(field);
                            }
                          });
                          // Aggiorno anche lo stato del widget principale
                          setState(() {});
                        },
                      ),
                  ],
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

  // Aggiunge una nuova riga alla tabella
  void _addInvoiceRow() {
    setState(() {
      invoiceRows.add({
        'id': UniqueKey(),
        'Prodotto': '',
        'Descrizione': '', // NUOVO CAMPO
        'Conto': '',
        'Etichetta': '',
        'Data inizio': null,
        'Data fine': null,
        'Quantità': 1,
        'Sconto %': 0.0,
        'Imposte': 0.0,
        'Prezzo': 0.0,
        'Importo': 0.0,
      });
    });
  }

  // Elimina una riga dalla tabella
  void _deleteInvoiceRow(int index) {
    setState(() {
      invoiceRows.removeAt(index);
    });
  }

  // Callback per la riorganizzazione delle righe tramite drag & drop
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final movedRow = invoiceRows.removeAt(oldIndex);
      invoiceRows.insert(newIndex, movedRow);
    });
  }
}
