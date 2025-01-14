import 'package:flutter/material.dart';
import 'package:flutter_app/pages/task_board/components/edit_task_helpers.dart';
import 'package:flutter_app/pages/task_board/components/task_class.dart';

class AddTaskPage extends StatefulWidget {
  final String list;
  final Function(Task) onAddTask;
  final List<Label> labels;
  final List<Member> members;
  final Function(Label) onAddLabel;
  final Function(Member) onAddMember;
  final Task? existingTask;

  AddTaskPage({
    required this.list,
    required this.onAddTask,
    required this.labels,
    required this.members,
    required this.onAddLabel,
    required this.onAddMember,
    this.existingTask,
  });

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dueDateController;
  late TextEditingController _estimatedTimeController;
  List<String> _attachments = [];
  Color _selectedColor = Colors.transparent;
  List<Label> _selectedLabels = [];
  List<Member> _selectedMembers = [];

  @override
  void initState() {
    super.initState();

    _titleController =
        TextEditingController(text: widget.existingTask?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.existingTask?.description ?? '');
    _dueDateController =
        TextEditingController(text: widget.existingTask?.dueDate ?? '');
    _estimatedTimeController =
        TextEditingController(text: widget.existingTask?.estimatedTime ?? '');
    _attachments = widget.existingTask?.attachments.split(', ') ?? [];
    _selectedColor = widget.existingTask?.markerColor ?? Colors.transparent;
    _selectedLabels = widget.existingTask?.labels ?? [];
    _selectedMembers = widget.existingTask?.members ?? [];
  }

  Widget _buildInputField({required String title, required Widget content}) {
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
      elevation: 4, // Aggiunge l'elevazione per l'ombreggiatura
      backgroundColor: Colors.white, // Sfondo bianco per l'AppBar
      shadowColor: Colors.black, // Colore dell'ombra
      leadingWidth: 100, // Imposta la larghezza del lato sinistro per evitare sovrapposizioni
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black), // Icona nera
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          widget.existingTask != null ? 'Edit Task' : 'Add Task',
          style: const TextStyle(color: Colors.black), // Testo nero
        ),
        centerTitle: false, // Allineamento del titolo a sinistra
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 8.0), // Margine orizzontale
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                'Salva Task',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                // Funzione di salvataggio del task
                final task = Task(
                  title: _titleController.text,
                  description: _descriptionController.text,
                  list: widget.list,
                  markerColor: _selectedColor,
                  members: _selectedMembers,
                  labels: _selectedLabels,
                  dueDate: _dueDateController.text,
                  estimatedTime: _estimatedTimeController.text,
                  attachments: _attachments.join(', '),
                );
                widget.onAddTask(task);
                Navigator.of(context).pop();
              }, // Callback per aggiungere una lista di task
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.grey[700]),
            ),
          ),
        ],
      ),
      body: Container(
            color: Colors
                .white, // Imposta lo sfondo bianco per il contenuto principale
            child: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputField(
                title: "Title & Description",
                content: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: 'Title'),
                    ),
                    SizedBox(height: 8.0),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                    ),
                  ],
                ),
              ),
              _buildInputField(
                title: "Members",
                content: Column(
                  children: [
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      alignment: WrapAlignment.start,
                      children: _selectedMembers.map((member) {
                        return Chip(
                          label: Text(
                            member.name,
                            style: TextStyle(color: Colors.black87),
                          ),
                          backgroundColor: Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          onDeleted: () {
                            setState(() {
                              _selectedMembers.remove(member);
                            });
                          },
                          deleteIconColor: Colors.black,
                        );
                      }).toList(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.black),
                          onPressed: () {
                            showAddMemberDialog(
                              context: context,
                              onAddMember: (member) {
                                setState(() {
                                  _selectedMembers.add(member);
                                });
                              },
                            );
                          },
                        ),
                        Builder(
                          builder: (context) => Builder(
                            builder: (context) => IconButton(
                              icon: const Icon(Icons.person_add,
                                  color: Colors.black),
                              onPressed: () {
                                showMemberMenu(
                                  context: context,
                                  members: widget.members,
                                  onMemberSelected: (member) {
                                    setState(() {
                                      _selectedMembers.add(member);
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildInputField(
                title: "Due Date & Estimated Time",
                content: Column(
                  children: [
                    TextField(
                      controller: _dueDateController,
                      decoration: InputDecoration(
                        labelText: 'Due Date',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () {
                            selectDueDate(
                              context: context,
                              onDueDateSelected: (date) {
                                setState(() {
                                  _dueDateController.text = date;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    TextField(
                      controller: _estimatedTimeController,
                      decoration: InputDecoration(labelText: 'Estimated Time'),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Etichette',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      alignment: WrapAlignment.center,
                      children: _selectedLabels.map((label) {
                        return Chip(
                          label: Text(
                            label.name,
                            style: TextStyle(color: Colors.black87),
                          ),
                          backgroundColor: label.color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          onDeleted: () {
                            setState(() {
                              _selectedLabels.remove(label);
                            });
                          },
                          deleteIconColor: Colors.black,
                        );
                      }).toList(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.black),
                          onPressed: () {
                            showAddLabelDialog(
                              context: context,
                              onAddLabel: (label) {
                                setState(() {
                                  _selectedLabels.add(label);
                                });
                              },
                            );
                          },
                        ),
                        Builder(
                          builder: (context) => Builder(
                            builder: (context) => IconButton(
                              icon:
                                  const Icon(Icons.label, color: Colors.black),
                              onPressed: () {
                                showLabelMenu(
                                  context: context,
                                  labels: widget.labels,
                                  onLabelSelected: (label) {
                                    setState(() {
                                      _selectedLabels.add(label);
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attachments',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      alignment: WrapAlignment.center,
                      children: _attachments.map((attachment) {
                        return Chip(
                          label: Text(attachment),
                          backgroundColor: Colors.grey[200],
                          onDeleted: () {
                            setState(() {
                              _attachments.remove(attachment);
                            });
                          },
                        );
                      }).toList(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.attach_file),
                          onPressed: () {
                            selectAttachments(
                              context: context,
                              currentAttachments: _attachments,
                              onAttachmentsSelected: (attachments) {
                                setState(() {
                                  _attachments = attachments;
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Text('Select Marker Color:'),
                  SizedBox(width: 10),
                  ...Colors.primaries.map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: _selectedColor == color
                              ? Border.all(width: 2.0, color: Colors.black)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
              //SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ));
  }
}
