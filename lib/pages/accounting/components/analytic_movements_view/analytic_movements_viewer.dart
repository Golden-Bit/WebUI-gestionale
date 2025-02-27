import 'package:flutter/material.dart';
import 'package:flutter_app/pages/accounting/components/subcomponents/analytic_movements/analytic_movements_actions_bar.dart';

// Esempio di struttura dati per i movimenti contabili
class AccountingMovement {
  final String name;             // Nome del movimento (es. "Registrazione in bozza")
  final String financialAccount; // Conto finanziario associato (es. "110100 Costi di impianto")

  AccountingMovement({
    required this.name,
    required this.financialAccount,
  });
}

/// Widget principale che mostra l'editor "AnalyticMovementsEditor"
/// in layout 2/3 (sinistra) + 1/3 (destra, vuoto).
class AnalyticMovementsPage extends StatefulWidget {
  const AnalyticMovementsPage({Key? key}) : super(key: key);

  @override
  State<AnalyticMovementsPage> createState() => _AnalyticMovementsPageState();
}

class _AnalyticMovementsPageState extends State<AnalyticMovementsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // 2/3 editor a sinistra
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Action bar sopra il riquadro
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: MovementActionsBar(
                    onConfirm: () => debugPrint("Conferma cliccato"),
                    onCancel: () => debugPrint("Annulla cliccato"),
                  ),
                ),

                // Riquadro con bordo contenente l'editor
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const AnalyticMovementsEditor(),
                  ),
                ),
              ],
            ),
          ),

          // 1/3 vuoto a destra
          Expanded(
            flex: 1,
            child: Container(color: Colors.transparent),
          ),
        ],
      ),
    );
  }
}

/// Widget che riproduce i campi dell’interfaccia Odoo:
/// - ELEMENTO ANALITICO (Descrizione, Progetto, Data)
/// - IMPORTO (Importo, Riferimento, Partner, Quantità, Prodotto, Unità)
/// - CONTABILITÀ (Movimento contabile, Conto finanziario)
class AnalyticMovementsEditor extends StatefulWidget {
  const AnalyticMovementsEditor({Key? key}) : super(key: key);

  @override
  State<AnalyticMovementsEditor> createState() => _AnalyticMovementsEditorState();
}

class _AnalyticMovementsEditorState extends State<AnalyticMovementsEditor> {
  // -----------------------------
  // ELEMENTO ANALITICO
  // -----------------------------
  final TextEditingController _descrizioneController = TextEditingController();
  String _selectedProgetto = "Progetto A";
  DateTime? _selectedDate;

  // -----------------------------
  // IMPORTO
  // -----------------------------
  final TextEditingController _importoController = TextEditingController(text: "0.00");
  final TextEditingController _riferimentoController = TextEditingController();
  String _selectedPartner = "Partner 1";
  final TextEditingController _quantitaController = TextEditingController(text: "0.00");
  String _selectedProdotto = "Prodotto 1";
  String _selectedUnita = "m"; // default

  // -----------------------------
  // CONTABILITÀ
  // -----------------------------
  // Lista simulata di movimenti contabili -> conto finanziario
  final List<AccountingMovement> _accountingMovements = [
    AccountingMovement(name: "Registrazione in bozza", financialAccount: "110100 Costi di impianto"),
    AccountingMovement(name: "Registrazione confermata", financialAccount: "110200 Spese generali"),
    AccountingMovement(name: "Registrazione chiusa", financialAccount: "110300 Manutenzioni"),
  ];

  // Movimento contabile selezionato
  AccountingMovement? _selectedMovement;

  @override
  void initState() {
    super.initState();
    // Selezioniamo di default il primo della lista
    _selectedMovement = _accountingMovements.first;
  }

  @override
  void dispose() {
    _descrizioneController.dispose();
    _importoController.dispose();
    _riferimentoController.dispose();
    _quantitaController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Qui usiamo SingleChildScrollView per permettere lo scroll verticale
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -----------------------------------
          // COLONNA SINISTRA: ELEMENTO ANALITICO
          // -----------------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("ELEMENTO ANALITICO"),
                const SizedBox(height: 8),

                // Descrizione
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 100, child: _buildLabel("Descrizione")),
                    Expanded(
                      child: TextField(
                        controller: _descrizioneController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Progetto
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 100, child: _buildLabel("Progetto")),
                    Expanded(
                      child: CustomDropdown(
                        items: const [
                          "Progetto A",
                          "Progetto B",
                          "Progetto C",
                          "Progetto Interno",
                        ],
                        value: _selectedProgetto,
                        onChanged: (val) {
                          setState(() {
                            _selectedProgetto = val;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Data
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 100, child: _buildLabel("Data")),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context),
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          child: Text(
                            _selectedDate != null
                                ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                                : "Seleziona data",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 32),

          // -------------------------
          // COLONNA DESTRA
          // -------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IMPORTO
                _buildSectionTitle("IMPORTO"),
                const SizedBox(height: 8),

                // Importo
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 70, child: _buildLabel("Importo")),
                    Expanded(
                      child: TextField(
                        controller: _importoController,
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
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Riferimento
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 70, child: _buildLabel("Rif.")),
                    Expanded(
                      child: TextField(
                        controller: _riferimentoController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Partner
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 70, child: _buildLabel("Partner")),
                    Expanded(
                      child: CustomDropdown(
                        items: const ["Partner 1", "Partner 2", "Partner 3", "Altri..."],
                        value: _selectedPartner,
                        onChanged: (val) {
                          setState(() {
                            _selectedPartner = val;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Quantità
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 70, child: _buildLabel("Quantità")),
                    Expanded(
                      child: TextField(
                        controller: _quantitaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Prodotto
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 70, child: _buildLabel("Prodotto")),
                    Expanded(
                      child: CustomDropdown(
                        items: const ["Prodotto 1", "Prodotto 2", "Prodotto 3"],
                        value: _selectedProdotto,
                        onChanged: (val) {
                          setState(() {
                            _selectedProdotto = val;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Unità
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 70, child: _buildLabel("Unità")),
                    Expanded(
                      child: CustomDropdown(
                        items: const [
                          "m",
                          "kg",
                          "Ton",
                          "L",
                          "Ore",
                          "Unità",
                          "Pack of 6",
                          "Giorni",
                        ],
                        value: _selectedUnita,
                        onChanged: (val) {
                          setState(() {
                            _selectedUnita = val;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // CONTABILITÀ (sotto la parte di importo)
                _buildSectionTitle("CONTABILITÀ"),
                const SizedBox(height: 8),

                // Movimento contabile
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 120, child: _buildLabel("Mov. contabile")),
                    Expanded(
                      child: CustomDropdown(
                        items: _accountingMovements.map((e) => e.name).toList(),
                        value: _selectedMovement?.name ?? "",
                        onChanged: (val) {
                          setState(() {
                            _selectedMovement =
                                _accountingMovements.firstWhere((m) => m.name == val);
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Conto finanziario (in sola lettura)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 120, child: _buildLabel("Conto finanz.")),
                    Expanded(
                      child: Container(
                        height: 45,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _selectedMovement?.financialAccount ?? "-",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Crea un titolo di sezione (es. "ELEMENTO ANALITICO") + una riga orizzontale sotto
  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const Divider(thickness: 1, color: Colors.grey),
      ],
    );
  }

  /// Utility per una label con stile simile a Odoo
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}

// -----------------------------------------------------------------------
// CustomDropdown (stessa implementazione con Overlay per la ricerca, etc.)
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
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    // Copia locale degli items
    List<String> localFilteredItems = List.from(widget.items);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateOverlay) {
            return Stack(
              children: [
                // Cattura il tap all’esterno per chiudere
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
                                        .where(
                                          (item) => item.toLowerCase().contains(
                                                query.toLowerCase(),
                                              ),
                                        )
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

    // Focalizza immediatamente il campo di ricerca
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
