import 'package:flutter/material.dart';
import 'package:flutter_app/pages/task_board/components/task_board_ui_helpers.dart';
import 'package:flutter_app/pages/task_board/components/task_class.dart';

class CustomTaskCalendar extends StatefulWidget {
  final List<Task> tasks; // Elenco dei task da visualizzare
  final Function(Task) onTaskTap; // Callback per selezionare un task

  const CustomTaskCalendar({
    Key? key,
    required this.tasks,
    required this.onTaskTap,
  }) : super(key: key);

  @override
  _CustomTaskCalendarState createState() => _CustomTaskCalendarState();
}

class _CustomTaskCalendarState extends State<CustomTaskCalendar> {
  DateTime _currentDate = DateTime.now();
  late List<DateTime> _daysInView;

  @override
  void initState() {
    super.initState();
    _updateDaysInView();
  }

  /// Calcola i giorni da mostrare nel calendario (una settimana alla volta)
  void _updateDaysInView() {
    final firstDayOfWeek =
        _currentDate.subtract(Duration(days: _currentDate.weekday - 1));
    _daysInView =
        List.generate(7, (index) => firstDayOfWeek.add(Duration(days: index)));
  }

  /// Raggruppa i task per giorno
  Map<DateTime, List<Task>> _groupTasksByDay(List<Task> tasks) {
    final Map<DateTime, List<Task>> groupedTasks = {};

    for (final task in tasks) {
      final DateTime? dueDate = DateTime.tryParse(task.dueDate);
      if (dueDate != null) {
        final normalizedDay =
            DateTime(dueDate.year, dueDate.month, dueDate.day);

        groupedTasks[normalizedDay] = groupedTasks[normalizedDay] ?? [];
        groupedTasks[normalizedDay]!.add(task);
      }
    }
    return groupedTasks;
  }

  /// Navigazione del calendario: giorno, settimana, mese
  void _changeView({required int days}) {
    setState(() {
      _currentDate = _currentDate.add(Duration(days: days));
      _updateDaysInView();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasksByDay = _groupTasksByDay(widget.tasks);

    return Column(
      children: [
        // Barra di navigazione
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Freccia per tornare indietro
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _changeView(days: -7), // Settimana precedente
              ),

              // Titolo con mese e anno
              Text(
                "${_currentDate.year} - ${_getMonthName(_currentDate.month)}",
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),

              // Freccia per andare avanti
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _changeView(days: 7), // Settimana successiva
              ),
            ],
          ),
        ),

        // Intestazioni dei giorni (Lunedì, Martedì, ecc.)
        Row(
          children: _daysInView.map((day) {
            return Expanded(
              child: Container(
                height: 40,
                alignment: Alignment.center,
                color: Colors.grey.shade200,
                child: Text(
                  "${day.day}/${day.month}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        // Corpo del calendario (scrollabile verticalmente)
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Aggiunto per allineare in alto
              children: List.generate(_daysInView.length, (index) {
                final day = _daysInView[index];
                return Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Separatore verticale
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                        ),
                      ),

                      // Task del giorno
                      ..._getTasksForDay(tasksByDay, day),

                      // Riempitivo per mantenere l'allineamento
                      Expanded(child: Container()),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  /// Restituisce i task di un determinato giorno
  List<Widget> _getTasksForDay(
    Map<DateTime, List<Task>> tasksByDay,
    DateTime day,
  ) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final tasks = tasksByDay[normalizedDay] ?? [];

    // Ordiniamo i task per titolo per una visualizzazione ordinata
    tasks.sort((a, b) => a.title.compareTo(b.title));

    return tasks.map((task) {
      return GestureDetector(
        onTap: () {
          // Mostra il dialog senza ricalcolare lo stato del calendario
          showTaskDetails(
            context: context,
            task: task,
            onDeleteTask: (deletedTask) {
              // Aggiorna la mappa dei task solo dopo l'eliminazione
              setState(() {
                tasksByDay[normalizedDay]?.remove(deletedTask);
              });
            },
            customizeMarkdownCheckboxes: (markdown) {
              return markdown.replaceAllMapped(
                RegExp(r'- \[( |x)\]'),
                (match) => match.group(1) == 'x' ? '☑️' : '⬜',
              );
            },
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          padding: const EdgeInsets.all(8.0),
          width: double.infinity,
          decoration: BoxDecoration(
            color: task.markerColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            task.title,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      );
    }).toList();
  }

  /// Restituisce il nome del mese
  String _getMonthName(int month) {
    const months = [
      "Gen", "Feb", "Mar", "Apr", "Mag", "Giu", "Lug", "Ago", "Set", "Ott", "Nov", "Dic"
    ];
    return months[month - 1];
  }
}
