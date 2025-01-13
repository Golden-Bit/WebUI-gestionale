import 'package:flutter/material.dart';
import 'package:flutter_app/pages/task_board/components/task_class.dart';
import 'package:flutter_markdown/flutter_markdown.dart';


class TaskCard extends StatefulWidget {
  final Task task;
  final Function(Task, String, int) onMoveTask;
  final Function(Task) onRemoveTask;
  final Function(Task) onTaskTap;
  final Function(Task, String) onDuplicateTask;
  final Function(Task) onEditTask;

  const TaskCard({
    required this.task,
    required this.onMoveTask,
    required this.onRemoveTask,
    required this.onTaskTap,
    required this.onDuplicateTask,
    required this.onEditTask,
    Key? key,
  }) : super(key: key);

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  String _customizeMarkdownCheckboxes(String markdown) {
    return markdown.replaceAllMapped(
      RegExp(r'- \[( |x)\] '),
      (match) {
        final isChecked = match.group(1) == 'x';
        return '\n ${isChecked ? '☑️' : '⬜'} ';
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onTaskTap(widget.task),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 2,
        child: Column(
          children: [
            Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.task.markerColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        widget.onRemoveTask(widget.task);
                      } else if (value == 'duplicate') {
                        widget.onDuplicateTask(widget.task, widget.task.list);
                      } else if (value == 'edit') {
                        widget.onEditTask(widget.task);
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
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Modifica'),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                      widget.task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: _isExpanded ? 24 : 18,
                      ),
                    ),
                    subtitle: _isExpanded
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.task.description.isNotEmpty)
                                _buildTaskField(
                                  title: "Description",
                                  content: MarkdownBody(
                                    data: _customizeMarkdownCheckboxes(widget.task.description),
                                  ),
                                ),
                              if (widget.task.members.isNotEmpty)
                                _buildTaskField(
                                  title: "Members",
                                  content: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Wrap(
                                      spacing: 4.0,
                                      runSpacing: 4.0,
                                      children: widget.task.members.map((member) {
                                        return Chip(
                                          label: Text(member.name, style: TextStyle(color: Colors.black87)),
                                          backgroundColor: Colors.grey[200],
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              if (widget.task.labels.isNotEmpty)
                                _buildTaskField(
                                  title: "Labels",
                                  content: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Wrap(
                                      spacing: 4.0,
                                      runSpacing: 4.0,
                                      children: widget.task.labels.map((label) {
                                        return Chip(
                                          label: Text(label.name, style: TextStyle(color: Colors.black87)),
                                          backgroundColor: label.color,
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              if (widget.task.dueDate.isNotEmpty || widget.task.estimatedTime.isNotEmpty)
                                _buildTaskField(
                                  title: "Due Date & Estimated Time",
                                  content: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (widget.task.dueDate.isNotEmpty)
                                        Text('Due Date: ${widget.task.dueDate}'),
                                      if (widget.task.estimatedTime.isNotEmpty)
                                        Text('Estimated Time: ${widget.task.estimatedTime}'),
                                    ],
                                  ),
                                ),
                              if (widget.task.attachments.isNotEmpty)
                                _buildTaskField(
                                  title: "Attachments",
                                  content: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Wrap(
                                      spacing: 4.0,
                                      runSpacing: 4.0,
                                      children: widget.task.attachments.split(', ').map((attachment) {
                                        return Chip(
                                          label: Text(attachment),
                                          backgroundColor: Colors.grey[200],
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(
                      child: IconButton(
                        icon: Icon(
                          _isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.grey[800],
                        ),
                        onPressed: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
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
}