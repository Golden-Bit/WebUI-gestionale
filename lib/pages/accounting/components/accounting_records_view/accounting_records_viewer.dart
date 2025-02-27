import 'package:flutter/material.dart';
import 'package:flutter_app/pages/accounting/components/subcomponents/accounting_records/OtherInformationsWidget.dart';
import 'package:flutter_app/pages/accounting/components/subcomponents/accounting_records/accounting_records_actions_bar.dart';
import 'package:flutter_app/pages/accounting/components/subcomponents/accounting_records/accounting_records_rows_widget.dart';

/// Widget principale che mostra un’interfaccia di “registrazione contabile”
/// con due tab: “Movimenti contabili” e “Altre informazioni”.
class AccountingRecordsWidget extends StatefulWidget {
  const AccountingRecordsWidget({Key? key}) : super(key: key);

  @override
  State<AccountingRecordsWidget> createState() =>
      _AccountingRecordsWidgetState();
}

class _AccountingRecordsWidgetState extends State<AccountingRecordsWidget>
    with SingleTickerProviderStateMixin {
  // Controller per i due tab
  late TabController _tabController;

  // Righe contabili (prima erano invoiceRows)
  List<Map<String, dynamic>> invoiceRows = [];

  // Campo di testo "Riferimento" (ex "Cliente")
  final TextEditingController referenceController = TextEditingController();

  // Data contabile (ex invoiceDate)
  DateTime? accountingDate;

  // Campo "Registro"
  String selectedRegister = "Fatture cliente";

  // Identificativo: rinominato da “Fattura” a “Registrazione”
  final TextEditingController registrationIdentifierController =
      TextEditingController(text: "MISC/2025/02/0001");

  /// Dizionario “Altre informazioni”
  /// Rimasto invariato, salvo che continuiamo ad usarlo per il Tab “Altre informazioni”.
  Map<String, dynamic> additionalInfo = {
    "confermaAutomatica": "No",      // default
    "verified": false,               // default
    "internalNote": "",              // nota vuota all'inizio
    "fiscalPosition": "Nazionale",   // default
  };

  @override
  void initState() {
    super.initState();
    // Adesso abbiamo solo 2 tab
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    registrationIdentifierController.dispose();
    referenceController.dispose();
    super.dispose();
  }

  Future<void> _selectAccountingDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        accountingDate = picked;
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
                          // Identificativo Registrazione (invece di "Identificativo Fattura")
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Identificativo Registrazione",
                                style: TextStyle(color: Colors.orange),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: registrationIdentifierController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Esempio di campi "Riferimento" (testuale), "Data contabile", "Registro"
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Riferimento
                              Expanded(
                                flex: 2,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 80,
                                      child: Text(
                                        "Riferimento",
                                        style: TextStyle(color: Colors.green),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: referenceController,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Colonna con Data contabile, Registro
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    // Data contabile
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 100,
                                          child: Text(
                                            "Data contabile",
                                            style:
                                                TextStyle(color: Colors.green),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () =>
                                                _selectAccountingDate(context),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 16,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade400),
                                                borderRadius:
                                                    BorderRadius.circular(4.0),
                                              ),
                                              child: Text(
                                                accountingDate != null
                                                    ? "${accountingDate!.day}/${accountingDate!.month}/${accountingDate!.year}"
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

                                    // Registro
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 100,
                                          child: Text(
                                            "Registro",
                                            style:
                                                TextStyle(color: Colors.green),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                        Expanded(
                                          child: CustomDropdown(
                                            items: [
                                              "Fatture cliente",
                                              "Altro registro",
                                            ],
                                            value: selectedRegister,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedRegister = value;
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

                          // TabBar con 2 tab: "Movimenti contabili" e "Altre informazioni"
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

                          // TabBarView corrispondente ai 2 tab
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // 1) Movimenti contabili (ex Righe Fattura)
                                AccountingRowsWidget(
                                  rows: invoiceRows,
                                  onRowsChanged: (newRows) {
                                    setState(() {
                                      invoiceRows = newRows;
                                    });
                                  },
                                ),

                                // 2) Altre informazioni
                                AltreInformazioniWidget(
                                  additionalInfo: additionalInfo,
                                  onAdditionalInfoChanged: (newInfo) {
                                    setState(() {
                                      additionalInfo = newInfo;
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

    // Lista locale filtrabile
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
