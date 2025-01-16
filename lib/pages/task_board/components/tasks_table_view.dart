import 'package:flutter/material.dart';
import 'package:flutter_app/pages/task_board/components/task_column.dart';


class TaskTableView extends StatelessWidget {
  final List<TaskColumnData> taskColumns;

  const TaskTableView({
    Key? key,
    required this.taskColumns,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Combina tutti i task da tutte le colonne in un'unica lista
    final tasks = taskColumns.expand((column) => column.tasks).toList();

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 16.0,
          headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
          columns: const [
            DataColumn(label: Text('Nome')),
            DataColumn(label: Text('Descrizione')),
            DataColumn(label: Text('Etichette')),
            DataColumn(label: Text('Data Scadenza')),
            DataColumn(label: Text('Azioni')),
          ],
          rows: tasks.map((task) {
            final labels = task.labels.map((label) => label.name).join(', ');
            return DataRow(
              cells: [
                DataCell(Text(task.title)),
                DataCell(Text(task.description)),
                DataCell(Text(labels.isEmpty ? '-' : labels)),
                DataCell(Text(task.dueDate.isNotEmpty ? task.dueDate : '-')),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // Logica per modificare il task
                          print('Modifica task: ${task.title}');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Logica per eliminare il task
                          print('Elimina task: ${task.title}');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
