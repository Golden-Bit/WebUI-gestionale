import 'package:flutter/material.dart';
import 'package:flutter_app/pages/task_board/components/task_class.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

/// Mostra un dialog per aggiungere una nuova etichetta
void showAddLabelDialog({
  required BuildContext context,
  required Function(Label) onAddLabel,
}) {
  final _labelNameController = TextEditingController();
  Color _labelColor = Colors.transparent;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Create New Label'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _labelNameController,
                  decoration: const InputDecoration(labelText: 'Label Name'),
                ),
                Row(
                  children: [
                    const Text('Select Color:'),
                    const SizedBox(width: 10),
                    ...Colors.primaries.map((color) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _labelColor = color;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
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
                  onAddLabel(label);
                  Navigator.of(context).pop();
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    },
  );
}

/// Mostra un dialog per aggiungere un nuovo membro
void showAddMemberDialog({
  required BuildContext context,
  required Function(Member) onAddMember,
}) {
  final _memberNameController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Create New Member'),
        content: TextField(
          controller: _memberNameController,
          decoration: const InputDecoration(labelText: 'Member Name'),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              final member = Member(name: _memberNameController.text);
              onAddMember(member);
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}

/// Mostra un menu per selezionare un membro
void showMemberMenu({
  required BuildContext context,
  required List<Member> members,
  required Function(Member) onMemberSelected,
}) {
  showMenu(
    context: context,
    position: RelativeRect.fromLTRB(100, 100, 100, 100),
    items: members.map((Member member) {
      return PopupMenuItem<Member>(
        value: member,
        child: ListTile(
          title: Text(member.name),
        ),
      );
    }).toList(),
  ).then((value) {
    if (value != null) {
      onMemberSelected(value);
    }
  });
}

/// Mostra un menu per selezionare un'etichetta
void showLabelMenu({
  required BuildContext context,
  required List<Label> labels,
  required Function(Label) onLabelSelected,
}) {
  showMenu(
    context: context,
    position: RelativeRect.fromLTRB(100, 100, 100, 100),
    items: labels.map((Label label) {
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
      onLabelSelected(value);
    }
  });
}

/// Seleziona una data e un orario
Future<void> selectDueDate({
  required BuildContext context,
  required Function(String) onDueDateSelected,
}) async {
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
      onDueDateSelected(
        DateFormat('yyyy-MM-dd HH:mm').format(
          DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          ),
        ),
      );
    }
  }
}

/// Gestisce la selezione degli allegati
Future<void> selectAttachments({
  required BuildContext context,
  required List<String> currentAttachments,
  required Function(List<String>) onAttachmentsSelected,
}) async {
  try {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: true, withData: true);

    if (result != null) {
      onAttachmentsSelected(
        [...currentAttachments, ...result.files.map((file) => file.name)],
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error selecting files: $e'),
      ),
    );
  }
}
