import 'package:flutter/material.dart';
import 'package:flutter_app/pages/task_board/components/task_card.dart';
import 'package:flutter_app/pages/task_board/components/task_class.dart';
import 'package:flutter_app/pages/task_board/task_board_.dart';
import 'package:uuid/uuid.dart';

class TaskColumnData {
  final String id;
  String title;
  List<Task> tasks;
  String? databaseId; // ID specifico del documento MongoDB

  TaskColumnData(this.title, this.tasks, {String? id, this.databaseId}) : id = id ?? Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'tasks': tasks.map((task) => task.toJson()).toList(),
    };
  }

  factory TaskColumnData.fromJson(Map<String, dynamic> json) {
    return TaskColumnData(
      json['title'],
      (json['tasks'] as List).map((taskJson) => Task.fromJson(taskJson)).toList(),
      id: json['id'],
      databaseId: json['_id'], // Carica l'ID specifico del documento MongoDB
    );
  }
}

class TaskColumn extends StatefulWidget {
  final String id; // Aggiungi questo campo
  final String title;
  final List<Task> tasks;
  final Function(Task, String, int) onMoveTask;
  final VoidCallback onAddTask;
  final Function(Task) onRemoveTask;
  final Function(Task) onTaskTap;
  final Function(Task, String) onDuplicateTask;
  final Function(String) onRemoveColumn;
  final Function(TaskColumnData) onDuplicateColumn;
  final Function(Task) onEditTask;

  const TaskColumn({
    required this.id, // Aggiungi questo parametro
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
  });

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
      margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
PopupMenuButton<String>(
  onSelected: (value) {
    if (value == 'delete') {
      widget.onRemoveColumn(widget.id); // Usa l'ID della colonna
    } else if (value == 'duplicate') {
      widget.onDuplicateColumn(TaskColumnData(widget.title, widget.tasks)); // Crea una copia della colonna attuale
    }
  },
  itemBuilder: (BuildContext context) {
    return [
      PopupMenuItem<String>(
        value: 'delete',
        child: Text('Elimina'),
      ),
      PopupMenuItem<String>(
        value: 'duplicate',
        child: Text('Duplica'),
      ),
    ];
  },
),
            ],
          ),
Expanded(
  child: DragTarget<Task>(
    onWillAccept: (task) => true,
    onAcceptWithDetails: (details) {
      setState(() {
        int newIndex = (details.offset.dy ~/ 80).clamp(0, tasks.length);
        widget.onMoveTask(details.data, widget.id, newIndex);  // Passa l'ID della colonna
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
          Container(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(Icons.add, color: Colors.grey[800]),
              label: Text(
                'Crea Task',
                style: TextStyle(color: Colors.grey[800]),
              ),
              onPressed: widget.onAddTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
              ),
            ),
          ),
        ],
      ),
    );
  }
}