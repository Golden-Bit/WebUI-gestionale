import 'package:flutter/material.dart';
import 'package:flutter_app/pages/accounting/components/invoice/invoice_editor.dart'; // Assicurati che qui sia presente anche il CustomDropdown
import 'dart:math' as math;

/// Elenco di opzioni per il campo "Conto"
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

/// Elenco di opzioni per il campo "Griglie imposte"
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

/// Widget che visualizza la tabella dei movimenti contabili.
/// L’intero contenuto è scrollabile orizzontalmente, le righe sono alternate (bianco/grigio)
/// e, in aggiunta, vengono aggiunte (alla fine) delle righe extra speciali di debito IVA
/// e una riga extra speciale di credito.
/// - Le righe IVA sono generate per ciascun valore distinto di "Imposte" presente nelle invoiceRows (Tab 1).
///   In queste righe:
///     • Il campo "Conto" è un dropdown (default "260100 Debito IVA") modificabile;
///     • Il campo "Etichetta" è impostato sul valore dell'imposta seguito dal simbolo "%" (es. "22%");
///     • Il campo "Dare" mostra il totale dell'imposta pagata per quel tax rate (calcolato dinamicamente);
///     • Il campo "Avere" è 0.0 (non editabile);
///     • Gli altri campi sono vuoti.
/// - La riga di credito (aggiunta come ultima) ha:
///     • Il campo "Conto" editabile, con default "1501000 Credito verso i cleinti";
///     • Il campo "Etichetta" editabile (default vuoto);
///     • Il campo "Scadenze" editabile (default: data odierna);
///     • Il campo "Dare" non editabile, pari al totale degli importi delle righe prodotto (Tab 1) più il totale delle imposte;
///     • Il campo "Avere" non editabile, fisso su 0.0;
///     • Gli altri campi vuoti;
/// - Infine, viene aggiunta una riga di totale (ultima riga) che contiene solo i campi "Dare", "Avere" e "Importo dello sconto",
///   i cui valori corrispondono alla somma totale delle relative voci delle altre righe.
class AccountingMovementsWidget extends StatefulWidget {
  final List<Map<String, dynamic>> invoiceRows;
  final List<Map<String, dynamic>> movimentsRows;
  final ValueChanged<List<Map<String, dynamic>>> onInvoiceRowsChanged;
  final ValueChanged<List<Map<String, dynamic>>> onMovementsChanged;

  const AccountingMovementsWidget({
    Key? key,
    required this.invoiceRows,
    required this.movimentsRows,
    required this.onInvoiceRowsChanged,
    required this.onMovementsChanged,
  }) : super(key: key);

  @override
  _AccountingMovementsWidgetState createState() =>
      _AccountingMovementsWidgetState();
}

class _AccountingMovementsWidgetState extends State<AccountingMovementsWidget>
    with AutomaticKeepAliveClientMixin {
  /// Ordine delle colonne (da sinistra a destra)
  final List<String> movementColumnOrder = [
    'Conto',
    'Etichetta',
    'Scadenze',
    'Imposte',
    'Dare',
    'Avere',
    'Data di sconto',
    'Importo dello sconto',
    'Griglie imposte',
  ];

  late Map<String, double> movementColumnWidths;

  // Mappa di stato per le righe extra IVA, indicizzate per valore di "Imposte"
  Map<double, Map<String, dynamic>> _extraRows = {};

  // Variabile per memorizzare un "hash" profondo delle invoiceRows.
  String _invoiceRowsHash = "";

  // Variabile di stato per la riga extra di credito (unica)
  Map<String, dynamic> _creditoRow = {
    'specialRow': true,
    'tipo': 'credito', // per identificare questa riga come credito
    'Conto': "1501000 Credito verso i cleinti",
    'Etichetta': "Credito",
    'Scadenze': DateTime.now(), // default data odierna
    'Dare': 0.0, // verrà calcolato dinamicamente
    'Avere': 0.0, // fisso su 0.0
    'Imposte': 0.0,
    'Data di sconto': null,
    'Importo dello sconto': 0.0,
    'Griglie imposte': "",
  };

  // Controller per il campo "Etichetta" della riga di credito
  late TextEditingController _creditoEtichettaController;

  @override
  bool get wantKeepAlive => true; // Preserva lo stato anche cambiando tab

  @override
  void initState() {
    super.initState();
    _creditoEtichettaController =
        TextEditingController(text: _creditoRow['Etichetta']);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      setState(() {
        double defaultWidth = (screenWidth - 128) / movementColumnOrder.length * 0.67;
        movementColumnWidths = {
          for (var col in movementColumnOrder) col: defaultWidth,
        };
      });
    });
  }

  @override
  void dispose() {
    _creditoEtichettaController.dispose();
    super.dispose();
  }

  /// Funzione helper per calcolare un hash profondo delle invoiceRows.
  String _computeInvoiceRowsHash(List<Map<String, dynamic>> rows) {
    return rows
        .map((row) =>
            row.entries.map((entry) => "${entry.key}:${entry.value}").join(","))
        .join("||");
  }

  /// Sincronizza le invoiceRows: se il contenuto cambia, forza il rebuild.
  void _syncInvoiceRows() {
    final newHash = _computeInvoiceRowsHash(widget.invoiceRows);
    if (newHash != _invoiceRowsHash) {
      _invoiceRowsHash = newHash;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  /// Calcola le righe dei movimenti derivanti dalle invoiceRows.
  /// Se alcuni campi extra (Griglie imposte, Data di sconto, Scadenze) non sono presenti,
  /// vengono aggiunti con un valore di default.
  List<Map<String, dynamic>> _computeLocalMovementsRows() {
    _syncInvoiceRows();
    List<Map<String, dynamic>> computedMovements;
    if (widget.movimentsRows.isEmpty && widget.invoiceRows.isNotEmpty) {
      computedMovements = List.generate(widget.invoiceRows.length, (i) {
        final invoice = widget.invoiceRows[i];
        if (invoice['type'] != null && invoice['type'] != 'normal') {
          Map<String, dynamic> special = Map<String, dynamic>.from(invoice);
          if (special['Etichetta'] == null || special['Etichetta'] == '') {
            if (special['type'] == 'note') {
              special['Etichetta'] = "NOTA";
            } else if (special['type'] == 'section') {
              special['Etichetta'] = "SEZIONE";
            }
          }
          return special;
        } else {
          return {
            'Conto': invoice['Conto'] ?? contoOptions[0],
            'Etichetta': (invoice['Etichetta'] != null && invoice['Etichetta'] != '')
                ? invoice['Etichetta']
                : invoice['Prodotto'] ?? '',
            'Imposte': invoice['Imposte'] ?? 0.0,
            'Griglie imposte': invoice.containsKey('Griglie imposte')
                ? invoice['Griglie imposte']
                : "+02 Imposte Italia",
  'Dare': 0.0,
  'Avere': invoice['Importo'] ?? 0.0,
            'Data di sconto': invoice.containsKey('Data di sconto')
                ? invoice['Data di sconto']
                : null,
            'Importo dello sconto': invoice.containsKey('Importo dello sconto')
                ? invoice['Importo dello sconto']
                : 0.0,
            'Scadenze': invoice.containsKey('Scadenze')
                ? invoice['Scadenze']
                : null,
          };
        }
      });
    } else {
      computedMovements = List.from(widget.movimentsRows);
    }
    for (int i = 0; i < widget.invoiceRows.length && i < computedMovements.length; i++) {
      if (widget.invoiceRows[i]['type'] == null || widget.invoiceRows[i]['type'] == 'normal') {
        computedMovements[i]['Conto'] = widget.invoiceRows[i]['Conto'] ?? contoOptions[0];
        computedMovements[i]['Etichetta'] = (widget.invoiceRows[i]['Etichetta'] != null &&
            widget.invoiceRows[i]['Etichetta'] != '')
            ? widget.invoiceRows[i]['Etichetta']
            : widget.invoiceRows[i]['Prodotto'] ?? '';
        computedMovements[i]['Imposte'] = widget.invoiceRows[i]['Imposte'] ?? 0.0;
        computedMovements[i]['Avere'] = widget.invoiceRows[i]['Importo'] ?? 0.0;
        computedMovements[i]['Griglie imposte'] = widget.invoiceRows[i].containsKey('Griglie imposte')
            ? widget.invoiceRows[i]['Griglie imposte']
            : imposteOptions[0];
        computedMovements[i]['Data di sconto'] = widget.invoiceRows[i].containsKey('Data di sconto')
            ? widget.invoiceRows[i]['Data di sconto']
            : null;
        computedMovements[i]['Scadenze'] = widget.invoiceRows[i].containsKey('Scadenze')
            ? widget.invoiceRows[i]['Scadenze']
            : null;
      }
    }
    return computedMovements;
  }

  /// Calcola il totale degli importi per le righe prodotto (normali) delle invoiceRows.
  double _calculateProductTotal() {
    double total = 0.0;
    for (var row in widget.invoiceRows) {
      if (row['type'] == null || row['type'] == 'normal') {
        total += (row['Importo'] ?? 0.0);
      }
    }
    return total;
  }

  /// Calcola le somme delle imposte per ciascun tax rate dalle invoiceRows.
  Map<double, double> _calculateTaxTotals() {
    Map<double, double> taxTotals = {};
    for (var row in widget.invoiceRows) {
      if (row.containsKey('type') && row['type'] != 'normal') continue;
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

  /// Estende la lista dei movimenti aggiungendo, come ultime righe,
  /// le righe extra speciali IVA e la riga extra speciale di credito, e infine
  /// una riga di totale che somma i campi Dare, Avere e Importo dello sconto.
  /// I totali vengono calcolati sommando solo i valori diversi da zero (e non nulli)
  List<Map<String, dynamic>> _computeLocalMovementsRowsWithExtra() {
    List<Map<String, dynamic>> computedMovements = _computeLocalMovementsRows();

    // --- Righe extra IVA ---
    Set<double> taxValues = {};
    for (var row in widget.invoiceRows) {
      if (row['type'] == null || row['type'] == 'normal') {
        double tax = 0.0;
        try {
          tax = (row['Imposte'] is num)
              ? (row['Imposte'] as num).toDouble()
              : double.parse(row['Imposte'].toString());
        } catch (e) {
          continue;
        }
        taxValues.add(tax);
      }
    }
    _extraRows.removeWhere((key, value) => !taxValues.contains(key));
    for (double tax in taxValues) {
      if (!_extraRows.containsKey(tax)) {
        _extraRows[tax] = {
          'specialRow': true,
          'Conto': "260100 Debito IVA",
          'Dare': 0.0, // rimane 0.0
          'Avere': 0.0, // verrà aggiornato dinamicamente
          'Etichetta': "${tax.toString()}%",
          'Scadenze': null,
          'Imposte': tax,
          'Data di sconto': null,
          'Importo dello sconto': 0.0,
          'Griglie imposte': "+4v Imposte Italia",
        };
      } else {
        _extraRows[tax]!['Etichetta'] = "${tax.toString()}%";
        _extraRows[tax]!['Imposte'] = tax;
      }
    }
    Map<double, double> taxTotals = _calculateTaxTotals();
    _extraRows.forEach((tax, extraRow) {
      extraRow['Avere'] = taxTotals[tax] ?? 0.0;
    });
    List<double> sortedTaxes = _extraRows.keys.toList()..sort();
    for (double tax in sortedTaxes) {
      computedMovements.add(_extraRows[tax]!);
    }

    // --- Riga extra di credito ---
    double productTotal = _calculateProductTotal();
    double totalTax = _calculateTaxTotals().values.fold(0.0, (prev, element) => prev + element);
    _creditoRow['Dare'] = productTotal + totalTax;
    if (_creditoRow['Scadenze'] == null) {
      _creditoRow['Scadenze'] = DateTime.now();
    }
    computedMovements.add(_creditoRow);

    // --- Riga di Totale ---
    double totalDare = 0.0;
    double totalAvere = 0.0;
    double totalSconto = 0.0;
    // Sommiamo le voci di tutte le righe già presenti (esclusa la riga di totale che stiamo per aggiungere)
for (var m in computedMovements) {
  double dareValue = (m['Dare'] is num)
      ? m['Dare'] as double
      : double.tryParse(m['Dare']?.toString() ?? '0') ?? 0.0;
  double avereValue = (m['Avere'] is num)
      ? m['Avere'] as double
      : double.tryParse(m['Avere']?.toString() ?? '0') ?? 0.0;
  double scontoValue = (m['Importo dello sconto'] is num)
      ? m['Importo dello sconto'] as double
      : double.tryParse(m['Importo dello sconto']?.toString() ?? '0') ?? 0.0;
  
  print('$dareValue, $avereValue');
  print('${m['Dare']} ${m['Avere']}');

  totalDare += dareValue;
  totalAvere += avereValue;
  //totalSconto += scontoValue;

  print('total --> $totalDare, $totalAvere');
}

    Map<String, dynamic> totalsRow = {
      'specialRow': true,
      'tipo': 'totals',
      'Conto': "",
      'Etichetta': "",
      'Scadenze': null,
      'Dare': totalDare,
      'Avere': totalAvere,
      'Imposte': 0.0,
      'Data di sconto': null,
      'Importo dello sconto': totalSconto,
      'Griglie imposte': "",
    };
    computedMovements.add(totalsRow);

    print(totalsRow);

    return computedMovements;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necessario per AutomaticKeepAliveClientMixin
    final localMovementsRows = _computeLocalMovementsRowsWithExtra();

// Calcola la larghezza totale delle colonne
final double computedWidth = movementColumnWidths.values.fold(0, (sum, w) => sum + w);
// Imposta la larghezza di constraint come il massimo tra la larghezza dello schermo e quella calcolata
final double widthConstraint = math.max(MediaQuery.of(context).size.width, computedWidth); 

return SingleChildScrollView(
  scrollDirection: Axis.vertical,
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: ConstrainedBox(
      constraints: BoxConstraints(
        // Fissa sia il minWidth che il maxWidth a widthConstraint
        minWidth: widthConstraint,
        maxWidth: widthConstraint,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMovementsTableHeader(),
              const Divider(),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: localMovementsRows.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> row = localMovementsRows[index];
                  if (row.containsKey('specialRow') && row['specialRow'] == true) {
                    return _buildExtraSpecialRow(row, index);
                  } else if (index < widget.invoiceRows.length &&
                      widget.invoiceRows[index]['type'] != null &&
                      widget.invoiceRows[index]['type'] != 'normal') {
                    return Container(
                      color: index % 2 == 0 ? Colors.white : Colors.grey[200]!,
                      child: _buildSpecialMovementRow(row, index),
                    );
                  } else {
                    return Container(
                      color: index % 2 == 0 ? Colors.white : Colors.grey[200]!,
                      child: Row(
                        children: movementColumnOrder.map((col) {
                          return Container(
                            width: movementColumnWidths[col],
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                            child: _buildMovementCellInput(col, row, index),
                          );
                        }).toList(),
                      ),
                    );
                  }
                },
              ),
              // AGGIUNTA DI 400 PIXEL DI SPAZIO LIBERO
              const SizedBox(height: 400),
        ],
      ),
    ),
  ),
);

  }

  @override
  Widget _buildMovementsTableHeader() {
    return Row(
      children: movementColumnOrder.map((col) {
        return Container(
          width: movementColumnWidths[col],
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Text(
            col,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSpecialMovementRow(Map<String, dynamic> row, int index) {
    double totalWidth = movementColumnWidths.values.fold(0, (sum, w) => sum + w);
    String prefix = "";
    if (widget.invoiceRows[index]['type'] == 'note') {
      prefix = "NOTA: ";
    } else if (widget.invoiceRows[index]['type'] == 'section') {
      prefix = "SEZIONE: ";
    }
    return Container(
      width: totalWidth,
      padding: const EdgeInsets.all(8.0),
      child: Text(
        prefix + (row['text'] ?? ''),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildMovementCellInput(String field, Map<String, dynamic> row, int index) {
    if (field == 'Conto') {
      return Text(
        row['Conto'] ?? contoOptions[0],
        style: const TextStyle(color: Colors.black87),
      );
    } else if (field == 'Etichetta') {
      return TextField(
        decoration: const InputDecoration(border: InputBorder.none),
        onChanged: (value) {
          setState(() {
            row['Etichetta'] = value;
          });
          widget.onInvoiceRowsChanged(widget.invoiceRows);
        },
        controller: TextEditingController(text: row['Etichetta']),
      );
    } else if (field == 'Imposte') {
      return Text(
        (row['Imposte'] ?? 0).toString(),
        style: const TextStyle(color: Colors.black87),
      );
    } else if (field == 'Avere') {
      double avereValue = 0.0;
      if (index < widget.invoiceRows.length) {
        final invoiceRow = widget.invoiceRows[index];
        if (invoiceRow['type'] == null || invoiceRow['type'] == 'normal') {
          avereValue = invoiceRow['Importo'] ?? 0.0;
        }
      }
      return Text(
        "${avereValue.toStringAsFixed(2)} €",
        style: const TextStyle(fontWeight: FontWeight.bold),
      );
    } else if (field == 'Griglie imposte') {
      return CustomDropdown(
        items: imposteOptions,
        value: widget.invoiceRows[index]['Griglie imposte'] ?? imposteOptions[0],
        onChanged: (value) {
          setState(() {
            widget.invoiceRows[index]['Griglie imposte'] = value;
          });
          widget.onInvoiceRowsChanged(widget.invoiceRows);
        },
      );
    } else if (field == 'Dare' || field == 'Importo dello sconto') {
      return TextFormField(
        initialValue: (row[field] ?? 0).toString(),
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(border: InputBorder.none),
        onChanged: (value) {
          setState(() {
            row[field] = double.tryParse(value) ?? 0.0;
          });
          widget.onInvoiceRowsChanged(widget.invoiceRows);
        },
      );
    } else if (field == 'Data di sconto') {
      return InkWell(
        onTap: () async {
          DateTime? selectedDate = await showDatePicker(
            context: context,
            initialDate: widget.invoiceRows[index]['Data di sconto'] ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (selectedDate != null) {
            setState(() {
              widget.invoiceRows[index]['Data di sconto'] = selectedDate;
            });
            widget.onInvoiceRowsChanged(widget.invoiceRows);
          }
        },
        child: Text(
          widget.invoiceRows[index]['Data di sconto'] != null
              ? "${widget.invoiceRows[index]['Data di sconto'].day}/${widget.invoiceRows[index]['Data di sconto'].month}/${widget.invoiceRows[index]['Data di sconto'].year}"
              : "Seleziona data",
        ),
      );
    } else if (field == 'Scadenze') {
      return InkWell(
        onTap: () async {
          DateTime? selectedDate = await showDatePicker(
            context: context,
            initialDate: widget.invoiceRows[index]['Scadenze'] ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (selectedDate != null) {
            setState(() {
              widget.invoiceRows[index]['Scadenze'] = selectedDate;
            });
            widget.onInvoiceRowsChanged(widget.invoiceRows);
          }
        },
        child: Text(
          widget.invoiceRows[index]['Scadenze'] != null
              ? "${widget.invoiceRows[index]['Scadenze'].day}/${widget.invoiceRows[index]['Scadenze'].month}/${widget.invoiceRows[index]['Scadenze'].year}"
              : "Seleziona data",
        ),
      );
    } else {
      return const Text("");
    }
  }

  Widget _buildExtraSpecialRow(Map<String, dynamic> row, int index) {
    return Container(
      color: index % 2 == 0 ? Colors.white : Colors.grey[200]!,
      child: Row(
        children: movementColumnOrder.map((col) {
          return Container(
            width: movementColumnWidths[col],
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: _buildExtraSpecialCellInput(col, row),
          );
        }).toList(),
      ),
    );
  }

Widget _buildExtraSpecialCellInput(String col, Map<String, dynamic> row) {
  // Gestione del caso "totals"
  if (row.containsKey('tipo') && row['tipo'] == 'totals') {
    if (col == 'Dare') {
      return Text(
        "${row['Dare'].toStringAsFixed(2)} €",
        style: const TextStyle(fontWeight: FontWeight.bold),
      );
    } else if (col == 'Avere') {
      return Text(
        "${row['Avere'].toStringAsFixed(2)} €",
        style: const TextStyle(fontWeight: FontWeight.bold),
      );
    } else if (col == 'Importo dello sconto') {
      return Text(
        "${row['Importo dello sconto'].toStringAsFixed(2)} €",
        style: const TextStyle(fontWeight: FontWeight.bold),
      );
    } else {
      return const Text("");
    }
  }
    if (row.containsKey('tipo') && row['tipo'] == 'credito') {
      // RIGA SPECIALE DI CREDITO
      if (col == 'Conto') {
        return CustomDropdown(
          items: contoOptions,
          value: row['Conto'],
          onChanged: (value) {
            setState(() {
              row['Conto'] = value;
            });
          },
        );
      } else if (col == 'Etichetta') {
        return TextField(
          decoration: const InputDecoration(border: InputBorder.none),
          controller: _creditoEtichettaController,
          onChanged: (value) {
            setState(() {
              row['Etichetta'] = value;
            });
          },
        );
      } else if (col == 'Scadenze') {
        return InkWell(
          onTap: () async {
            DateTime? selectedDate = await showDatePicker(
              context: context,
              initialDate: row['Scadenze'] ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (selectedDate != null) {
              setState(() {
                row['Scadenze'] = selectedDate;
              });
            }
          },
          child: Text(
            row['Scadenze'] != null
                ? "${row['Scadenze'].day}/${row['Scadenze'].month}/${row['Scadenze'].year}"
                : "Seleziona data",
          ),
        );
      } else if (col == 'Dare') {
        return Text(
          "${row['Dare'].toStringAsFixed(2)} €",
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      } else if (col == 'Avere') {
        return const Text(
          "0.0 €",
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      } else if (col == 'Griglie imposte') {
        return CustomDropdown(
          items: imposteOptions,
          value: row['Griglie imposte'] ?? imposteOptions[0],
          onChanged: (value) {
            setState(() {
              row['Griglie imposte'] = value;
            });
          },
        );
      } else {
        return const Text("");
      }
    } else {
      // RIGA IVA
      if (col == 'Conto') {
        return CustomDropdown(
          items: contoOptions,
          value: row['Conto'],
          onChanged: (value) {
            setState(() {
              row['Conto'] = value;
            });
          },
        );
      } else if (col == 'Etichetta') {
        return Text(
          row['Etichetta'] ?? "",
          style: const TextStyle(color: Colors.black87),
        );
      } else if (col == 'Dare') {
        return const Text(
          "0.0",
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      } else if (col == 'Avere') {
        double taxRate = row['Imposte'] ?? 0.0;
        Map<double, double> taxTotals = _calculateTaxTotals();
        double taxTotal = taxTotals[taxRate] ?? 0.0;
        return Text(
          "${taxTotal.toStringAsFixed(2)} €",
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      } else if (col == 'Griglie imposte') {
        return CustomDropdown(
          items: imposteOptions,
          value: row['Griglie imposte'] ?? imposteOptions[0],
          onChanged: (value) {
            setState(() {
              row['Griglie imposte'] = value;
              double tax = row['Imposte'] ?? 0.0;
              if (_extraRows.containsKey(tax)) {
                _extraRows[tax]!['Griglie imposte'] = value;
              }
            });
          },
        );
      } else {
        return const Text("");
      }
    }
  }
}
