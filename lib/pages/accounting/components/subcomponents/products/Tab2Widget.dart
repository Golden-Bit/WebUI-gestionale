import 'package:flutter/material.dart';

/// Opzioni per il dropdown "Conto di ricavo" (colonna CREDITI)
const List<String> creditAccountOptions = [
  "151010 Crediti verso i clienti",
  "151020 Crediti speciali",
  "151030 Crediti esteri",
];

/// Opzioni per il dropdown "Conto di costo" (colonna DEBITI)
const List<String> debitAccountOptions = [
  "250100 Debiti v/fornitori",
  "250200 Debiti v/fornitori esteri",
  "250300 Debiti speciali",
];

/// Widget che mostra due colonne:
/// - Colonna sinistra: CREDITI
///    * "Conto di ricavo" (CustomDropdown)
/// - Colonna destra: DEBITI
///    * "Conto di costo" (CustomDropdown)
///
/// Usa [accountingData] per memorizzare i valori correnti e [onChanged] per notificarne le modifiche.
class AccountingTabWidget extends StatefulWidget {
  /// Mappa con i campi:
  ///   "creditAccount": string (es. "151010 Crediti verso i clienti")
  ///   "debitAccount":  string (es. "250100 Debiti v/fornitori")
  final Map<String, dynamic> accountingData;

  /// Callback che riceve la nuova mappa aggiornata ogni volta che un campo cambia
  final ValueChanged<Map<String, dynamic>> onChanged;

  const AccountingTabWidget({
    Key? key,
    required this.accountingData,
    required this.onChanged,
  }) : super(key: key);

  @override
  _AccountingTabWidgetState createState() => _AccountingTabWidgetState();
}

class _AccountingTabWidgetState extends State<AccountingTabWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  /// Helper per aggiornare un campo stringa nella mappa e chiamare il callback
  void _updateStringField(String key, String value) {
    final newData = Map<String, dynamic>.from(widget.accountingData);
    newData[key] = value;
    widget.onChanged(newData);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Leggiamo i valori correnti dalla mappa
    final data = widget.accountingData;
    final String selectedCreditAccount =
        data["creditAccount"] ?? creditAccountOptions.first;
    final String selectedDebitAccount =
        data["debitAccount"] ?? debitAccountOptions.first;

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------------------------------------------------
          // COLONNA DI SINISTRA: CREDITI
          // ---------------------------------------------------------
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titolo "CREDITI"
                const Text(
                  "CREDITI",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Divider(),
                const SizedBox(height: 8),

                // Campo "Conto di ricavo"
                buildLabelRow(
                  label: "Conto di ricavo",
                  tooltip: "Scegli il conto di ricavo",
                  child: CustomDropdown(
                    items: creditAccountOptions,
                    value: selectedCreditAccount,
                    onChanged: (val) => _updateStringField("creditAccount", val),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 40),

          // ---------------------------------------------------------
          // COLONNA DI DESTRA: DEBITI
          // ---------------------------------------------------------
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titolo "DEBITI"
                const Text(
                  "DEBITI",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Divider(),
                const SizedBox(height: 8),

                // Campo "Conto di costo"
                buildLabelRow(
                  label: "Conto di costo",
                  tooltip: "Scegli il conto di costo",
                  child: CustomDropdown(
                    items: debitAccountOptions,
                    value: selectedDebitAccount,
                    onChanged: (val) => _updateStringField("debitAccount", val),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper per costruire una riga con label e tooltip a sinistra,
  /// e un widget di input (o dropdown) a destra.
  /// Qui aggiungiamo un po' di padding verticale per separare i campi.
  Widget buildLabelRow({
    required String label,
    required String tooltip,
    required Widget child,
    double labelWidth = 140,
    double spacing = 16,
  }) {
    return Padding(
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

/// Esempio di CustomDropdown (già definito in precedenza).
/// Singola selezione con un campo di ricerca, come da screenshot e specifiche.
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

  /// Funzione che alterna l'apertura/chiusura del dropdown
  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      _showDropdown();
    }
  }

  /// Mostra l'Overlay con la lista di opzioni filtrabili
  void _showDropdown() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

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
                  width: renderBox.size.width * 0.5, // Larghezza dropdown
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
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                            // Lista delle opzioni filtrate
                            Expanded(
                              child: ListView(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                children: localFilteredItems.map((item) {
                                  return _buildHoverableListTile(
                                    title: item,
                                    onTap: () {
                                      // Aggiorniamo il valore selezionato e chiudiamo
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

    // Inseriamo l'Overlay nella gerarchia
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isDropdownOpen = true;
    });

    // Mettiamo subito il focus sul campo di ricerca
    Future.delayed(Duration.zero, () {
      _searchFocusNode.requestFocus();
    });
  }

  /// Chiude il dropdown
  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isDropdownOpen = false;
    });
  }

  /// Costruisce una ListTile "hoverable" per la lista delle opzioni
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
                color: backgroundColor,
                borderRadius: BorderRadius.circular(4.0),
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
      onTap: _toggleDropdown, // Apertura/chiusura al tap
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
              // Testo con valore corrente
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
              // Icona freccia
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}
