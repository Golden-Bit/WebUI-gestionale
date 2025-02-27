import 'package:flutter/material.dart';
import 'package:flutter_app/pages/accounting/components/invoice/invoice_editor.dart';
// Qui risiede la definizione di "CustomDropdown" già usata in Tab 1, 2, 3.

// Elenco valori possibili per ciascun dropdown

const List<String> ddtOptions = [
  "Seleziona DDT",
  "DDT - Documento di Trasporto",
  "Fattura accompagnatoria",
  "Bolla di consegna",
];

const List<String> paymentTypeOptions = [
  "Seleziona tipo di pagamento",
  "Pagamento integrale",
  "Pagamento a rate",
  "Rimessa diretta",
  "Cerca ancora...",
];

const List<String> documentTypeOptions = [
  "Seleziona tipo documento",
  "TD01 - Fattura (immediata o accompagnatoria)",
  "TD02 - Deposito/anticipo su fattura",
  "TD03 - Deposito/anticipo sulla parcella",
  "TD04 - Nota di credito",
  "TD05 - Nota di debito",
  "TD06 - Parcella",
  "TD07 - Fattura semplificata",
  "TD08 - Nota di credito semplificata",
  "Cerca ancora...",
];

const List<String> paymentMethodOptions = [
  "Seleziona metodo pagamento",
  "MP01 - Contanti",
  "MP02 - Assegno",
  "MP05 - Bonifico",
  "MP08 - Carta di credito",
  "MP12 - Bollettino postale",
];

/// Widget Tab 4: Fatturazione Elettronica.
/// Riceve un dizionario [electronicInvoicingInfo] con tutte le chiavi necessarie, e
/// una callback [onElectronicInvoicingChanged] che riceverà il nuovo Map<...>
/// aggiornato a ogni modifica dell’utente.
class ElectronicInvoicingWidget extends StatefulWidget {
  final Map<String, dynamic> electronicInvoicingInfo;
  final ValueChanged<Map<String, dynamic>> onElectronicInvoicingChanged;

  const ElectronicInvoicingWidget({
    Key? key,
    required this.electronicInvoicingInfo,
    required this.onElectronicInvoicingChanged,
  }) : super(key: key);

  @override
  _ElectronicInvoicingWidgetState createState() =>
      _ElectronicInvoicingWidgetState();
}

class _ElectronicInvoicingWidgetState extends State<ElectronicInvoicingWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
@override
void initState() {
  super.initState();
  
  // Leggi il valore dal dizionario e converti in double
  final initialBolloValue =
      widget.electronicInvoicingInfo["datiBollo"] ?? 0.0;
  
  _datiBolloController = TextEditingController(
    text: (initialBolloValue is num)
        ? initialBolloValue.toStringAsFixed(2)
        : "0.00",
  );
}

@override
void didUpdateWidget(covariant ElectronicInvoicingWidget oldWidget) {
  super.didUpdateWidget(oldWidget);
  
  // Se "datiBollo" è cambiato nel nuovo widget, aggiorna il testo del controller
  final newValue = widget.electronicInvoicingInfo["datiBollo"] ?? 0.0;
  final newValueString = (newValue is num)
      ? newValue.toStringAsFixed(2)
      : "0.00";
  
  if (_datiBolloController.text != newValueString) {
    // Salviamo anche la posizione del cursore per non farlo saltare
    final cursorPos = _datiBolloController.selection.baseOffset;
    _datiBolloController.text = newValueString;
    if (cursorPos > -1 && cursorPos <= newValueString.length) {
      _datiBolloController.selection = TextSelection.fromPosition(
        TextPosition(offset: cursorPos),
      );
    }
  }
}

late TextEditingController _datiBolloController;
  /// Aggiorna un campo (chiave) con il valore [value].
  /// 
  void _updateField(String key, dynamic value) {
    final newInfo = Map<String, dynamic>.from(widget.electronicInvoicingInfo);
    newInfo[key] = value;
    widget.onElectronicInvoicingChanged(newInfo);
  }

  /// Aggiorna un campo numerico (double), effettuando il parsing.
  void _updateDoubleField(String key, String stringValue) {
    final newInfo = Map<String, dynamic>.from(widget.electronicInvoicingInfo);
    final parsed = double.tryParse(stringValue.replaceAll(",", ".")) ?? 0.0;
    newInfo[key] = parsed;
    widget.onElectronicInvoicingChanged(newInfo);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final info = widget.electronicInvoicingInfo;
    final double datiBollo = (info["datiBollo"] is num)
        ? (info["datiBollo"] as num).toDouble()
        : 0.0;
    final String selectedDDT = info["selectedDDT"] ?? "Seleziona DDT";
    final String selectedPaymentType =
        info["selectedPaymentType"] ?? "Seleziona tipo di pagamento";
    final String selectedDocumentType =
        info["selectedDocumentType"] ?? "Seleziona tipo documento";
    final String selectedPaymentMethod =
        info["selectedPaymentMethod"] ?? "Seleziona metodo pagamento";

    return SingleChildScrollView(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Prima Expanded: con flex=1 occupa metà dello spazio orizzontale
      Expanded(
        flex: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Fatturazione Elettronica",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // DATI BOLLO (campo numerico)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 140,
                  child: Text("Dati Bollo", style: TextStyle(fontSize: 14)),
                ),
                Tooltip(
                  message: "Importo del bollo in fattura (es. 2.00)",
                  child: const Icon(Icons.help_outline, size: 16),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                    controller: _datiBolloController,
textAlign: TextAlign.left,           // o TextAlign.right se preferisci allineare i numeri a destra
textDirection: TextDirection.ltr,    // Garantisce che i caratteri escano in ordine LTR
onChanged: (value) => _updateDoubleField("datiBollo", value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // DDT (Dropdown)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 140,
                  child: Text("DDT", style: TextStyle(fontSize: 14)),
                ),
                Tooltip(
                  message: "Seleziona il tipo di DDT o documento di trasporto",
                  child: const Icon(Icons.help_outline, size: 16),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomDropdown(
                    items: ddtOptions,
                    value: selectedDDT,
                    onChanged: (newVal) => _updateField("selectedDDT", newVal),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tipo di pagamento (dropdown)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 140,
                  child:
                      Text("Tipo di pagamento", style: TextStyle(fontSize: 14)),
                ),
                Tooltip(
                  message:
                      "Seleziona la modalità di pagamento (acconto, saldo...)",
                  child: const Icon(Icons.help_outline, size: 16),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomDropdown(
                    items: paymentTypeOptions,
                    value: selectedPaymentType,
                    onChanged: (newVal) =>
                        _updateField("selectedPaymentType", newVal),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tipo di documento (dropdown)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 140,
                  child: Text("Tipo documento", style: TextStyle(fontSize: 14)),
                ),
                Tooltip(
                  message: "Es. TD01 Fattura, TD04 Nota di credito, ecc.",
                  child: const Icon(Icons.help_outline, size: 16),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomDropdown(
                    items: documentTypeOptions,
                    value: selectedDocumentType,
                    onChanged: (newVal) =>
                        _updateField("selectedDocumentType", newVal),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Metodo di pagamento (dropdown)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 140,
                  child:
                      Text("Metodo pagamento", style: TextStyle(fontSize: 14)),
                ),
                Tooltip(
                  message:
                      "Es. contanti, bonifico, assegno, carta di credito, ecc.",
                  child: const Icon(Icons.help_outline, size: 16),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomDropdown(
                    items: paymentMethodOptions,
                    value: selectedPaymentMethod,
                    onChanged: (newVal) =>
                        _updateField("selectedPaymentMethod", newVal),
                  ),
                ),
              ],
            ),
            //const SizedBox(height: 30),
          const SizedBox(height: 400,)],
        ),
      ),            Expanded(
          flex: 1,
          child: Container(
            // Per ora la lasciamo vuota, oppure aggiungi ciò che vuoi
          ),
        ),  
    ]));
  }
}
