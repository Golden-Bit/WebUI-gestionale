import 'package:flutter/material.dart';

/// Stati possibili del prestito (o fattura, a seconda del contesto)
/// Ora includiamo tre stati: "bozza", "in esecuzione" e "chiuso".
enum LoanStatus {
  bozza,
  inEsecuzione,
  chiuso,
}

/// Widget con due pulsanti a sinistra ("Conferma" e "Azzera")
/// e un indicatore di stato a destra che mostra in sequenza "Bozza -> In esecuzione -> Chiuso".
/// Inizialmente lo stato è "Bozza" (con evidenza in azzurro) e vengono mostrati i pulsanti
/// "Conferma" (viola) e "Azzera" (grigio). Quando viene cliccato uno dei due,
/// questi scompaiono e al loro posto compare un pulsante grigio "Reimposta a bozza".
/// Cliccando su "Reimposta a bozza" lo stato torna a "Bozza" e i pulsanti "Conferma" e "Azzera" ricompaiono.
class LoanActionsBar extends StatefulWidget {
  /// Callback da invocare al click di "Conferma"
  final VoidCallback onConfirm;

  /// Callback da invocare al click di "Azzera"
  final VoidCallback onCancel;

  /// (Questo parametro viene ignorato nella nuova logica, dato che lo stato iniziale è sempre "Bozza")
  final bool defaultIsRunning;

  const LoanActionsBar({
    Key? key,
    required this.onConfirm,
    required this.onCancel,
    this.defaultIsRunning = false,
  }) : super(key: key);

  @override
  State<LoanActionsBar> createState() => _LoanActionsBarState();
}

class _LoanActionsBarState extends State<LoanActionsBar> {
  late LoanStatus _loanStatus;

  @override
  void initState() {
    super.initState();
    // Lo stato iniziale è sempre "bozza"
    _loanStatus = LoanStatus.bozza;
  }

  /// Al click di "Conferma": lo stato passa a "in esecuzione"
  /// e viene invocata la callback onConfirm.
  void _handleConfirm() {
    setState(() {
      _loanStatus = LoanStatus.inEsecuzione;
    });
    widget.onConfirm();
  }

  /// Al click di "Azzera": lo stato passa a "chiuso"
  /// e viene invocata la callback onCancel.
  void _handleAzzera() {
    setState(() {
      _loanStatus = LoanStatus.chiuso;
    });
    widget.onCancel();
  }

  /// Al click di "Reimposta a bozza": lo stato torna a "bozza"
  void _handleResetToDraft() {
    setState(() {
      _loanStatus = LoanStatus.bozza;
    });
  }

  /// Pulsante "Conferma" (viola scuro)
  Widget _buildConfirmButton() {
    return TextButton(
      onPressed: _handleConfirm,
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xFF6B3A5B), // Viola scuro
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: const Text(
        "Conferma",
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    );
  }

  /// Pulsante "Azzera" (grigio)
  Widget _buildAzzeraButton() {
    return TextButton(
      onPressed: _handleAzzera,
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xFFEAEAEA),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: const Text(
        "Azzera",
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    );
  }

  /// Pulsante "Reimposta a bozza" (grigio)
  Widget _buildResetButton() {
    return TextButton(
      onPressed: _handleResetToDraft,
      style: TextButton.styleFrom(
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: const Text(
        "Reimposta a bozza",
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    );
  }

  /// Costruisce l'indicatore di stato a destra che mostra tre box:
  /// "Bozza", "In esecuzione" e "Chiuso".
  /// Lo stato attivo viene evidenziato: se "Bozza" attivo, il box è in azzurro;
  /// se "In esecuzione" o "Chiuso" attivi, il box è in teal.
  /// I box inattivi sono mostrati con sfondo grigio.
  Widget _buildStatusIndicator() {
    final bozzaActive = _loanStatus == LoanStatus.bozza;
    final inEsecuzioneActive = _loanStatus == LoanStatus.inEsecuzione;
    final chiusoActive = _loanStatus == LoanStatus.chiuso;

    // Box "Bozza": se attivo, usa un colore azzurro, altrimenti grigio.
    final bozzaWidget = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: bozzaActive ? Colors.white : Colors.grey[300],
        border: Border.all(
          color: bozzaActive ? Colors.teal : Colors.grey[300]!,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        "Bozza",
        style: TextStyle(
          color: bozzaActive ? Colors.teal : Colors.grey,
        ),
      ),
    );

    // Box "In esecuzione": se attivo, evidenzia in teal, altrimenti grigio.
    final inEsecuzioneWidget = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: inEsecuzioneActive ? Colors.white : Colors.grey[300],
        border: Border.all(
          color: inEsecuzioneActive ? Colors.teal : Colors.grey[300]!,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        "In esecuzione",
        style: TextStyle(
          color: inEsecuzioneActive ? Colors.teal : Colors.grey,
        ),
      ),
    );

    // Box "Chiuso": se attivo, evidenzia in teal, altrimenti grigio.
    final chiusoWidget = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: chiusoActive ? Colors.white : Colors.grey[300],
        border: Border.all(
          color: chiusoActive ? Colors.teal : Colors.grey[300]!,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        "Chiuso",
        style: TextStyle(
          color: chiusoActive ? Colors.teal : Colors.grey,
        ),
      ),
    );

    return Row(
      children: [
        bozzaWidget,
        const SizedBox(width: 4),
        const Icon(Icons.arrow_right, color: Colors.teal),
        const SizedBox(width: 4),
        inEsecuzioneWidget,
        const SizedBox(width: 4),
        const Icon(Icons.arrow_right, color: Colors.teal),
        const SizedBox(width: 4),
        chiusoWidget,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Se lo stato è "bozza", visualizza i pulsanti "Conferma" e "Azzera".
    // Altrimenti, visualizza il pulsante "Reimposta a bozza".
    Widget leftButtons;
    if (_loanStatus == LoanStatus.bozza) {
      leftButtons = Row(
        children: [
          _buildConfirmButton(),
          const SizedBox(width: 8),
          _buildAzzeraButton(),
        ],
      );
    } else {
      leftButtons = _buildResetButton();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          leftButtons,
          _buildStatusIndicator(),
        ],
      ),
    );
  }
}
