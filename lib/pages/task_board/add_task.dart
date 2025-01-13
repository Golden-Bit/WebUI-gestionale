import 'package:flutter/material.dart';
import 'package:flutter_app/pages/task_board/components/task_class.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';


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

    _titleController = TextEditingController(text: widget.existingTask?.title ?? '');
    _descriptionController = TextEditingController(text: widget.existingTask?.description ?? '');
    _dueDateController = TextEditingController(text: widget.existingTask?.dueDate ?? '');
    _estimatedTimeController = TextEditingController(text: widget.existingTask?.estimatedTime ?? '');
    _attachments = widget.existingTask?.attachments.split(', ') ?? [];
    _selectedColor = widget.existingTask?.markerColor ?? Colors.transparent;
    _selectedLabels = widget.existingTask?.labels ?? [];
    _selectedMembers = widget.existingTask?.members ?? [];
  }

  Future<void> _selectDueDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _dueDateController.text = DateFormat('yyyy-MM-dd HH:mm').format(
              DateTime(picked.year, picked.month, picked.day, time.hour,
                  time.minute));
        });
      }
    }
  }

  Future<void> _selectAttachment() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true, withData: true);

      if (result != null) {
        setState(() {
          _attachments.addAll(result.files.map((file) => file.name).toList());
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting files: $e'),
        ),
      );
    }
  }

  void _addLabel() {
    final _labelNameController = TextEditingController();
    Color _labelColor = Colors.transparent;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Create New Label'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _labelNameController,
                    decoration: InputDecoration(labelText: 'Label Name'),
                  ),
                  Row(
                    children: [
                      Text('Select Color:'),
                      SizedBox(width: 10),
                      ...Colors.primaries.map((color) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _labelColor = color;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 5.0),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: _labelColor == color
                                  ? Border.all(width: 2.0, color: Colors.black)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    final label = Label(
                      name: _labelNameController.text,
                      color: _labelColor,
                    );
                    widget.onAddLabel(label);
                    Navigator.of(context).pop();
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addMember() {
    final _memberNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create New Member'),
          content: TextField(
            controller: _memberNameController,
            decoration: InputDecoration(labelText: 'Member Name'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final member = Member(name: _memberNameController.text);
                widget.onAddMember(member);
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showMemberMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(Offset.zero, ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: widget.members.map((Member member) {
        return PopupMenuItem<Member>(
          value: member,
          child: ListTile(
            title: Text(member.name),
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedMembers.add(value);
        });
      }
    });
  }

  void _showLabelMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(Offset.zero, ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: widget.labels.map((Label label) {
        return PopupMenuItem<Label>(
          value: label,
          child: ListTile(
            title: Text(label.name),
            leading: CircleAvatar(
              backgroundColor: label.color,
            ),
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedLabels.add(value);
        });
      }
    });
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(widget.existingTask != null ? 'Edit Task' : 'Add Task'),
      ),
      body: Padding(
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
                          icon: Icon(Icons.add, color: Colors.black),
                          onPressed: _addMember,
                        ),
                        Builder(
                          builder: (context) => IconButton(
                            icon: Icon(Icons.person_add, color: Colors.black),
                            onPressed: () => _showMemberMenu(context),
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
                          icon: Icon(Icons.calendar_today),
                          onPressed: () => _selectDueDate(context),
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
                          icon: Icon(Icons.add, color: Colors.black),
                          onPressed: _addLabel,
                        ),
                        Builder(
                          builder: (context) => IconButton(
                            icon: Icon(Icons.label, color: Colors.black),
                            onPressed: () => _showLabelMenu(context),
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
                          icon: Icon(Icons.attach_file),
                          onPressed: () => _selectAttachment(),
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
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
                },
                child: Text(
                  widget.existingTask != null ? 'Save Task' : 'Add Task',
                  style: TextStyle(color: Colors.grey[800]),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  minimumSize: Size(double.infinity, 36),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
