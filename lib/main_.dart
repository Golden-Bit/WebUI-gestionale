import 'package:flutter/material.dart';
import 'package:flutter_app/pages/generic_object_page/generic_object_page.dart';
import 'package:flutter_app/pages/login/login.dart';
import 'package:flutter_app/pages/register/register.dart';
import 'package:flutter_app/pages/settings/settings.dart';
import 'package:flutter_app/document_manager/documents_utils.dart';
import 'package:flutter_app/document_manager/file_manager_service.dart';
import 'package:flutter_app/pages/task_board/components/workspace_helpers.dart';
import 'dart:html' as html;  // Importa dart:html per aprire una nuova finestra

import 'user_manager/user_model.dart';
import 'databases_manager/database_pages.dart';
import 'pages/calendar/calendar.dart';
import 'pages/task_board/task_board.dart';
import 'pages/contacts/contacts.dart';
import 'pages/products/products.dart';
import 'pages/services/services.dart';
import 'esg_data_manager/euroistat.dart';
import 'esg_data_manager/yahoo_finance.dart';

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

  /*@override
  void initState() {
    super.initState();
    if (widget.user.databases.isNotEmpty) {
      selectedDatabase = widget.user.databases.first.dbName.replaceFirst('${widget.user.username}-', ''); // Seleziona il primo database come predefinito
    }
  }*/

  @override
void initState() {
  super.initState();
  _loadWorkspaces(); // Carica gli spazi di lavoro
  _loadAvailableDatabases(); // Carica i database disponibili
}

  /// Carica gli spazi di lavoro dal database
  Future<void> _loadWorkspaces() async {
    try {
      final loadedWorkspaces = await loadWorkspacesFromDatabase(
        widget.token.accessToken,
        'appData',
      );
      setState(() {
        workspaces = loadedWorkspaces;
        if (workspaces.isNotEmpty) {
          selectedWorkspace = workspaces.first;
        }
      });
    } catch (error) {
      print("Errore durante il caricamento degli spazi di lavoro: $error");
    }
  }

  /// Carica l'elenco dei database disponibili
  Future<void> _loadAvailableDatabases() async {
    try {
      final databases = widget.user.databases;
      setState(() {
        availableDatabases = databases.map((db) => db.dbName).toList();
      });
    } catch (error) {
      print("Errore durante il caricamento dei database disponibili: $error");
    }
  }

  /// Mostra un dialog per creare o modificare uno spazio di lavoro
  Future<void> _showWorkspaceDialog({Workspace? workspace}) async {
    final nameController = TextEditingController(text: workspace?.name ?? '');
    final descriptionController = TextEditingController(text: workspace?.description ?? '');
    String? selectedDatabase = workspace?.associatedDatabase ?? (availableDatabases.isNotEmpty ? availableDatabases.first : null);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(workspace == null ? "Crea Spazio di Lavoro" : "Modifica Spazio di Lavoro"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nome"),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Descrizione"),
              ),
              DropdownButtonFormField<String>(
                value: selectedDatabase,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                decoration: const InputDecoration(labelText: "Database Associato"),
                dropdownColor: Colors.grey[200],
                items: availableDatabases.map((db) {
                  return DropdownMenuItem<String>(
                    value: db,
                    child: Text(
                      db.replaceFirst('${widget.user.username}-', ''),
                      style: const TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedDatabase = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Annulla"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || selectedDatabase == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Nome e database associato sono obbligatori.")),
                  );
                  return;
                }
                final newWorkspace = Workspace(
                  id: workspace?.id ?? UniqueKey().toString(),
                  name: nameController.text,
                  description: descriptionController.text,
                  associatedDatabase: selectedDatabase!,
                  databaseId: workspace?.databaseId,
                );

                if (workspace == null) {
                  await saveWorkspaceToDatabase(widget.token.accessToken, 'appData', newWorkspace);
                } else {
                  await updateWorkspaceInDatabase(widget.token.accessToken, 'appData', newWorkspace);
                }

                await _loadWorkspaces();
                Navigator.of(context).pop();
              },
              child: Text(workspace == null ? "Crea" : "Salva"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [DropdownButton<Workspace>(
    value: selectedWorkspace,
    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
    dropdownColor: Colors.blueAccent,
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
    onChanged: (workspace) {
      setState(() {
        selectedWorkspace = workspace;
      });
    },
  ),
  IconButton(
    icon: const Icon(Icons.add),
    onPressed: () => _showWorkspaceDialog(), // Mostra il dialog per creare uno spazio di lavoro
  ),
        ],
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double gridWidth = constraints.maxWidth < 400 ? constraints.maxWidth : 400;
            return Container(
              width: gridWidth,
              child: GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 1,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildGridCard(
                    context,
                    icon: Icons.settings,
                    label: 'Impostazioni',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AccountSettingsPage(user: widget.user, token: widget.token),
                        ),
                      );
                    },
                  ),
                  _buildGridCard(
                    context,
                    icon: Icons.storage,
                    label: 'Databases',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DatabasePage(databases: widget.user.databases, token: widget.token.accessToken, user: widget.user),
                        ),
                      );
                    },
                  ),
                  _buildGridCard(
                    context,
                    icon: Icons.calendar_today,
                    label: 'Calendario',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CalendarComponent(
                            token: widget.token.accessToken,
                            dbName: selectedWorkspace?.associatedDatabase ?? '',
                          ),
                        ),
                      );
                    },
                  ),
                  _buildGridCard(
                    context,
                    icon: Icons.task,
                    label: 'Task Manager',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskBoard(
                            token: widget.token.accessToken,
                            dbName: selectedWorkspace?.associatedDatabase ?? '',
                          ),
                        ),
                      );
                    },
                  ),
                  _buildGridCard(
                    context,
                    icon: Icons.contacts,
                    label: 'Gestione Contatti',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContactManagerPage(
                            token: widget.token.accessToken,
                            dbName: selectedWorkspace?.associatedDatabase ?? '',
                          ),
                        ),
                      );
                    },
                  ),
                  _buildGridCard(
                    context,
                    icon: Icons.shopping_cart,
                    label: 'Gestione Prodotti',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductManagerPage(
                            token: widget.token.accessToken,
                            dbName: selectedWorkspace?.associatedDatabase ?? '',
                          ),
                        ),
                      );
                    },
                  ),
                  _buildGridCard(
                    context,
                    icon: Icons.build,
                    label: 'Gestione Servizi',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServiceManagerPage(
                            token: widget.token.accessToken,
                            dbName: selectedWorkspace?.associatedDatabase ?? '',
                          ),
                        ),
                      );
                    },
                  ),
                  _buildGridCard(
                    context,
                    icon: Icons.data_object,
                    label: 'Gestione Oggetti (Esempio)',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GenericObjectPage(
                            token: widget.token.accessToken,
                            dbName: selectedWorkspace?.associatedDatabase ?? '',
                          ),
                        ),
                      );
                    },
                  ),
                  _buildGridCard(
                    context,
                    icon: Icons.description,
                    label: 'Gestione Documenti',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DocumentManagerHomePage(
                            currentFolder: FolderInfo.root(),
                            path: "Root",
                            token: widget.token.accessToken,
                            dbName: selectedWorkspace?.associatedDatabase ?? '',
                          ),
                        ),
                      );
                    },
                  ),
                  _buildGridCard(
                    context,
                    icon: Icons.bar_chart,
                    label: 'MacroAnalisi ESG',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DataScreen(),
                        ),
                      );
                    },
                  ),
                  _buildGridCard(
                    context,
                    icon: Icons.bar_chart,
                    label: 'Analisi ESG',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ESGDataScreen(),
                        ),
                      );
                    },
                  ),
                  _buildGridCard(
                    context,
                    icon: Icons.chat,
                    label: 'ChatBot',
                    onTap: () {
                      html.window.open('http://localhost:59868', '_blank');
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onTap}) {
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
