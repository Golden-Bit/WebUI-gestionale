import 'package:flutter/material.dart';
import 'package:flutter_app/pages/task_board/components/task_card.dart';
import 'package:flutter_app/pages/task_board/components/task_class.dart';
import 'package:uuid/uuid.dart';

/// Rappresenta una singola bacheca.
/*class Board {
  final String id;
  final String title;

  Board({required this.id, required this.title});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      id: json['id'],
      title: json['title'],
    );
  }
}*/

/// Rappresenta una singola colonna (Task List) appartenente a una bacheca.
class TaskColumnData {
  final String id; // ID della colonna
  String boardId; // ID della bacheca di appartenenza
  String title; // Titolo della colonna
  List<Task> tasks; // Lista di task appartenenti alla colonna
  String? databaseId; // ID specifico del documento MongoDB

  TaskColumnData(this.boardId, this.title, this.tasks, {String? id, this.databaseId})
      : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'boardId': boardId,
      'title': title,
      'tasks': tasks.map((task) => task.toJson()).toList(),
    };
  }

  factory TaskColumnData.fromJson(Map<String, dynamic> json) {
    return TaskColumnData(
      json['boardId'], // ID della bacheca
      json['title'], // Titolo della colonna
      (json['tasks'] as List).map((taskJson) => Task.fromJson(taskJson)).toList(),
      id: json['id'], // ID della colonna
      databaseId: json['_id'], // ID del documento nel database
    );
  }
}

/// Widget per visualizzare una singola colonna nella board.
class TaskColumn extends StatefulWidget {
  final String id; // ID della colonna
  final String title; // Titolo della colonna
  final List<Task> tasks; // Lista di task appartenenti alla colonna
  final Function(Task, String, int) onMoveTask; // Funzione per spostare un task
  final VoidCallback onAddTask; // Funzione per aggiungere un task
  final Function(Task) onRemoveTask; // Funzione per rimuovere un task
  final Function(Task) onTaskTap; // Funzione per visualizzare i dettagli di un task
  final Function(Task, String) onDuplicateTask; // Funzione per duplicare un task
  final Function(String) onRemoveColumn; // Funzione per rimuovere la colonna
  final Function(TaskColumnData) onDuplicateColumn; // Funzione per duplicare la colonna
  final Function(Task) onEditTask; // Funzione per modificare un task

  const TaskColumn({
    required this.id,
    required this.title,
    required this.tasks,
    required this.onMoveTask,
    required this.onAddTask,
    required this.onRemoveTask,
    required this.onTaskTap,
    required this.onDuplicateTask,
    required this.onRemoveColumn,
    required this.onDuplicateColumn,
    required this.onEditTask,
    Key? key,
  }) : super(key: key);

  @override
  _TaskColumnState createState() => _TaskColumnState();
}

class _TaskColumnState extends State<TaskColumn> {
  late List<Task> tasks;

  @override
  void initState() {
    super.initState();
    tasks = widget.tasks;
  }

  @override
  void didUpdateWidget(TaskColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tasks != widget.tasks) {
      tasks = widget.tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header della colonna (titolo e menu opzioni)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    widget.onRemoveColumn(widget.id);
                  } else if (value == 'duplicate') {
                    widget.onDuplicateColumn(
                      TaskColumnData(widget.id, widget.title, widget.tasks),
                    );
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Elimina'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'duplicate',
                      child: Text('Duplica'),
                    ),
                  ];
                },
              ),
            ],
          ),

          // Lista di task
          Expanded(
            child: DragTarget<Task>(
              onWillAccept: (task) => true,
              onAcceptWithDetails: (details) {
                setState(() {
                  int newIndex = (details.offset.dy ~/ 80).clamp(0, tasks.length);
                  widget.onMoveTask(details.data, widget.id, newIndex);
                });
              },
              builder: (context, candidateData, rejectedData) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return Draggable<Task>(
                      key: ValueKey(tasks[index].id),
                      data: tasks[index],
                      feedback: Material(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Container(
                          width: 300,
                          child: TaskCard(
                            key: ValueKey(tasks[index].id),
                            task: tasks[index],
                            onMoveTask: widget.onMoveTask,
                            onRemoveTask: widget.onRemoveTask,
                            onTaskTap: widget.onTaskTap,
                            onDuplicateTask: widget.onDuplicateTask,
                            onEditTask: widget.onEditTask,
                          ),
                        ),
                        elevation: 6.0,
                        shadowColor: Colors.black.withOpacity(0.5),
                      ),
                      childWhenDragging: Container(),
                      child: TaskCard(
                        key: ValueKey(tasks[index].id),
                        task: tasks[index],
                        onMoveTask: widget.onMoveTask,
                        onRemoveTask: widget.onRemoveTask,
                        onTaskTap: widget.onTaskTap,
                        onDuplicateTask: widget.onDuplicateTask,
                        onEditTask: widget.onEditTask,
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Pulsante per aggiungere nuovi task
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Crea Task',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: widget.onAddTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
