import 'package:flutter/material.dart';
import 'package:flutter_app/pages/accounting/components/entities/entities_editor.dart';

// Esempi di costanti (dropdown) per i nuovi campi
const List<String> salespersonOptions = [
  "Seleziona venditore",
  "Mario Rossi",
  "Luigi Bianchi",
  "Paolo Verdi",
];

const List<String> paymentTermOptions = [
  "Immediato",
  "30 giorni",
  "60 giorni",
  "90 giorni",
];

const List<String> paymentMethodOptions = [
  "Bonifico bancario",
  "Carta di credito",
  "Assegno",
  "Contanti",
];

const List<String> priceListOptions = [
  "Default (EUR)",
  "Listino sconti 2025",
  "Listino Premium",
];

const List<String> fiscalPositionOptions = [
  "Nazionale",
  "EU B2C",
  "Intra-Comunitario",
  "Importazione/Esportazione",
  "Scissione dei Pagamenti",
];

/// Opzioni “Settore” da usare se la entità è “persona”
const List<String> sectorOptionsForPerson = [
  "Privato",
  "Professionista",
  "Artigiano",
  "Altro",
];

/// Widget che replica i campi mostrati in figura, con:
/// - VENDITE
/// - INFORMAZIONI FISCALI
/// - ACQUISTI
/// - VARIE
///
/// Nel caso `entityType == "azienda"`, la sezione "VARIE" mostra:
///    * ID Azienda (TextField)
///    * Riferimento (TextField)
///    * Settore (TextField)
///
/// Nel caso `entityType == "persona"`, la sezione "VARIE" mostra:
///    * (NO ID Azienda)
///    * Riferimento (TextField)
///    * Settore (CustomDropdown)
///
/// Le altre sezioni (Vendite, Informazioni Fiscali, Acquisti) restano uguali.
class OtherInformationsWidget extends StatefulWidget {
  final Map<String, dynamic> additionalInfo;
  final ValueChanged<Map<String, dynamic>> onAdditionalInfoChanged;

  const OtherInformationsWidget({
    Key? key,
    required this.additionalInfo,
    required this.onAdditionalInfoChanged,
  }) : super(key: key);

  @override
  _OtherInformationsWidgetState createState() =>
      _OtherInformationsWidgetState();
}

class _OtherInformationsWidgetState extends State<OtherInformationsWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  /// Helper per aggiornare un campo stringa
  void _updateStringField(String key, String value) {
    final newInfo = Map<String, dynamic>.from(widget.additionalInfo);
    newInfo[key] = value;
    widget.onAdditionalInfoChanged(newInfo);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Leggiamo i valori correnti
    final info = widget.additionalInfo;
    final String entityType = info["entityType"] ?? "azienda";

    // Campi "Vendite"
    final String salesPerson = info["salesPerson"] ?? salespersonOptions.first;
    final String salesPaymentTerm =
        info["salesPaymentTerm"] ?? paymentTermOptions.first;
    final String salesPaymentMethod =
        info["salesPaymentMethod"] ?? paymentMethodOptions.first;
    final String priceList = info["priceList"] ?? priceListOptions.first;

    // Campo "Informazioni fiscali"
    final String selectedFiscalPosition =
        info["fiscalPosition"] ?? fiscalPositionOptions.first;

    // Campi "Acquisti"
    final String purchasePaymentTerm =
        info["purchasePaymentTerm"] ?? paymentTermOptions.first;
    final String purchasePaymentMethod =
        info["purchasePaymentMethod"] ?? paymentMethodOptions.first;

    // Campi "Varie"
    final String companyID = info["companyID"] ?? "";
    final String reference = info["reference"] ?? "";
    final String sector = info["sector"] ?? "";

    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------------------------------------------------
              // Colonna sinistra: VENDITE + INFORMAZIONI FISCALI
              // ---------------------------------------------------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titolo sezione "VENDITE"
                    const Text(
                      "VENDITE",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Addetto vendite
                    buildLabelRow(
                      label: "Addetto vendite",
                      tooltip: "Seleziona l'addetto vendite",
                      child: CustomDropdown(
                        items: salespersonOptions,
                        value: salesPerson,
                        onChanged: (newVal) =>
                            _updateStringField("salesPerson", newVal),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Termini di pagamento (vendite)
                    buildLabelRow(
                      label: "Termini di pagamento",
                      tooltip: "Condizioni di pagamento per le vendite",
                      child: CustomDropdown(
                        items: paymentTermOptions,
                        value: salesPaymentTerm,
                        onChanged: (newVal) =>
                            _updateStringField("salesPaymentTerm", newVal),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Metodo di pagamento (vendite)
                    buildLabelRow(
                      label: "Metodo di pagamento",
                      tooltip: "Modalità di incasso (vendite)",
                      child: CustomDropdown(
                        items: paymentMethodOptions,
                        value: salesPaymentMethod,
                        onChanged: (newVal) =>
                            _updateStringField("salesPaymentMethod", newVal),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Listino prezzi
                    buildLabelRow(
                      label: "Listino prezzi",
                      tooltip: "Seleziona un listino prezzi per le vendite",
                      child: CustomDropdown(
                        items: priceListOptions,
                        value: priceList,
                        onChanged: (newVal) =>
                            _updateStringField("priceList", newVal),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Sezione INFORMAZIONI FISCALI
                    const Text(
                      "INFORMAZIONI FISCALI",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Posizione fiscale
                    buildLabelRow(
                      label: "Posizione fiscale",
                      tooltip: "Seleziona la posizione fiscale",
                      child: CustomDropdown(
                        items: fiscalPositionOptions,
                        value: selectedFiscalPosition,
                        onChanged: (newVal) =>
                            _updateStringField("fiscalPosition", newVal),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 40),

              // ---------------------------------------------------------
              // Colonna destra: ACQUISTI + VARIE
              // ---------------------------------------------------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sezione ACQUISTI (uguale per persona e azienda)
                    const Text(
                      "ACQUISTI",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Termini di pagamento (acquisti)
                    buildLabelRow(
                      label: "Termini di pagamento",
                      tooltip: "Condizioni di pagamento per gli acquisti",
                      child: CustomDropdown(
                        items: paymentTermOptions,
                        value: purchasePaymentTerm,
                        onChanged: (newVal) =>
                            _updateStringField("purchasePaymentTerm", newVal),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Metodo di pagamento (acquisti)
                    buildLabelRow(
                      label: "Metodo di pagamento",
                      tooltip: "Modalità di pagamento (acquisti)",
                      child: CustomDropdown(
                        items: paymentMethodOptions,
                        value: purchasePaymentMethod,
                        onChanged: (newVal) =>
                            _updateStringField("purchasePaymentMethod", newVal),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Sezione VARIE
                    const Text(
                      "VARIE",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Se entityType == "azienda", mostriamo "ID Azienda" e "Settore" come TextField
                    // Se entityType == "persona", non mostriamo "ID Azienda" e "Settore" è un CustomDropdown
                    // (il resto - "Riferimento" - rimane uguale)

                    if (entityType == "azienda") ...[
                      // 1) ID Azienda
                      buildLabelRow(
                        label: "ID Azienda",
                        tooltip: "Identificativo interno dell'azienda",
                        child: TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                          controller: TextEditingController(text: companyID),
                          onChanged: (value) =>
                              _updateStringField("companyID", value),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Riferimento (uguale per entrambi)
                    buildLabelRow(
                      label: "Riferimento",
                      tooltip: "Campo per note o riferimenti extra",
                      child: TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                        controller: TextEditingController(text: reference),
                        onChanged: (value) =>
                            _updateStringField("reference", value),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (entityType == "azienda") ...[
                      // Settore come CustomDropdown
                      buildLabelRow(
                        label: "Settore",
                        tooltip: "Settore di appartenenza della persona",
                        child: CustomDropdown(
                          items: sectorOptionsForPerson,
                          value: sectorOptionsForPerson.contains(sector)
                              ? sector
                              : sectorOptionsForPerson.first,
                          onChanged: (newVal) =>
                              _updateStringField("sector", newVal),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Metodo helper per costruire una riga con label e tooltip a sinistra,
  /// e un widget di input (o dropdown) a destra.
  ///
  /// Qui gestiamo:
  /// - allineamento verticale (crossAxisAlignment: center)
  /// - possibilità di multilinea nel label (max 2 righe)
  /// - padding verticale aggiuntivo tra i campi
  Widget buildLabelRow({
    required String label,
    required String tooltip,
    required Widget child,
    double labelWidth = 140,
    double spacing = 16,
  }) {
    return Padding(
      // padding verticale per separare i campi
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: labelWidth,
            margin: EdgeInsets.only(right: spacing),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                    softWrap: true,
                  ),
                ),
                const SizedBox(width: 4),
                Tooltip(
                  message: tooltip,
                  child: const Icon(Icons.help_outline, size: 16),
                ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
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
                // Sfondo trasparente per chiudere il dropdown se si clicca fuori
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

    // Focus sul campo di ricerca
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
          onEnter: (_) =>
              setStateItem(() => backgroundColor = Colors.grey[200]!),
          onExit: (_) =>
              setStateItem(() => backgroundColor = Colors.white),
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
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}
