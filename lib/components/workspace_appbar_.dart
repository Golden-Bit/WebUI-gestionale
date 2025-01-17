import 'package:flutter/material.dart';
import 'package:flutter_app/pages/task_board/components/workspace_helpers.dart';

class WorkspaceAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Workspace? selectedWorkspace;
  final List<Workspace> workspaces;
  final Function(Workspace?) onWorkspaceChanged;
  final VoidCallback onAddWorkspace;

  const WorkspaceAppBar({
    Key? key,
    required this.selectedWorkspace,
    required this.workspaces,
    required this.onWorkspaceChanged,
    required this.onAddWorkspace,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("Home"),
      actions: [
        // Dropdown per selezionare lo spazio di lavoro
        DropdownButton<Workspace>(
          value: selectedWorkspace,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          dropdownColor: Colors.white,
          underline: const SizedBox(),
          items: workspaces.map((workspace) {
            return DropdownMenuItem<Workspace>(
              value: workspace,
              child: Text(
                workspace.name,
                style: const TextStyle(color: Colors.black),
              ),
              
            );
          }).toList(),
          onChanged: onWorkspaceChanged,
        ),
        // Pulsante per aggiungere uno spazio di lavoro
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: onAddWorkspace,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
