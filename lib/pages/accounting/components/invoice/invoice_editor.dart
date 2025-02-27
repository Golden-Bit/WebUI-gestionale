import 'package:flutter/material.dart';
import 'package:flutter_app/pages/accounting/components/subcomponents/invoice/AccountingMovementsWidget.dart';
import 'package:flutter_app/pages/accounting/components/subcomponents/invoice/ElectronicInvoicingWidget.dart';
import 'package:flutter_app/pages/accounting/components/subcomponents/invoice/OtherInformationsWidget.dart';
import 'package:flutter_app/pages/accounting/components/subcomponents/invoice/invoice_actions_bar.dart';
import 'package:flutter_app/pages/accounting/components/subcomponents/invoice/invoice_rows_widget.dart';

class InvoiceDetailsWidget extends StatefulWidget {
  const InvoiceDetailsWidget({Key? key}) : super(key: key);

  @override
  State<InvoiceDetailsWidget> createState() => _InvoiceDetailsWidgetState();
}

class _InvoiceDetailsWidgetState extends State<InvoiceDetailsWidget>
    with SingleTickerProviderStateMixin {
  // Tab controller
  late TabController _tabController;
  List<Map<String, dynamic>> invoiceRows = [];
  // Dropdown values
  String selectedCustomer = "Seleziona cliente";
  String selectedRegister = "Fatture cliente";

  // Date values
  DateTime? invoiceDate;
  DateTime? dueDate;
  List<Map<String, dynamic>> movimentsRows = [];
  // Text editing controller
  final TextEditingController invoiceIdentifierController =
      TextEditingController(text: "INV/2025/00001");

  /// Dizionario che contiene tutti i campi di "Altre Informazioni"
  Map<String, dynamic> additionalInfo = {
    "customerReference": "", // Riferimento cliente (stringa)
    "selectedSalesperson": "Seleziona venditore",
    "selectedBank": "Seleziona banca",
    "paymentReference": "",
    "deliveryDate": null, // Data consegna (DateTime? o null)

    "selectedTermineResa": "[EXW] FRANCO FABBRICA",
    "incotermLocation": "",
    "selectedFiscalPosition": "Nazionale",
    "selectedPaymentMethod": "Manual Payment (Banca)",
    "selectedConfermaAutomatica": "No",
    "verified": false, // bool
  };

  /// Dizionario che contiene i dati del **Tab 4: Fatturazione Elettronica**
  Map<String, dynamic> electronicInvoicingInfo = {
    "datiBollo": 0.00, // Numero decimale per Dati Bollo
    "selectedDDT": "Seleziona DDT",
    "selectedDocumentType": "Seleziona tipo documento",
    "selectedPaymentMethod": "Seleziona metodo pagamento",
  };
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
      body: Row(
        children: [
          // Colonna sinistra (2/3 della larghezza)
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // 1) InvoiceActionsBar dentro l'Expanded, ma fuori dal Container con bordo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: InvoiceActionsBar(
                    onConfirm: () {
                      // Logica di salvataggio o passaggio a "Confermata"
                      print("Conferma premuto");
                    },
                    onCancel: () {
                      // Logica di ripristino bozza o annullamento
                      print("Annulla premuto");
                    },
                    defaultIsDraft: true, // Facoltativo: di default è true
                  ),
                ),

                // Eventuale divisore
                //const SizedBox(height: 8),

                // 2) Contenitore con bordo nero/grigio che racchiude il resto
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey, // Se preferisci nero: Colors.black
                        width: 2, // Spessore del bordo
                      ),
                      borderRadius: BorderRadius.circular(4), // Angoli arrotondati opzionali
                    ),
                    margin: const EdgeInsets.fromLTRB(16,0,16,16), // Spazio esterno
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          //const Divider(thickness: 2, color: Colors.grey),
                          //const SizedBox(height: 16),
                          // Identificativo Fattura
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

                          // Sezione: Cliente, Data, Scadenza, Registro
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Cliente
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

                              // Colonna con Data Fattura, Scadenza e Registro
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    // Data Fattura
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
                                            onTap: () => _selectDate(context, isInvoiceDate: true),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 16,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey.shade400),
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

                                    // Scadenza
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
                                            onTap: () => _selectDate(context, isInvoiceDate: false),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 16,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey.shade400),
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

                                    // Registro
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
                                          child: CustomDropdown(
                                            items: [
                                              "fatture cliente",
                                              "altro registro",
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

                          // TabBar
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

                          // TabBarView
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // 1) Righe fattura
                                InvoiceRowsWidget(
                                  invoiceRows: invoiceRows,
                                  onRowsChanged: (newRows) {
                                    setState(() {
                                      invoiceRows = newRows;
                                    });
                                  },
                                ),

                                // 2) Movimenti contabili
                                AccountingMovementsWidget(
                                  invoiceRows: invoiceRows,
                                  movimentsRows: movimentsRows,
                                  onInvoiceRowsChanged: (newInvoiceRows) {
                                    setState(() {
                                      invoiceRows = newInvoiceRows;
                                    });
                                  },
                                  onMovementsChanged: (newMovementsRows) {
                                    setState(() {
                                      movimentsRows = newMovementsRows;
                                    });
                                  },
                                ),

                                // 3) Altre informazioni
                                OtherInformationsWidget(
                                  additionalInfo: additionalInfo,
                                  onAdditionalInfoChanged: (newInfo) {
                                    setState(() {
                                      additionalInfo = newInfo;
                                    });
                                  },
                                ),

                                // 4) Fatturazione elettronica
                                ElectronicInvoicingWidget(
                                  electronicInvoicingInfo: electronicInvoicingInfo,
                                  onElectronicInvoicingChanged: (newInfo) {
                                    setState(() {
                                      electronicInvoicingInfo = newInfo;
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

          // Colonna destra (1/3), vuota o per altri contenuti
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ],
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
