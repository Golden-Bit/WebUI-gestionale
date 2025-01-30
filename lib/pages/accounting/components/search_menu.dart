import 'package:flutter/material.dart';

OverlayEntry createOverlayMenu({
  required BuildContext context,
  required LayerLink layerLink,
  required VoidCallback closeOverlayMenu,
}) {
  return OverlayEntry(
    builder: (context) {
      return GestureDetector(
        onTap: closeOverlayMenu, // Chiude il menu al clic esterno
        behavior: HitTestBehavior.opaque,
        child: Stack(children: [
          Positioned(
            width: 800, // Larghezza uguale alla barra di ricerca
            child: CompositedTransformFollower(
              link: layerLink,
              showWhenUnlinked: false,
              offset: const Offset(-200, 45),
              child: GestureDetector(
                // Permette l'interazione interna senza chiudere il menu
                onTap: () {},
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Colonna "Filtri"
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding:
                                const EdgeInsets.all(8.0), // Margini interni
                            child: Column(
                              spacing: 0,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.filter_alt,
                                        size: 20, color: Color(0xFF6B3A5B)),
                                    SizedBox(width: 8),
                                    Text(
                                      "Filtri",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildHoverableListTile(
                                  title: "Le mie fatture",
                                  onTap: () => print("Le mie fatture cliccato"),
                                ),
                                const SizedBox(height: 3),
                                const Divider(),
                                const SizedBox(height: 3),
                                _buildHoverableListTile(
                                  title: "Bozza",
                                  onTap: () => print("'Bozza' cliccato"),
                                ),
                                _buildHoverableListTile(
                                  title: "Confermata",
                                  onTap: () => print("'Confermata' cliccato"),
                                ),
                                _buildHoverableListTile(
                                  title: "Annullata",
                                  onTap: () => print("'Annullata' cliccato"),
                                ),
                                const SizedBox(height: 3),
                                const Divider(),
                                const SizedBox(height: 3),
                                _buildHoverableListTile(
                                  title: "Non inviato",
                                  onTap: () => print("'Non inviato' cliccato"),
                                ),
                                _buildHoverableListTile(
                                  title: "Fatture",
                                  onTap: () => print("'Fatture' cliccato"),
                                ),
                                _buildHoverableListTile(
                                  title: "Note di credito",
                                  onTap: () =>
                                      print("'Note di credito' cliccato"),
                                ),
                                const SizedBox(height: 3),
                                const Divider(),
                                const SizedBox(height: 3),
                                _buildHoverableListTile(
                                  title: "Da controllare",
                                  onTap: () =>
                                      print("'Da controllare' cliccato"),
                                ),
                                _buildHoverableListTile(
                                  title: "Peppol pronto",
                                  onTap: () =>
                                      print("'Peppol pronto' cliccato"),
                                ),
                                const SizedBox(height: 3),
                                const Divider(),
                                const SizedBox(height: 3),
                                _buildHoverableListTile(
                                  title: "Da pagare",
                                  onTap: () => print("'Da pagare' cliccato"),
                                ),
                                _buildHoverableListTile(
                                  title: "In pagamento",
                                  onTap: () => print("'In pagamento' cliccato"),
                                ),
                                _buildHoverableListTile(
                                  title: "In ritardo",
                                  onTap: () => print("'In ritardo' cliccato"),
                                ),
                                const SizedBox(height: 3),
                                const Divider(),
                                const SizedBox(height: 3),
                                _buildHoverableListTile(
                                  title: "Data fattura",
                                  trailing: const Icon(Icons.arrow_drop_down,
                                      size: 20),
                                  onTap: () => print("'Data fattura' cliccato"),
                                ),
                                _buildHoverableListTile(
                                  title: "Scadenza",
                                  trailing: const Icon(Icons.arrow_drop_down,
                                      size: 20),
                                  onTap: () => print("'Scadenza' cliccato"),
                                ),
                                const SizedBox(height: 3),
                                const Divider(),
                                const SizedBox(height: 3),
                                _buildHoverableListTile(
                                  title: "Aggiungi filtro personalizzato",
                                  trailing: const Icon(Icons.add, size: 20),
                                  onTap: () => print(
                                      "'Aggiungi filtro personalizzato' cliccato"),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const VerticalDivider(
                          width: 1,
                          color: Colors.grey,
                        ),
                        // Colonna "Raggruppa per"
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding:
                                const EdgeInsets.all(8.0), // Margini interni
                            child: Column(
                              spacing: 0,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.layers,
                                        size: 20, color: Colors.teal),
                                    SizedBox(width: 8),
                                    Text(
                                      "Raggruppa per",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildHoverableListTile(
                                  title: "Addetto vendite",
                                  onTap: () =>
                                      print("'Addetto vendite' cliccato"),
                                ),
                                _buildHoverableListTile(
                                  title: "Partner",
                                  onTap: () => print("'Partner' cliccato"),
                                ),
                                _buildHoverableListTile(
                                  title: "Stato",
                                  onTap: () => print("'Stato' cliccato"),
                                ),
                                _buildHoverableListTile(
                                  title: "Stato Peppol",
                                  onTap: () => print("'Stato Peppol' cliccato"),
                                ),
                                _buildHoverableListTile(
                                  title: "Metodo di pagamento",
                                  onTap: () =>
                                      print("'Metodo di pagamento' cliccato"),
                                ),
                                const SizedBox(height: 3),
                                const Divider(),
                                const SizedBox(height: 3),
                                _buildHoverableListTile(
                                  title: "Data fattura",
                                  trailing: const Icon(Icons.arrow_drop_down,
                                      size: 20),
                                  onTap: () => print("'Data fattura' cliccato"),
                                ),
                                _buildHoverableListTile(
                                  title: "Scadenza",
                                  trailing: const Icon(Icons.arrow_drop_down,
                                      size: 20),
                                  onTap: () => print("'Scadenza' cliccato"),
                                ),
                                _buildHoverableListTile(
                                  title: "Data contabile",
                                  trailing: const Icon(Icons.arrow_drop_down,
                                      size: 20),
                                  onTap: () =>
                                      print("'Data contabile' cliccato"),
                                ),
                                const SizedBox(height: 3),
                                const Divider(),
                                const SizedBox(height: 3),
                                _buildHoverableListTile(
                                  title: "Aggiungi gruppo personalizzato",
                                  trailing: const Icon(Icons.arrow_drop_down,
                                      size: 20),
                                  onTap: () => print(
                                      "'Aggiungi gruppo personalizzato' cliccato"),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const VerticalDivider(
                          width: 1,
                          color: Colors.grey,
                        ),
                        // Colonna "Preferiti"
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding:
                                const EdgeInsets.all(8.0), // Margini interni
                            child: Column(
                              spacing: 0,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.star,
                                        size: 20, color: Colors.yellow),
                                    SizedBox(width: 8),
                                    Text(
                                      "Preferiti",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildHoverableListTile(
                                  title: "Salva ricerca corrente",
                                  trailing: const Icon(Icons.arrow_drop_down,
                                      size: 20),
                                  onTap: () => print(
                                      "'Salva ricerca corrente' cliccato"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]),
      );
    },
  );
}

Widget _buildHoverableListTile({
  required String title,
  required VoidCallback onTap,
  Widget? leading,
  Widget? trailing,
}) {
  Color backgroundColor = Colors.white; // Colore di sfondo iniziale

  return StatefulBuilder(
    builder: (context, setState) {
      return MouseRegion(
        onEnter: (_) {
          setState(() {
            backgroundColor = Colors.grey[200]!; // Colore hover
          });
        },
        onExit: (_) {
          setState(() {
            backgroundColor = Colors.white; // Ripristina colore normale
          });
        },
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                //shape: BoxShape.rectangle,
                color: backgroundColor), // Sfondo dinamico basato sull'hover
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                if (leading != null) leading, // Icona opzionale a sinistra
                const SizedBox(width: 8), // Spaziatura tra leading e titolo
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                if (trailing != null) trailing, // Icona opzionale a destra
              ],
            ),
          ),
        ),
      );
    },
  );
}
