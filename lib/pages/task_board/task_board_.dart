import 'package:flutter/material.dart';
import 'package:flutter_app/pages/task_board/add_task.dart';
import 'package:flutter_app/pages/task_board/components/task_class.dart';
import 'package:flutter_app/pages/task_board/components/task_column.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../databases_manager/database_service.dart';
import '../../user_manager/auth_service.dart';


class TaskBoard extends StatefulWidget {
  final String token;
  final String dbName;

  TaskBoard({required this.token,required this.dbName});  // Accetta il token come parametro

  @override
  _TaskBoardState createState() => _TaskBoardState();
}
class _TaskBoardState extends State<TaskBoard> {
  List<TaskColumnData> taskColumns = [];
  String currentBoardId = 'my_board'; // Board attuale

  List<Label> labels = [];
  List<Member> members = [
    Member(name: 'John Doe'),
    Member(name: 'Jane Smith'),
    Member(name: 'Alice Johnson'),
    Member(name: 'Bob Brown'),
    Member(name: 'Charlie White'),
    Member(name: 'Daisy Green'),
    Member(name: 'Eve Black'),
    Member(name: 'Frank Yellow'),
    Member(name: 'Grace Blue'),
    Member(name: 'Hank Red'),
  ];

  String _customizeMarkdownCheckboxes(String markdown) {
    return markdown.replaceAllMapped(
      RegExp(r'- \[( |x)\] '),
      (match) {
        final isChecked = match.group(1) == 'x';
        return '\n ${isChecked ? '☑️' : '⬜'} ';
      },
    );
  }

 // Caricare i task dal database durante l'inizializzazione
  @override
  void initState() {
    super.initState();
    _loadTasksFromDatabase();
  }

Future<void> _loadTasksFromDatabase() async {
  try {
    final databaseService = DatabaseService();
    final authService = AuthService();

    // Ottenere l'utente corrente utilizzando il token
    final user = await authService.fetchCurrentUser(widget.token);
    final dbName = '${user.username}-${widget.dbName}';

    // Carica le liste dal database, filtrando per boardId
    final listsData = await databaseService.fetchCollectionData(dbName, 'taskLists', widget.token);

    setState(() {
      // Pulisci le colonne esistenti
      taskColumns.clear();

      // Filtra le liste per boardId e aggiungile alla board
      for (var listJson in listsData) {
        if (listJson['boardId'] == currentBoardId) {
          final taskColumn = TaskColumnData.fromJson(listJson);
          taskColumns.add(taskColumn);
        }
      }
    });

    // Ora carica i task e assegnali alle colonne corrette
    final tasksData = await databaseService.fetchCollectionData(dbName, 'tasks', widget.token);

    setState(() {
      for (var taskJson in tasksData) {
        final task = Task.fromJson(taskJson);
        for (var column in taskColumns) {
          if (column.id == task.list) {
            column.tasks.add(task);
            break;
          }
        }
      }
    });
  } catch (e) {
    print("Errore durante il caricamento dei task: $e");
  }
}


Future<void> _saveTaskColumnToDatabase(TaskColumnData column) async {
  try {
    final databaseService = DatabaseService();
    final authService = AuthService();

    final user = await authService.fetchCurrentUser(widget.token);
    final dbName = '${user.username}-${widget.dbName}';

    // Aggiorna il valore di boardId per la colonna
    column.boardId = currentBoardId;

    if (column.databaseId != null) {
      await databaseService.updateCollectionData(dbName, 'taskLists', column.databaseId!, column.toJson(), widget.token);
    } else {
      final newDatabaseId = (await databaseService.addDataToCollection(dbName, 'taskLists', column.toJson(), widget.token))["id"];
      setState(() {
        column.databaseId = newDatabaseId;
      });
    }
  } catch (e) {
    print("Errore durante il salvataggio della lista: $e");
  }
}

Future<void> _saveTaskToDatabase(Task task) async {
  try {
    final databaseService = DatabaseService();
    final authService = AuthService();

    final user = await authService.fetchCurrentUser(widget.token);
    final dbName = '${user.username}-${widget.dbName}';
    final collectionName = 'tasks';

    await databaseService.addDataToCollection(dbName, collectionName, task.toJson(), widget.token);
  } catch (e) {
    print("Errore durante il salvataggio del task: $e");
  }
}

  Future<void> _updateTaskInDatabase(Task task) async {
    try {
      final databaseService = DatabaseService();
      final authService = AuthService();

      final user = await authService.fetchCurrentUser(widget.token);
      final dbName = '${user.username}-${widget.dbName}';
      final collectionName = 'tasks';

      if (task.databaseId != null) {
      await databaseService.updateCollectionData(dbName, collectionName, task.databaseId!, task.toJson(), widget.token);
      } else {        print("Errore: ID del documento MongoDB non disponibile.");
      }
    } catch (e) {
      print("Errore durante l'aggiornamento del task: $e");
    }
  }

  Future<void> _deleteTaskFromDatabase(Task task) async {
    try {
      final databaseService = DatabaseService();
      final authService = AuthService();

      final user = await authService.fetchCurrentUser(widget.token);
      final dbName = '${user.username}-${widget.dbName}';
      final collectionName = 'tasks';

      if (task.databaseId != null) {
        await databaseService.deleteCollectionData(dbName, collectionName, task.databaseId!, widget.token);
      } else {
        print("Errore: ID del documento MongoDB non disponibile.");
      }
    } catch (e) {
      print("Errore durante l'eliminazione del task: $e");
    }
  }

void _addTask(Task task, String listId, {bool updateState = true}) {
  if (updateState) {
    setState(() {
      for (var column in taskColumns) {
        if (column.id == listId) {
          column.tasks.add(task);
          print("Task aggiunto alla colonna: ${column.title}"); // Debug log
          _saveTaskToDatabase(task);
          break;
        }
      }
    });
  }
}


  void _removeTask(Task task) {
    setState(() {
      for (var column in taskColumns) {
        column.tasks.remove(task);
        _deleteTaskFromDatabase(task);  // Elimina il task dal database
      }
    });
  }

  void _updateTask(Task oldTask, Task updatedTask) {
  setState(() {
    for (var column in taskColumns) {
      if (column.id == oldTask.list) {  // Usa l'ID della colonna
        int index = column.tasks.indexOf(oldTask);
        if (index != -1) {
          column.tasks[index] = updatedTask;
          updatedTask.databaseId = oldTask.databaseId;
          _updateTaskInDatabase(updatedTask);  // Aggiorna il task nel database
        }
        break;
      }
    }
  });
}

  void _duplicateTask(Task task, String list) {
    final duplicatedTask = Task(
      title: '${task.title} (Copy)',
      description: task.description,
      list: list,
      markerColor: task.markerColor,
      members: task.members.map((member) => Member(name: member.name)).toList(),
      labels: task.labels.map((label) => Label(
        name: label.name,
        color: label.color,
      )).toList(),
      dueDate: task.dueDate,
      estimatedTime: task.estimatedTime,
      attachments: task.attachments,
    );
    _addTask(duplicatedTask, list);
  }

void _removeTaskColumn(String columnId) async {
  try {
    // Trova la colonna da eliminare
    final columnToRemove = taskColumns.firstWhere((column) => column.id == columnId);

    // Rimuovi la colonna dallo stato
    setState(() {
      taskColumns.removeWhere((column) => column.id == columnId);
    });

    // Elimina la colonna dal database
    if (columnToRemove.databaseId != null) {
      final databaseService = DatabaseService();
      final authService = AuthService();

      final user = await authService.fetchCurrentUser(widget.token);
      final dbName = '${user.username}-${widget.dbName}';

      await databaseService.deleteCollectionData(dbName, 'taskLists', columnToRemove.databaseId!, widget.token);
    } else {
      print("Errore: ID del documento MongoDB non disponibile per l'eliminazione.");
    }
  } catch (e) {
    print("Errore durante l'eliminazione della lista: $e");
  }
}

void _duplicateTaskColumn(TaskColumnData column) async {
  try {
    final duplicatedColumn = TaskColumnData(
      currentBoardId,
      '${column.title} (Copy)',
      column.tasks.map((task) => Task(
        title: '${task.title} (Copy)',
        description: task.description,
        list: column.id,
        markerColor: task.markerColor,
        members: task.members.map((member) => Member(name: member.name)).toList(),
        labels: task.labels.map((label) => Label(
          name: label.name,
          color: label.color,
        )).toList(),
        dueDate: task.dueDate,
        estimatedTime: task.estimatedTime,
        attachments: task.attachments,
      )).toList(),
    );

    setState(() {
      taskColumns.add(duplicatedColumn);
    });

    // Salva la colonna duplicata nel database
    await _saveTaskColumnToDatabase(duplicatedColumn);
  } catch (e) {
    print("Errore durante la duplicazione della lista: $e");
  }
}


void _moveTask(Task task, String newListId, int newIndex) {
  setState(() {
    // Rimuovi il task dalla vecchia colonna
    for (var column in taskColumns) {
      if (column.id == task.list) { // Ora task.list contiene l'ID della colonna
        column.tasks.remove(task);
        break;
      }
    }

    // Aggiorna il valore della lista con il nuovo ID
    task.list = newListId;

    // Inserisci il task nella nuova colonna
    for (var column in taskColumns) {
      if (column.id == newListId) {
        if (newIndex > column.tasks.length) newIndex = column.tasks.length;
        column.tasks.insert(newIndex, task);
        break;
      }
    }
    _updateTaskInDatabase(task);  // Aggiorna il task nel database
  });
}

 void _showAddTaskColumnDialog(BuildContext context) {
  final _titleController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Create Task List'),
        content: TextField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (taskColumns.any((column) => column.title == _titleController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('A list with this name already exists'),
                    ),
                  );
                } else {
                  final newColumn = TaskColumnData(
                    currentBoardId, // Assegna il valore di currentBoardId
                    _titleController.text,
                    [],
                  );
                  taskColumns.add(newColumn);
                  _saveTaskColumnToDatabase(newColumn); // Salva la nuova colonna nel database
                }
              });
              Navigator.of(context).pop();
            },
            child: Text(
              'Create',
              style: TextStyle(color: Colors.grey[800]),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
            ),
          ),
        ],
      );
    },
  );
}


  void _navigateToAddTaskPage(BuildContext context, String listId, {Task? task}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AddTaskPage(
        list: listId,  // Passa l'ID della colonna
        onAddTask: (newTask) {
          if (task != null) {
            _updateTask(task, newTask);
          } else {
            _addTask(newTask, listId);
          }
        },
        labels: labels,
        members: members,
        onAddLabel: (label) {
          setState(() {
            labels.add(label);
          });
        },
        onAddMember: (member) {
          setState(() {
            members.add(member);
          });
        },
        existingTask: task,
      ),
    ),
  );
}

  void _showTaskDetails(Task task) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: EdgeInsets.all(0),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 40,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: task.markerColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        topRight: Radius.circular(8.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _removeTask(task);
                            Navigator.of(context).pop();
                          },
                          color: Colors.black,
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        if (task.description.isNotEmpty)
                          _buildTaskField(
                            title: "Description",
                            content: MarkdownBody(
                              data: _customizeMarkdownCheckboxes(task.description),
                            ),
                          ),
                        if (task.members.isNotEmpty)
                          _buildTaskField(
                            title: "Members",
                            content: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: task.members.map((member) {
                                  return Chip(
                                    label: Text(member.name, style: TextStyle(color: Colors.black87)),
                                    backgroundColor: Colors.grey[200],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        if (task.labels.isNotEmpty)
                          _buildTaskField(
                            title: "Labels",
                            content: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: task.labels.map((label) {
                                  return Chip(
                                    label: Text(label.name, style: TextStyle(color: Colors.black87)),
                                    backgroundColor: label.color,
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        if (task.dueDate.isNotEmpty || task.estimatedTime.isNotEmpty)
                          _buildTaskField(
                            title: "Due Date & Estimated Time",
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (task.dueDate.isNotEmpty)
                                  Text('Due Date: ${task.dueDate}'),
                                if (task.estimatedTime.isNotEmpty)
                                  Text('Estimated Time: ${task.estimatedTime}'),
                              ],
                            ),
                          ),
                        if (task.attachments.isNotEmpty)
                          _buildTaskField(
                            title: "Attachments",
                            content: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: task.attachments.split(', ').map((attachment) {
                                  return Chip(
                                    label: Text(attachment),
                                    backgroundColor: Colors.grey[200],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildTaskField({required String title, required Widget content}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(12.0),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Board'),
        actions: [
          ElevatedButton.icon(
            icon: Icon(Icons.add, color: Colors.grey[800]),
            label: Text(
              'Crea Task List',
              style: TextStyle(color: Colors.grey[800]),
            ),
            onPressed: () => _showAddTaskColumnDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
    onMoveTask: _moveTask,
    onAddTask: () => _navigateToAddTaskPage(context, column.id),  // Passa l'ID della colonna
    onRemoveTask: _removeTask,
    onTaskTap: _showTaskDetails,
    onDuplicateTask: _duplicateTask,
    onRemoveColumn: _removeTaskColumn,
    onDuplicateColumn: _duplicateTaskColumn,
    onEditTask: (task) => _navigateToAddTaskPage(context, column.id, task: task), // Passa l'ID della colonna
  ),
);
          }).toList(),
        ),
      ),
    );
  }
}



