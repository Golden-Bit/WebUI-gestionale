import 'package:flutter/material.dart';

class TaskBoardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isMenuOpen;
  final VoidCallback onMenuToggle;
  final VoidCallback onCreateBoard;
  final VoidCallback onAddTaskList;
  final VoidCallback onOpenFilter; // Callback per aprire il filtro

  TaskBoardAppBar({
    required this.isMenuOpen,
    required this.onMenuToggle,
    required this.onCreateBoard,
    required this.onAddTaskList,
    required this.onOpenFilter, // Aggiunto il nuovo parametro
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 4, // Aggiunge l'elevazione per l'ombreggiatura
      backgroundColor: Colors.white, // Sfondo bianco per l'AppBar
      shadowColor: Colors.black, // Colore dell'ombra
      leadingWidth: 100, // Imposta la larghezza del lato sinistro
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black), // Freccia indietro nera
            onPressed: () => Navigator.of(context).pop(),
          ),
          IconButton(
            icon: Icon(
              isMenuOpen ? Icons.close : Icons.menu,
              color: Colors.black,
            ), // Simbolo hamburger o chiudi
            onPressed: onMenuToggle,
          ),
        ],
      ),
      title: const Text(
        'Task Board',
        style: TextStyle(color: Colors.black), // Testo nero
      ),
      centerTitle: false, // Mantiene il titolo allineato a sinistra
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0), // Aggiunge padding
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Crea Board',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: onCreateBoard, // Callback per creare una board
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[700]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0), // Aggiunge padding
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Crea Task List',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: onAddTaskList, // Callback per aggiungere una lista di task
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[700]),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.filter_alt, color: Colors.black), // Icona filtro
          onPressed: onOpenFilter, // Callback per aprire il dialog di filtro
          tooltip: 'Filtra Task', // Tooltip per maggiore chiarezza
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
