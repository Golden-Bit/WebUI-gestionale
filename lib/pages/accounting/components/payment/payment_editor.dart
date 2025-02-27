import 'package:flutter/material.dart';
import 'package:flutter_app/pages/accounting/components/subcomponents/payment/payment_actions_bar.dart';

// Esempio di tipo di pagamento (Invia / Ricevi)
enum PaymentType { invia, ricevi }

class PaymentDetailsWidget extends StatefulWidget {
  const PaymentDetailsWidget({Key? key}) : super(key: key);

  @override
  State<PaymentDetailsWidget> createState() => _PaymentDetailsWidgetState();
}

class _PaymentDetailsWidgetState extends State<PaymentDetailsWidget>
    with SingleTickerProviderStateMixin {
  // Tipo di pagamento: invia (uscita) o ricevi (entrata)
  PaymentType _paymentType = PaymentType.ricevi;

  // Dropdown values
  String selectedCustomer = "Seleziona cliente";
  String selectedRegister = "Banca"; // o "Cassa"
  String selectedPaymentMethod = "Manual Payment";
  String selectedEnterpriseBankAccount = "Conto XYZ";

  // Data e importo
  DateTime? paymentDate;
  final TextEditingController amountController =
      TextEditingController(text: "0.00");
  final TextEditingController memoController =
      TextEditingController(text: "Memo pagamento...");

  @override
  void dispose() {
    amountController.dispose();
    memoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        paymentDate = picked;
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
                // 1) PaymentActionsBar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: PaymentActionsBar(
                    onConfirm: () {
                      debugPrint("Pagamento: Conferma -> passa a 'In corso'");
                    },
                    onCancel: () {
                      debugPrint("Pagamento: Annulla -> torna a 'Bozza'");
                    },
                    defaultIsDraft: true, // parte da Bozza
                  ),
                ),

                // 2) Contenitore con bordo che racchiude i campi del pagamento
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Titolo
                            const Text(
                              "Pagamento",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 1) Tipo di pagamento: Invia / Ricevi
                            Row(
                              children: [
                                const Text(
                                  "Tipo di pagamento  ",
                                  style: TextStyle(fontSize: 16),
                                ),
                                Row(
                                  children: [
                                    Radio<PaymentType>(
                                      value: PaymentType.invia,
                                      groupValue: _paymentType,
                                      onChanged: (value) {
                                        setState(() {
                                          _paymentType = value!;
                                        });
                                      },
                                    ),
                                    const Text("Invia"),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Row(
                                  children: [
                                    Radio<PaymentType>(
                                      value: PaymentType.ricevi,
                                      groupValue: _paymentType,
                                      onChanged: (value) {
                                        setState(() {
                                          _paymentType = value!;
                                        });
                                      },
                                    ),
                                    const Text("Ricevi"),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // 2) Cliente
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 70,
                                  child: Text(
                                    "Cliente",
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                                Expanded(
                                  child: CustomDropdown(
                                    items: [
                                      "Cliente 1",
                                      "Cliente 2",
                                      "Cliente 3",
                                      "Cliente 4",
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
                            const SizedBox(height: 16),

                            // 3) Importo
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 70,
                                  child: Text(
                                    "Importo",
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                                SizedBox(
                                  width: 200,
                                  child: TextField(
                                    controller: amountController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      suffixIcon: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
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

                            // 4) Data
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 70,
                                  child: Text(
                                    "Data",
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => _selectDate(context),
                                  child: Container(
                                    width: 200,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade400),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: Text(
                                      paymentDate != null
                                          ? "${paymentDate!.day}/${paymentDate!.month}/${paymentDate!.year}"
                                          : "Seleziona data",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // 5) Promemoria
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 70,
                                  child: Text(
                                    "Promemoria",
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: memoController,
                                    maxLines: 1,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // 6) Registro (Banca o Cassa)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 70,
                                  child: Text(
                                    "Registro",
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                                Expanded(
                                  child: CustomDropdown(
                                    items: ["Banca", "Cassa"],
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
                            const SizedBox(height: 16),

                            // 7) Metodo di pagamento
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 70,
                                  child: Text(
                                    "Metodo",
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                                Expanded(
                                  child: CustomDropdown(
                                    items: [
                                      "Manual Payment",
                                      "Batch Deposit",
                                      "Bank Receipt (IT)",
                                    ],
                                    value: selectedPaymentMethod,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedPaymentMethod = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // 8) Conto bancario
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 70,
                                  child: Text(
                                    "Conto imp.",
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                                Expanded(
                                  child: CustomDropdown(
                                    items: [
                                      "Conto XYZ",
                                      "Conto ABC",
                                      "Conto 123",
                                    ],
                                    value: selectedEnterpriseBankAccount,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedEnterpriseBankAccount = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Colonna destra (1/3)
          Expanded(
            flex: 1,
            child: Container(color: Colors.transparent),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// Sezione: CustomDropdown (la stessa definita con l'overlay).
// Copia/includi come da codice mostrato sopra.
// ----------------------------------------------------------

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
                            // Ricerca
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

    // Focalizza il campo di ricerca
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
          onEnter: (_) => setStateItem(() {
            backgroundColor = Colors.grey[200]!;
          }),
          onExit: (_) => setStateItem(() {
            backgroundColor = Colors.white;
          }),
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
              const Icon(Icons.arrow_drop_down, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }
}
