import 'package:flutter/material.dart';
import 'package:flutter_app/pages/accounting/components/subcomponents/assets/OtherInformationsWidget.dart';
import 'package:flutter_app/pages/accounting/components/subcomponents/assets/assets_actions_bar.dart';
import 'package:flutter_app/pages/accounting/components/subcomponents/assets/assets_rows_widget.dart';

/// Widget principale che mostra un’interfaccia di “registrazione contabile”
/// con due tab invertiti: il primo è "Altre informazioni" e il secondo "Movimenti contabili".
/// Sopra il Tab viene visualizzato un solo campo di testo con titolo "NOME CESPITE".
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

  // Righe contabili (precedentemente invoiceRows)
  List<Map<String, dynamic>> invoiceRows = [];

  // Campo di testo "NOME CESPITE"
  final TextEditingController nomeCespiteController = TextEditingController();

  // Campo "Registro"
  String selectedRegister = "Fatture cliente";

  // Identificativo: rinominato da “Fattura” a “Registrazione”
  final TextEditingController registrationIdentifierController =
      TextEditingController(text: "MISC/2025/02/0001");

  /// Dizionario “Altre informazioni”
  Map<String, dynamic> additionalInfo = {
    "confermaAutomatica": "No",      // default
    "verified": false,               // default
    "internalNote": "",              // nota vuota all'inizio
    "fiscalPosition": "Nazionale",   // default
  };

  @override
  void initState() {
    super.initState();
    // Adesso abbiamo 2 tab: il primo per "Altre informazioni" e il secondo per "Movimenti contabili"
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    registrationIdentifierController.dispose();
    nomeCespiteController.dispose();
    super.dispose();
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
                // Contenitore bordato che racchiude il form e i tab
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
                              const Text(
                                "Nome cespite",
                                style: TextStyle(color: Colors.orange),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: nomeCespiteController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Inserisci il nome del cespite",
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // TabBar con 2 tab invertiti:
                          // il primo è "Immobilizzazione" e il secondo "Movimenti contabili"
                          TabBar(
                            controller: _tabController,
                            labelColor: Colors.black,
                            indicatorColor: Colors.teal,
                            tabs: const [
                              Tab(text: "Immobilizzazione"),
                              Tab(text: "Fatture"),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // TabBarView corrispondente ai 2 tab (ordine invertito)
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // 1) Immobilizzazione
                                AltreInformazioniWidget(
                                  assetData: additionalInfo,
                                  onAssetDataChanged: (newInfo) {
                                    setState(() {
                                      additionalInfo = newInfo;
                                    });
                                  },
                                ),
                                // 2) Fatture
                                AccountingRowsWidget(
                                  rows: invoiceRows,
                                  onRowsChanged: (newRows) {
                                    setState(() {
                                      invoiceRows = newRows;
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
          // Colonna destra (1/3), vuota
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
          padding: const EdgeInsets.symmetric(horizontal: 8),
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
