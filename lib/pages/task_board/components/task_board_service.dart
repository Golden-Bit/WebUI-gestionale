/*import 'package:flutter_app/databases_manager/database_service.dart';
import 'package:flutter_app/pages/task_board/components/task_class.dart';
import 'package:flutter_app/pages/task_board/components/task_column.dart';
import 'package:uuid/uuid.dart';

class TaskBoardService {
  final DatabaseService _databaseService = DatabaseService();

  // Assicura che la collezione "boards" esista nel database
  Future<void> ensureBoardsCollection(String token) async {
    const globalDbName = "sans7-database_0";
    final collections = await _databaseService.fetchCollections(globalDbName, token);

    if (!collections.any((col) => col.name == 'boards')) {
      await _databaseService.createCollection(globalDbName, 'boards', token);
    }
  }

  // Carica tutte le bacheche
  Future<List<Board>> fetchBoards(String token) async {
    await ensureBoardsCollection(token);
    const globalDbName = "sans7-database_0";
    final boardsData = await _databaseService.fetchCollectionData(globalDbName, 'boards', token);
    return boardsData.map((json) => Board.fromJson(json)).toList();
  }

  // Crea una nuova bacheca
  Future<void> createBoard(String title, String token) async {
    await ensureBoardsCollection(token);
    const globalDbName = "sans7-database_0";
    final newBoard = Board(id: const Uuid().v4(), title: title);

    await _databaseService.addDataToCollection(globalDbName, 'boards', newBoard.toJson(), token);
  }

  // Carica le colonne (task list) per una specifica bacheca
  Future<List<TaskColumnData>> fetchTaskColumns(String boardId, String dbName, String token) async {
    final columnsData = await _databaseService.fetchCollectionData(dbName, 'taskLists', token);

    return columnsData
        .map((json) => TaskColumnData.fromJson(json))
        .where((column) => column.boardId == boardId)
        .toList();
  }

  // Salva una task list
  Future<void> saveTaskColumn(TaskColumnData column, String dbName, String token) async {
    if (column.databaseId != null) {
      await _databaseService.updateCollectionData(dbName, 'taskLists', column.databaseId!, column.toJson(), token);
    } else {
      final response = await _databaseService.addDataToCollection(dbName, 'taskLists', column.toJson(), token);
      column.databaseId = response['id'];
    }
  }

  // Carica i task e li assegna alle colonne
  Future<void> fetchTasksForColumns(List<TaskColumnData> columns, String dbName, String token) async {
    final tasksData = await _databaseService.fetchCollectionData(dbName, 'tasks', token);

    for (var taskJson in tasksData) {
      final task = Task.fromJson(taskJson);
      for (var column in columns) {
        if (column.id == task.list) {
          column.tasks.add(task);
          break;
        }
      }
    }
  }

  // Salva un task
  Future<void> saveTask(Task task, String dbName, String token) async {
    await _databaseService.addDataToCollection(dbName, 'tasks', task.toJson(), token);
  }

  // Aggiorna un task
  Future<void> updateTask(Task task, String dbName, String token) async {
    if (task.databaseId != null) {
      await _databaseService.updateCollectionData(dbName, 'tasks', task.databaseId!, task.toJson(), token);
    } else {
      throw Exception('Task ID is missing for update');
    }
  }

  // Elimina un task
  Future<void> deleteTask(Task task, String dbName, String token) async {
    if (task.databaseId != null) {
      await _databaseService.deleteCollectionData(dbName, 'tasks', task.databaseId!, token);
    } else {
      throw Exception('Task ID is missing for deletion');
    }
  }
}*/

