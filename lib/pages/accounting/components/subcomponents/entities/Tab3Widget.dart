import 'package:flutter/material.dart';
//import 'package:flutter_app/pages/accounting/components/entities/entities_editor.dart';

// Esempi di costanti (dropdown) per la colonna di sinistra (Generale e Fatture cliente)
const List<String> banksOptions = [
  "Seleziona banca",
  "Banca A",
  "Banca B",
  "Banca C",
];
const List<String> creditAccountOptions = [
  "151010 Crediti verso i clienti",
  "151020 Crediti speciali",
  "151030 Crediti esteri",
];
const List<String> debitAccountOptions = [
  "250100 Debiti v/fornitori",
  "250200 Debiti v/fornitori esteri",
];
const List<String> autoInvoiceRegOptions = [
  "Dopo 3 condiz. senza modifiche",
  "Sempre manuale",
  "Automatica immediata",
];
const List<String> eInvoicingOptions = [
  "Fatturazione elettronica e e-mail",
  "Solo e-mail",
  "Solo elettronica",
  "Nessuna notifica",
];

// Per la colonna di destra (Follow-up fattura)
const List<String> responsibleOptions = [
  "Mario Rossi",
  "Luigi Bianchi",
  "Nessun responsabile",
];

/// Widget che mostra la UI “Contabilità” come da figura:
/// - Colonna sinistra con:
///   * GENERALE (4 dropdown)
///   * FATTURE CLIENTE (1 dropdown)
/// - Colonna destra con FOLLOW-UP FATTURA:
///   * Stato sollecito (read-only)
///   * Promemoria (radio + bottone “Invia”)
///   * Prossimo promemoria (data)
///   * Responsabile (custom dropdown)
///
/// Usa [accountingData] per mantenere i valori e [onChanged] per notificarne le modifiche.
class AccountingTabWidget extends StatefulWidget {
  final Map<String, dynamic> accountingData;
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

  /// Helper per aggiornare un campo stringa nella mappa
  void _updateStringField(String key, String value) {
    final newData = Map<String, dynamic>.from(widget.accountingData);
    newData[key] = value;
    widget.onChanged(newData);
  }

  /// Helper per aggiornare la data
  Future<void> _pickDate(BuildContext context, String key) async {
    final currentValue = widget.accountingData[key] as DateTime?;
    final picked = await showDatePicker(
      context: context,
      initialDate: currentValue ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final newData = Map<String, dynamic>.from(widget.accountingData);
      newData[key] = picked;
      widget.onChanged(newData);
    }
  }

  /// Helper per aggiornare un campo bool (ad es. radio “Automatico” vs “Manuale”)
  void _updateReminderMode(bool isAutomatic) {
    final newData = Map<String, dynamic>.from(widget.accountingData);
    newData["reminderMode"] = isAutomatic ? "Automatico" : "Manuale";
    widget.onChanged(newData);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final data = widget.accountingData;

    // Leggiamo i valori correnti
    final String selectedBank = data["bank"] ?? banksOptions.first;
    final String selectedCreditAccount =
        data["creditAccount"] ?? creditAccountOptions.first;
    final String selectedDebitAccount =
        data["debitAccount"] ?? debitAccountOptions.first;
    final String selectedAutoInvoiceReg =
        data["autoInvoiceReg"] ?? autoInvoiceRegOptions.first;

    final String selectedEInvoicing =
        data["eInvoicing"] ?? eInvoicingOptions.first;

    final String reminderState =
        data["reminderState"] ?? "Nessuna azione richiesta";
    final String reminderMode =
        data["reminderMode"] ?? "Automatico"; // “Automatico” o “Manuale”
    final DateTime? nextReminderDate = data["nextReminderDate"] as DateTime?;
    final String selectedResponsible =
        data["responsible"] ?? responsibleOptions.first;

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // allineamento centrale
        children: [
          // ---------------------------------------------------------
          // COLONNA DI SINISTRA
          // ---------------------------------------------------------
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // centrato verticalmente
              children: [
                // Sezione GENERALE
                const Text(
                  "GENERALE",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Divider(),
                const SizedBox(height: 8),

                // Banche
                buildLabelRow(
                  label: "Banche",
                  tooltip: "Seleziona la banca principale",
                  child: CustomDropdown(
                    items: banksOptions,
                    value: selectedBank,
                    onChanged: (val) => _updateStringField("bank", val),
                  ),
                ),
                const SizedBox(height: 16),

                // Conto di credito
                buildLabelRow(
                  label: "Conto di credito",
                  tooltip: "Conto per i crediti verso i clienti",
                  child: CustomDropdown(
                    items: creditAccountOptions,
                    value: selectedCreditAccount,
                    onChanged: (val) =>
                        _updateStringField("creditAccount", val),
                  ),
                ),
                const SizedBox(height: 16),

                // Conto di debito
                buildLabelRow(
                  label: "Conto di debito",
                  tooltip: "Conto per i debiti verso i fornitori",
                  child: CustomDropdown(
                    items: debitAccountOptions,
                    value: selectedDebitAccount,
                    onChanged: (val) =>
                        _updateStringField("debitAccount", val),
                  ),
                ),
                const SizedBox(height: 16),

                // Registrazione automatica fattura?
                buildLabelRow(
                  label: "Registr. autom. fattura?",
                  tooltip: "Definisce se e quando registrare automaticamente la fattura",
                  child: CustomDropdown(
                    items: autoInvoiceRegOptions,
                    value: selectedAutoInvoiceReg,
                    onChanged: (val) => _updateStringField("autoInvoiceReg", val),
                  ),
                ),
                const SizedBox(height: 32),

                // Sezione FATTURE CLIENTE
                const Text(
                  "FATTURE CLIENTE",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Divider(),
                const SizedBox(height: 8),

                // Fatturazione elettronica e e-mail
                buildLabelRow(
                  label: "Fatture cliente",
                  tooltip: "Impostazioni di fatturazione elettronica e/o email",
                  child: CustomDropdown(
                    items: eInvoicingOptions,
                    value: selectedEInvoicing,
                    onChanged: (val) => _updateStringField("eInvoicing", val),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 40),

          // ---------------------------------------------------------
          // COLONNA DI DESTRA: FOLLOW-UP FATTURA
          // ---------------------------------------------------------
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titolo
                const Text(
                  "FOLLOW-UP FATTURA",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Divider(),
                const SizedBox(height: 8),

                // Stato sollecito (read-only)
                buildLabelRow(
                  label: "Stato sollecito",
                  tooltip: "Stato attuale del sollecito",
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(reminderState),
                  ),
                ),
                const SizedBox(height: 16),

                // Promemoria (radio group + bottone “Invia”)
                buildLabelRow(
                  label: "Promemoria",
                  tooltip: "Modalità di invio promemoria di sollecito",
                  child: Row(
                    children: [
                      // Radio “Automatico”
                      Row(
                        children: [
                          Radio<String>(
                            value: "Automatico",
                            groupValue: reminderMode,
                            onChanged: (val) {
                              if (val != null) {
                                _updateReminderMode(true);
                              }
                            },
                          ),
                          const Text("Automatico"),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Radio “Manuale”
                      Row(
                        children: [
                          Radio<String>(
                            value: "Manuale",
                            groupValue: reminderMode,
                            onChanged: (val) {
                              if (val != null) {
                                _updateReminderMode(false);
                              }
                            },
                          ),
                          const Text("Manuale"),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Bottone “Invia”
                      TextButton(
                        onPressed: () {
                          debugPrint("Invio promemoria...");
                          // Logica per inviare il promemoria
                        },
                        child: const Text("Invia"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Prossimo promemoria (campo data)
                buildLabelRow(
                  label: "Prossimo promemoria",
                  tooltip: "Data prevista per il prossimo promemoria",
                  child: InkWell(
                    onTap: () => _pickDate(context, "nextReminderDate"),
                    child: Container(
                      height: 45,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        (nextReminderDate != null)
                            ? "${nextReminderDate.day.toString().padLeft(2, '0')}/"
                              "${nextReminderDate.month.toString().padLeft(2, '0')}/"
                              "${nextReminderDate.year}"
                            : "Seleziona data",
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Responsabile (custom dropdown)
                buildLabelRow(
                  label: "Responsabile",
                  tooltip: "Utente responsabile del follow-up",
                  child: CustomDropdown(
                    items: responsibleOptions,
                    value: selectedResponsible,
                    onChanged: (val) => _updateStringField("responsible", val),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper per costruire una riga con label (in verde) a sinistra e campo di input a destra,
  /// con padding verticale per separare i campi e con allineamento centrale.
  Widget buildLabelRow({
    required String label,
    required String tooltip,
    required Widget child,
    double labelWidth = 140,
    double spacing = 16,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // padding verticale aggiunto
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // allineamento centrale
        children: [
          Container(
            width: labelWidth,
            margin: EdgeInsets.only(right: spacing),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center, // allinea label e tooltip al centro
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
          onEnter: (_) => setStateItem(() => backgroundColor = Colors.grey[200]!),
          onExit: (_) => setStateItem(() => backgroundColor = Colors.white),
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
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
