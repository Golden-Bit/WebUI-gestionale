import 'package:flutter/material.dart';
import 'package:flutter_app/pages/task_board/components/task_board_app_bar.dart';
import 'package:flutter_app/pages/task_board/components/task_board_body.dart';
import 'package:flutter_app/pages/task_board/components/task_board_class.dart';
import 'package:flutter_app/pages/task_board/components/task_board_service.dart';
import 'package:flutter_app/pages/task_board/components/task_board_ui_helpers.dart';
import 'package:flutter_app/pages/task_board/components/task_class.dart';
import 'package:flutter_app/pages/task_board/components/task_column.dart';

class TaskBoard extends StatefulWidget {
  final String token;
  final String dbName;

  TaskBoard(
      {required this.token,
      required this.dbName}); // Accetta il token come parametro

  @override
  _TaskBoardState createState() => _TaskBoardState();
}

class _TaskBoardState extends State<TaskBoard> {
  List<TaskColumnData> taskColumns = [];
  List<Board> boards = []; // Lista di board esistenti
  Board? currentBoard; // Board attualmente selezionata
  String currentBoardId = 'my_board';
  bool _isMenuOpen = false; // Indica se il menu laterale è aperto
List<TaskColumnData> originalTaskColumns = []; // Nuova lista per mantenere i dati originali
List<Label> availableLabels = []; // Elenco delle etichette disponibili
List<Label> selectedLabels = []; // Elenco delle etichette selezionate
bool matchAllLabels = false; // Indica se devono essere soddisfatte tutte le etichette

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
    _loadBoardsFromDatabase(); // Carica le board
  }

Future<void> _loadTasksFromDatabase() async {
  try {
    final loadedColumns = await loadTasksFromDatabase(
      widget.token,
      widget.dbName,
      currentBoardId,
    );

    setState(() {
      taskColumns = loadedColumns;
      originalTaskColumns = List.from(loadedColumns);

      // Estrai etichette uniche dai task
      final labelSet = <String, Label>{};
      for (final column in loadedColumns) {
        for (final task in column.tasks) {
          for (final label in task.labels) {
            labelSet[label.name] = label;
          }
        }
      }
      availableLabels = labelSet.values.toList();
    });
  } catch (e) {
    print("Errore durante il caricamento dei task: $e");
  }
}


  Future<void> _saveTaskColumnToDatabase(TaskColumnData column) async {
    try {
      await saveTaskColumnToDatabase(
        widget.token,
        widget.dbName,
        currentBoardId,
        column,
      );
    } catch (e) {
      print("Errore durante il salvataggio della lista: $e");
    }
  }

  Future<void> _saveTaskToDatabase(Task task) async {
    try {
      await saveTaskToDatabase(widget.token, widget.dbName, task);
    } catch (e) {
      print("Errore durante il salvataggio del task: $e");
    }
  }

  Future<void> _updateTaskInDatabase(Task task) async {
    try {
      await updateTaskInDatabase(widget.token, widget.dbName, task);
    } catch (e) {
      print("Errore durante l'aggiornamento del task: $e");
    }
  }

  Future<void> _deleteTaskFromDatabase(Task task) async {
    try {
      await deleteTaskFromDatabase(widget.token, widget.dbName, task);
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
        _deleteTaskFromDatabase(task); // Elimina il task dal database
      }
    });
  }

  void _updateTask(Task oldTask, Task updatedTask) {
    setState(() {
      for (var column in taskColumns) {
        if (column.id == oldTask.list) {
          // Usa l'ID della colonna
          int index = column.tasks.indexOf(oldTask);
          if (index != -1) {
            column.tasks[index] = updatedTask;
            updatedTask.databaseId = oldTask.databaseId;
            _updateTaskInDatabase(updatedTask); // Aggiorna il task nel database
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
      labels: task.labels
          .map((label) => Label(
                name: label.name,
                color: label.color,
              ))
          .toList(),
      dueDate: task.dueDate,
      estimatedTime: task.estimatedTime,
      attachments: task.attachments,
    );
    _addTask(duplicatedTask, list);
  }

  void _removeTaskColumn(String columnId) async {
    try {
      final columnToRemove =
          taskColumns.firstWhere((column) => column.id == columnId);

      setState(() {
        taskColumns.remove(columnToRemove); // Rimuove la colonna dallo stato
      });

      await removeTaskColumnFromDatabase(
        widget.token,
        widget.dbName,
        columnToRemove,
      );
    } catch (e) {
      print("Errore durante l'eliminazione della lista: $e");
    }
  }

  void _duplicateTaskColumn(TaskColumnData column) async {
    try {
      final duplicatedColumn =
          await duplicateTaskColumn(currentBoardId, column);

      setState(() {
        taskColumns.add(duplicatedColumn);
      });

      await _saveTaskColumnToDatabase(duplicatedColumn);
    } catch (e) {
      print("Errore durante la duplicazione della lista: $e");
    }
  }

  void _moveTask(Task task, String newListId, int newIndex) {
    setState(() {
      // Rimuovi il task dalla vecchia colonna
      for (var column in taskColumns) {
        if (column.id == task.list) {
          // Ora task.list contiene l'ID della colonna
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
      _updateTaskInDatabase(task); // Aggiorna il task nel database
    });
  }

  /// Funzione per modificare una board
  void _editBoard(Board updatedBoard) async {
    try {
      await updateBoardInDatabase(widget.token, widget.dbName, updatedBoard);

      setState(() {
        final boardIndex =
            boards.indexWhere((board) => board.id == updatedBoard.id);
        if (boardIndex != -1) {
          boards[boardIndex] = updatedBoard; // Aggiorna la board
          if (currentBoardId == updatedBoard.id) {
            currentBoard = updatedBoard; // Aggiorna la board corrente
          }
        }
      });
    } catch (e) {
      print("Errore durante la modifica della board: $e");
    }
  }

  /// Funzione per eliminare una board
  void _deleteBoard(Board board) async {
    try {
      await deleteBoardFromDatabase(widget.token, widget.dbName, board);

      setState(() {
        boards.remove(board);
        if (currentBoardId == board.id) {
          currentBoard = boards.isNotEmpty ? boards.first : null;
          currentBoardId = currentBoard?.id ?? '';
          taskColumns
              .clear(); // Cancella le colonne se la board eliminata era selezionata
          if (currentBoard != null) _loadTasksFromDatabase();
        }
      });
    } catch (e) {
      print("Errore durante l'eliminazione della board: $e");
    }
  }

  void _showCreateBoardDialog() {
    showCreateBoardDialog(
      context: context,
      token: widget.token,
      dbName: widget.dbName,
      onBoardCreated: (newBoard) {
        setState(() {
          boards.add(newBoard);
          currentBoard = newBoard;
          currentBoardId = newBoard.id;
          taskColumns.clear();
        });
      },
    );
  }

  Future<void> _loadBoardsFromDatabase() async {
    try {
      final loadedBoards = await loadBoardsFromDatabase(
        widget.token,
        widget.dbName,
      );

      setState(() {
        boards = loadedBoards;

        if (currentBoard == null && boards.isNotEmpty) {
          currentBoard = boards.first;
          currentBoardId = currentBoard!.id;
          _loadTasksFromDatabase();
        }
      });
    } catch (e) {
      print("Errore durante il caricamento delle board: $e");
    }
  }

  void _showAddTaskColumnDialog(BuildContext context) {
    showAddTaskColumnDialog(
      context: context,
      currentBoardId: currentBoardId,
      onTaskColumnCreated: (columnTitle) {
        setState(() {
          final newColumn = TaskColumnData(currentBoardId, columnTitle, []);
          taskColumns.add(newColumn);
          _saveTaskColumnToDatabase(newColumn);
        });
      },
    );
  }

  void _navigateToAddTaskPage(BuildContext context, String listId,
      {Task? task}) {
    navigateToAddTaskPage(
      context: context,
      listId: listId,
      labels: labels,
      members: members,
      existingTask: task,
      onAddTask: (newTask) {
        if (task != null) {
          _updateTask(task, newTask);
        } else {
          _addTask(newTask, listId);
        }
      },
    );
  }

  void _showTaskDetails(Task task) {
    showTaskDetails(
      context: context,
      task: task,
      onDeleteTask: _removeTask,
      customizeMarkdownCheckboxes: _customizeMarkdownCheckboxes,
    );
  }






void _showFilterDialog(BuildContext context) {
  String keyword = ''; // Parola chiave
  bool showNoMembers = true;
  bool showAssignedToMe = true;
  bool showNoDueDate = true;
  bool showOverdue = false;
  bool showDueTomorrow = false;
  bool matchAllLabels = false; // Indica se devono essere soddisfatte tutte le etichette
  List<Label> selectedLabels = []; // Etichette selezionate

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // Angoli arrotondati
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titolo del dialog
                    const Text(
                      'Filtro',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Filtro per parola chiave
                    const Text('Parola Chiave'),
                    TextField(
                      onChanged: (value) => keyword = value,
                      decoration: const InputDecoration(
                        hintText: 'Inserisci una parola chiave...',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Filtro per membri
                    const Text('Membri'),
                    CheckboxListTile(
                      value: showNoMembers,
                      onChanged: (value) => setState(() => showNoMembers = value!),
                      title: const Text('Nessun membro'),
                    ),
                    CheckboxListTile(
                      value: showAssignedToMe,
                      onChanged: (value) => setState(() => showAssignedToMe = value!),
                      title: const Text('Schede assegnate a me'),
                    ),
                    const SizedBox(height: 16),

                    // Filtro per data di scadenza
                    const Text('Data di Scadenza'),
                    CheckboxListTile(
                      value: showNoDueDate,
                      onChanged: (value) => setState(() => showNoDueDate = value!),
                      title: const Text('Nessuna scadenza'),
                    ),
                    CheckboxListTile(
                      value: showOverdue,
                      onChanged: (value) => setState(() => showOverdue = value!),
                      title: const Text('Scaduto'),
                    ),
                    CheckboxListTile(
                      value: showDueTomorrow,
                      onChanged: (value) => setState(() => showDueTomorrow = value!),
                      title: const Text('In scadenza domani'),
                    ),
                    const SizedBox(height: 16),

                    // Filtro per etichette
                    const Text('Etichette'),
                    CheckboxListTile(
                      value: matchAllLabels,
                      onChanged: (value) => setState(() => matchAllLabels = value!),
                      title: const Text('Richiedi tutte le etichette'),
                    ),
                    const SizedBox(height: 8),

                    // Lista scrollabile delle etichette
                    Container(
                      height: 200, // Altezza limitata della lista
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: availableLabels.length,
                        itemBuilder: (context, index) {
                          final label = availableLabels[index];
                          final isSelected = selectedLabels.contains(label);
                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (selected) {
                              setState(() {
                                if (selected!) {
                                  selectedLabels.add(label);
                                } else {
                                  selectedLabels.remove(label);
                                }
                              });
                            },
                            title: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: label.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(label.name),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Pulsanti di azione
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Pulsante per annullare
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Annulla'),
                        ),
                        // Pulsante per reimpostare i filtri
                        TextButton(
                          onPressed: () {
                            setState(() {
                              taskColumns = List.from(originalTaskColumns); // Ripristina dati originali
                            });
                            Navigator.of(context).pop();
                          },
                          child: const Text('Reimposta'),
                        ),
                        // Pulsante per applicare i filtri
                        ElevatedButton(
                          onPressed: () {
                            _applyFilters(
                              keyword,
                              showNoMembers,
                              showAssignedToMe,
                              showNoDueDate,
                              showOverdue,
                              showDueTomorrow,
                              selectedLabels,
                              matchAllLabels,
                            );
                            Navigator.of(context).pop();
                          },
                          child: const Text('Applica'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

void _applyFilters(
  String keyword,
  bool showNoMembers,
  bool showAssignedToMe,
  bool showNoDueDate,
  bool showOverdue,
  bool showDueTomorrow,
  List<Label> selectedLabels,
  bool matchAllLabels, // Nuovo parametro per indicare il tipo di filtro sulle etichette
) {
  setState(() {
    taskColumns = originalTaskColumns.map((column) {
      final filteredTasks = column.tasks.where((task) {
        // Filtra per parola chiave
        if (keyword.isNotEmpty && !task.description.contains(keyword)) {
          return false;
        }

        // Filtra per membri
        if (!showNoMembers && task.members.isEmpty) return false;
        if (!showAssignedToMe && task.members.any((m) => m.name == 'Me')) {
          return false;
        }

        // Filtra per data di scadenza
        if (!showNoDueDate && task.dueDate.isEmpty) return false;
        if (showOverdue &&
            DateTime.tryParse(task.dueDate)?.isBefore(DateTime.now()) == false) {
          return false;
        }
        if (showDueTomorrow &&
            DateTime.tryParse(task.dueDate)
                    ?.isAtSameMomentAs(DateTime.now().add(const Duration(days: 1))) ==
                false) {
          return false;
        }

        // Filtra per etichette
        if (selectedLabels.isNotEmpty) {
          final taskLabels = task.labels.toSet();
          if (matchAllLabels) {
            // Deve soddisfare tutte le etichette selezionate
            if (!selectedLabels.every((label) => taskLabels.contains(label))) {
              return false;
            }
          } else {
            // Deve soddisfare almeno una delle etichette selezionate
            if (!selectedLabels.any((label) => taskLabels.contains(label))) {
              return false;
            }
          }
        }

        return true;
      }).toList();

      return TaskColumnData(
        column.boardId,
        column.title,
        filteredTasks,
        id: column.id,
        databaseId: column.databaseId,
      );
    }).toList();
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TaskBoardAppBar(
  isMenuOpen: _isMenuOpen,
  onMenuToggle: () {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  },
  onCreateBoard: _showCreateBoardDialog,
  onAddTaskList: () => _showAddTaskColumnDialog(context),
  onOpenFilter: () => _showFilterDialog(context), // Nuovo callback
),
      body: TaskBoardBody(
        isMenuOpen: _isMenuOpen,
        boards: boards,
        currentBoard: currentBoard,
        taskColumns: taskColumns,
        currentBoardId: currentBoardId,
        onBoardSelected: (boardId) {
          setState(() {
            currentBoardId = boardId;
            currentBoard = boards.firstWhere(
                (board) => board.id == boardId); // Aggiorna anche currentBoard
            taskColumns.clear();
            _loadTasksFromDatabase(); // Ricarica le colonne relative alla bacheca selezionata
          });
        },
        onCreateBoard: _showCreateBoardDialog,
        onAddTaskColumn: (listId) => _showAddTaskColumnDialog(context),
        onMoveTask: _moveTask,
        onRemoveTask: _removeTask,
        onTaskTap: _showTaskDetails,
        onDuplicateTask: _duplicateTask,
        onRemoveColumn: _removeTaskColumn,
        onDuplicateColumn: _duplicateTaskColumn,
        navigateToAddTaskPage: _navigateToAddTaskPage,
        onEditBoard: _editBoard, // Passa il callback per modificare una board
        onDeleteBoard:
            _deleteBoard, // Passa il callback per eliminare una board
      ),
    );
  }
}
