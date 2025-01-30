import 'package:flutter/material.dart';
import 'package:flutter_app/pages/accounting/components/appbar_actions_menu.dart';

class CustomAppBar extends StatelessWidget {
  final LayerLink searchLayerLink;
  final FocusNode searchFocusNode;
  final OverlayEntry? searchMenuOverlay;
  final VoidCallback showOverlayMenu;
  final VoidCallback closeOverlayMenu;
  final int selectedViewIndex;
  final Function(int) onViewChanged;
  // Funzione per mostrare il menu a tendina
  final Function(String) onDropDownMenuButtonPressed;
  final Function(String) onMenuButtonPressed;

  // LayerLinks per ogni pulsante
  final LayerLink clientiLayerLink;
  final LayerLink fornitoriLayerLink;
  final LayerLink contabilitaLayerLink;
  final LayerLink rendicontazioneLayerLink;
  final LayerLink configurazioneLayerLink;

  const CustomAppBar({
    Key? key,
    required this.searchLayerLink,
    required this.searchFocusNode,
    required this.searchMenuOverlay,
    required this.showOverlayMenu,
    required this.closeOverlayMenu,
    required this.selectedViewIndex,
    required this.onViewChanged,
    required this.onDropDownMenuButtonPressed,
        required this.onMenuButtonPressed,
    required this.clientiLayerLink,
    required this.fornitoriLayerLink,
    required this.contabilitaLayerLink,
    required this.rendicontazioneLayerLink,
    required this.configurazioneLayerLink,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Prima barra superiore
        AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            children: [
              // Icona principale
              const Icon(
                Icons.insert_chart, // Puoi cambiare con un'icona personalizzata
                color: Color(0xFF6B3A5B),
              ),
              const SizedBox(width: 8), // Spazio tra icona e titolo
              const Text(
                "Contabilità",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 24), // Spazio prima delle azioni
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
              padding: const EdgeInsets.only(
                  right: 16), // Padding tra notifiche e attività
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
                      decoration: BoxDecoration(
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
              padding: const EdgeInsets.only(
                  right: 16), // Padding tra attività e avatar
              child: IconButton(
                icon: const Icon(Icons.local_activity, color: Colors.black),
                onPressed: () {
                  print("Attività cliccate");
                },
              ),
            ),
            // Avatar utente
            const Padding(
              padding: EdgeInsets.only(right: 16), // Padding tra avatar e bordo
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
        // Seconda barra sotto il titolo
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey, // Colore del bordo inferiore
                width: 1.0, // Spessore del bordo inferiore
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              // Pulsante "Nuovo" con stile personalizzato
              TextButton(
                onPressed: () {
                  print("Nuovo cliccato");
                },
                style: TextButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF6B3A5B), // Colore viola scuro
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(4), // Angoli arrotondati
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text(
                  "Nuovo",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Pulsante "Carica" con stile personalizzato
              TextButton(
                onPressed: () {
                  print("Carica cliccato");
                },
                style: TextButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFEAEAEA), // Colore grigio chiaro
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(4), // Angoli arrotondati
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text(
                  "Carica",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 16), // Spaziatura tra pulsanti e titolo
              // Titolo sezione con rotellina
              Row(
                children: [
                  const Text(
                    "Titolo Sezione", // Titolo accanto ai pulsanti
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      print("Rotellina cliccata");
                    },
                    icon: const Icon(
                      Icons.settings, // Icona rotellina
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                  width:
                      75), // Barra di ricerca centrata orizzontalmente con larghezza massima
              Spacer(),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                      maxWidth: 600), // Larghezza massima di 600
                  child: CompositedTransformTarget(
                    link: searchLayerLink, // Collega la barra di ricerca al menu
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                            4), // Angoli arrotondati a 4 gradi
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        focusNode: searchFocusNode,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search, color: Colors.black),
                          contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                          hintText: "Ricerca...",
                          border: InputBorder.none,
                        ),
                        onTap: () {
                          if (searchMenuOverlay == null) {
                            showOverlayMenu(); // Mostra il menu in sovrapposizione
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Spacer(), // Spaziatore per mantenere gli elementi distribuiti
              // Pulsanti vista (es. lista, griglia, attività) ancorati al lato destro
              // Sezione elementi mostrati con frecce e pulsanti vista
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Testo con indice degli elementi
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "1-10 / 100", // Aggiorna dinamicamente se necessario
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // Freccia sinistra
                  TextButton(
                    onPressed: () {
                      print("Freccia sinistra cliccata");
                    },
                    style: TextButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFEAEAEA), // Stile pulsante grigio
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.all(8),
                    ),
                    child: const Icon(Icons.chevron_left,
                        color: Colors.black, size: 20),
                  ),
                  const SizedBox(width: 2),
                  // Freccia destra
                  TextButton(
                    onPressed: () {
                      print("Freccia destra cliccata");
                    },
                    style: TextButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFEAEAEA), // Stile pulsante grigio
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.all(8),
                    ),
                    child: const Icon(Icons.chevron_right,
                        color: Colors.black, size: 20),
                  ),
                  const SizedBox(
                      width: 16), // Spaziatura tra frecce e pulsanti vista
                  // Pulsanti vista (Elenco, Kanban, Attività)
                  Tooltip(
                    message: "Elenco",
                    child: TextButton(
                      onPressed: () {
                        onViewChanged(0); // Aggiorna la vista selezionata
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: selectedViewIndex == 0
                            ? const Color(0xFFDFF3F2)
                            : const Color(0xFFEAEAEA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.all(8),
                      ),
                      child: Icon(
                        Icons.list,
                        color:
                            selectedViewIndex == 0 ? Colors.teal : Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Tooltip(
                    message: "Kanban",
                    child: TextButton(
                      onPressed: () {
                        onViewChanged(1); // Aggiorna la vista selezionata
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: selectedViewIndex == 1
                            ? const Color(0xFFDFF3F2)
                            : const Color(0xFFEAEAEA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.all(8),
                      ),
                      child: Icon(
                        Icons.view_kanban,
                        color:
                            selectedViewIndex == 1 ? Colors.teal : Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Tooltip(
                    message: "Attività",
                    child: TextButton(
                      onPressed: () {
                        onViewChanged(2); // Aggiorna la vista selezionata
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: selectedViewIndex == 2
                            ? const Color(0xFFDFF3F2)
                            : const Color(0xFFEAEAEA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.all(8),
                      ),
                      child: Icon(
                        Icons.local_activity,
                        color:
                            selectedViewIndex == 2 ? Colors.teal : Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

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

  Widget _buildActionButton(
      String title, BuildContext context) {
    return TextButton(
        onPressed: () {
          // Mostra il menu a tendina per il pulsante selezionato
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

class SearchBarWithOverlay extends StatelessWidget {
  final LayerLink layerLink;
  final FocusNode searchFocusNode;
  final OverlayEntry? overlayEntry;
  final VoidCallback showOverlayMenu;
  final VoidCallback closeOverlayMenu;

  const SearchBarWithOverlay({
    Key? key,
    required this.layerLink,
    required this.searchFocusNode,
    required this.overlayEntry,
    required this.showOverlayMenu,
    required this.closeOverlayMenu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: CompositedTransformTarget(
        link: layerLink,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            focusNode: searchFocusNode,
            textAlignVertical: TextAlignVertical.center,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.black),
              contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              hintText: "Ricerca...",
              border: InputBorder.none,
            ),
            onTap: () {
              if (overlayEntry == null) {
                showOverlayMenu();
              }
            },
          ),
        ),
      ),
    );
  }
}

OverlayEntry createDropdownMenu({
  required BuildContext context,
  required LayerLink link,
  required VoidCallback onClose,
  required AppbarActionsMenu content, // Accetta lista di widget
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
