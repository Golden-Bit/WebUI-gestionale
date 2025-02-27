import 'package:flutter/material.dart';

// Esempio di import personalizzati (da adattare al tuo progetto reale)
// In un caso reale, rinomina e/o sostituisci con i tuoi widget specifici
import 'package:flutter_app/pages/accounting/components/subcomponents/loans/OtherInformationsWidget.dart'
    as loan_additional; // <- eventuale rinomina dell'import se necessario
import 'package:flutter_app/pages/accounting/components/subcomponents/loans/loans_rows_widget.dart'
    as loan_rows;
import 'package:flutter_app/pages/accounting/components/subcomponents/loans/loans_actions_bar.dart';
// <- eventuale rinomina dell'import se necessario

/// Widget principale che mostra l’editor di un Prestito
/// con due tab: “Movimenti contabili” e “Altre informazioni”.
class LoanEditorWidget extends StatefulWidget {
  const LoanEditorWidget({Key? key}) : super(key: key);

  @override
  State<LoanEditorWidget> createState() => _LoanEditorWidgetState();
}

class _LoanEditorWidgetState extends State<LoanEditorWidget>
    with SingleTickerProviderStateMixin {
  // Controller per i due tab (Movimenti contabili, Altre informazioni)
  late TabController _tabController;

  // Lista di righe associate al prestito (equivalente a invoiceRows)
  List<Map<String, dynamic>> loanRows = [];

  // Campo di testo "Nome" del prestito
  final TextEditingController loanNameController =
      TextEditingController(text: "");

  // Campo di testo "Importo prestito"
  final TextEditingController loanAmountController =
      TextEditingController(text: "0.00");

  // Campo di testo "Interesse"
  final TextEditingController loanInterestController =
      TextEditingController(text: "0.00");

  // Campo di testo "Saldo scoperto" (sola lettura)
  final TextEditingController loanBalanceController =
      TextEditingController(text: "0.00");

  // Data prestito
  DateTime? loanDate;

  // Campo di testo "Durata" (valore numerico)
  final TextEditingController loanDurationController =
      TextEditingController(text: "0");

  // Campo "Gruppo cespite" (dropdown personalizzato)
  String selectedAssetGroup = "Gruppo default";

  /// Dizionario “Altre informazioni” (usato nel Tab “Altre informazioni”)
  Map<String, dynamic> loanAdditionalInfo = {
    "confermaAutomatica": "No",
    "verified": false,
    "internalNote": "",
    "fiscalPosition": "Nazionale",
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    loanNameController.dispose();
    loanAmountController.dispose();
    loanInterestController.dispose();
    loanBalanceController.dispose();
    loanDurationController.dispose();
    super.dispose();
  }

  Future<void> _selectLoanDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        loanDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Colonna di sinistra (2/3 larghezza)
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Action Bar (pulsanti Conferma/Annulla, etc.)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: LoanActionsBar(
                    onConfirm: () {
                      debugPrint("Conferma premuto");
                    },
                    onCancel: () {
                      debugPrint("Annulla premuto");
                    },
                    defaultIsRunning: true,
                  ),
                ),

                // Contenitore bordato con la form + i tab
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // RIGA SUPERIORE: NOME
// Campo "Nome" con titolo sopra
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Nome",
                                style: TextStyle(color: Colors.orange),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: loanNameController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "NOME PRESTITO",
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // RIGA SUCCESSIVA: DUE COLONNE, OGNUNA CON 3 CAMPI
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // COLONNA DI SINISTRA (Importo prestito, Interesse, Saldo scoperto)
                              Expanded(
                                child: Column(
                                  children: [
                                    // Importo prestito
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 150,
                                          child: Text(
                                            "Importo prestito",
                                            style:
                                                TextStyle(color: Colors.green),
                                          ),
                                        ),
                                        Expanded(
                                          child: TextField(
                                            controller: loanAmountController,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // Interesse
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 150,
                                          child: Text(
                                            "Interesse",
                                            style:
                                                TextStyle(color: Colors.green),
                                          ),
                                        ),
                                        Expanded(
                                          child: TextField(
                                            controller: loanInterestController,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // Saldo scoperto
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 150,
                                          child: Text(
                                            "Saldo scoperto",
                                            style:
                                                TextStyle(color: Colors.green),
                                          ),
                                        ),
                                        Expanded(
                                          child: TextField(
                                            controller: loanBalanceController,
                                            readOnly: true,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),

                              // COLONNA DI DESTRA (Data prestito, Durata, Gruppo cespite)
                              Expanded(
                                child: Column(
                                  children: [
                                    // Data prestito
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 150,
                                          child: Text(
                                            "Data prestito",
                                            style:
                                                TextStyle(color: Colors.green),
                                          ),
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () =>
                                                _selectLoanDate(context),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 14,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade400),
                                                borderRadius:
                                                    BorderRadius.circular(4.0),
                                              ),
                                              child: Text(
                                                loanDate != null
                                                    ? "${loanDate!.day}/${loanDate!.month}/${loanDate!.year}"
                                                    : "Seleziona data",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // Durata
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 150,
                                          child: Text(
                                            "Durata",
                                            style:
                                                TextStyle(color: Colors.green),
                                          ),
                                        ),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: TextField(
                                                  controller:
                                                      loanDurationController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Text("mesi"),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // Gruppo cespite
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 150,
                                          child: Text(
                                            "Gruppo cespite",
                                            style:
                                                TextStyle(color: Colors.green),
                                          ),
                                        ),
                                        Expanded(
                                          child: CustomDropdown(
                                            items: [
                                              "Gruppo default",
                                              "Gruppo A",
                                              "Gruppo B",
                                            ],
                                            value: selectedAssetGroup,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedAssetGroup = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // ========== TAB BAR ==========
                          TabBar(
                            controller: _tabController,
                            labelColor: Colors.black,
                            indicatorColor: Colors.teal,
                            tabs: const [
                              Tab(text: "Movimenti contabili"),
                              Tab(text: "Altre informazioni"),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ========== TAB VIEW ==========
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // 1) Movimenti contabili (qui potresti gestire rate/prestiti)
                                loan_rows.AccountingRowsWidget(
                                  rows: loanRows,
                                  onRowsChanged: (newRows) {
                                    setState(() {
                                      loanRows = newRows;
                                    });
                                  },
                                ),

                                // 2) Altre informazioni
                                loan_additional.AltreInformazioniWidget(
                                  additionalInfo: loanAdditionalInfo,
                                  onAdditionalInfoChanged: (newInfo) {
                                    setState(() {
                                      loanAdditionalInfo = newInfo;
                                    });
                                  },
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

          // Colonna di destra (1/3), vuota (eventuali pannelli aggiuntivi)
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

  final FocusNode _searchFocusNode = FocusNode();

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

    // Copia locale per filtrare in tempo reale
    List<String> localFilteredItems = List.from(widget.items);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateOverlay) {
            return Stack(
              children: [
                GestureDetector(
                  onTap: _closeDropdown,
                  behavior: HitTestBehavior.opaque,
                  child: Container(color: Colors.transparent),
                ),
                Positioned(
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
                            // Campo di ricerca
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
                                },
                              ),
                            ),
                            Expanded(
                              child: ListView(
                                shrinkWrap: true,
                                children: localFilteredItems.map((item) {
                                  return _buildHoverableListTile(
                                    title: item,
                                    onTap: () {
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

    // Metti il focus sul campo di ricerca
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

  Widget _buildHoverableListTile({
    required String title,
    required VoidCallback onTap,
    double horizontalPadding = 8.0,
    double verticalPadding = 6.0,
  }) {
    Color backgroundColor = Colors.white;

    return StatefulBuilder(
      builder: (context, setStateItem) {
        return MouseRegion(
          onEnter: (_) {
            setStateItem(() {
              backgroundColor = Colors.grey[200]!;
            });
          },
          onExit: (_) {
            setStateItem(() {
              backgroundColor = Colors.white;
            });
          },
          child: InkWell(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: backgroundColor,
              ),
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
}
