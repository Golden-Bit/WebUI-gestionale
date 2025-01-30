import 'package:flutter/material.dart';

class InvoiceDetailsWidget extends StatefulWidget {
  const InvoiceDetailsWidget({Key? key}) : super(key: key);

  @override
  State<InvoiceDetailsWidget> createState() => _InvoiceDetailsWidgetState();
}

class _InvoiceDetailsWidgetState extends State<InvoiceDetailsWidget>
    with SingleTickerProviderStateMixin {
  // Tab controller
  late TabController _tabController;

  // Dropdown values
  String selectedCustomer = "Seleziona cliente";
  String selectedRegister = "Fatture cliente";

  // Date values
  DateTime? invoiceDate;
  DateTime? dueDate;

  // Text editing controller
  final TextEditingController invoiceIdentifierController =
      TextEditingController(text: "INV/2025/00001");

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    invoiceIdentifierController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context,
      {required bool isInvoiceDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isInvoiceDate) {
          invoiceDate = picked;
        } else {
          dueDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top Section: Invoice Identifier
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Identificativo Fattura",
                  style: TextStyle(color: Colors.orange),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: invoiceIdentifierController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Top Section: Client and Invoice Details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Cliente
                Expanded(
                  flex: 2,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 80,
                        child: Text(
                          "Cliente",
                          style: TextStyle(color: Colors.green),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Expanded(
                        child: CustomDropdown(
                          items: [
                            "abc 1",
                            "def 2",
                            "abg 3",
                            "frt 4",
                            "Cliente 5",
                            "Cliente 6",
                            "Cliente 7",
                            "Cliente 8",
                            "Cliente 9"
                          ],
                          value: selectedCustomer,
                          onChanged: (value) {
                            setState(() {
                              selectedCustomer = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Center Column: Date Fields
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 100,
                            child: Text(
                              "Data fattura",
                              style: TextStyle(color: Colors.green),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () =>
                                  _selectDate(context, isInvoiceDate: true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Text(
                                  invoiceDate != null
                                      ? "${invoiceDate!.day}/${invoiceDate!.month}/${invoiceDate!.year}"
                                      : "Seleziona data",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 100,
                            child: Text(
                              "Scadenza",
                              style: TextStyle(color: Colors.green),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () =>
                                  _selectDate(context, isInvoiceDate: false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Text(
                                  dueDate != null
                                      ? "${dueDate!.day}/${dueDate!.month}/${dueDate!.year}"
                                      : "Seleziona scadenza",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 100,
                            child: Text(
                              "Registro",
                              style: TextStyle(color: Colors.green),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Expanded(
                            child: DropdownButton<String>(
                              value: selectedRegister,
                              onChanged: (value) {
                                setState(() {
                                  selectedRegister = value!;
                                });
                              },
                              items: [
                                "Fatture cliente",
                                "Altro registro",
                              ]
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(item),
                                    ),
                                  )
                                  .toList(),
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
            // Tab Section
            TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              indicatorColor: Colors.teal,
              tabs: const [
                Tab(text: "Righe fattura"),
                Tab(text: "Movimenti contabili"),
                Tab(text: "Altre informazioni"),
                Tab(text: "Fatturazione Elettronica"),
              ],
            ),
            const SizedBox(height: 16),
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPlaceholderContent("Righe Fattura"),
                  _buildPlaceholderContent("Movimenti Contabili"),
                  _buildPlaceholderContent("Altre Informazioni"),
                  _buildPlaceholderContent("Fatturazione Elettronica"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderContent(String title) {
    return Center(
      child: Text(
        "Placeholder $title",
        style: const TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}

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
final TextEditingController _searchController = TextEditingController();
  List<String> _filteredItems = [];
final FocusNode _searchFocusNode = FocusNode();

@override
void initState() {
  super.initState();
  _filteredItems = widget.items;

  // Listener per aggiornare la lista in tempo reale
_searchController.addListener(() {
  setState(() {
    List<String> newFilteredItems = widget.items
        .where((item) => item.toLowerCase().contains(_searchController.text.toLowerCase()))
        .toList();

    if (_filteredItems.length != newFilteredItems.length ||
        !_filteredItems.toSet().containsAll(newFilteredItems.toSet())) {
      
      _filteredItems = newFilteredItems;

      // 🔹 Mantieni il testo attuale
      String currentText = _searchController.text;

      // 🔹 Rimuove e ricrea il dropdown
      _overlayEntry?.remove();
      _showDropdown();

      // 🔹 Ripristina il testo e il cursore
      _searchController.text = currentText;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: currentText.length),
      );

      // 🔹 Dai automaticamente il focus e forza il refresh del cursore
      Future.delayed(Duration.zero, () {
        _searchFocusNode.unfocus();  // 🔹 Rimuove temporaneamente il focus
        _searchFocusNode.requestFocus(); // 🔹 Riapplica il focus per attivare il cursore
      });
    }
  });
});


}
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

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Rileva tocchi fuori dal menu e chiude il dropdown
            GestureDetector(
              onTap: _closeDropdown,
              behavior: HitTestBehavior
                  .opaque, // Assicura che catturi i tocchi ovunque
              child: Container(
                color: Colors
                    .transparent, // Sfondo trasparente per catturare i tocchi
              ),
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
                    constraints: const BoxConstraints(
                      maxHeight: 300, // Limite massimo di altezza
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Campo di input per la ricerca
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: StatefulBuilder(
  builder: (context, setStateDropdown) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
  controller: _searchController,
  focusNode: _searchFocusNode, // 🔹 FocusNode associato
  decoration: InputDecoration(
    border: OutlineInputBorder(),
    hintText: 'Cerca...',
    contentPadding: EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 4,
    ),
  ),
),
    );
  },
),
                        ),
                        // Lista scrollabile
                        Expanded(
                          child: ListView(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            children: _filteredItems.map((item) {
                              return _buildHoverableListTile(
                                title: item,
                                onTap: () {
  widget.onChanged(item); // Aggiorna il valore tramite callback
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

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isDropdownOpen = true;
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
