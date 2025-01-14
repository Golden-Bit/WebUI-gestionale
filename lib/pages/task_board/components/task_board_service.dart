import 'package:flutter_app/databases_manager/database_service.dart';
import 'package:flutter_app/user_manager/auth_service.dart';
import 'package:flutter_app/pages/task_board/components/task_board_class.dart';
import 'package:flutter_app/pages/task_board/components/task_class.dart';
import 'package:flutter_app/pages/task_board/components/task_column.dart';


/// Funzione per caricare i task dal database
Future<List<TaskColumnData>> loadTasksFromDatabase(
  String token,
  String dbName,
  String currentBoardId,
) async {
  final databaseService = DatabaseService();
  final authService = AuthService();

  // Ottenere l'utente corrente utilizzando il token
  final user = await authService.fetchCurrentUser(token);
  final actualDbName = '${user.username}-$dbName';

  // Carica le liste dal database, filtrando per boardId
  final listsData =
      await databaseService.fetchCollectionData(actualDbName, 'taskLists', token);

  List<TaskColumnData> taskColumns = [];
  for (var listJson in listsData) {
    if (listJson['boardId'] == currentBoardId) {
      final taskColumn = TaskColumnData.fromJson(listJson);
      taskColumns.add(taskColumn);
    }
  }

  // Ora carica i task e assegnali alle colonne corrette
  final tasksData =
      await databaseService.fetchCollectionData(actualDbName, 'tasks', token);

  for (var taskJson in tasksData) {
    final task = Task.fromJson(taskJson);
    for (var column in taskColumns) {
      if (column.id == task.list) {
        column.tasks.add(task);
        break;
      }
    }
  }

  return taskColumns;
}

/// Funzione per caricare le board dal database
Future<List<Board>> loadBoardsFromDatabase(String token, String dbName) async {
  final databaseService = DatabaseService();
  final authService = AuthService();

  final user = await authService.fetchCurrentUser(token);
  final actualDbName = '${user.username}-$dbName';

  final boardsData =
      await databaseService.fetchCollectionData(actualDbName, 'boards', token);

  return boardsData.map<Board>((boardJson) => Board.fromJson(boardJson)).toList();
}

/// Funzione per salvare un task nel database
Future<void> saveTaskToDatabase(
  String token,
  String dbName,
  Task task,
) async {
  final databaseService = DatabaseService();
  final authService = AuthService();

  final user = await authService.fetchCurrentUser(token);
  final actualDbName = '${user.username}-$dbName';

  await databaseService.addDataToCollection(
    actualDbName,
    'tasks',
    task.toJson(),
    token,
  );
}





/// Salva una colonna di task nel database
Future<void> saveTaskColumnToDatabase(
  String token,
  String dbName,
  String currentBoardId,
  TaskColumnData column,
) async {
  final databaseService = DatabaseService();
  final authService = AuthService();

  final user = await authService.fetchCurrentUser(token);
  final actualDbName = '${user.username}-$dbName';

  column.boardId = currentBoardId;

  if (column.databaseId != null) {
    // Aggiorna la colonna se esiste
    await databaseService.updateCollectionData(
      actualDbName,
      'taskLists',
      column.databaseId!,
      column.toJson(),
      token,
    );
  } else {
    // Crea una nuova colonna
    final newDatabaseId = (await databaseService.addDataToCollection(
      actualDbName,
      'taskLists',
      column.toJson(),
      token,
    ))["id"];
    column.databaseId = newDatabaseId; // Aggiorna l'ID nel modello
  }
}

/// Elimina una colonna dal database
Future<void> removeTaskColumnFromDatabase(
  String token,
  String dbName,
  TaskColumnData column,
) async {
  if (column.databaseId == null) {
    throw Exception("Errore: ID della colonna non trovato.");
  }

  final databaseService = DatabaseService();
  final authService = AuthService();

  final user = await authService.fetchCurrentUser(token);
  final actualDbName = '${user.username}-$dbName';

  await databaseService.deleteCollectionData(
    actualDbName,
    'taskLists',
    column.databaseId!,
    token,
  );
}

/// Duplica una colonna di task
Future<TaskColumnData> duplicateTaskColumn(
  String currentBoardId,
  TaskColumnData column,
) async {
  final duplicatedColumn = TaskColumnData(
    currentBoardId,
    '${column.title} (Copy)',
    column.tasks.map((task) {
      return Task(
        title: '${task.title} (Copy)',
        description: task.description,
        list: column.id,
        markerColor: task.markerColor,
        members: task.members.map((member) => Member(name: member.name)).toList(),
        labels: task.labels.map((label) => Label(name: label.name, color: label.color)).toList(),
        dueDate: task.dueDate,
        estimatedTime: task.estimatedTime,
        attachments: task.attachments,
      );
    }).toList(),
  );

  return duplicatedColumn;
}

/// Aggiorna un task nel database
Future<void> updateTaskInDatabase(
  String token,
  String dbName,
  Task task,
) async {
  if (task.databaseId == null) {
    throw Exception("Errore: ID del task non trovato.");
  }

  final databaseService = DatabaseService();
  final authService = AuthService();

  final user = await authService.fetchCurrentUser(token);
  final actualDbName = '${user.username}-$dbName';

  await databaseService.updateCollectionData(
    actualDbName,
    'tasks',
    task.databaseId!,
    task.toJson(),
    token,
  );
}

/// Elimina un task dal database
Future<void> deleteTaskFromDatabase(
  String token,
  String dbName,
  Task task,
) async {
  if (task.databaseId == null) {
    throw Exception("Errore: ID del task non trovato.");
  }

  final databaseService = DatabaseService();
  final authService = AuthService();

  final user = await authService.fetchCurrentUser(token);
  final actualDbName = '${user.username}-$dbName';

  await databaseService.deleteCollectionData(
    actualDbName,
    'tasks',
    task.databaseId!,
    token,
  );
}








/// Elimina una board dal database
Future<void> deleteBoardFromDatabase(
  String token,
  String dbName,
  Board board,
) async {
  if (board.id == null) {
    throw Exception("Errore: ID della board non trovato.");
  }

  final databaseService = DatabaseService();
  final authService = AuthService();

  final user = await authService.fetchCurrentUser(token);
  final actualDbName = '${user.username}-$dbName';

  await databaseService.deleteCollectionData(
    actualDbName,
    'boards',
    board.databaseId!, // Usa l'ID della board
    token,
  );
}

/// Aggiorna una board nel database
Future<void>   updateBoardInDatabase(
  String token,
  String dbName,
  Board board,
) async {
  if (board.id == null) {
    throw Exception("Errore: ID della board non trovato.");
  }

  final databaseService = DatabaseService();
  final authService = AuthService();

  final user = await authService.fetchCurrentUser(token);
  final actualDbName = '${user.username}-$dbName';
  print(board.databaseId);
  await databaseService.updateCollectionData(
    actualDbName,
    'boards',
    board.databaseId!, // Usa l'ID della board
    board.toJson(),
    token,
  );
}




/// Aggiorna una task list nel database
Future<void> updateTaskListInDatabase(
  String token,
  String dbName,
  TaskColumnData taskList,
) async {
  if (taskList.databaseId == null) {
    throw Exception("Errore: ID della task list non trovato.");
  }

  final databaseService = DatabaseService();
  final authService = AuthService();

  final user = await authService.fetchCurrentUser(token);
  final actualDbName = '${user.username}-$dbName';

  await databaseService.updateCollectionData(
    actualDbName,
    'taskLists',
    taskList.databaseId!,
    taskList.toJson(),
    token,
  );
}

