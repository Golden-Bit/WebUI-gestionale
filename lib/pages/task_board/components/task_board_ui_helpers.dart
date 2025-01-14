import 'package:flutter/material.dart';
import 'package:flutter_app/pages/task_board/components/task_class.dart';
import 'package:flutter_app/pages/task_board/edit_task.dart';
import 'package:flutter_app/pages/task_board/components/task_board_class.dart';
import 'package:flutter_app/databases_manager/database_service.dart';
import 'package:flutter_app/user_manager/auth_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:uuid/uuid.dart';

/// Mostra il dialog per creare una nuova colonna di task
void showAddTaskColumnDialog({
  required BuildContext context,
  required String currentBoardId,
  required Function(String columnTitle) onTaskColumnCreated,
}) {
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
              final title = _titleController.text;

              if (title.isNotEmpty) {
                onTaskColumnCreated(title);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Create'),
          ),
        ],
      );
    },
  );
}

/// Naviga alla pagina per aggiungere un task
void navigateToAddTaskPage({
  required BuildContext context,
  required String listId,
  required List<Label> labels,
  required List<Member> members,
  required void Function(Task newTask) onAddTask,
  Task? existingTask,
}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AddTaskPage(
        list: listId,
        labels: labels,
        members: members,
        existingTask: existingTask,
        onAddTask: onAddTask,
        onAddLabel: (label) => labels.add(label),
        onAddMember: (member) => members.add(member),
      ),
    ),
  );
}

/// Mostra i dettagli di un task
void showTaskDetails({
  required BuildContext context,
  required Task task,
  required Function(Task) onDeleteTask,
  required String Function(String markdown) customizeMarkdownCheckboxes,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con colore del task e pulsanti "delete" e "close"
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
                          onDeleteTask(task); // Funzione per eliminare il task
                          Navigator.of(context).pop(); // Chiudi il dialog
                        },
                        color: Colors.black,
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop(); // Chiudi il dialog
                        },
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),

                // Corpo del dialog
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titolo del task
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Descrizione del task (se esiste)
                      if (task.description.isNotEmpty)
                        buildTaskField(
                          title: "Description",
                          content: MarkdownBody(
                            data: customizeMarkdownCheckboxes(task.description),
                          ),
                        ),

                      // Membri del task (se presenti)
                      if (task.members.isNotEmpty)
                        buildTaskField(
                          title: "Members",
                          content: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: task.members.map((member) {
                              return Chip(
                                label: Text(
                                  member.name,
                                  style: const TextStyle(color: Colors.black87),
                                ),
                                backgroundColor: Colors.grey[200],
                              );
                            }).toList(),
                          ),
                        ),

                      // Etichette del task (se presenti)
                      if (task.labels.isNotEmpty)
                        buildTaskField(
                          title: "Labels",
                          content: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: task.labels.map((label) {
                              return Chip(
                                label: Text(
                                  label.name,
                                  style: const TextStyle(color: Colors.black87),
                                ),
                                backgroundColor: label.color,
                              );
                            }).toList(),
                          ),
                        ),

                      // Data di scadenza e tempo stimato (se presenti)
                      if (task.dueDate.isNotEmpty || task.estimatedTime.isNotEmpty)
                        buildTaskField(
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

                      // Allegati del task (se presenti)
                      if (task.attachments.isNotEmpty)
                        buildTaskField(
                          title: "Attachments",
                          content: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: task.attachments
                                .split(', ')
                                .map((attachment) {
                              return Chip(
                                label: Text(attachment),
                                backgroundColor: Colors.grey[200],
                              );
                            }).toList(),
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


Widget buildTaskField({
  required String title,
  required Widget content,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    padding: const EdgeInsets.all(12.0),
    width: double.infinity,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titolo del campo
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),

        // Contenuto del campo
        content,
      ],
    ),
  );
}


/// Mostra il dialog per creare una nuova board
void showCreateBoardDialog({
  required BuildContext context,
  required String token,
  required String dbName,
  required Function(Board) onBoardCreated,
}) {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Create New Board'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Board Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Board Description'),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              final name = _nameController.text;
              final description = _descriptionController.text;

              if (name.isNotEmpty) {
                final newBoardId = Uuid().v4();
                final newBoard = Board(
                  id: newBoardId,
                  name: name,
                  description: description,
                );

                final databaseService = DatabaseService();
                final user = await AuthService().fetchCurrentUser(token);
                final actualDbName = '${user.username}-$dbName';

                await databaseService.addDataToCollection(
                  actualDbName,
                  'boards',
                  newBoard.toJson(),
                  token,
                );

                onBoardCreated(newBoard); // Passa la nuova board al callback
                Navigator.of(context).pop();
              }
            },
            child: const Text('Create'),
          ),
        ],
      );
    },
  );
}