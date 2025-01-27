import 'package:flutter/material.dart';

class AccountingPage extends StatefulWidget {
  const AccountingPage({Key? key}) : super(key: key);

  @override
  State<AccountingPage> createState() => _AccountingPageState();
}

class _AccountingPageState extends State<AccountingPage> {
  String selectedFilter = "Fatture"; // Per gestire i filtri selezionati
  int selectedViewIndex = 0; // Indice per gestire lo stato dei pulsanti (0: lista, 1: griglia, 2: attività)
final LayerLink _layerLink = LayerLink(); // Link per gestire la sovrapposizione
OverlayEntry? _overlayEntry; // Overlay menu entry
final FocusNode _searchFocusNode = FocusNode(); // Focus per la barra di ricerca

void _showOverlayMenu() {
  _overlayEntry = OverlayEntry(
    builder: (context) {
      return Positioned(
        width: 600, // Stessa larghezza della barra di ricerca
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 50), // Distanza dal widget di riferimento
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.history, color: Colors.grey),
                    title: const Text(
                      "Ricerca recente 1",
                      style: TextStyle(fontSize: 14),
                    ),
                    onTap: () {
                      print("Ricerca recente 1 selezionata");
                      _closeOverlayMenu();
                    },
                  ),
                  const Divider(height: 1, color: Colors.grey),
                  ListTile(
                    leading: const Icon(Icons.history, color: Colors.grey),
                    title: const Text(
                      "Ricerca recente 2",
                      style: TextStyle(fontSize: 14),
                    ),
                    onTap: () {
                      print("Ricerca recente 2 selezionata");
                      _closeOverlayMenu();
                    },
                  ),
                  const Divider(height: 1, color: Colors.grey),
                  ListTile(
                    leading: const Icon(Icons.clear, color: Colors.red),
                    title: const Text(
                      "Cancella cronologia",
                      style: TextStyle(fontSize: 14, color: Colors.red),
                    ),
                    onTap: () {
                      print("Cronologia cancellata");
                      _closeOverlayMenu();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  // Aggiungi l'overlay
  Overlay.of(context).insert(_overlayEntry!);
}

void _closeOverlayMenu() {
  _overlayEntry?.remove();
  _overlayEntry = null;
}

@override
void dispose() {
  _searchFocusNode.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120), // Altezza personalizzata
        child: Column(
          children: [
            // Prima barra superiore
            AppBar(
              backgroundColor: Colors.white,
              elevation: 4,
              title: Row(
                children: [
                  // Icona principale
                  const Icon(
                    Icons.insert_chart, // Puoi cambiare con un'icona personalizzata
                    color: Colors.deepPurple,
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
                  _buildActionButton("Bacheca"),
                  _buildActionButton("Clienti"),
                  _buildActionButton("Fornitori"),
                  _buildActionButton("Contabilità"),
                  _buildActionButton("Rendicontazione"),
                  _buildActionButton("Configurazione"),
                ],
              ),
              actions: [
  // Simbolo notifiche
  Padding(
    padding: const EdgeInsets.only(right: 16), // Padding tra notifiche e attività
    child: Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.red),
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
    padding: const EdgeInsets.only(right: 16), // Padding tra attività e avatar
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
              color: Colors.grey[100],
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  // Pulsante "Nuovo" con stile personalizzato
      TextButton(
        onPressed: () {
          print("Nuovo cliccato");
        },
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFF6B3A5B), // Colore viola scuro
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4), // Angoli arrotondati
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          backgroundColor: const Color(0xFFEAEAEA), // Colore grigio chiaro
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4), // Angoli arrotondati
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
SizedBox(width: 75),                  // Barra di ricerca centrata orizzontalmente con larghezza massima
Spacer(),
Center(
  child: ConstrainedBox(
  constraints: const BoxConstraints(maxWidth: 600), // Larghezza massima di 600
  child: CompositedTransformTarget(
    link: _layerLink, // Collega la barra di ricerca al menu
    child: Container(
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4), // Angoli arrotondati a 4 gradi
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        focusNode: _searchFocusNode,
        textAlignVertical: TextAlignVertical.center,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.black),
          contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 10),
          hintText: "Ricerca...",
          border: InputBorder.none,
        ),
        onTap: () {
          if (_overlayEntry == null) {
            _showOverlayMenu(); // Mostra il menu in sovrapposizione
          }
        },
      ),
    ),
  ),
),

), 
Spacer(),// Spaziatore per mantenere gli elementi distribuiti
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
        backgroundColor: const Color(0xFFEAEAEA), // Stile pulsante grigio
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(8),
      ),
      child: const Icon(Icons.chevron_left, color: Colors.black, size: 20),
    ),
    const SizedBox(width: 8),
    // Freccia destra
    TextButton(
      onPressed: () {
        print("Freccia destra cliccata");
      },
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xFFEAEAEA), // Stile pulsante grigio
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(8),
      ),
      child: const Icon(Icons.chevron_right, color: Colors.black, size: 20),
    ),
    const SizedBox(width: 16), // Spaziatura tra frecce e pulsanti vista
    // Pulsanti vista (Elenco, Kanban, Attività)
    Tooltip(
      message: "Elenco",
      child: TextButton(
        onPressed: () {
          setState(() {
            selectedViewIndex = 0;
          });
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
          color: selectedViewIndex == 0 ? Colors.teal : Colors.black,
          size: 20,
        ),
      ),
    ),
    const SizedBox(width: 8),
    Tooltip(
      message: "Kanban",
      child: TextButton(
        onPressed: () {
          setState(() {
            selectedViewIndex = 1;
          });
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
          color: selectedViewIndex == 1 ? Colors.teal : Colors.black,
          size: 20,
        ),
      ),
    ),
    const SizedBox(width: 8),
    Tooltip(
      message: "Attività",
      child: TextButton(
        onPressed: () {
          setState(() {
            selectedViewIndex = 2;
          });
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
          color: selectedViewIndex == 2 ? Colors.teal : Colors.black,
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
        ),
      ),
      body: Center(
        // Placeholder per il contenuto della pagina
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.insert_chart_outlined, // Placeholder icon
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              "Placeholder per Contenuti",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Funzione per creare un'azione accanto al titolo
  Widget _buildActionButton(String title) {
    return TextButton(
      onPressed: () {
        print("Navigazione verso $title");
      },
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4), // Angoli arrotondati a 4 gradi
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
