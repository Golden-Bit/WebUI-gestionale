import 'package:flutter/material.dart';
import 'package:flutter_app/pages/task_board/components/workspace_helpers.dart';

class WorkspaceAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Workspace? selectedWorkspace;
  final List<Workspace> workspaces;
  final Function(Workspace?) onWorkspaceChanged;
  final VoidCallback onAddWorkspace;
  final VoidCallback onMenuToggle;
  final bool isMenuOpen;
  final VoidCallback onCreateBoard;
  final VoidCallback onAddTaskList;
  final VoidCallback onOpenFilter;
  final Function(String) onSearchQueryChanged;
  final FocusNode searchFocusNode;

  const WorkspaceAppBar({
    Key? key,
    required this.selectedWorkspace,
    required this.workspaces,
    required this.onWorkspaceChanged,
    required this.onAddWorkspace,
    required this.onMenuToggle,
    required this.isMenuOpen,
    required this.onCreateBoard,
    required this.onAddTaskList,
    required this.onOpenFilter,
    required this.onSearchQueryChanged,
    required this.searchFocusNode,
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
            'Home',
            style: TextStyle(color: Colors.black),
          ),
          const SizedBox(width: 16),
          _WorkspaceDropdownButton(
            selectedWorkspace: selectedWorkspace,
            workspaces: workspaces,
            onWorkspaceChanged: onWorkspaceChanged,
          ),
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
          const SizedBox(width: 16),
          ElevatedButton.icon(
            icon:
                const Icon(Icons.add, color: Colors.white), // Icona aggiornata
            label: const Text(
              'Crea Spazio di Lavoro', // Testo aggiornato
              style: TextStyle(color: Colors.white),
            ),
            onPressed: onAddWorkspace, // Callback aggiornato
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.grey[700], // Colore di sfondo
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4.0), // Arrotonda gli angoli
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: 16.0, // Margini interni orizzontali
      vertical: 12.0, // Margini interni verticali
    ),
  ),
          ),
        ],
      ),
      centerTitle: false,
      actions: [
        // Barra di ricerca
        Container(
          width: 240,
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFDDDDDD)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            focusNode: searchFocusNode,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              prefixIcon: const Icon(Icons.search, color: Colors.black),
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

class _WorkspaceDropdownButton extends StatelessWidget {
  final Workspace? selectedWorkspace;
  final List<Workspace> workspaces;
  final Function(Workspace?) onWorkspaceChanged;

  const _WorkspaceDropdownButton({
    Key? key,
    required this.selectedWorkspace,
    required this.workspaces,
    required this.onWorkspaceChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Workspace>(
      onSelected: onWorkspaceChanged,
      itemBuilder: (BuildContext context) => workspaces
          .map(
            (workspace) => PopupMenuItem<Workspace>(
              value: workspace,
              child: Text(
                workspace.name,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          )
          .toList(),
      child: TextButton.icon(
        onPressed: null, // Il PopupMenuButton gestisce i clic
        icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
        label: Text(
          selectedWorkspace?.name ?? 'Seleziona Spazio di Lavoro',
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
