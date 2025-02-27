import 'package:flutter/material.dart';

/// Esempio di widget che replica il tab "Immobilizzazione" di Odoo,
/// con layout in 3 righe, ognuna con 2 sezioni (tranne l'ultima che ne ha 1).
///
/// Usa un Map<String, dynamic> "assetData" per i valori
/// e un callback "onAssetDataChanged" per notificare le modifiche.
class AltreInformazioniWidget extends StatefulWidget {
  final Map<String, dynamic> assetData;
  final ValueChanged<Map<String, dynamic>> onAssetDataChanged;

  const AltreInformazioniWidget({
    Key? key,
    required this.assetData,
    required this.onAssetDataChanged,
  }) : super(key: key);

  @override
  _AltreInformazioniWidgetState createState() => _AltreInformazioniWidgetState();
}

class _AltreInformazioniWidgetState extends State<AltreInformazioniWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // ----------------------------------
  // Sezione "Valori Cespite"
  // ----------------------------------
  late TextEditingController _valoreOriginaleController;
  DateTime? _dataAcquisizione;
  String _selectedAssetModel = "";
  String _selectedAssetGroup = "";

  final List<String> _assetModelOptions = ["Modello 1", "Modello 2", "Modello 3"];
  final List<String> _assetGroupOptions = ["Gruppo A", "Gruppo B", "Gruppo C"];

  // ----------------------------------
  // Sezione "Metodo di ammortamento"
  // ----------------------------------
  String _selectedMetodo = "";
  late TextEditingController _durataController;
  String _selectedDurataUnit = "";
  String _selectedCalcolo = "";
  DateTime? _dataProRata;

  final List<String> _metodoOptions = [
    "Linea retta",
    "Decrescente",
    "Decrescente poi lineare",
  ];
  final List<String> _durataUnitOptions = ["Mesi", "Anni"];
  final List<String> _calcoloOptions = [
    "No prorata",
    "Periodi costanti",
    "Basato su giorni per periodo",
  ];

  // ----------------------------------
  // Sezione "Valore all'importazione"
  // ----------------------------------
  late TextEditingController _importoAmmortizzatoController;

  // ----------------------------------
  // Sezione "Valori attuali"
  // ----------------------------------
  late TextEditingController _valoreNonAmmortizzatoController;
  late TextEditingController _valoreContabileController;

  // ----------------------------------
  // Sezione "Contabilità" (3 conti + Registro)
  // ----------------------------------
  String _selectedContoImmobilizzazioni = "";
  String _selectedContoAmmortamento = "";
  String _selectedContoCostiPeriodici = "";
  String _selectedRegistro = "";

  // 3 conti diversi, con tooltips differenti
  final List<String> _contoImmobilizzazioniOptions = [
    "Conto Imm1",
    "Conto Imm2",
    "Conto Imm3",
  ];
  final List<String> _contoAmmortamentoOptions = [
    "Conto Amm1",
    "Conto Amm2",
    "Conto Amm3",
  ];
  final List<String> _contoCostiPeriodiciOptions = [
    "Conto Costi1",
    "Conto Costi2",
    "Conto Costi3",
  ];

  final List<String> _registroOptions = [
    "Operazioni varie",
    "Operazioni straordinarie",
  ];

  // ----------------------------------
  // Inizializzazione
  // ----------------------------------
  @override
  void initState() {
    super.initState();
    _initFromAssetData();
  }

  void _initFromAssetData() {
    final data = widget.assetData;

    // Valori Cespite
    _valoreOriginaleController = TextEditingController(
      text: data["valoreOriginale"]?.toString() ?? "0.00",
    );
    _dataAcquisizione = data["dataAcquisizione"] as DateTime?;
    _selectedAssetModel = data["assetModel"] ?? _assetModelOptions.first;
    _selectedAssetGroup = data["assetGroup"] ?? _assetGroupOptions.first;

    // Metodo Ammortamento
    _selectedMetodo = data["metodo"] ?? _metodoOptions.first;
    _durataController = TextEditingController(
      text: data["durata"]?.toString() ?? "5",
    );
    _selectedDurataUnit = data["durataUnit"] ?? _durataUnitOptions.last;
    _selectedCalcolo = data["calcolo"] ?? _calcoloOptions.first;
    _dataProRata = data["dataProRata"] as DateTime?;

    // Valore all'importazione
    _importoAmmortizzatoController = TextEditingController(
      text: data["importoAmmortizzato"]?.toString() ?? "0.00",
    );

    // Valori attuali
    _valoreNonAmmortizzatoController = TextEditingController(
      text: data["valoreNonAmmortizzato"]?.toString() ?? "0.00",
    );
    _valoreContabileController = TextEditingController(
      text: data["valoreContabile"]?.toString() ?? "0.00",
    );

    // Contabilità
    _selectedContoImmobilizzazioni =
        data["contoImmobilizzazioni"] ?? _contoImmobilizzazioniOptions.first;
    _selectedContoAmmortamento =
        data["contoAmmortamento"] ?? _contoAmmortamentoOptions.first;
    _selectedContoCostiPeriodici =
        data["contoCostiPeriodici"] ?? _contoCostiPeriodiciOptions.first;
    _selectedRegistro = data["registro"] ?? _registroOptions.first;
  }

  // ----------------------------------
  // Aggiornamento mappa + callback
  // ----------------------------------
  void _updateAssetData(String key, dynamic value) {
    final newData = Map<String, dynamic>.from(widget.assetData);
    newData[key] = value;
    widget.onAssetDataChanged(newData);
  }

  // ----------------------------------
  // Selettori data
  // ----------------------------------
  Future<void> _selectDataAcquisizione(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataAcquisizione ?? DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dataAcquisizione = picked);
      _updateAssetData("dataAcquisizione", picked);
    }
  }

  Future<void> _selectDataProRata(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataProRata ?? DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dataProRata = picked);
      _updateAssetData("dataProRata", picked);
    }
  }

  @override
  void dispose() {
    _valoreOriginaleController.dispose();
    _durataController.dispose();
    _importoAmmortizzatoController.dispose();
    _valoreNonAmmortizzatoController.dispose();
    _valoreContabileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // RIGA 1: "Valori Cespite" (sinistra) + "Valori attuali" (destra)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sezione sinistra
              Expanded(child: _buildValoriCespiteSection()),
              const SizedBox(width: 32),
              // Sezione destra
              Expanded(child: _buildValoriAttualiSection()),
            ],
          ),
          const SizedBox(height: 24),

          // RIGA 2: "Metodo di ammortamento" (sinistra) + "Contabilità" (destra)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildMetodoAmmortamentoSection()),
              const SizedBox(width: 32),
              Expanded(child: _buildContabilitaSection()),
            ],
          ),
          const SizedBox(height: 24),

          // RIGA 3: "Valore all'importazione" (sinistra) + colonna vuota (destra)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildValoreAllImportazioneSection()),
              const SizedBox(width: 32),
              Expanded(child: Container()), // sezione destra vuota
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------
  // SEZIONE "Valori Cespite"
  // ----------------------------------
  Widget _buildValoriCespiteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("VALORI CESPITE"),
        const Divider(thickness: 1, color: Colors.grey),
        const SizedBox(height: 8),

        // Valore originale
        _buildLabelAndFieldWithTooltip(
          label: "Valore originale",
          tooltip: "conto usato per registrare l’acquisto del cespite al suo prezzo originale",
          child: SizedBox(
            width: 150,
            child: TextField(
              controller: _valoreOriginaleController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Center(
                    widthFactor: 0.0,
                    child: Text(
                      "€",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              onChanged: (val) => _updateAssetData("valoreOriginale", val),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Data di acquisizione
        _buildLabelAndFieldWithTooltip(
          label: "Data di acquisizione",
          tooltip: "Data in cui il cespite è stato acquisito",
          child: InkWell(
            onTap: () => _selectDataAcquisizione(context),
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                _dataAcquisizione != null
                    ? "${_dataAcquisizione!.day}/${_dataAcquisizione!.month}/${_dataAcquisizione!.year}"
                    : "Seleziona data",
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Modello cespite
        _buildLabelAndFieldWithTooltip(
          label: "Modello cespite",
          tooltip: "Seleziona il modello di ammortamento preconfigurato",
          child: CustomDropdown(
            items: _assetModelOptions,
            value: _selectedAssetModel,
            onChanged: (val) {
              setState(() => _selectedAssetModel = val);
              _updateAssetData("assetModel", val);
            },
          ),
        ),
        const SizedBox(height: 16),

        // Gruppo cespite
        _buildLabelAndFieldWithTooltip(
          label: "Gruppo cespite",
          tooltip: "Scegli il gruppo di cespiti a cui appartiene",
          child: CustomDropdown(
            items: _assetGroupOptions,
            value: _selectedAssetGroup,
            onChanged: (val) {
              setState(() => _selectedAssetGroup = val);
              _updateAssetData("assetGroup", val);
            },
          ),
        ),
      ],
    );
  }

  // ----------------------------------
  // SEZIONE "Valori attuali"
  // ----------------------------------
  Widget _buildValoriAttualiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("VALORI ATTUALI"),
        const Divider(thickness: 1, color: Colors.grey),
        const SizedBox(height: 8),

        // Valore non ammortizzato
        _buildLabelAndFieldWithTooltip(
          label: "Valore non ammortizzato",
          tooltip: "Importo rimanente da ammortizzare",
          child: SizedBox(
            width: 150,
            child: TextField(
              controller: _valoreNonAmmortizzatoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Center(
                    widthFactor: 0.0,
                    child: Text(
                      "€",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              onChanged: (val) =>
                  _updateAssetData("valoreNonAmmortizzato", val),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Valore contabile
        _buildLabelAndFieldWithTooltip(
          label: "Valore contabile",
          tooltip: "Valore netto del cespite a bilancio",
          child: SizedBox(
            width: 150,
            child: TextField(
              controller: _valoreContabileController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Center(
                    widthFactor: 0.0,
                    child: Text(
                      "€",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              onChanged: (val) => _updateAssetData("valoreContabile", val),
            ),
          ),
        ),
      ],
    );
  }

  // ----------------------------------
  // SEZIONE "Metodo di ammortamento"
  // ----------------------------------
  Widget _buildMetodoAmmortamentoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("METODO DI AMMORTAMENTO"),
        const Divider(thickness: 1, color: Colors.grey),
        const SizedBox(height: 8),

        // Metodo
        _buildLabelAndFieldWithTooltip(
          label: "Metodo",
          tooltip: "Scegli la formula di calcolo dell'ammortamento",
          child: CustomDropdown(
            items: _metodoOptions,
            value: _selectedMetodo,
            onChanged: (val) {
              setState(() => _selectedMetodo = val);
              _updateAssetData("metodo", val);
            },
          ),
        ),
        const SizedBox(height: 16),

        // Durata (campo numerico + dropdown)
        _buildLabelAndFieldWithTooltip(
          label: "Durata",
          tooltip: "Imposta la durata e l'unità di tempo dell'ammortamento",
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _durataController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => _updateAssetData("durata", val),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: CustomDropdown(
                  items: _durataUnitOptions,
                  value: _selectedDurataUnit,
                  onChanged: (val) {
                    setState(() => _selectedDurataUnit = val);
                    _updateAssetData("durataUnit", val);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Calcolo
        _buildLabelAndFieldWithTooltip(
          label: "Calcolo",
          tooltip: "Specifica la modalità di calcolo per l'ammortamento",
          child: CustomDropdown(
            items: _calcoloOptions,
            value: _selectedCalcolo,
            onChanged: (val) {
              setState(() => _selectedCalcolo = val);
              _updateAssetData("calcolo", val);
            },
          ),
        ),
        const SizedBox(height: 16),

        // Data pro rata (visibile se _selectedCalcolo != "No prorata")
        if (_selectedCalcolo != "No prorata") ...[
          _buildLabelAndFieldWithTooltip(
            label: "Data pro rata",
            tooltip: "Data di riferimento per il calcolo pro rata temporis",
            child: InkWell(
              onTap: () => _selectDataProRata(context),
              child: Container(
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  _dataProRata != null
                      ? "${_dataProRata!.day}/${_dataProRata!.month}/${_dataProRata!.year}"
                      : "Seleziona data",
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  // ----------------------------------
  // SEZIONE "Contabilità"
  // (3 conti + Registro)
  // ----------------------------------
  Widget _buildContabilitaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("CONTABILITÀ"),
        const Divider(thickness: 1, color: Colors.grey),
        const SizedBox(height: 8),

        // Conto immobilizzazioni
        _buildLabelAndFieldWithTooltip(
          label: "Conto immobilizzazioni",
          tooltip: "conto usato per registrare l'acquisto del cespite al suo prezzo originale",
          child: CustomDropdown(
            items: _contoImmobilizzazioniOptions,
            value: _selectedContoImmobilizzazioni,
            onChanged: (val) {
              setState(() => _selectedContoImmobilizzazioni = val);
              _updateAssetData("contoImmobilizzazioni", val);
            },
          ),
        ),
        const SizedBox(height: 16),

        // Conto di ammortamento
        _buildLabelAndFieldWithTooltip(
          label: "Conto di ammortamento",
          tooltip: "conto usato nelle registrazioni di ammortamento, per diminuire il valore del cespite",
          child: CustomDropdown(
            items: _contoAmmortamentoOptions,
            value: _selectedContoAmmortamento,
            onChanged: (val) {
              setState(() => _selectedContoAmmortamento = val);
              _updateAssetData("contoAmmortamento", val);
            },
          ),
        ),
        const SizedBox(height: 16),

        // Conto costi periodici
        _buildLabelAndFieldWithTooltip(
          label: "Conto costi periodici",
          tooltip: "conto usato nelle registrazioni periodiche, per registrare una parte del cespite come costo",
          child: CustomDropdown(
            items: _contoCostiPeriodiciOptions,
            value: _selectedContoCostiPeriodici,
            onChanged: (val) {
              setState(() => _selectedContoCostiPeriodici = val);
              _updateAssetData("contoCostiPeriodici", val);
            },
          ),
        ),
        const SizedBox(height: 16),

        // Registro
        _buildLabelAndFieldWithTooltip(
          label: "Registro",
          tooltip: "Registro contabile in cui registrare le scritture",
          child: CustomDropdown(
            items: _registroOptions,
            value: _selectedRegistro,
            onChanged: (val) {
              setState(() => _selectedRegistro = val);
              _updateAssetData("registro", val);
            },
          ),
        ),
      ],
    );
  }

  // ----------------------------------
  // SEZIONE "Valore all'importazione"
  // ----------------------------------
  Widget _buildValoreAllImportazioneSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("VALORE ALL'IMPORTAZIONE"),
        const Divider(thickness: 1, color: Colors.grey),
        const SizedBox(height: 8),

        _buildLabelAndFieldWithTooltip(
          label: "Importo ammortizzato",
          tooltip: "Quota già ammortizzata prima dell'importazione",
          child: SizedBox(
            width: 150,
            child: TextField(
              controller: _importoAmmortizzatoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Center(
                    widthFactor: 0.0,
                    child: Text(
                      "€",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              onChanged: (val) => _updateAssetData("importoAmmortizzato", val),
            ),
          ),
        ),
      ],
    );
  }

  // ----------------------------------
  // Helper: Titolo di sezione (con divider e spazio)
  // ----------------------------------
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  // ----------------------------------
  // Helper: label + tooltip + child
  // ----------------------------------
 Widget _buildLabelAndFieldWithTooltip({
  required String label,
  required String tooltip,
  required Widget child,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start, // o .center
    children: [
      SizedBox(
        width: 160,
        // Qui usiamo spaceBetween per separare testo e icona
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Testo (può anche essere in un Expanded se serve)
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                overflow: TextOverflow.ellipsis, // se vuoi tagliare testo lungo
              ),
            ),
            Tooltip(
              message: tooltip,
              child: const Icon(Icons.help_outline, size: 16),
            ),
          ],
        ),
      ),
      // Campo di input
      Expanded(child: child),
    ],
  );
}
    }

// -----------------------------------------------------------------------
// Esempio di CustomDropdown con overlay (ricerca, hover, ecc.)
// -----------------------------------------------------------------------
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
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    List<String> localFilteredItems = List.from(widget.items);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateOverlay) {
            return Stack(
              children: [
                // Cattura il tap all’esterno
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
    // Focalizza subito il campo di ricerca
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
  }) {
    Color backgroundColor = Colors.white;
    return StatefulBuilder(
      builder: (context, setStateItem) {
        return MouseRegion(
          onEnter: (_) => setStateItem(() => backgroundColor = Colors.grey[200]!),
          onExit: (_) => setStateItem(() => backgroundColor = Colors.white),
          child: InkWell(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: backgroundColor,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
              // Valore selezionato
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
              const Icon(Icons.arrow_drop_down, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }
}
