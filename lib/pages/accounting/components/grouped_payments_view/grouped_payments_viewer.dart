import 'package:flutter/material.dart';
import 'dart:math' as math;

// Import personalizzato per la Action Bar (se necessario, sostituire con il tuo)
import 'package:flutter_app/pages/accounting/components/subcomponents/grouped_payments/grouped_payments_actions_bar.dart';

// Import personalizzato per il widget delle righe (se necessario, sostituire con il tuo)
import 'package:flutter_app/pages/accounting/components/subcomponents/grouped_payments/grouped_payments_rows_widget.dart';

/// Widget principale che mostra un’interfaccia per “raggruppamento pagamenti”
/// con una tab che elenca i movimenti (pagamenti) e un pannello superiore
/// con i campi mostrati in figura.
///
/// In particolare:
/// - 3 campi a sinistra (tipo di raggruppamento, banca, metodo di pagamento), tutti dropdown
/// - 2 campi a destra (data, riferimento), rispettivamente un selettore data e un TextField
/// - 1 tab con “Movimenti contabili” (in questo caso, i pagamenti)
class AccountingRecordsWidget extends StatefulWidget {
  const AccountingRecordsWidget({Key? key}) : super(key: key);

  @override
  State<AccountingRecordsWidget> createState() => _AccountingRecordsWidgetState();
}

class _AccountingRecordsWidgetState extends State<AccountingRecordsWidget>
    with SingleTickerProviderStateMixin {
  // Controller per il tab
  late TabController _tabController;

  // Righe dei pagamenti (lista di mappe)
  List<Map<String, dynamic>> paymentRows = [];

  // Selezioni e campi del pannello superiore
  String selectedGroupingType = "In entrata"; // "Tipo di raggruppamento"
  String selectedBank = "Banca 1";            // "Banca"
  String selectedPaymentMethod = "Pagamento manuale"; // "Metodo di pagamento"
  DateTime? selectedDate;                     // "Data"
  final TextEditingController referenceController =
      TextEditingController();                // "Riferimento"

  @override
  void initState() {
    super.initState();
    // Abbiamo (ipoteticamente) 1 tab visibile ("Movimenti contabili").
    // Se servisse un secondo tab ("Altre informazioni"), aggiungere length: 2.
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    referenceController.dispose();
    super.dispose();
  }

  /// Selezione della data (Date Picker)
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Colonna sinistra (2/3 larghezza)
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Barra di azioni in alto (pulsanti Conferma/Annulla, etc.)
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

                // Contenitore bordato con la form + la tab
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
                          // ===========================
                          //   Campi in due colonne
                          // ===========================
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Colonna di sinistra (3 campi dropdown)
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 1) Tipo di raggruppamento
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 140,
                                          child: Text(
                                            "Tipo di raggruppamento",
                                            style:
                                                TextStyle(color: Colors.green),
                                          ),
                                        ),
                                        Expanded(
                                          child: CustomDropdown(
                                            items: const [
                                              "In entrata",
                                              "In uscita",
                                            ],
                                            value: selectedGroupingType,
                                            onChanged: (val) {
                                              setState(() {
                                                selectedGroupingType = val;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // 2) Banca
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 140,
                                          child: Text(
                                            "Banca",
                                            style:
                                                TextStyle(color: Colors.green),
                                          ),
                                        ),
                                        Expanded(
                                          child: CustomDropdown(
                                            items: const [
                                              "Banca 1",
                                              "Banca 2",
                                              "Banca 3",
                                            ],
                                            value: selectedBank,
                                            onChanged: (val) {
                                              setState(() {
                                                selectedBank = val;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // 3) Metodo di pagamento
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 140,
                                          child: Text(
                                            "Metodo di pagamento",
                                            style:
                                                TextStyle(color: Colors.green),
                                          ),
                                        ),
                                        Expanded(
                                          child: CustomDropdown(
                                            items: const [
                                              "Pagamento manuale",
                                              "Bonifico",
                                              "Carta di credito",
                                            ],
                                            value: selectedPaymentMethod,
                                            onChanged: (val) {
                                              setState(() {
                                                selectedPaymentMethod = val;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),

                              // Colonna di destra (2 campi: data, riferimento)
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 1) Data
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 80,
                                          child: Text(
                                            "Data",
                                            style:
                                                TextStyle(color: Colors.green),
                                          ),
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () => _selectDate(context),
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
                                                selectedDate != null
                                                    ? "${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}"
                                                    : "Seleziona data",
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // 2) Riferimento
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 80,
                                          child: Text(
                                            "Riferimento",
                                            style:
                                                TextStyle(color: Colors.green),
                                          ),
                                        ),
                                        Expanded(
                                          child: TextField(
                                            controller: referenceController,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText:
                                                  "Non compilare per creare abbinamento...",
                                            ),
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

                          // ==============
                          //   TabBar
                          // ==============
                          TabBar(
                            controller: _tabController,
                            labelColor: Colors.black,
                            indicatorColor: Colors.teal,
                            tabs: const [
                              Tab(text: "Movimenti contabili"),
                              // Se volessi aggiungere un secondo tab, decommenta:
                              // Tab(text: "Altre informazioni"),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ==============
                          //   TabBarView
                          // ==============
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // 1) Movimenti contabili (pagamenti)
                                PaymentRowsWidget(
                                  rows: paymentRows,
                                  onRowsChanged: (newRows) {
                                    setState(() {
                                      paymentRows = newRows;
                                    });
                                  },
                                ),

                                // 2) Altre informazioni (eventualmente, se definito)
                                // AltreInformazioniWidget(
                                //   additionalInfo: additionalInfo,
                                //   onAdditionalInfoChanged: (newInfo) {
                                //     setState(() {
                                //       additionalInfo = newInfo;
                                //     });
                                //   },
                                // ),
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

          // Colonna di destra (1/3), vuota
          Expanded(
            flex: 1,
            child: Container(color: Colors.transparent),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------
// CustomDropdown (invariato), per selezionare i campi a tendina
// -------------------------------------------------------------------
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

    // Lista locale per filtrare in tempo reale
    List<String> localFilteredItems = List.from(widget.items);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateOverlay) {
            return Stack(
              children: [
                // Schermata trasparente per chiudere il dropdown
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
