import 'package:flutter/material.dart';

class TaskBoardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isMenuOpen;
  final VoidCallback onMenuToggle;
  final VoidCallback onCreateBoard;
  final VoidCallback onAddTaskList;
  final VoidCallback onOpenFilter;
  final Function(String) onSearchQueryChanged; // Callback per la ricerca
  final FocusNode searchFocusNode; // FocusNode per il campo di ricerca

  const TaskBoardAppBar({
    Key? key,
    required this.isMenuOpen,
    required this.onMenuToggle,
    required this.onCreateBoard,
    required this.onAddTaskList,
    required this.onOpenFilter,
    required this.onSearchQueryChanged,
    required this.searchFocusNode, // FocusNode passato come parametro
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 4,
      backgroundColor: Colors.white,
      shadowColor: Colors.black,
      leadingWidth: 100,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          IconButton(
            icon: Icon(
              isMenuOpen ? Icons.close : Icons.menu,
              color: Colors.black,
            ),
            onPressed: onMenuToggle,
          ),
        ],
      ),
      title: Row(
        children: [
          const Text(
            'Task Board',
            style: TextStyle(color: Colors.black),
          ),
          const SizedBox(width: 16), // Spazio tra il titolo e i pulsanti
          _DropdownButtonWithMenu(
            label: 'Spazi di lavoro',
            items: ['Opzione 1', 'Opzione 2', 'Opzione 3'], // Elementi del menu
            onSelected: (value) {
              print('Selezionato in "Spazi di lavoro": $value');
            },
          ),
          const SizedBox(width: 16),
          _DropdownButtonWithMenu(
            label: 'Recenti',
            items: ['Progetto 1', 'Progetto 2', 'Progetto 3'],
            onSelected: (value) {
              print('Selezionato in "Recenti": $value');
            },
          ),
          const SizedBox(width: 16),
          _DropdownButtonWithMenu(
            label: 'Preferita',
            items: ['Preferito 1', 'Preferito 2', 'Preferito 3'],
            onSelected: (value) {
              print('Selezionato in "Preferita": $value');
            },
          ),
          const SizedBox(width: 16),
          _DropdownButtonWithMenu(
            label: 'Modelli',
            items: ['Modello 1', 'Modello 2', 'Modello 3'],
            onSelected: (value) {
              print('Selezionato in "Modelli": $value');
            },
          ),
          //const SizedBox(width: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Crea Board',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: onCreateBoard,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700], // Colore di sfondo
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(4.0), // Arrotonda gli angoli
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, // Margini interni orizzontali
                  vertical: 12.0, // Margini interni verticali
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Crea Task List',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: onAddTaskList,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700], // Colore di sfondo
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(4.0), // Arrotonda gli angoli
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, // Margini interni orizzontali
                  vertical: 12.0, // Margini interni verticali
                ),
              ),
            ),
          ),
        ],
      ),
      centerTitle: false,
      actions: [
        // Barra di ricerca         // Barra di ricerca
Container(
  height: 40, // Altezza complessiva del contenitore
  width: 240,
  margin: const EdgeInsets.symmetric(horizontal: 8.0),
  //padding: const EdgeInsets.fromLTRB(0,0,0,0),
  decoration: BoxDecoration(
    color: Colors.white,
    border: Border.all(color: const Color(0xFFDDDDDD)),
    borderRadius: BorderRadius.circular(4),
  ),
  child: TextField(
    focusNode: searchFocusNode,
    textAlignVertical: TextAlignVertical.center, // Allinea il testo verticalmente
    decoration: const InputDecoration(
      contentPadding: EdgeInsets.fromLTRB(0,0,0,10), // Centra il testo e il cursore
      prefixIcon: Icon(Icons.search, color: Colors.black),
      hintText: 'Ricerca',
      border: InputBorder.none,
    ),
    onChanged: onSearchQueryChanged,
  ),
),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            color: Colors.grey[700],
            shape: BoxShape.circle,
          ),
          /*child: IconButton(
            icon: const Icon(Icons.filter_alt, color: Colors.white),
            onPressed: onOpenFilter,
            tooltip: 'Filtra Task',
          ),*/
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            color: Colors.grey[700],
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
            tooltip: 'Notifiche',
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            color: Colors.grey[700],
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {},
            tooltip: 'Info',
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            color: Colors.grey[700],
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Text(
              'IE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {},
            tooltip: 'Utente',
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _DropdownButtonWithMenu extends StatelessWidget {
  final String label;
  final List<String> items;
  final Function(String) onSelected;

  const _DropdownButtonWithMenu({
    Key? key,
    required this.label,
    required this.items,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (BuildContext context) => items
          .map(
            (item) => PopupMenuItem<String>(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
      child: TextButton.icon(
        onPressed: null, // Usa il PopupMenuButton per gestire i clic
        icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
        label: Text(
          label,
          style: const TextStyle(color: Colors.black),
        ),
        style: TextButton.styleFrom(
          backgroundColor: Colors.grey[200], // Sfondo grigio chiaro
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4), // Angoli arrotondati
          ),
        ),
      ),
    );
  }
}
