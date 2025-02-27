import 'package:flutter/material.dart';
import 'package:flutter_app/pages/accounting/components/accounting_records/accounting_records_editor.dart';

// Opzioni per "Conferma automatica"
const List<String> confermaAutomaticaOptions = [
  "No",
  "Alla data",
  "Mensile",
  "Trimestrale",
  "Annuale",
];

// Opzioni per "Posizione fiscale"
const List<String> fiscalPositionOptions = [
  "Nazionale",
  "EU B2C",
  "Intra-Comunitario",
  "Importazione/Esportazione",
  "Scissione dei Pagamenti",
  "Subappalto Edilizia - IC",
];

/// Widget che rappresenta la tab "Altre informazioni"
/// con due colonne (sinistra e destra).
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
  bool get wantKeepAlive => true; // preserva lo stato

  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    // Preleva l'eventuale nota esistente e posiziona il cursore in fondo
    final currentNote = widget.additionalInfo["internalNote"] ?? "";
    _noteController = TextEditingController(text: currentNote)
      ..selection = TextSelection.collapsed(offset: currentNote.length);
  }

  /// Helper per aggiornare un campo stringa nella mappa [additionalInfo]
  void _updateStringField(String key, String value) {
    final newInfo = Map<String, dynamic>.from(widget.additionalInfo);
    newInfo[key] = value;
    widget.onAdditionalInfoChanged(newInfo);
  }

  /// Helper per aggiornare un campo bool nella mappa [additionalInfo]
  void _updateBoolField(String key, bool value) {
    final newInfo = Map<String, dynamic>.from(widget.additionalInfo);
    newInfo[key] = value;
    widget.onAdditionalInfoChanged(newInfo);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Alias per leggibilità
    final info = widget.additionalInfo;

    // Valori correnti
    final String selectedConferma =
        info["confermaAutomatica"] ?? confermaAutomaticaOptions.first; // "No" di default
    final bool verified = info["verified"] ?? false;
    final String note = info["internalNote"] ?? "";
    final String selectedFiscalPosition =
        info["fiscalPosition"] ?? fiscalPositionOptions.first; // "Nazionale" di default

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -------------------------------------------------
          // COLONNA DI SINISTRA
          // -------------------------------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CONFERMA AUTOMATICA (dropdown)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 140,
                      child: Text(
                        "Conferma automatica",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    Tooltip(
                      message: "Seleziona la periodicità di conferma",
                      child: const Icon(Icons.help_outline, size: 16),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomDropdown(
                        items: confermaAutomaticaOptions,
                        value: selectedConferma,
                        onChanged: (newVal) =>
                            _updateStringField("confermaAutomatica", newVal),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // VERIFICATO (checkbox)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 140,
                      child: Text(
                        "Verificato?",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    Tooltip(
                      message: "Spunta se la fattura è già stata verificata",
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
                const SizedBox(height: 16),

                // NOTA TESTUALE
                TextField(
                  controller: _noteController,
                    //..selection = TextSelection.collapsed(offset: note.length),
                  onChanged: (val) {
                    // Aggiorna lo stato interno e la mappa esterna
                    _updateStringField("internalNote", val);
                  },
                  // Per far sì che i caratteri si inseriscano "a destra"
                  // è sufficiente che il textAlign sia standard (left) e
                  // che il cursor resti a fine testo (vedi initState).
                  decoration: const InputDecoration(
                    hintText: "Aggiungi una nota interna...",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                  ),
                  maxLines: null, // consente la multi-riga
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // -------------------------------------------------
          // COLONNA DI DESTRA
          // -------------------------------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // POSIZIONE FISCALE (dropdown)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 120,
                      child: Text(
                        "Posizione fiscale",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    Tooltip(
                      message: "Seleziona la posizione fiscale applicabile",
                      child: const Icon(Icons.help_outline, size: 16),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomDropdown(
                        items: fiscalPositionOptions,
                        value: selectedFiscalPosition,
                        onChanged: (newVal) =>
                            _updateStringField("fiscalPosition", newVal),
                      ),
                    ),
                  ],
                ),

                // Uno spazio extra in basso (come in figura)
                const SizedBox(height: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
