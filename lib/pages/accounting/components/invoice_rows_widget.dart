import 'package:flutter/material.dart';

class InvoiceRowsWidget extends StatefulWidget {
  const InvoiceRowsWidget({Key? key}) : super(key: key);

  @override
  _InvoiceRowsWidgetState createState() => _InvoiceRowsWidgetState();
}

class _InvoiceRowsWidgetState extends State<InvoiceRowsWidget> {
  // Lista dinamica delle righe della tabella
  List<Map<String, dynamic>> invoiceRows = [];

  // Campi visibili configurati tramite il filtro
  Set<String> visibleFields = {
    'Prodotto',
    'Etichetta',
    'Data inizio',
    'Data fine',
    'Quantità',
    'Sconto %',
    'Imposte',
  };

  // Campi non filtrabili (sempre visibili)
  final List<String> fixedFields = ['Conto', 'Prezzo', 'Importo'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titoli delle colonne e simbolo filtro
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ..._buildTableHeaders(), // Titoli delle colonne
              Container(
                alignment: Alignment.center,
                width: 60, // Larghezza fissa per la colonna del filtro
                child: IconButton(
                  icon: const Icon(Icons.filter_alt_outlined, color: Colors.teal),
                  onPressed: _showFieldFilterDialog,
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        // Righe della tabella
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
              ),
              child: Column(
                children: [
                  // Righe dinamiche
                  ...invoiceRows.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> row = entry.value;

                    return Row(
                      children: [
                        ..._buildOrderedFieldInputs(row),
                        // Icona per eliminare la riga
                        Container(
                          alignment: Alignment.center,
                          width: 60, // Larghezza corrispondente alla colonna del filtro
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteInvoiceRow(index),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
        // Pulsante "Aggiungi Riga" allineato a destra
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextButton(
              onPressed: _addInvoiceRow,
              child: const Text(
                "Aggiungi riga",
                style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Metodo per aggiungere una riga
  void _addInvoiceRow() {
    setState(() {
      invoiceRows.add({
        'Prodotto': '',
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

  // Metodo per eliminare una riga
  void _deleteInvoiceRow(int index) {
    setState(() {
      invoiceRows.removeAt(index);
    });
  }

  // Metodo per costruire i titoli delle colonne
  List<Widget> _buildTableHeaders() {
    List<String> orderedFields = [
      if (visibleFields.contains('Prodotto')) 'Prodotto',
      'Conto',
      ...visibleFields.where((field) => field != 'Prodotto'),
      'Prezzo',
      'Importo',
    ];
    return orderedFields.map((field) {
      return Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        width: 150, // Larghezza coerente con i campi sottostanti
        child: Text(
          field,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }).toList();
  }

  // Metodo per costruire gli input dei campi ordinati
  List<Widget> _buildOrderedFieldInputs(Map<String, dynamic> row) {
    List<String> orderedFields = [
      if (visibleFields.contains('Prodotto')) 'Prodotto',
      'Conto',
      ...visibleFields.where((field) => field != 'Prodotto'),
      'Prezzo',
      'Importo',
    ];
    return orderedFields.map((field) {
      return Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        width: 150, // Larghezza coerente con i titoli delle colonne
        child: _buildCellInput(field, row),
      );
    }).toList();
  }

  // Metodo per costruire i vari tipi di input per ogni cella
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
            // Ricalcola l'importo
            row['Importo'] = _calculateImporto(row);
          }),
        );
      case 'Importo':
        // Campo non editabile
        return Text(
          "${row['Importo']?.toStringAsFixed(2) ?? '0.00'}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      default:
        return const Text("");
    }
  }

  // Metodo per calcolare l'importo
  double _calculateImporto(Map<String, dynamic> row) {
    double prezzo = row['Prezzo'] ?? 0.0;
    int quantita = row['Quantità'] ?? 1;
    double imposte = row['Imposte'] ?? 0.0;
    return (prezzo * quantita) + imposte;
  }

  // Metodo per mostrare il filtro dei campi visibili
  void _showFieldFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Seleziona campi da visualizzare"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                for (var field in [
                  'Prodotto',
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
                      setState(() {
                        if (value == true) {
                          visibleFields.add(field);
                        } else {
                          visibleFields.remove(field);
                        }
                      });
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
  }
}
