import 'package:flutter/material.dart';

/// Possibili stati del pagamento
enum PaymentStatus {
  bozza,    // Stato iniziale
  inCorso,  // Dopo click su "Conferma"
  pagata,   // Dopo click su "Valida"
}

/// Widget che mostra un'Action Bar con pulsanti e indicatore di stato:
/// - A sinistra: pulsanti (in base allo stato).
/// - A destra: catena "Bozza -> In corso -> Pagata", con lo stato corrente evidenziato.
class PaymentActionsBar extends StatefulWidget {
  final VoidCallback onConfirm; // Callback quando si clicca "Conferma"
  final VoidCallback onCancel;  // Callback quando si clicca "Annulla"

  /// Se true, parte da [PaymentStatus.bozza], altrimenti parte da [inCorso].
  final bool defaultIsDraft;

  const PaymentActionsBar({
    Key? key,
    required this.onConfirm,
    required this.onCancel,
    this.defaultIsDraft = true,
  }) : super(key: key);

  @override
  State<PaymentActionsBar> createState() => _PaymentActionsBarState();
}

class _PaymentActionsBarState extends State<PaymentActionsBar> {
  late PaymentStatus _paymentStatus;

  @override
  void initState() {
    super.initState();
    // Se defaultIsDraft è true, partiamo dallo stato "Bozza", altrimenti "In corso"
    _paymentStatus = widget.defaultIsDraft
        ? PaymentStatus.bozza
        : PaymentStatus.inCorso;
  }

  /// Dallo stato Bozza -> passa a In corso, invocando onConfirm()
  void _handleConfirm() {
    setState(() {
      _paymentStatus = PaymentStatus.inCorso;
    });
    widget.onConfirm();
  }

  /// Riporta lo stato a Bozza, invocando onCancel()
  void _handleCancel() {
    setState(() {
      _paymentStatus = PaymentStatus.bozza;
    });
    widget.onCancel();
  }

  /// Dallo stato In corso -> passa a Pagata
  void _handleValidate() {
    setState(() {
      _paymentStatus = PaymentStatus.pagata;
    });
    // Se serve, puoi invocare un callback specifico, es. widget.onValidate()
  }

  /// Qualunque stato -> Bozza
  void _handleResetToDraft() {
    setState(() {
      _paymentStatus = PaymentStatus.bozza;
    });
  }

  /// Pulsanti quando si è in Bozza
  /// ("Conferma" viola, "Annulla" grigio)
  Widget _buildBozzaButtons() {
    return Row(
      children: [
        // "Conferma" (viola)
        TextButton(
          onPressed: _handleConfirm,
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFF6B3A5B),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text("Conferma"),
        ),
        const SizedBox(width: 8),

        // "Annulla" (grigio)
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
          child: const Text("Annulla"),
        ),
      ],
    );
  }

  /// Pulsanti quando si è in In corso
  /// ("Valida" viola, "Reimposta a bozza" grigio, "Segna come inviato" grigio)
  Widget _buildInCorsoButtons() {
    return Row(
      children: [
        _buildCustomButton(
          "Valida",
          backgroundColor: const Color(0xFF6B3A5B),
          textColor: Colors.white,
          onTap: _handleValidate,
        ),
        const SizedBox(width: 8),
        _buildCustomButton(
          "Reimposta a bozza",
          backgroundColor: const Color(0xFFEAEAEA),
          textColor: Colors.black,
          onTap: _handleResetToDraft,
        ),
        const SizedBox(width: 8),
        _buildCustomButton(
          "Segna come inviato",
          backgroundColor: const Color(0xFFEAEAEA),
          textColor: Colors.black,
          onTap: () {
            // Rimaniamo in "inCorso", ma puoi implementare logica personalizzata
            debugPrint("Pagamento contrassegnato come inviato");
          },
        ),
      ],
    );
  }

  /// Pulsanti quando si è in Pagata
  /// (solo "Reimposta a bozza" grigio)
  Widget _buildPagataButtons() {
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

  /// Catena a destra: "Bozza -> In corso -> Pagata"
  /// con il box attivo evidenziato in teal.
  Widget _buildStatusIndicator() {
    final isBozza = _paymentStatus == PaymentStatus.bozza;
    final isInCorso = _paymentStatus == PaymentStatus.inCorso;
    final isPagata = _paymentStatus == PaymentStatus.pagata;

    final bozzaWidget = _buildStatusBox("Bozza", isActive: isBozza);
    final inCorsoWidget = _buildStatusBox("In corso", isActive: isInCorso);
    final pagataWidget = _buildStatusBox("Pagata", isActive: isPagata);

    return Row(
      children: [
        bozzaWidget,
        const SizedBox(width: 4),
        const Icon(Icons.arrow_right, color: Colors.teal),
        const SizedBox(width: 4),
        inCorsoWidget,
        const SizedBox(width: 4),
        const Icon(Icons.arrow_right, color: Colors.teal),
        const SizedBox(width: 4),
        pagataWidget,
      ],
    );
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
    Widget leftButtons;
    switch (_paymentStatus) {
      case PaymentStatus.bozza:
        leftButtons = _buildBozzaButtons();
        break;
      case PaymentStatus.inCorso:
        leftButtons = _buildInCorsoButtons();
        break;
      case PaymentStatus.pagata:
        leftButtons = _buildPagataButtons();
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Pulsanti a sinistra
          leftButtons,
          // Indicatore di stato a destra
          _buildStatusIndicator(),
        ],
      ),
    );
  }
}
