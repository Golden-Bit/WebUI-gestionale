import 'package:flutter/material.dart';
import 'package:flutter_app/pages/accounting/components/subcomponents/entities/Tab1Widget.dart';
import 'package:flutter_app/pages/accounting/components/subcomponents/entities/Tab2Widget.dart';
import 'package:flutter_app/pages/accounting/components/subcomponents/entities/Tab3Widget.dart';
import 'package:flutter_app/pages/accounting/components/subcomponents/entities/Tab4Widget.dart';
import 'package:flutter_app/pages/accounting/components/subcomponents/entities/entities_actions_bar.dart';

/// Esempio di enum per distinguere "Persona" o "Azienda"
enum EntityType { persona, azienda }

class EntityDetailsWidget extends StatefulWidget {
  const EntityDetailsWidget({Key? key}) : super(key: key);

  @override
  State<EntityDetailsWidget> createState() => _EntityDetailsWidgetState();
}

class _EntityDetailsWidgetState extends State<EntityDetailsWidget>
    with SingleTickerProviderStateMixin {
  // Variabile per gestire se è selezionato "Persona" o "Azienda"
  EntityType _selectedEntityType = EntityType.azienda;

  // Controller per il nome (p. es. Lumber Inc)
  final TextEditingController nameController =
      TextEditingController(text: "p. es. Lumber Inc");

  // Controller campi colonna sinistra (Indirizzo e associati)
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController capController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController vatNumberController = TextEditingController();

  // Controller campi colonna destra
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController pecController = TextEditingController();
  final TextEditingController fiscalCodeController = TextEditingController();
  final TextEditingController recipientCodeController = TextEditingController();
  String myNotes = "Inserisci qui le tue note...";

  // Mappa per "Altre informazioni" (usata nel Tab 2)
  Map<String, dynamic> myAdditionalInfoMap = {
    "entityType": "azienda", // valore di default
    "selectedCompanyName":
        "Nessuna azienda", // per il dropdown "Nome azienda" in persona
    "salesPerson": "Seleziona venditore",
    "salesPaymentTerm": "Immediato",
    "salesPaymentMethod": "Bonifico bancario",
    "priceList": "Default (EUR)",
    "fiscalPosition": "Nazionale",
    "purchasePaymentTerm": "30 giorni",
    "purchasePaymentMethod": "Carta di credito",
    "companyID": "",
    "reference": "",
    "sector": "",
  };
// Dati per la sezione "Contabilità" (Tab 3)
  Map<String, dynamic> myAccountingDataMap = {
    "bank": "Seleziona banca",
    "creditAccount": "151010 Crediti verso i clienti",
    "debitAccount": "250100 Debiti v/fornitori",
    "autoInvoiceReg": "Dopo 3 condiz. senza modifiche",
    "eInvoicing": "Fatturazione elettronica e e-mail",
    "reminderState": "Nessuna azione richiesta",
    "reminderMode": "Automatico",
    "nextReminderDate": null, // DateTime?
    "responsible": "Mario Rossi",
  };
  List<Map<String, String>> contacts = [
    // Esempio di contatto di prova
    /*{
      "tipo": "Contatto",
      "nome": "Mario Rossi",
      "email": "mario@example.com",
      "posizione": "Developer",
      "telefono": "0123456789",
      "mobile": "9876543210",
    },
    {
      "tipo": "Fattura",
      "nome": "Ufficio Amministrazione",
      "email": "admin@example.com",
      "indirizzo": "Via Roma 1",
      "telefono": "0123456789",
    },*/
  ];
  // Etichette (Dropdown personalizzato)
  String selectedLabel = "Nessuna etichetta";

  // Tab Controller
  late TabController _tabController;

  // Opzioni di esempio per "Nome azienda" (se persona)
  final List<String> personaCompanyOptions = [
    "Nessuna azienda",
    "Azienda X",
    "Azienda Y",
    "Azienda Z"
  ];

  @override
  void initState() {
    super.initState();
    // 4 tab
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    nameController.dispose();
    address1Controller.dispose();
    address2Controller.dispose();
    cityController.dispose();
    provinceController.dispose();
    capController.dispose();
    countryController.dispose();
    vatNumberController.dispose();
    phoneController.dispose();
    mobileController.dispose();
    emailController.dispose();
    websiteController.dispose();
    pecController.dispose();
    fiscalCodeController.dispose();
    recipientCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Colonna di sinistra (2/3 di larghezza)
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Action Bar in alto (sempre visibile)
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

                // Container con bordo e spazi, con 2 sezioni verticali
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
                          // 1) TOP (campi) in un Expanded (flex=1) + SingleChildScrollView
                          Expanded(
                            flex: 1,
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: buildTopFields(),
                              ),
                            ),
                          ),

                          // 2) BOTTOM (TabBar + TabBarView) in un Expanded (flex=1)
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                // TabBar
                                TabBar(
                                  controller: _tabController,
                                  labelColor: Colors.black,
                                  indicatorColor: Colors.teal,
                                  tabs: const [
                                    Tab(text: "Contatti e indirizzi"),
                                    Tab(text: "Vendite e acquisti"),
                                    Tab(text: "Contabilità"),
                                    Tab(text: "Note interne"),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // TabBarView (espanso)
                                Expanded(
                                  child: TabBarView(
                                    controller: _tabController,
                                    children: [
                                      // Tab 1

                                      // Tab 1: Contatti e indirizzi
                                      ContattiIndirizziTab(
                                        contacts: contacts,
                                        onContactsChanged: (newData) {
                                          setState(() {
                                            contacts = newData;
                                          });
                                        },
                                        // Logica quando si preme "Aggiungi"
                                        //  debugPrint("Aggiungi premuto");
                                        //},
                                      ),

                                      // Tab 2 - integrazione di OtherInformationsWidget
                                      OtherInformationsWidget(
                                        additionalInfo: myAdditionalInfoMap,
                                        onAdditionalInfoChanged: (newInfo) {
                                          setState(() {
                                            myAdditionalInfoMap = newInfo;
                                          });
                                        },
                                      ),

                                      // Tab 3
                                      AccountingTabWidget(
                                        accountingData: myAccountingDataMap,
                                        onChanged: (newData) {
                                          setState(() {
                                            myAccountingDataMap = newData;
                                          });
                                        },
                                      ),

                                      // Tab 4
                                      NoteEsterneTab(
                                        initialNote: myNotes,
                                        onNoteChanged: (newData) {
                                          setState(() {
                                            myNotes = newData;
                                          });
                                        },
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

          // Colonna di destra (1/3) - eventuale spazio vuoto
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

  /// Sezione "top" con i campi:
  /// - Radio Persona/Azienda + Nome + icona fissa 96x96
  /// - (Se persona) un dropdown "Nome azienda"
  /// - Indirizzo
  /// - Telefono, E-mail, ecc.
  Widget buildTopFields() {
    return Column(
      children: [
        // Riga: Persona/Azienda + Nome + Icona fissa
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 90%: Persona/Azienda + Nome (+eventuale dropdown)
            Expanded(
              flex: 9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Radio Persona/Azienda
                  Row(
                    children: [
                      // Radio persona
                      Row(
                        children: [
                          Radio<EntityType>(
                            value: EntityType.persona,
                            groupValue: _selectedEntityType,
                            onChanged: (val) {
                              setState(() {
                                _selectedEntityType = val!;
                                myAdditionalInfoMap["entityType"] = "persona";
                              });
                            },
                          ),
                          const Text("Persona"),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Radio azienda
                      Row(
                        children: [
                          Radio<EntityType>(
                            value: EntityType.azienda,
                            groupValue: _selectedEntityType,
                            onChanged: (val) {
                              setState(() {
                                _selectedEntityType = val!;
                                myAdditionalInfoMap["entityType"] = "azienda";
                              });
                            },
                          ),
                          const Text("Azienda"),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Campo "Nome" a tutta larghezza
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: "p. es. Lumber Inc",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  // Se la selezione è persona, aggiungiamo un dropdown "Nome azienda"
                  if (_selectedEntityType == EntityType.persona) ...[
                    const SizedBox(height: 8),
                    _buildGreenLabelRow(
                      label: "Nome azienda",
                      child: CustomDropdown(
                        items: personaCompanyOptions,
                        value: myAdditionalInfoMap["selectedCompanyName"] ??
                            "Nessuna azienda",
                        onChanged: (newVal) {
                          setState(() {
                            myAdditionalInfoMap["selectedCompanyName"] = newVal;
                          });
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Icona fissa 96x96 per caricamento immagine
            SizedBox(
              width: 96,
              height: 96,
              child: IconButton(
                iconSize: 48,
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.grey,
                    ),
                  ],
                ),
                onPressed: () {
                  debugPrint("Carica immagine...");
                  // Logica di caricamento immagine
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Sezione "Indirizzo" + "Partita IVA" (colonna di sinistra) e
        // Telefono/E-mail/... (colonna di destra)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colonna di sinistra
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titolo "Indirizzo"
                  const Text(
                    "Indirizzo",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Indirizzo
                  TextField(
                    controller: address1Controller,
                    decoration: const InputDecoration(
                      labelText: "Indirizzo",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Indirizzo2
                  TextField(
                    controller: address2Controller,
                    decoration: const InputDecoration(
                      labelText: "Indirizzo 2",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Riga con Città - Provincia - CAP
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: cityController,
                          decoration: const InputDecoration(
                            labelText: "Città",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: provinceController,
                          decoration: const InputDecoration(
                            labelText: "Provincia",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: capController,
                          decoration: const InputDecoration(
                            labelText: "CAP",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Nazione
                  TextField(
                    controller: countryController,
                    decoration: const InputDecoration(
                      labelText: "Nazione",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Partita IVA
                  _buildGreenLabelRow(
                    label: "Partita IVA",
                    child: TextField(
                      controller: vatNumberController,
                      decoration: const InputDecoration(
                        hintText: "p. es. non applicabile",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),

            // Colonna di destra
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Telefono
                  _buildGreenLabelRow(
                    label: "Telefono",
                    child: TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Dispositivo mobile
                  _buildGreenLabelRow(
                    label: "Dispositivo mobile",
                    child: TextField(
                      controller: mobileController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // E-mail
                  _buildGreenLabelRow(
                    label: "E-mail",
                    child: TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Sito web
                  _buildGreenLabelRow(
                    label: "Sito web",
                    child: TextField(
                      controller: websiteController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Etichette
                  _buildGreenLabelRow(
                    label: "Etichette",
                    child: CustomDropdown(
                      items: const ["B2B", "VIP", "Consulenza", "Altro"],
                      value: selectedLabel,
                      onChanged: (val) {
                        setState(() {
                          selectedLabel = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // E-mail PEC
                  _buildGreenLabelRow(
                    label: "E-mail PEC",
                    child: TextField(
                      controller: pecController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Codice Fiscale
                  _buildGreenLabelRow(
                    label: "Codice Fiscale",
                    child: TextField(
                      controller: fiscalCodeController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Codice destinatario
                  _buildGreenLabelRow(
                    label: "Codice destinatario",
                    child: TextField(
                      controller: recipientCodeController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Helper per costruire una riga con label (in verde) a sinistra e campo di input a destra
  Widget _buildGreenLabelRow({
    required String label,
    required Widget child,
    double labelWidth = 120,
    double spacing = 8.0,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: labelWidth,
          child: Padding(
            padding: EdgeInsets.only(right: spacing),
            child: Text(
              label,
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

/// Esempio di CustomDropdown (già definito in precedenza)
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
