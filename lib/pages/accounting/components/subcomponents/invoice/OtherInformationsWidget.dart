import 'package:flutter/material.dart';
import 'package:flutter_app/pages/accounting/components/invoice/invoice_editor.dart'; 
// invoice_editor.dart contiene la definizione di CustomDropdown già usata negli altri Tab.

// Elenco valori possibili (stile costante come negli esempi precedenti)
const List<String> salespersonOptions = [
  "Seleziona venditore",
  "Mario Rossi",
  "Luigi Bianchi",
  "Simone Sansalone",
  "Paolo Verdi",
];

const List<String> bankBeneficiaryOptions = [
  "Seleziona banca",
  "Banca Intesa",
  "Unicredit",
  "BNL",
  "Credito Emiliano",
  "Monte dei Paschi",
];

const List<String> incotermOptions = [
  "[EXW] FRANCO FABBRICA",
  "[FCA] FRANCO VETTORE",
  "[FAS] FRANCO SOTTO BORDO",
  "[FOB] FRANCO A BORDO",
  "[CFR] COSTO E NOLO",
  "[CIF] COSTO, ASSICURAZIONE E NOLO",
  "[CPT] PORTO PAGATO FINO A",
  "[CIP] TRASPORTO E ASSICURAZIONE PAGATI FINO A",
];

const List<String> fiscalPositionOptions = [
  "Nazionale",
  "EU B2C",
  "Intra-Comunitario",
  "Importazione/Esportazione",
  "Scissione dei Pagamenti",
  "Subappalto Edilizia - IC",
  "Cerca ancora...",
];

const List<String> paymentMethodOptions = [
  "Manual Payment (Banca)",
  "Batch Deposit (Banca)",
  "Bank Receipt (IT) (Banca)",
  "Manual Payment (Cassa)",
  "Bank Receipt (IT) (Cassa)",
];

const List<String> confermaAutomaticaOptions = [
  "No",
  "Alla data",
  "Mensile",
  "Annuale",
  "Trimestrale",
];

/// Widget che rappresenta il Tab "Altre informazioni" (Tab 3).
/// Invece di ricevere singoli campi, riceve un [additionalInfo] Map<String, dynamic>
/// e un callback [onAdditionalInfoChanged], in modo simile a come avviene
/// con "invoiceRows" in Tab 1.
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

  /// Mostra il date picker per selezionare la data di consegna
  Future<void> _pickDeliveryDate(BuildContext context) async {
    final currentDeliveryDate = widget.additionalInfo["deliveryDate"] as DateTime?;
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDeliveryDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      // Creiamo una copia di additionalInfo e aggiorniamo la chiave
      final newInfo = Map<String, dynamic>.from(widget.additionalInfo);
      newInfo["deliveryDate"] = picked;
      widget.onAdditionalInfoChanged(newInfo);
    }
  }

  /// Helper per aggiornare una chiave testuale
  void _updateStringField(String key, String value) {
    final newInfo = Map<String, dynamic>.from(widget.additionalInfo);
    newInfo[key] = value;
    widget.onAdditionalInfoChanged(newInfo);
  }

  /// Helper per aggiornare una chiave bool
  void _updateBoolField(String key, bool value) {
    final newInfo = Map<String, dynamic>.from(widget.additionalInfo);
    newInfo[key] = value;
    widget.onAdditionalInfoChanged(newInfo);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Per AutomaticKeepAliveClientMixin

    final info = widget.additionalInfo; // Alias per leggibilità

    // Leggiamo i valori correnti dal dizionario
    final String customerReference = info["customerReference"] ?? "";
    final String salesperson = info["selectedSalesperson"] ?? "Seleziona venditore";
    final String bank = info["selectedBank"] ?? "Seleziona banca";
    final String paymentReference = info["paymentReference"] ?? "";
    final DateTime? deliveryDate = info["deliveryDate"];

    final String termineResa = info["selectedTermineResa"] ?? "[EXW] FRANCO FABBRICA";
    final String incotermLoc = info["incotermLocation"] ?? "";
    final String fiscalPosition = info["selectedFiscalPosition"] ?? "Nazionale";
    final String paymentMethod = info["selectedPaymentMethod"] ?? "Manual Payment (Banca)";
    final String confermaAutomatica = info["selectedConfermaAutomatica"] ?? "No";
    final bool verified = info["verified"] ?? false;

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -----------------------
          // Colonna di sinistra (FATTURA)
          // -----------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "FATTURA",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),
                Divider(),
                const SizedBox(height: 8),

                // Riferimento Cliente
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 140,
                      child: Text("Riferimento cliente",
                          style: TextStyle(fontSize: 13)),
                    ),
                    Tooltip(
                      message: "Riferimento interno del cliente",
                      child: const Icon(Icons.help_outline, size: 16),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        controller: TextEditingController(text: customerReference),
                        onChanged: (value) => _updateStringField("customerReference", value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Addetto vendite
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 140,
                      child: Text("Addetto vendite",
                          style: TextStyle(fontSize: 13)),
                    ),
                    Tooltip(
                      message: "Seleziona l'addetto vendite assegnato",
                      child: const Icon(Icons.help_outline, size: 16),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomDropdown(
                        items: salespersonOptions,
                        value: salesperson,
                        onChanged: (newVal) => _updateStringField("selectedSalesperson", newVal),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Banca del beneficiario
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 140,
                      child: Text("Banca del beneficiario",
                          style: TextStyle(fontSize: 13)),
                    ),
                    Tooltip(
                      message: "Seleziona la banca su cui avverrà l’accredito",
                      child: const Icon(Icons.help_outline, size: 16),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomDropdown(
                        items: bankBeneficiaryOptions,
                        value: bank,
                        onChanged: (newVal) => _updateStringField("selectedBank", newVal),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Riferimento pagamento
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 140,
                      child: Text("Riferimento pagamento",
                          style: TextStyle(fontSize: 13)),
                    ),
                    Tooltip(
                      message: "Es. codice pagamento o note",
                      child: const Icon(Icons.help_outline, size: 16),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        controller: TextEditingController(text: paymentReference),
                        onChanged: (value) => _updateStringField("paymentReference", value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Data consegna
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 140,
                      child: Text("Data consegna",
                          style: TextStyle(fontSize: 13)),
                    ),
                    Tooltip(
                      message: "Data in cui la merce/servizio viene consegnato/fornito",
                      child: const Icon(Icons.help_outline, size: 16),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickDeliveryDate(context),
                        child: Container(
                          height: 45,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            deliveryDate != null
                                ? "${deliveryDate.day}/${deliveryDate.month}/${deliveryDate.year}"
                                : "Seleziona data",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // -----------------------
          // Colonna di destra (CONTABILITÀ)
          // -----------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "CONTABILITÀ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),
                Divider(),
                const SizedBox(height: 8),

                // Termine di resa (Incoterm)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 120,
                      child: Text("Termine di resa",
                          style: TextStyle(fontSize: 13)),
                    ),
                    Tooltip(
                      message: "Incoterm: condizioni di trasporto",
                      child: const Icon(Icons.help_outline, size: 16),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomDropdown(
                        items: incotermOptions,
                        value: termineResa,
                        onChanged: (newVal) => _updateStringField("selectedTermineResa", newVal),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Ubicazione Incoterm
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 120,
                      child: Text("Ubicazione Incoterm",
                          style: TextStyle(fontSize: 13)),
                    ),
                    Tooltip(
                      message: "Luogo di consegna previsto dall’Incoterm",
                      child: const Icon(Icons.help_outline, size: 16),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        controller: TextEditingController(text: incotermLoc),
                        onChanged: (value) => _updateStringField("incotermLocation", value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Posizione fiscale
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 120,
                      child: Text("Posizione fiscale",
                          style: TextStyle(fontSize: 13)),
                    ),
                    Tooltip(
                      message: "Seleziona la posizione fiscale applicabile",
                      child: const Icon(Icons.help_outline, size: 16),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomDropdown(
                        items: fiscalPositionOptions,
                        value: fiscalPosition,
                        onChanged: (newVal) => _updateStringField("selectedFiscalPosition", newVal),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Metodo di pagamento
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 120,
                      child: Text("Metodo di pagamento",
                          style: TextStyle(fontSize: 13)),
                    ),
                    Tooltip(
                      message: "Modalità con cui il cliente paga la fattura",
                      child: const Icon(Icons.help_outline, size: 16),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomDropdown(
                        items: paymentMethodOptions,
                        value: paymentMethod,
                        onChanged: (newVal) => _updateStringField("selectedPaymentMethod", newVal),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Conferma automatica
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 120,
                      child: Text("Conferma automatica",
                          style: TextStyle(fontSize: 13)),
                    ),
                    Tooltip(
                      message: "Definisce la periodicità di conferma",
                      child: const Icon(Icons.help_outline, size: 16),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomDropdown(
                        items: confermaAutomaticaOptions,
                        value: confermaAutomatica,
                        onChanged: (newVal) => _updateStringField("selectedConfermaAutomatica", newVal),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Verificato (checkbox)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 120,
                      child:
                          Text("Verificato?", style: TextStyle(fontSize: 13)),
                    ),
                    Tooltip(
                      message: "Flag se la fattura è già stata verificata",
                      child: const Icon(Icons.help_outline, size: 16),
                    ),
                    const SizedBox(width: 16),
                    Checkbox(
                      value: verified,
                      onChanged: (bool? newValue) {
                        _updateBoolField("verified", newValue ?? false);
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 400,)],
            ),
          ),
        ],
      ),
    );
  }
}
