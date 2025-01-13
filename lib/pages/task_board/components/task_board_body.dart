import 'package:flutter/material.dart';
import 'package:flutter_app/pages/task_board/components/task_board_class.dart';
import 'package:flutter_app/pages/task_board/components/task_column.dart';
import 'package:flutter_app/pages/task_board/components/task_class.dart';

class TaskBoardBody extends StatelessWidget {
  final bool isMenuOpen; // Indica se il menu laterale è aperto
  final List<Board> boards; // Elenco delle bacheche
  final Board? currentBoard; // Bacheca selezionata
  final List<TaskColumnData> taskColumns; // Elenco delle colonne
  final String currentBoardId; // ID della bacheca corrente
  final Function(String) onBoardSelected; // Callback per selezionare una bacheca
  final VoidCallback onCreateBoard; // Callback per creare una nuova bacheca
  final Function(String) onAddTaskColumn; // Callback per aggiungere una colonna
  final Function(Task, String, int) onMoveTask; // Callback per spostare un task
  final Function(Task) onRemoveTask; // Callback per rimuovere un task
  final Function(Task) onTaskTap; // Callback per selezionare un task
  final Function(Task, String) onDuplicateTask; // Callback per duplicare un task
  final Function(String) onRemoveColumn; // Callback per rimuovere una colonna
  final Function(TaskColumnData) onDuplicateColumn; // Callback per duplicare una colonna
  final Function(BuildContext, String, {Task? task}) navigateToAddTaskPage; // Navigazione per aggiungere un task

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
              color: Colors.white, // Sfondo bianco per il menu
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sezione: "Bacheche"
                  Padding(
                    padding: const EdgeInsets.all(16.0),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                    leading: Icon(Icons.table_chart, color: Colors.black),
                    title: Text('Tabella', style: TextStyle(color: Colors.black)),
                    onTap: () {
                      // Logica per Tabella
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.calendar_today, color: Colors.black),
                    title: Text('Calendario', style: TextStyle(color: Colors.black)),
                    onTap: () {
                      // Logica per Calendario
                    },
                  ),
                  const Divider(color: Colors.black45), // Separatore scuro

                  // Sezione: "Le tue bacheche"
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Le tue bacheche',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: Colors.black),
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
      final bool isSelected = currentBoardId == board.id; // Controlla se è la bacheca selezionata

      return GestureDetector(
        onTap: () => onBoardSelected(board.id), // Chiama il callback con l'ID della bacheca selezionata
        child: Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: isSelected ? Colors.grey[700] : Colors.grey[200], // Sfondo diverso per la bacheca selezionata
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            board.name,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black, // Testo bianco se selezionato
              fontSize: 14,
            ),
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
          child: taskColumns.isNotEmpty
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: taskColumns.map((column) {
                      return Container(
                        width: 300,
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
                              navigateToAddTaskPage(context, column.id, task: task),
                        ),
                      );
                    }).toList(),
                  ),
                )
              : Center(
                  child: Text(
                    'Nessuna lista di task trovata per questa bacheca.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ),
        ),
      ],
    );
  }
}
