import 'package:flutter/material.dart';
import 'dart:math' as math;

// Esempio di opzioni per "Filtro analitico" (multi-selezione)
const List<String> analiticoOptions = [
  "PROJ 1",
  "PROJ 2",
  "PROJ 3",
  "Analisi A",
  "Analisi B",
];

// Esempio di opzioni per "Filtro partner" (multi-selezione)
const List<String> partnerOptions = [
  "simone sansalone",
  "gold solar",
  "cliente generico",
  "fornitore generico",
];

// Esempio di opzioni per "Conto di destinazione" (multi-selezione)
const List<String> contoDestOptions = [
  "110100 Costi di impianto",
  "110600 Software",
  "110800 Avviamento",
  "120500 Macchine d'ufficio",
];

/// -------------------------------
/// CUSTOM DROPDOWN (SELEZIONE SINGOLA)
/// -------------------------------
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
    if (_overlayEntry != null) return;
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    List<String> localFilteredItems = List.from(widget.items);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return StatefulBuilder(
          builder: (ctx, setStateOverlay) {
            void _filterItems(String query) {
              query = query.toLowerCase();
              localFilteredItems = widget.items
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
                                  prefixIcon: Icon(Icons.search),
                                  hintText: 'Cerca...',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                ),
                                onChanged: _filterItems,
                              ),
                            ),
                            Expanded(
                              child: ListView(
                                shrinkWrap: true,
                                children: localFilteredItems.map((item) {
                                  return ListTile(
                                    title: Text(item),
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleDropdown,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Container(
          height: 45,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
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

/// -------------------------------
/// CUSTOM CHIPS DROPDOWN (MULTI-SELEZIONE)
/// -------------------------------
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
                                      horizontal: 8, vertical: 4),
                                ),
                                onChanged: _filterItems,
                              ),
                            ),
                            Expanded(
                              child: ListView(
                                shrinkWrap: true,
                                children: localFilteredItems.map((item) {
                                  final alreadySelected =
                                      widget.selectedItems.contains(item);
                                  return _buildHoverableListTile(
                                    title: item,
                                    isSelected: alreadySelected,
onTap: () {
  if (!alreadySelected) {
    // Aggiunge item alla lista di selected
    final newList = [
      ...widget.selectedItems,
      item
    ];
    widget.onChanged(newList);
  }
  // Chiude il dropdown subito dopo aver selezionato
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
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
        ),
        constraints: const BoxConstraints(minHeight: 40),
        child: Row(
          children: [
            // Se non ci sono chip, il tap sull'intera area apre il dropdown
            Expanded(
              child: MouseRegion(
                cursor: widget.selectedItems.isNotEmpty
                    ? (_dragging
                        ? SystemMouseCursors.grabbing
                        : _hoveringChips
                            ? SystemMouseCursors.grab
                            : SystemMouseCursors.basic)
                    : SystemMouseCursors.click,
                onEnter: (_) => setState(() => _hoveringChips = true),
                onExit: (_) => setState(() => _hoveringChips = false),
                child: GestureDetector(
                  onTap: widget.selectedItems.isEmpty ? _toggleDropdown : null,
                  onPanStart: widget.selectedItems.isNotEmpty
                      ? (_) => setState(() => _dragging = true)
                      : null,
                  onPanUpdate: widget.selectedItems.isNotEmpty
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
                  onPanEnd: widget.selectedItems.isNotEmpty
                      ? (_) => setState(() => _dragging = false)
                      : null,
                  child: SingleChildScrollView(
                    controller: _chipsScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (widget.selectedItems.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text(
                              "Seleziona...",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        else
                          ...widget.selectedItems.map((val) {
                            return Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4),
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
                                      List<String>.from(widget.selectedItems);
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
              icon: Icon(
                _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              ),
              onPressed: _toggleDropdown,
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------
///         TRANSFERS ROWS WIDGET (4 COLONNE, SENZA RIGA TOTALI)
/// ---------------------------------------------------------
/// - Colonne: Filtro analitico, Filtro partner, Percentuale (%), Conto di destinazione.
/// - "Conto di destinazione" è ora un dropdown a singola selezione.
/// - Drag & drop, ridimensionamento colonne, scroll orizzontale e verticale.
class TransfersRowsWidget extends StatefulWidget {
  /// Ogni riga ha i seguenti campi:
  ///  - "id": UniqueKey() (per il reorder)
  ///  - "Filtro analitico": List<String>
  ///  - "Filtro partner": List<String>
  ///  - "Percentuale (%)": double
  ///  - "Conto di destinazione": String
  final List<Map<String, dynamic>> rows;
  final ValueChanged<List<Map<String, dynamic>>> onRowsChanged;

  const TransfersRowsWidget({
    Key? key,
    required this.rows,
    required this.onRowsChanged,
  }) : super(key: key);

  @override
  _TransfersRowsWidgetState createState() => _TransfersRowsWidgetState();
}

class _TransfersRowsWidgetState extends State<TransfersRowsWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final ScrollController _horizontalScrollController = ScrollController();
  bool _resizerHovering = false;
  final List<String> allColumnsOrder = [
    "Filtro analitico",
    "Filtro partner",
    "Percentuale (%)",
    "Conto di destinazione",
  ];
  late Map<String, double> columnWidths;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      final totalCols = allColumnsOrder.length + 1; // +1 colonna drag
      final defaultWidth = (screenWidth) / totalCols * 0.80 * 0.5;
      setState(() {
        columnWidths = {for (var col in allColumnsOrder) col: defaultWidth};
      });
    });
  }

  void _addRow() {
    final newRows = List<Map<String, dynamic>>.from(widget.rows);
    newRows.add({
      "id": UniqueKey(),
      "Filtro analitico": <String>[],
      "Filtro partner": <String>[],
      "Percentuale (%)": 0.0,
      "Conto di destinazione": contoDestOptions.first,
    });
    widget.onRowsChanged(newRows);
  }

  void _deleteRow(int index) {
    final newRows = List<Map<String, dynamic>>.from(widget.rows);
    newRows.removeAt(index);
    widget.onRowsChanged(newRows);
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > widget.rows.length - 1) {
      newIndex = widget.rows.length - 1;
    }
    if (newIndex > oldIndex) newIndex--;
    final newRows = List<Map<String, dynamic>>.from(widget.rows);
    final moved = newRows.removeAt(oldIndex);
    newRows.insert(newIndex, moved);
    widget.onRowsChanged(newRows);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double sumCols = 0.0;
    for (var c in allColumnsOrder) {
      sumCols += (columnWidths[c] ?? 60.0);
    }
    final totalTableWidth = sumCols + 40 + 60; // drag handle + colonna delete

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (ctx, constraints) {
              return Container(
                width: constraints.maxWidth,
                child: Scrollbar(
                  controller: _horizontalScrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  thickness: 8.0,
                  radius: const Radius.circular(4),
                  scrollbarOrientation: ScrollbarOrientation.bottom,
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth:
                            math.max(totalTableWidth, constraints.maxWidth),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTableHeaderRow(),
                          const Divider(),
                          ReorderableListView.builder(
                            buildDefaultDragHandles: false,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: widget.rows.length,
                            onReorder: _onReorder,
                            proxyDecorator: (child, index, animation) {
                              return Material(elevation: 6, child: child);
                            },
                            itemBuilder: (context, index) {
                              final row = widget.rows[index];
                              final rowKey = row['id'] ?? UniqueKey();
                              return _buildSingleRow(row, index, rowKey);
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const SizedBox(width: 40),
                              TextButton(
                                onPressed: _addRow,
                                child: const Text(
                                  "Aggiungi riga",
                                  style: TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 400),
        ],
      ),
    );
  }

  Widget _buildTableHeaderRow() {
    List<Widget> headerCells = [Container(width: 40)];
    for (String col in allColumnsOrder) {
      headerCells.add(_buildColumnHeaderCell(col));
    }
    headerCells.add(Container(width: 60));
    return Row(children: headerCells);
  }

  Widget _buildColumnHeaderCell(String column) {
    return Container(
      width: columnWidths[column],
      child: Stack(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Text(
              column,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeLeftRight,
              onEnter: (_) => setState(() => _resizerHovering = true),
              onExit: (_) => setState(() => _resizerHovering = false),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    double newW = columnWidths[column]! + details.delta.dx;
                    if (newW < 50) newW = 50;
                    columnWidths[column] = newW;
                  });
                },
                child: Container(
                  width: 5,
                  color: _resizerHovering ? Colors.grey : Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleRow(Map<String, dynamic> row, int index, Key key) {
    return Container(
      key: key,
      color: (index % 2 == 0) ? Colors.white : Colors.grey[200],
      child: Row(
        children: [
          // Drag handle
          Container(
            width: 40,
            alignment: Alignment.center,
            child: ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.menu),
            ),
          ),
          // Filtro analitico
          Container(
            width: columnWidths["Filtro analitico"],
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: CustomChipsDropdown(
              allItems: analiticoOptions,
              selectedItems: List<String>.from(row["Filtro analitico"] ?? []),
              onChanged: (newList) {
                setState(() {
                  row["Filtro analitico"] = newList;
                });
                widget.onRowsChanged(widget.rows);
              },
            ),
          ),
          // Filtro partner
          Container(
            width: columnWidths["Filtro partner"],
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: CustomChipsDropdown(
              allItems: partnerOptions,
              selectedItems: List<String>.from(row["Filtro partner"] ?? []),
              onChanged: (newList) {
                setState(() {
                  row["Filtro partner"] = newList;
                });
                widget.onRowsChanged(widget.rows);
              },
            ),
          ),
          // Percentuale (%)
          Container(
            width: columnWidths["Percentuale (%)"],
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: _buildNumericField(row, "Percentuale (%)"),
          ),
          // Conto di destinazione (dropdown a singola selezione)
          Container(
            width: columnWidths["Conto di destinazione"],
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: CustomDropdown(
              items: contoDestOptions,
              value: row["Conto di destinazione"] ?? contoDestOptions.first,
              onChanged: (val) {
                setState(() {
                  row["Conto di destinazione"] = val;
                });
                widget.onRowsChanged(widget.rows);
              },
            ),
          ),
          // Icona delete
          Container(
            width: 60,
            alignment: Alignment.center,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteRow(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumericField(Map<String, dynamic> row, String fieldName) {
    final val = (row[fieldName] is num) ? row[fieldName].toString() : "";
    final textCtrl = TextEditingController(text: val)
      ..selection = TextSelection.collapsed(offset: val.length);
    return TextField(
      controller: textCtrl,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(border: InputBorder.none),
      onChanged: (value) {
        setState(() {
          row[fieldName] = double.tryParse(value) ?? 0.0;
        });
        widget.onRowsChanged(widget.rows);
      },
    );
  }
}
