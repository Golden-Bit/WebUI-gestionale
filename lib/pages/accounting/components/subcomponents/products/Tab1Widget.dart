import 'package:flutter/material.dart';
import 'dart:math' as math;

// Costanti per i dropdown e le opzioni radio
const List<String> productTypeOptions = [
  "Beni",
  "Servizio",
  "Combo",
];

const List<String> saleTaxOptions = [
  "Nessuna imposta",
  "IVA 4%",
  "IVA 10%",
  "IVA 22%",
];

const List<String> purchaseTaxOptions = [
  "Nessuna imposta",
  "IVA 4%",
  "IVA 10%",
  "IVA 22%",
];

const List<String> categoryOptions = [
  "Nessuna categoria",
  "Categoria 1",
  "Categoria 2",
  "Categoria 3",
];

/// Opzioni di esempio per la selezione singola di "Scelte combo".
const List<String> comboChoiceOptions = [
  "Nessuna selezione",
  "Antipasto - Piatto - Dolce",
  "Menù Fisso",
  "Menù Degustazione",
  "Menù Kids",
];

/// Widget che gestisce le tre tipologie di prodotto:
/// - Beni
/// - Servizio
/// - Combo
///
/// Se "Combo", in colonna sinistra appare un CustomDropdown "Scelte combo"
/// e sotto il testo descrittivo. In colonna destra solo:
///   - Prezzo di vendita
///   - Categoria
///   - Riferimento
/// Se "Servizio" nascondiamo "Codice a barre".
/// Altrimenti (Beni) mostriamo tutti i campi.
class ProductDetailsWidget extends StatefulWidget {
  /// Mappa contenente i valori del prodotto:
  /// - productType (string: Beni / Servizio / Combo)
  /// - salePrice (string)
  /// - saleTax (lista di stringhe, p.es. ["IVA 22%"])
  /// - cost (string)
  /// - purchaseTax (lista di stringhe, p.es. ["Nessuna imposta"])
  /// - category (string)
  /// - reference (string)
  /// - barcode (string)
  /// - internalNote (string)
  /// - comboChoices (string) [per la selezione singola]
  final Map<String, dynamic> productInfo;

  /// Callback invocata a ogni modifica di un campo
  final ValueChanged<Map<String, dynamic>> onProductInfoChanged;

  const ProductDetailsWidget({
    Key? key,
    required this.productInfo,
    required this.onProductInfoChanged,
  }) : super(key: key);

  @override
  _ProductDetailsWidgetState createState() => _ProductDetailsWidgetState();
}

class _ProductDetailsWidgetState extends State<ProductDetailsWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Controller persistenti
  late TextEditingController salePriceController;
  late TextEditingController costController;
  late TextEditingController referenceController;
  late TextEditingController barcodeController;
  late TextEditingController internalNoteController;

  @override
  void initState() {
    super.initState();
    final info = widget.productInfo;

    salePriceController =
        TextEditingController(text: info["salePrice"] ?? "1.00");
    costController = TextEditingController(text: info["cost"] ?? "0.00");
    referenceController = TextEditingController(text: info["reference"] ?? "");
    barcodeController = TextEditingController(text: info["barcode"] ?? "");
    internalNoteController = TextEditingController(
      text: info["internalNote"] ?? "Questa nota è solo per uso interno.",
    );
  }

  @override
  void didUpdateWidget(covariant ProductDetailsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final info = widget.productInfo;

    _syncControllerText(salePriceController, info["salePrice"] ?? "1.00");
    _syncControllerText(costController, info["cost"] ?? "0.00");
    _syncControllerText(referenceController, info["reference"] ?? "");
    _syncControllerText(
      barcodeController,
      info["barcode"] ?? "",
    );
    _syncControllerText(
      internalNoteController,
      info["internalNote"] ?? "Questa nota è solo per uso interno.",
    );
  }

  void _syncControllerText(TextEditingController ctrl, String newValue) {
    if (ctrl.text != newValue) {
      final oldSelection = ctrl.selection;
      ctrl.text = newValue;
      ctrl.selection = oldSelection;
    }
  }

  @override
  void dispose() {
    salePriceController.dispose();
    costController.dispose();
    referenceController.dispose();
    barcodeController.dispose();
    internalNoteController.dispose();
    super.dispose();
  }

  /// Aggiorna un campo nella mappa e invoca callback
  void _updateField(String key, dynamic value) {
    final newInfo = Map<String, dynamic>.from(widget.productInfo);
    newInfo[key] = value;
    widget.onProductInfoChanged(newInfo);
  }

  /// Gruppo radio "Tipologia prodotto"
  Widget _buildProductTypeRadioGroup(String currentValue) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: productTypeOptions.map((option) {
        return Tooltip(
          message: "Seleziona '$option' come tipologia",
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio<String>(
                value: option,
                groupValue: currentValue,
                onChanged: (val) {
                  if (val != null) {
                    _updateField("productType", val);
                  }
                },
              ),
              Text(option),
              const SizedBox(width: 16),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final info = widget.productInfo;
    final String productType = info["productType"] ?? "Beni";

    // Imposte vendite e acquisto come liste di stringhe (multi-selezione)
    final List<String> saleTaxSelected = info["saleTax"] is List<String>
        ? List<String>.from(info["saleTax"])
        : ["IVA 22%"];
    final List<String> purchaseTaxSelected = info["purchaseTax"] is List<String>
        ? List<String>.from(info["purchaseTax"])
        : ["Nessuna imposta"];

    final String category = info["category"] ?? "Nessuna categoria";
    final String comboChoice = info["comboChoices"] ?? "Nessuna selezione";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Riga con label "Tipologia prodotto:" + radio
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Tipologia prodotto:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(width: 8),
              _buildProductTypeRadioGroup(productType),
            ],
          ),
          const SizedBox(height: 24),

          // Row a due colonne: a sinistra eventuale "Scelte combo", a destra i campi
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colonna di sinistra
              Expanded(
                flex: 1,
                child: (productType == "Combo")
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Scelte combo",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          // CustomDropdown per scelte combo
                          CustomDropdown(
                            items: comboChoiceOptions,
                            value: comboChoice,
                            onChanged: (newVal) =>
                                _updateField("comboChoices", newVal),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Le combo consentono di scegliere un prodotto da una vasta selezione,\nper ogni categoria.",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      )
                    : Container(), // se non Combo, vuoto
              ),

              const SizedBox(width: 24),

              // Colonna di destra
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildRightColumn(
                    productType,
                    saleTaxSelected,
                    purchaseTaxSelected,
                    category,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // NOTE INTERNE (in basso, a tutta larghezza)
          const Text(
            "NOTE INTERNE",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Divider(),
          const SizedBox(height: 4),
          TextField(
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            controller: internalNoteController,
            onChanged: (val) => _updateField("internalNote", val),
          ),
        ],
      ),
    );
  }

  /// Costruisce i campi della colonna di destra in base al tipo di prodotto
  List<Widget> _buildRightColumn(
    String productType,
    List<String> saleTaxSelected,
    List<String> purchaseTaxSelected,
    String category,
  ) {
    // Se "Combo", mostriamo solo:
    // - Prezzo di vendita
    // - Categoria
    // - Riferimento
    if (productType == "Combo") {
      return [
        _buildLabelRow(
          label: "Prezzo di vendita",
          tooltip: "Prezzo unitario di vendita (in €)",
          child: TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(border: OutlineInputBorder()),
            controller: salePriceController,
            onChanged: (val) => _updateField("salePrice", val),
          ),
        ),
        const SizedBox(height: 16),
        _buildLabelRow(
          label: "Categoria",
          tooltip: "Categoria del prodotto/combo",
          child: CustomDropdown(
            items: categoryOptions,
            value: category,
            onChanged: (val) => _updateField("category", val),
          ),
        ),
        const SizedBox(height: 16),
        _buildLabelRow(
          label: "Riferimento",
          tooltip: "Codice interno o riferimento extra",
          child: TextField(
            decoration: const InputDecoration(border: OutlineInputBorder()),
            controller: referenceController,
            onChanged: (val) => _updateField("reference", val),
          ),
        ),
      ];
    }

    // Altrimenti (Beni o Servizio):
    // Mostriamo i campi, con "Servizio" che nasconde "Codice a barre".
    final bool isServizio = (productType == "Servizio");

    return [
      // Prezzo di vendita
      _buildLabelRow(
        label: "Prezzo di vendita",
        tooltip: "Prezzo unitario di vendita (in €)",
        child: TextField(
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(border: OutlineInputBorder()),
          controller: salePriceController,
          onChanged: (val) => _updateField("salePrice", val),
        ),
      ),
      const SizedBox(height: 16),

      // Imposte vendite (multi-selezione)
      _buildLabelRow(
        label: "Imposte vendite",
        tooltip: "Seleziona le aliquote per la vendita",
        child: CustomChipsDropdown(
          allItems: saleTaxOptions,
          selectedItems: saleTaxSelected,
          onChanged: (newValues) => _updateField("saleTax", newValues),
        ),
      ),
      const SizedBox(height: 24),

      // Costo
      _buildLabelRow(
        label: "Costo",
        tooltip: "Costo unitario di acquisto (in €)",
        child: TextField(
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(border: OutlineInputBorder()),
          controller: costController,
          onChanged: (val) => _updateField("cost", val),
        ),
      ),
      const SizedBox(height: 16),

if (productType != "Servizio" && (widget.productInfo["showPurchaseTax"] ?? true)) ...[
  // Mostra il campo "Imposte d'acquisto"
  _buildLabelRow(
    label: "Imposte d'acquisto",
    tooltip: "Seleziona le aliquote per l'acquisto",
    child: CustomChipsDropdown(
      allItems: purchaseTaxOptions,
      selectedItems: purchaseTaxSelected,
      onChanged: (newValues) => _updateField("purchaseTax", newValues),
    ),
  ),
  const SizedBox(height: 24),
],

      // Categoria
      _buildLabelRow(
        label: "Categoria",
        tooltip: "Categoria del prodotto",
        child: CustomDropdown(
          items: categoryOptions,
          value: category,
          onChanged: (val) => _updateField("category", val),
        ),
      ),
      const SizedBox(height: 16),

      // Riferimento
      _buildLabelRow(
        label: "Riferimento",
        tooltip: "Codice interno o riferimento extra",
        child: TextField(
          decoration: const InputDecoration(border: OutlineInputBorder()),
          controller: referenceController,
          onChanged: (val) => _updateField("reference", val),
        ),
      ),
      const SizedBox(height: 16),

      // Codice a barre (solo se NON Servizio)
      if (!isServizio) ...[
        _buildLabelRow(
          label: "Codice a barre",
          tooltip: "Inserisci il codice a barre (EAN, UPC, etc.)",
          child: TextField(
            decoration: const InputDecoration(border: OutlineInputBorder()),
            controller: barcodeController,
            onChanged: (val) => _updateField("barcode", val),
          ),
        ),
        const SizedBox(height: 24),
      ],
    ];
  }

  /// Riga label + widget a destra
  Widget _buildLabelRow({
    required String label,
    required String tooltip,
    required Widget child,
    double labelWidth = 160,
    double spacing = 16,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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
                    style: const TextStyle(fontSize: 14),
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

/// Widget per selezione multipla di aliquote, in stile "chips".
/// Viene riusato per "Imposte vendite" e "Imposte acquisto".
class CustomChipsDropdown extends StatefulWidget {
  final List<String> allItems;
  final List<String> selectedItems;
  final ValueChanged<List<String>> onChanged;

  const CustomChipsDropdown({
    Key? key,
    required this.allItems,
    required this.selectedItems,
    required this.onChanged,
  }) : super(key: key);

  @override
  _CustomChipsDropdownState createState() => _CustomChipsDropdownState();
}

class _CustomChipsDropdownState extends State<CustomChipsDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _chipsScrollController = ScrollController();

  bool _hoveringChips = false;
  bool _dragging = false;

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      _showDropdown();
    }
  }

  void _showDropdown() {
    if (_overlayEntry != null) return;
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    List<String> localFilteredItems = List.from(widget.allItems);

    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (ctx, setStateOverlay) {
            void _filterItems(String query) {
              query = query.toLowerCase();
              localFilteredItems = widget.allItems
                  .where((item) => item.toLowerCase().contains(query))
                  .toList();
              setStateOverlay(() {});
            }

            return Stack(
              children: [
                GestureDetector(
                  onTap: _closeDropdown,
                  behavior: HitTestBehavior.opaque,
                  child: Container(color: Colors.transparent),
                ),
                Positioned(
                  width: renderBox.size.width * 0.6,
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
                                onChanged: _filterItems,
                              ),
                            ),
                            Expanded(
                              child: ListView(
                                shrinkWrap: true,
                                children: localFilteredItems.map((item) {
                                  final isSelected =
                                      widget.selectedItems.contains(item);
                                  return _buildHoverableListTile(
                                    title: item,
                                    isSelected: isSelected,
                                    onTap: () {
                                      if (!isSelected) {
                                        final newList = [
                                          ...widget.selectedItems,
                                          item
                                        ];
                                        widget.onChanged(newList);
                                      }
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
    setState(() => _isDropdownOpen = true);

    Future.delayed(Duration.zero, () {
      _searchFocusNode.requestFocus();
    });
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isDropdownOpen = false);
  }

  Widget _buildHoverableListTile({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    double horizontalPadding = 8.0,
    double verticalPadding = 6.0,
  }) {
    Color backgroundColor = isSelected ? Colors.grey[300]! : Colors.white;
    return StatefulBuilder(
      builder: (context, setStateItem) {
        return MouseRegion(
          onEnter: (_) {
            if (!isSelected) {
              setStateItem(() {
                backgroundColor = Colors.grey[200]!;
              });
            }
          },
          onExit: (_) {
            setStateItem(() {
              backgroundColor = isSelected ? Colors.grey[300]! : Colors.white;
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
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check, color: Colors.green, size: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedItems = widget.selectedItems;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
        ),
        constraints: const BoxConstraints(minHeight: 40),
        child: Row(
          children: [
            Expanded(
              child: MouseRegion(
                cursor: selectedItems.isNotEmpty
                    ? (_dragging
                        ? SystemMouseCursors.grabbing
                        : _hoveringChips
                            ? SystemMouseCursors.grab
                            : SystemMouseCursors.basic)
                    : SystemMouseCursors.click,
                onEnter: (_) => setState(() => _hoveringChips = true),
                onExit: (_) => setState(() => _hoveringChips = false),
                child: GestureDetector(
                  onTap: selectedItems.isEmpty ? _toggleDropdown : null,
                  onPanStart: selectedItems.isNotEmpty
                      ? (_) => setState(() => _dragging = true)
                      : null,
                  onPanUpdate: selectedItems.isNotEmpty
                      ? (details) {
                          if (_chipsScrollController.hasClients) {
                            final currentOffset =
                                _chipsScrollController.offset;
                            final newOffset = currentOffset - details.delta.dx;
                            final maxScroll = _chipsScrollController
                                .position.maxScrollExtent;
                            final clampedOffset = math.max(
                                0.0, math.min(newOffset, maxScroll));
                            _chipsScrollController.jumpTo(clampedOffset);
                          }
                        }
                      : null,
                  onPanEnd: selectedItems.isNotEmpty
                      ? (_) => setState(() => _dragging = false)
                      : null,
                  child: SingleChildScrollView(
                    controller: _chipsScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (selectedItems.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text(
                              "Seleziona...",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        else
                          ...selectedItems.map((val) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: Chip(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                backgroundColor: const Color(0xFFB0A8B9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide.none,
                                ),
                                label: Text(
                                  val,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                                onDeleted: () {
                                  final newList =
                                      List<String>.from(selectedItems);
                                  newList.remove(val);
                                  widget.onChanged(newList);
                                },
                              ),
                            );
                          }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(_isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down),
              onPressed: _toggleDropdown,
            ),
          ],
        ),
      ),
    );
  }
}

/// Dropdown personalizzato a selezione singola
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
                                  final lowerQuery = query.toLowerCase();
                                  setStateOverlay(() {
                                    localFilteredItems = widget.items
                                        .where((item) => item
                                            .toLowerCase()
                                            .contains(lowerQuery))
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
    final currentValue = widget.value;

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
                  currentValue,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(_isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}
