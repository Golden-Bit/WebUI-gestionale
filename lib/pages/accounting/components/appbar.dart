import 'package:flutter/material.dart';
import 'package:flutter_app/pages/accounting/components/appbar_actions_menu.dart';

class CustomAppBar extends StatelessWidget {
  // Funzione per mostrare il menu a tendina
  final Function(String) onDropDownMenuButtonPressed;
  final Function(String) onMenuButtonPressed;

  // LayerLinks per ogni pulsante del menu (se ancora utilizzati altrove)
  final LayerLink clientiLayerLink;
  final LayerLink fornitoriLayerLink;
  final LayerLink contabilitaLayerLink;
  final LayerLink rendicontazioneLayerLink;
  final LayerLink configurazioneLayerLink;

  // Callback per il pulsante "Nuova"
  final VoidCallback onNuovoPressed;

  // Due stringhe da sostituire a "Fatture" e "Fattura in bozza"
  final String label1;
  final String label2;

  const CustomAppBar({
    Key? key,
    required this.onDropDownMenuButtonPressed,
    required this.onMenuButtonPressed,
    required this.clientiLayerLink,
    required this.fornitoriLayerLink,
    required this.contabilitaLayerLink,
    required this.rendicontazioneLayerLink,
    required this.configurazioneLayerLink,
    required this.onNuovoPressed,
    required this.label1,
    required this.label2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ------------------------------------------------
        // PRIMA BARRA SUPERIORE (AppBar principale)
        // ------------------------------------------------
        AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            children: [
              // Icona principale
              const Icon(
                Icons.insert_chart, // Puoi sostituire con un'icona personalizzata
                color: Color(0xFF6B3A5B),
              ),
              const SizedBox(width: 8),
              const Text(
                "Contabilità",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 24),
              // Azioni accanto al titolo
              _buildActionButton("Bacheca", context),
              _buildActionButtonWithMenu("Clienti", context, clientiLayerLink),
              _buildActionButtonWithMenu("Fornitori", context, fornitoriLayerLink),
              _buildActionButtonWithMenu("Contabilità", context, contabilitaLayerLink),
              _buildActionButtonWithMenu("Rendicontazione", context, rendicontazioneLayerLink),
              _buildActionButtonWithMenu("Configurazione", context, configurazioneLayerLink),
            ],
          ),
          actions: [
            // Simbolo notifiche
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.black),
                    onPressed: () {
                      print("Notifiche cliccate");
                    },
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        "3",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Simbolo attività
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                icon: const Icon(Icons.local_activity, color: Colors.black),
                onPressed: () {
                  print("Attività cliccate");
                },
              ),
            ),
            // Avatar utente
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.teal,
                child: Text(
                  "S",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),

        // ------------------------------------------------
        // SECONDA BARRA (parte inferiore personalizzata)
        // ------------------------------------------------
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey,
                width: 1.0,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              // Pulsante "Nuova" con effetto hover
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: TextButton(
                  onPressed: onNuovoPressed,
                  style: ButtonStyle(
                    // Sfondo trasparente di default, viola scuro in hover
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (states) {
                        if (states.contains(MaterialState.hovered)) {
                          return const Color(0xFF6B3A5B);
                        }
                        return Colors.transparent;
                      },
                    ),
                    // Testo viola di default, bianco in hover
                    foregroundColor: MaterialStateProperty.resolveWith<Color>(
                      (states) {
                        if (states.contains(MaterialState.hovered)) {
                          return Colors.white;
                        }
                        return const Color(0xFF6B3A5B);
                      },
                    ),
                    // Bordo viola
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: const BorderSide(color: Color(0xFF6B3A5B)),
                      ),
                    ),
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                  child: const Text(
                    "Nuova",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Due etichette personalizzabili (ex: "Fatture" / "Fattura in bozza")
              Text(
                label1,
                style: const TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label2,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),

              const SizedBox(width: 8),

              // Tre icone (rotellina, upload cloud, chiusura)
              IconButton(
                onPressed: () {
                  print("Rotellina cliccata");
                },
                icon: const Icon(
                  Icons.settings,
                  color: Colors.black,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () {
                  print("Cloud upload cliccato");
                },
                icon: const Icon(
                  Icons.cloud_upload,
                  color: Colors.black,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () {
                  print("Eliminazione modifiche cliccata");
                },
                icon: const Icon(
                  Icons.close,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------------------
  // Pulsante con menu a tendina (Clienti, Fornitori, Contabilità, ecc.)
  // ----------------------------------------------------------------------
  Widget _buildActionButtonWithMenu(
      String title, BuildContext context, LayerLink link) {
    return CompositedTransformTarget(
      link: link,
      child: TextButton(
        onPressed: () {
          // Mostra il menu a tendina per il pulsante selezionato
          onDropDownMenuButtonPressed(title);
        },
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------------------
  // Pulsante semplice (Bacheca, ecc.)
  // ----------------------------------------------------------------------
  Widget _buildActionButton(String title, BuildContext context) {
    return TextButton(
      onPressed: () {
        onMenuButtonPressed(title);
      },
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Se serve ancora gestire i menu a tendina, la funzione di utilità
// rimane disponibile; in caso non serva, puoi rimuoverla.
// ----------------------------------------------------------------------
OverlayEntry createDropdownMenu({
  required BuildContext context,
  required LayerLink link,
  required VoidCallback onClose,
  required AppbarActionsMenu content,
}) {
  return OverlayEntry(
    builder: (context) {
      return GestureDetector(
        onTap: onClose, // Chiude il menu quando si clicca fuori
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Positioned(
              child: CompositedTransformFollower(
                link: link,
                showWhenUnlinked: false,
                offset: const Offset(0, 40), // Offset per il menu
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    width: 250, // Larghezza del menu
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: content,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
