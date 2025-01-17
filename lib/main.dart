import 'package:flutter/material.dart';
import 'package:flutter_app/components/workspace_body.dart';
import 'package:flutter_app/pages/login/login.dart';
import 'package:flutter_app/pages/register/register.dart';
import 'package:flutter_app/pages/task_board/components/workspace_helpers.dart';
import 'user_manager/user_model.dart';
import 'package:flutter_app/components/workspace_appbar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  final User user;
  final Token token;

  HomePage({required this.user, required this.token});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Workspace> workspaces = [];
  Workspace? selectedWorkspace;
  List<String> availableDatabases = []; // Lista dei database disponibili
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _loadWorkspaces(); // Carica gli spazi di lavoro
    _loadAvailableDatabases(); // Carica i database disponibili
  }

  Future<void> _loadWorkspaces() async {
    final loadedWorkspaces = await loadWorkspaces(
      token: widget.token.accessToken,
      dbName: 'appData',
    );
    setState(() {
      workspaces = loadedWorkspaces;
      if (workspaces.isNotEmpty) {
        selectedWorkspace = workspaces.first;
      }
    });
  }

  Future<void> _loadAvailableDatabases() async {
    final databases = await loadAvailableDatabases(
      databases: widget.user.databases,
    );
    setState(() {
      availableDatabases = databases;
    });
  }

  Future<void> _showWorkspaceDialog({Workspace? workspace}) async {
    await showWorkspaceDialog(
      context: context,
      user: widget.user,
      workspace: workspace,
      availableDatabases: availableDatabases,
      token: widget.token.accessToken,
      onWorkspaceSaved: _loadWorkspaces,
    );
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  void _createBoard() {
    print('Creazione di una nuova board');
    // Logica per la creazione di una nuova board
  }

  void _createTaskList() {
    print('Creazione di una nuova task list');
    // Logica per la creazione di una nuova task list
  }

  void _openFilter() {
    print('Apertura del filtro');
    // Logica per il filtro
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WorkspaceAppBar(
        selectedWorkspace: selectedWorkspace,
        workspaces: workspaces,
        onWorkspaceChanged: (workspace) {
          setState(() {
            selectedWorkspace = workspace;
          });
        },
        onAddWorkspace: () => _showWorkspaceDialog(),
        onMenuToggle: _toggleMenu, // Per la gestione del menu laterale
        isMenuOpen: _isMenuOpen,
        onCreateBoard: _createBoard,
        onAddTaskList: _createTaskList,
        onOpenFilter: _openFilter,
        onSearchQueryChanged: (query) {
          print('Query di ricerca: $query');
        },
        searchFocusNode: FocusNode(),
      ),
      body: Container(
      color: Colors.white, // Sfondo bianco
      child: Center(
        child: WorkspaceBody(
                selectedWorkspace: selectedWorkspace, 
                user: widget.user,
                token: widget.token,)
      ),
    ));
  }

  Widget _buildGridCard(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: StatefulBuilder(
        builder: (context, setState) {
          bool isHovered = false;

          return MouseRegion(
            onEnter: (_) {
              setState(() => isHovered = true);
            },
            onExit: (_) {
              setState(() => isHovered = false);
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              transform: Matrix4.identity()..scale(isHovered ? 1.05 : 1.0),
              curve: Curves.easeInOut,
              child: Card(
                elevation: isHovered ? 8.0 : 4.0,
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 32.0),
                        SizedBox(height: 4.0),
                        Text(
                          label,
                          style: TextStyle(fontSize: 12.0),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
