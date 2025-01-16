import 'package:flutter/material.dart';
import 'package:flutter_app/pages/task_board/components/task_board_class.dart';
import 'package:flutter_app/pages/task_board/components/tasks_calendar_view.dart';
import 'package:flutter_app/pages/task_board/components/task_column.dart';
import 'package:flutter_app/pages/task_board/components/task_class.dart';
import 'package:flutter_app/pages/task_board/components/tasks_table_view.dart';
import 'package:flutter_app/pages/task_board/components/top_bar.dart';

class TaskBoardBody extends StatelessWidget {
  final bool isMenuOpen; // Indica se il menu laterale è aperto
  final List<Board> boards; // Elenco delle bacheche
  final Board? currentBoard; // Bacheca selezionata
  final List<TaskColumnData> taskColumns; // Elenco delle colonne
  final String currentBoardId; // ID della bacheca corrente
  final Function(String)
      onBoardSelected; // Callback per selezionare una bacheca
  final VoidCallback onCreateBoard; // Callback per creare una nuova bacheca
  final Function(String) onAddTaskColumn; // Callback per aggiungere una colonna
  final Function(Task, String, int) onMoveTask; // Callback per spostare un task
  final Function(Task) onRemoveTask; // Callback per rimuovere un task
  final Function(Task) onTaskTap; // Callback per selezionare un task
  final Function(Task, String)
      onDuplicateTask; // Callback per duplicare un task
  final Function(String) onRemoveColumn; // Callback per rimuovere una colonna
  final Function(TaskColumnData)
      onDuplicateColumn; // Callback per duplicare una colonna
  final Function(BuildContext, String, {Task? task})
      navigateToAddTaskPage; // Navigazione per aggiungere un task
  final Function(Board) onEditBoard; // Callback per modificare una board
  final Function(Board) onDeleteBoard; // Callback per eliminare una board
  final VoidCallback onOpenFilter; // Callback aggiunto

  /// Vista corrente (Bacheca, Tabella, Calendario)
  final BoardView currentView;

  /// Callback per cambiare la vista
  final Function(BoardView) onViewSelected;

  const TaskBoardBody({
    Key? key,
    required this.isMenuOpen,
    required this.boards,
    required this.currentBoard,
    required this.taskColumns,
    required this.currentBoardId,
    required this.onBoardSelected,
    required this.onCreateBoard,
    required this.onAddTaskColumn,
    required this.onMoveTask,
    required this.onRemoveTask,
    required this.onTaskTap,
    required this.onDuplicateTask,
    required this.onRemoveColumn,
    required this.onDuplicateColumn,
    required this.navigateToAddTaskPage,
    required this.onEditBoard,
    required this.onDeleteBoard,
    required this.onOpenFilter,
    required this.currentView,
    required this.onViewSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Menu laterale
        if (isMenuOpen)
          Material(
            elevation: 6, // Elevazione per aggiungere ombra
            child: Container(
              width: 300,
              decoration: const BoxDecoration(
                color: Colors.white, // Sfondo bianco per il menu
                border: Border(
                  right: BorderSide(
                      color: Colors.grey,
                      width: 1), // Bordo destro grigio sottile
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sezione: "Bacheche"
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Bacheche',
                      style: TextStyle(
                        color: Colors.black, // Testo nero
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(color: Colors.black45), // Separatore scuro

                  // Sezione: "Viste dello spazio di lavoro"
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Viste dello spazio di lavoro',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.view_column, color: Colors.black),
                    title: const Text('Bacheca',
                        style: TextStyle(color: Colors.black)),
                    onTap: () => onViewSelected(BoardView.board),
                  ),
                  ListTile(
                    leading: const Icon(Icons.table_chart, color: Colors.black),
                    title: const Text('Tabella',
                        style: TextStyle(color: Colors.black)),
                    onTap: () => onViewSelected(BoardView.table),
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.calendar_today, color: Colors.black),
                    title: const Text('Calendario',
                        style: TextStyle(color: Colors.black)),
                    onTap: () => onViewSelected(BoardView.calendar),
                  ),
                  const Divider(color: Colors.black45), // Separatore scuro

                  // Sezione: "Le tue bacheche"
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Le tue bacheche',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.black),
                          onPressed: onCreateBoard,
                        ),
                      ],
                    ),
                  ),

                  // Lista delle bacheche
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: boards.length,
                      itemBuilder: (context, index) {
                        final board = boards[index];
                        final bool isSelected = currentBoardId ==
                            board.id; // Controlla se è la bacheca selezionata

                        return GestureDetector(
                          onTap: () => onBoardSelected(board.id),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.grey[700]
                                  : Colors.grey[
                                      200], // Sfondo diverso per la bacheca selezionata
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Nome della board
                                Text(
                                  board.name,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                                // Menu a tre pallini
                                if (isSelected)
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black),
                                    onSelected: (value) {
                                      if (value == 'modifica') {
                                        _showEditBoardDialog(context, board);
                                      } else if (value == 'elimina') {
                                        onDeleteBoard(board);
                                      }
                                    },
                                    itemBuilder: (BuildContext context) => [
                                      const PopupMenuItem(
                                        value: 'modifica',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, size: 18),
                                            SizedBox(width: 8),
                                            Text('Modifica'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'elimina',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, size: 18),
                                            SizedBox(width: 8),
                                            Text('Elimina'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

// Contenuto principale
Expanded(
  child: Stack(
    children: [
      // Sfondo bianco
      Container(color: Colors.white),

      Column(
        children: [
          // Riquadro superiore
          TopBarWidget(
            boardName: currentBoard?.name ?? 'Nessuna Board',
            onVisibilityPressed: () {
              // Logica per il pulsante Visibilità
            },
            onFilterPressed: onOpenFilter,
            currentView: currentView,
            onViewSelected: onViewSelected,
          ),

          // Contenuto principale dinamico
          Expanded(
            child: Container(
              width: double.infinity, // Assicura che occupi tutta la larghezza
              child: Builder(
                builder: (context) {
                  if (currentView == BoardView.board) {
                    // Vista Bacheca
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        width: double.infinity, // Larghezza completa
                        child: Row(
                          children: taskColumns.map((column) {
                            return Container(
                              width: 300,
                              margin: const EdgeInsets.only(left: 8.0),
                              child: TaskColumn(
                                id: column.id,
                                title: column.title,
                                tasks: column.tasks,
                                onMoveTask: onMoveTask,
                                onAddTask: () =>
                                    navigateToAddTaskPage(context, column.id),
                                onRemoveTask: onRemoveTask,
                                onTaskTap: onTaskTap,
                                onDuplicateTask: onDuplicateTask,
                                onRemoveColumn: onRemoveColumn,
                                onDuplicateColumn: onDuplicateColumn,
                                onEditTask: (task) =>
                                    navigateToAddTaskPage(context, column.id,
                                        task: task),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  } else if (currentView == BoardView.table) {
                    // Vista Tabella
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Container(
                        width: double.infinity, // Larghezza completa
                        child: TaskTableView(taskColumns: taskColumns),
                      ),
                    );
                  } else if (currentView == BoardView.calendar) {
  return CustomTaskCalendar(
    tasks: taskColumns
        .expand((column) => column.tasks) // Combina tutti i task
        .toList(),
    onTaskTap: onTaskTap, // Callback per interagire con i task
  );
} else {
                    return const SizedBox.shrink();
                  }
                },
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

  /// Mostra un dialog per modificare una board
  void _showEditBoardDialog(BuildContext context, Board board) {
    final TextEditingController nameController =
        TextEditingController(text: board.name);
    final TextEditingController descriptionController =
        TextEditingController(text: board.description);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modifica Bacheca'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome Bacheca'),
              ),
              TextField(
                controller: descriptionController,
                decoration:
                    const InputDecoration(labelText: 'Descrizione Bacheca'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedBoard = Board(
                  id: board.id,
                  name: nameController.text,
                  description: descriptionController.text,
                  databaseId: board.databaseId,
                );
                onEditBoard(updatedBoard);
                Navigator.of(context).pop();
              },
              child: const Text('Salva'),
            ),
          ],
        );
      },
    );
  }
}
