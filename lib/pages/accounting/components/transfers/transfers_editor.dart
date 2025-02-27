import 'package:flutter/material.dart';
import 'package:flutter_app/pages/accounting/components/subcomponents/transfers/transfers_actions_bar.dart';
import 'package:flutter_app/pages/accounting/components/subcomponents/transfers/transfers_rows_widget.dart';
import 'package:flutter_app/pages/accounting/components/subcomponents/transfers/accounts_rows_widget.dart';

/// Widget principale che mostra un’interfaccia di “registrazione contabile”
/// con due tabelle affiancate: la prima "CONTI DI ORIGINE" e la seconda "TASFERIEMNTO AUTOMATIZZATO".
/// Sopra le tabelle viene visualizzato un campo di testo con titolo "NOME CESPITE".
class AccountingRecordsWidget extends StatefulWidget {
  const AccountingRecordsWidget({Key? key}) : super(key: key);

  @override
  State<AccountingRecordsWidget> createState() => _AccountingRecordsWidgetState();
}

class _AccountingRecordsWidgetState extends State<AccountingRecordsWidget> {
  // Liste di righe per le due tabelle
  List<Map<String, dynamic>> contiDiOrigineRows = [];
  List<Map<String, dynamic>> trasferimentoAutomatizzatoRows = [];
// Date per il periodo
DateTime fromDate = DateTime(2025, 1, 1);
DateTime toDate = DateTime(2025, 2, 14);

// Dropdown "Frequenza"
final List<String> frequencyOptions = ["Mensile", "Trimestrale", "Annuale"];
String selectedFrequency = "Mensile";

// Dropdown "Registro"
final List<String> registerOptions = ["Operazioni varie", "Registro 1", "Registro 2"];
String selectedRegister = "Operazioni varie";
  // Campo di testo "NOME CESPITE"
  final TextEditingController nomeCespiteController = TextEditingController();


  // Identificativo: rinominato da “Fattura” a “Registrazione”
  final TextEditingController registrationIdentifierController =
      TextEditingController(text: "MISC/2025/02/0001");

  @override
  void initState() {
    super.initState();
    // Non serve TabController in quanto non usiamo più TabBar e TabBarView
  }

  @override
  void dispose() {
    registrationIdentifierController.dispose();
    nomeCespiteController.dispose();
    super.dispose();
  }
/// Formatta la data in "dd/MM/yyyy"
String _formatDate(DateTime? dt) {
  if (dt == null) return "";
  return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
}

/// Mostra un datePicker e aggiorna la variabile passata
Future<void> _pickDate(bool isFromDate) async {
  final initial = isFromDate ? fromDate : toDate;
  final picked = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
  if (picked != null) {
    setState(() {
      if (isFromDate) {
        fromDate = picked;
      } else {
        toDate = picked;
      }
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Colonna sinistra (2/3 della larghezza)
          Expanded(
            flex: 4,
            child: Column(
              children: [
                // Action Bar (pulsanti Conferma/Annulla, etc.)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: InvoiceActionsBar(
                    onConfirm: () {
                      debugPrint("Conferma premuto");
                    },
                    onCancel: () {
                      debugPrint("Annulla premuto");
                    },
                    defaultIsDraft: true,
                  ),
                ),
                // Contenitore bordato che racchiude il form e le tabelle
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Campo unificato "NOME CESPITE"
                          Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Campo "Nome cespite" (come già esistente)
    const Text(
      "Descrizione",
      style: TextStyle(color: Colors.orange),
    ),
    const SizedBox(height: 8),
    TextField(
      controller: nomeCespiteController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: "es. Trasferimento spese",
      ),
    ),
  ],
),

// Spazio
const SizedBox(height: 16),

// Riga con "Periodo ... fino al ... Registro"
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    // Sezione sinistra: "Periodo"
    Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Periodo ",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          // fromDate
          InkWell(
            onTap: () => _pickDate(true),
            child: Text(
              _formatDate(fromDate),
              style: const TextStyle(
                decoration: TextDecoration.underline,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text("fino al"),
          const SizedBox(width: 8),
          // toDate
          InkWell(
            onTap: () => _pickDate(false),
            child: Text(
              _formatDate(toDate),
              style: const TextStyle(
                decoration: TextDecoration.underline,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    ),
    // Sezione destra: "Registro"
    Row(
      children: [
        const Text(
          "Registro ",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 180,
          child: CustomDropdown(
            items: registerOptions,
            value: selectedRegister,
            onChanged: (val) {
              setState(() {
                selectedRegister = val;
              });
            },
          ),
        ),
      ],
    ),
  ],
),

// Spazio
const SizedBox(height: 8),

// Riga "Frequenza"
Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    const Text(
      "Frequenza ",
      style: TextStyle(fontWeight: FontWeight.w500),
    ),
    const SizedBox(width: 8),
    // Dropdown "Frequenza"
    SizedBox(
      width: 150,
      child: CustomDropdown(
        items: frequencyOptions,
        value: selectedFrequency,
        onChanged: (val) {
          setState(() {
            selectedFrequency = val;
          });
        },
      ),
    ),
  ],
),

// Spazio
const SizedBox(height: 16),
                          const SizedBox(height: 16),
                          // Due tabelle affiancate
                          Expanded(
                            child: Row(
                              children: [
                                // Tabella "CONTI DI ORIGINE"
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "CONTI DI ORIGINE",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Divider(),
                                      Expanded(
                                        child: Expanded(
  child: AccountingRowsWidget(
    rows: contiDiOrigineRows,
    onRowsChanged: (newRows) {
      setState(() {
        contiDiOrigineRows = newRows;
      });
    },
  ),
),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 32),
                                // Tabella "TASFERIEMNTO AUTOMATIZZATO"
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "TASFERIEMNTO AUTOMATIZZATO",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Divider(),
                                      Expanded(
                                        child: Expanded(
  child: TransfersRowsWidget(
    rows: trasferimentoAutomatizzatoRows,
    onRowsChanged: (newRows) {
      setState(() {
        trasferimentoAutomatizzatoRows = newRows;
      });
    },
  ),
),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Colonna destra (1/3 della larghezza), attualmente vuota
          Expanded(
            flex: 1,
            child: Container(color: Colors.transparent),
          ),
        ],
      ),
    );
  }
}

// ---------------------------
// CustomDropdown (invariato)
// ---------------------------
class CustomDropdown extends StatefulWidget {
  final List<String> items;
  final String value;
  final ValueChanged<String> onChanged;

  const CustomDropdown({
    Key? key,
    required this.items,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;

  // RIMOSSO: la lista filtrata nel genitore
  // List<String> filteredItems = [];

  // RIMOSSO: il metodo di aggiornamento "pubblico"
  // void _updateFilteredItems(String query) {
  //   setState(() {
  //     filteredItems = widget.items
  //         .where((item) => item.toLowerCase().contains(query.toLowerCase()))
  //         .toList();
  //   });
  // }

  final FocusNode _searchFocusNode = FocusNode();

  // RIMOSSO: In initState non gestiamo più la filteredItems nel genitore
  // @override
  // void initState() {
  //   super.initState();
  //   filteredItems = List.from(widget.items);
  // }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      _showDropdown();
    }
  }

  void _showDropdown() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    // AGGIUNTO: manteniamo la lista in una variabile locale (una sola fonte di verità)
    List<String> localFilteredItems = List.from(widget.items);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateOverlay) {
            return Stack(
              children: [
                // Schermata trasparente per chiudere il dropdown se si clicca fuori
                GestureDetector(
                  onTap: _closeDropdown,
                  behavior: HitTestBehavior.opaque,
                  child: Container(color: Colors.transparent),
                ),
                Positioned(
                  // Se desideri la stessa larghezza del widget di base, usa renderBox.size.width
                  width: renderBox.size.width * 0.5,
                  left: offset.dx,
                  top: offset.dy + renderBox.size.height,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(4),
                    child: CompositedTransformFollower(
                      offset: Offset(0, renderBox.size.height),
                      link: _layerLink,
                      showWhenUnlinked: false,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          color: Colors.white,
                        ),
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Campo di ricerca: aggiorna solo la variabile locale localFilteredItems
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                focusNode: _searchFocusNode,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Cerca...',
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                ),
                                onChanged: (query) {
                                  setStateOverlay(() {
                                    localFilteredItems = widget.items
                                        .where((item) => item
                                            .toLowerCase()
                                            .contains(query.toLowerCase()))
                                        .toList();
                                  });

                                  // RIMOSSO: niente più chiamata al metodo del genitore
                                  // _updateFilteredItems(query);
                                },
                              ),
                            ),
                            Expanded(
                              child: ListView(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                children: localFilteredItems.map((item) {
                                  return _buildHoverableListTile(
                                    title: item,
                                    onTap: () {
                                      // Selezione: aggiorna il valore e chiude l’overlay
                                      widget.onChanged(item);
                                      _closeDropdown();
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);

    setState(() {
      _isDropdownOpen = true;
    });

    // Richiama subito il focus sul campo di ricerca
    Future.delayed(Duration.zero, () {
      _searchFocusNode.requestFocus();
    });
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    setState(() {
      _isDropdownOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleDropdown,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Container(
          height: 45,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey, width: 1.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_drop_down,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Costruisce un elemento hoverable per il menu
  Widget _buildHoverableListTile({
    required String title,
    required VoidCallback onTap,
    double horizontalPadding = 8.0,
    double verticalPadding = 6.0,
  }) {
    Color backgroundColor = Colors.white; // Colore iniziale dello sfondo

    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) {
            setState(() {
              backgroundColor = Colors.grey[200]!; // Colore hover
            });
          },
          onExit: (_) {
            setState(() {
              backgroundColor = Colors.white; // Ripristino colore originale
            });
          },
          child: InkWell(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  //shape: BoxShape.rectangle,
                  color: backgroundColor), // Sfondo dinamico basato sull'hover
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
