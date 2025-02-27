import 'package:flutter/material.dart';

/// Stati possibili della fattura
enum InvoiceStatus {
  bozza,
  confermata,
  annullata,
}

/// Widget con comportamenti differenti a seconda dello stato:
/// - Se bozza: mostra pulsanti [Conferma], [Annulla], e indicatori Bozza -> Confermata.
/// - Se confermata: mostra pulsanti [Invia], [Registra pagamento], [Anteprima],
///   [Nota di credito], [Reimposta a bozza], e indicatori Bozza -> Confermata.
/// - Se annullata: mostra indicatori Bozza -> Confermata -> Annullata e
///   pulsante "Reimposta a bozza".
class InvoiceActionsBar extends StatefulWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  /// Se true, lo stato iniziale è [InvoiceStatus.bozza], altrimenti [confermata].
  final bool defaultIsDraft;

  const InvoiceActionsBar({
    Key? key,
    required this.onConfirm,
    required this.onCancel,
    this.defaultIsDraft = true,
  }) : super(key: key);

  @override
  State<InvoiceActionsBar> createState() => _InvoiceActionsBarState();
}

class _InvoiceActionsBarState extends State<InvoiceActionsBar> {
  late InvoiceStatus _invoiceStatus;

  @override
  void initState() {
    super.initState();
    // Se defaultIsDraft è true, partiamo in bozza, altrimenti in confermata
    _invoiceStatus = widget.defaultIsDraft
        ? InvoiceStatus.bozza
        : InvoiceStatus.confermata;
  }

  /// Passa lo stato a [confermata] e invoca la callback onConfirm.
  void _handleConfirm() {
    setState(() {
      _invoiceStatus = InvoiceStatus.confermata;
    });
    widget.onConfirm();
  }

  /// Passa lo stato a [annullata] e invoca la callback onCancel.
  /// (Non torna più a bozza, a meno che non si clicchi su "Reimposta a bozza".)
  void _handleCancel() {
    setState(() {
      _invoiceStatus = InvoiceStatus.annullata;
    });
    widget.onCancel();
  }

  /// Da confermata o annullata -> torna in bozza
  void _handleResetToDraft() {
    setState(() {
      _invoiceStatus = InvoiceStatus.bozza;
    });
    // Se necessario, puoi invocare una callback qui
    // es. widget.onResetDraft(); (non definita in questo esempio)
  }

  /// Se in bozza, pulsanti: Conferma, Annulla.
  Widget _buildDraftButtons() {
    return Row(
      children: [
        // Pulsante Conferma (viola scuro)
        TextButton(
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
        ),
        const SizedBox(width: 8),
        // Pulsante Annulla (grigio)
        TextButton(
          onPressed: _handleCancel,
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFFEAEAEA),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text(
            "Annulla",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ),
      ],
    );
  }

  /// Se in confermata, pulsanti: Invia, Registra pagamento, Anteprima, Nota di credito, Reimposta a bozza.
  Widget _buildConfirmedButtons() {
    return Row(
      children: [
        _buildCustomButton("Storna registrazione", backgroundColor: Colors.grey[200], onTap: _handleResetToDraft),
        const SizedBox(width: 8),
        _buildCustomButton("Reimposta a bozza", backgroundColor: Colors.grey[200], onTap: _handleResetToDraft),
      ],
    );
  }

  /// Se in annullata, mostra un solo pulsante: [Reimposta a bozza].
  Widget _buildCancelledButtons() {
    return Row(
      children: [
        _buildCustomButton(
          "Reimposta a bozza",
          backgroundColor: Colors.grey[200],
          onTap: _handleResetToDraft,
        ),
      ],
    );
  }

  /// Builder generico per creare un pulsante testuale con stili base
  Widget _buildCustomButton(
    String label, {
    Color? backgroundColor,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.grey[300],
        foregroundColor: textColor ?? Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14) //, color: textColor ?? Colors.black),
      ),
    );
  }

  /// Costruisce la sezione di destra con la catena "Bozza -> Confermata" e, se annullata, "-> Annullata".
  Widget _buildStatusIndicator() {
    final bozzaActive = _invoiceStatus == InvoiceStatus.bozza;
    final confermataActive = _invoiceStatus == InvoiceStatus.confermata;

    // Widget per Bozza
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

    // Widget per Confermata
    final confermataWidget = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: confermataActive ? Colors.white : Colors.grey[300],
        border: Border.all(
          color: confermataActive ? Colors.teal : Colors.grey[300]!,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        "Confermata",
        style: TextStyle(
          color: confermataActive ? Colors.teal : Colors.grey,
        ),
      ),
    );

    // Se annullata, aggiungiamo un ulteriore step "Annullata" a destra.
    if (_invoiceStatus == InvoiceStatus.annullata) {
      final annullataWidget = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.white,
          border: Border.all(color: Colors.teal),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: const Text(
          "Annullata",
          style: TextStyle(color: Colors.teal),
        ),
      );

      return Row(
        children: [
          bozzaWidget,
          const SizedBox(width: 4),
          const Icon(Icons.arrow_right, color: Colors.teal),
          const SizedBox(width: 4),
          confermataWidget,
          const SizedBox(width: 4),
          const Icon(Icons.arrow_right, color: Colors.teal),
          const SizedBox(width: 4),
          annullataWidget,
        ],
      );
    } else {
      // Mostra solo "Bozza -> Confermata"
      return Row(
        children: [
          bozzaWidget,
          const SizedBox(width: 4),
          const Icon(Icons.arrow_right, color: Colors.teal),
          const SizedBox(width: 4),
          confermataWidget,
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scegliamo i pulsanti a sinistra in base allo stato
    Widget leftButtons;
    switch (_invoiceStatus) {
      case InvoiceStatus.bozza:
        leftButtons = _buildDraftButtons();
        break;
      case InvoiceStatus.confermata:
        leftButtons = _buildConfirmedButtons();
        break;
      case InvoiceStatus.annullata:
        leftButtons = _buildCancelledButtons();
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sezione sinistra (pulsanti)
          leftButtons,
          // Sezione destra (indicatori di stato)
          _buildStatusIndicator(),
        ],
      ),
    );
  }
}
