import 'package:flutter/material.dart';

/// Widget che rappresenta la tab "Altre informazioni"
/// con 4 campi di tipo dropdown sulla colonna di sinistra
/// e 1 campo di tipo data sulla colonna di destra.
/// Utilizza la mappa [additionalInfo] per conservare i valori.
class AltreInformazioniWidget extends StatefulWidget {
  final Map<String, dynamic> additionalInfo;
  final ValueChanged<Map<String, dynamic>> onAdditionalInfoChanged;

  const AltreInformazioniWidget({
    Key? key,
    required this.additionalInfo,
    required this.onAdditionalInfoChanged,
  }) : super(key: key);

  @override
  _AltreInformazioniWidgetState createState() =>
      _AltreInformazioniWidgetState();
}

class _AltreInformazioniWidgetState extends State<AltreInformazioniWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // preserva lo stato del tab

  // Helper per aggiornare un campo stringa nella mappa
  void _updateStringField(String key, String value) {
    final newInfo = Map<String, dynamic>.from(widget.additionalInfo);
    newInfo[key] = value;
    widget.onAdditionalInfoChanged(newInfo);
  }

  // Helper per aggiornare un campo data (DateTime) nella mappa
  void _updateDateField(String key, DateTime? value) {
    final newInfo = Map<String, dynamic>.from(widget.additionalInfo);
    newInfo[key] = value;
    widget.onAdditionalInfoChanged(newInfo);
  }

  Future<void> _selectSaldoFinoAlDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _updateDateField("saldoFinoAl", picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Alias per leggibilità
    final info = widget.additionalInfo;

    // Valori correnti (stringhe e data)
    final String contoLungoTermine = info["contoLungoTermine"] ?? "";
    final String contoBreveTermine = info["contoBreveTermine"] ?? "";
    final String contoAmmortamento = info["contoAmmortamento"] ?? "";
    final String registro = info["registro"] ?? "";
    final DateTime? saldoFinoAl = info["saldoFinoAl"] as DateTime?;

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -------------------------------------------------
          // COLONNA DI SINISTRA (4 dropdown)
          // -------------------------------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1) Conto lungo termine
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 150,
                      child: Text(
                        "Conto lungo termine",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: "Seleziona il conto utilizzato per le operazioni a lungo termine",
                      child: const Icon(Icons.help_outline, size: 16),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomDropdown(
                        items: const [
                          "Opzione CLT 1",
                          "Opzione CLT 2",
                          "Opzione CLT 3",
                        ],
                        value: contoLungoTermine.isNotEmpty
                            ? contoLungoTermine
                            : "Seleziona...",
                        onChanged: (newVal) =>
                            _updateStringField("contoLungoTermine", newVal),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 2) Conto a breve termine
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 150,
                      child: Text(
                        "Conto a breve termine",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: "Seleziona il conto utilizzato per le operazioni a breve termine",
                      child: const Icon(Icons.help_outline, size: 16),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomDropdown(
                        items: const [
                          "Opzione CBT 1",
                          "Opzione CBT 2",
                          "Opzione CBT 3",
                        ],
                        value: contoBreveTermine.isNotEmpty
                            ? contoBreveTermine
                            : "Seleziona...",
                        onChanged: (newVal) =>
                            _updateStringField("contoBreveTermine", newVal),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 3) Conto di ammortamento
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 150,
                      child: Text(
                        "Conto di ammortamento",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: "Seleziona il conto per la gestione degli ammortamenti",
                      child: const Icon(Icons.help_outline, size: 16),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomDropdown(
                        items: const [
                          "Opzione Amm 1",
                          "Opzione Amm 2",
                          "Opzione Amm 3",
                        ],
                        value: contoAmmortamento.isNotEmpty
                            ? contoAmmortamento
                            : "Seleziona...",
                        onChanged: (newVal) =>
                            _updateStringField("contoAmmortamento", newVal),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 4) Registro
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 150,
                      child: Text(
                        "Registro",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: "Seleziona il registro contabile da associare",
                      child: const Icon(Icons.help_outline, size: 16),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomDropdown(
                        items: const [
                          "Registro 1",
                          "Registro 2",
                          "Registro 3",
                        ],
                        value: registro.isNotEmpty ? registro : "Seleziona...",
                        onChanged: (newVal) =>
                            _updateStringField("registro", newVal),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // -------------------------------------------------
          // COLONNA DI DESTRA (1 campo data)
          // -------------------------------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SALDO FINO AL (data)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text(
                        "Saldo fino al",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: "Imposta la data fino alla quale calcolare il saldo",
                      child: const Icon(Icons.help_outline, size: 16),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectSaldoFinoAlDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            saldoFinoAl != null
                                ? "${saldoFinoAl.day.toString().padLeft(2, '0')}/${saldoFinoAl.month.toString().padLeft(2, '0')}/${saldoFinoAl.year}"
                                : "Seleziona data",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 400)
              ],
            ),
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
                // Schermata trasparente per chiudere il dropdown se si clicca fuori
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
}
