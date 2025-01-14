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
          taskColumns.clear(); // Cancella le colonne se la board eliminata era selezionata
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
        onDeleteBoard: _deleteBoard, // Passa il callback per eliminare una board
      ),
    );
  }
}
