import 'package:flutter/material.dart';

/// Possibili stati di un movimento analitico
enum MovementStatus {
  bozza,      // Stato iniziale
  confermata, // Dopo click su "Conferma"
  annullata,  // Dopo click su "Annulla"
}

/// Widget che mostra un'Action Bar con pulsanti e indicatore di stato:
/// - A sinistra: pulsanti (in base allo stato).
/// - A destra: catena che parte come "Bozza -> Confermata"
///   e, solo se si clicca "Annulla", diventa "Bozza -> Confermata -> Annullata"
class MovementActionsBar extends StatefulWidget {
  final VoidCallback onConfirm; // Callback quando si clicca "Conferma"
  final VoidCallback onCancel;  // Callback quando si clicca "Annulla"

  /// Se true, parte da [MovementStatus.bozza], altrimenti da [MovementStatus.confermata].
  final bool defaultIsDraft;

  const MovementActionsBar({
    Key? key,
    required this.onConfirm,
    required this.onCancel,
    this.defaultIsDraft = true,
  }) : super(key: key);

  @override
  State<MovementActionsBar> createState() => _MovementActionsBarState();
}

class _MovementActionsBarState extends State<MovementActionsBar> {
  late MovementStatus _movementStatus;
  bool _annullataVisibile = false; // Di default lo stato "Annullata" è nascosto

  @override
  void initState() {
    super.initState();
    // Se defaultIsDraft è true, partiamo dallo stato "Bozza", altrimenti "Confermata"
    _movementStatus = widget.defaultIsDraft
        ? MovementStatus.bozza
        : MovementStatus.confermata;
  }

  /// Dallo stato Bozza -> passa a Confermata
  void _handleConfirm() {
    setState(() {
      _movementStatus = MovementStatus.confermata;
    });
    widget.onConfirm();
  }

  /// Dallo stato Bozza -> passa a Annullata
  /// (mostra anche "Annullata" nella catena di destra)
  void _handleCancel() {
    setState(() {
      _movementStatus = MovementStatus.annullata;
      _annullataVisibile = true; // Mostriamo "Annullata" e la relativa freccia
    });
    widget.onCancel();
  }

  /// Reimposta lo stato a Bozza
  void _handleResetToDraft() {
    setState(() {
      _movementStatus = MovementStatus.bozza;
      // Nascondiamo nuovamente "Annullata"
      _annullataVisibile = false;
    });
  }

  /// Pulsanti quando si è in Bozza ("Conferma" viola, "Annulla" grigio)
  Widget _buildBozzaButtons() {
    return Row(
      children: [
        _buildCustomButton(
          "Conferma",
          backgroundColor: const Color(0xFF6B3A5B),
          textColor: Colors.white,
          onTap: _handleConfirm,
        ),
        const SizedBox(width: 8),
        _buildCustomButton(
          "Annulla",
          backgroundColor: const Color(0xFFEAEAEA),
          textColor: Colors.black,
          onTap: _handleCancel,
        ),
      ],
    );
  }

  /// Pulsanti quando si è in Confermata (solo "Reimposta a bozza" grigio)
  Widget _buildConfermataButtons() {
    return Row(
      children: [
        _buildCustomButton(
          "Reimposta a bozza",
          backgroundColor: const Color(0xFFEAEAEA),
          textColor: Colors.black,
          onTap: _handleResetToDraft,
        ),
      ],
    );
  }

  /// Pulsanti quando si è in Annullata (solo "Reimposta a bozza" grigio)
  Widget _buildAnnullataButtons() {
    return Row(
      children: [
        _buildCustomButton(
          "Reimposta a bozza",
          backgroundColor: const Color(0xFFEAEAEA),
          textColor: Colors.black,
          onTap: _handleResetToDraft,
        ),
      ],
    );
  }

  /// Builder generico di pulsanti
  Widget _buildCustomButton(
    String label, {
    required Color backgroundColor,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor ?? Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    );
  }

  /// Catena a destra iniziale: "Bozza -> Confermata"
  /// Se `_annullataVisibile == true`, aggiunge "-> Annullata".
  Widget _buildStatusIndicator() {
    final isBozza = _movementStatus == MovementStatus.bozza;
    final isConfermata = _movementStatus == MovementStatus.confermata;
    final isAnnullata = _movementStatus == MovementStatus.annullata;

    // Widget base
    final bozzaWidget = _buildStatusBox("Bozza", isActive: isBozza);
    final confermataWidget =
        _buildStatusBox("Confermata", isActive: isConfermata);

    // Se `_annullataVisibile == false`, la catena è solo "Bozza -> Confermata"
    if (!_annullataVisibile) {
      return Row(
        children: [
          bozzaWidget,
          const SizedBox(width: 4),
          const Icon(Icons.arrow_right, color: Colors.teal),
          const SizedBox(width: 4),
          confermataWidget,
        ],
      );
    } else {
      // Se `_annullataVisibile == true`, aggiungiamo "-> Annullata"
      final annullataWidget =
          _buildStatusBox("Annullata", isActive: isAnnullata);

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
    }
  }

  /// Piccolo rettangolo con bordo e testo,
  /// evidenziato in teal se 'isActive' = true.
  Widget _buildStatusBox(String label, {required bool isActive}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isActive ? Colors.white : Colors.grey[300],
        border: Border.all(
          color: isActive ? Colors.teal : Colors.grey[300]!,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        label,
        style: TextStyle(color: isActive ? Colors.teal : Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mostriamo i pulsanti in base allo stato
    late Widget leftButtons;
    switch (_movementStatus) {
      case MovementStatus.bozza:
        leftButtons = _buildBozzaButtons();
        break;
      case MovementStatus.confermata:
        leftButtons = _buildConfermataButtons();
        break;
      case MovementStatus.annullata:
        leftButtons = _buildAnnullataButtons();
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Pulsanti a sinistra
          leftButtons,
          // Indicatore di stato a destra (dinamico)
          _buildStatusIndicator(),
        ],
      ),
    );
  }
}
