import 'package:flutter/material.dart';
import 'package:flutter_app/pages/task_board/components/task_board_app_bar.dart';
import 'package:flutter_app/pages/task_board/components/workspace_helpers.dart';

class TaskBoardHome extends StatefulWidget {
  final String token;
  final String dbName;

  const TaskBoardHome({
    Key? key,
    required this.token,
    required this.dbName,
  }) : super(key: key);

  @override
  State<TaskBoardHome> createState() => _TaskBoardHomeState();
}

class _TaskBoardHomeState extends State<TaskBoardHome> {
  bool isExpanded = false; // Per gestire il menu espandibile
  bool showWorkspaceItems =
      true; // Stato per espandere/nascondere i pulsanti sotto "Spazi di lavoro"
  List<Workspace> workspaces = [];
  Workspace? selectedWorkspace;

  // Stato per il pulsante selezionato
  int selectedIndex = 0; // 0 = Bacheche, 1 = Modelli, 2 = Pagina iniziale

  @override
  void initState() {
    super.initState();
    _loadWorkspaces(); // Simulazione caricamento workspaces
  }

  /// Simula il caricamento degli spazi di lavoro
  void _loadWorkspaces() {
    setState(() {
      workspaces = [
        Workspace(
            id: "1",
            name: "Gestione Progetti",
            description: "",
            associatedDatabase: ""),
        Workspace(
            id: "2",
            name: "Analisi Dati",
            description: "",
            associatedDatabase: ""),
      ];
      selectedWorkspace = workspaces.isNotEmpty ? workspaces.first : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final FocusNode searchFocusNode = FocusNode();

    return Scaffold(
      appBar: TaskBoardAppBar(
        isMenuOpen: false, // Simulazione del menu
        onMenuToggle: () {
          // Azione di toggle menu
          print("Menu toggle clicked");
        },
        onCreateBoard: () {
          // Placeholder per "Crea Board"
          print("Crea nuovo board");
        },
        onAddTaskList: () {
          // Placeholder per "Crea Task List"
          print("Crea nuova task list");
        },
        onOpenFilter: () {
          // Placeholder per filtro
          print("Filtra");
        },
        onSearchQueryChanged: (query) {
          // Placeholder per ricerca
          print("Query di ricerca: $query");
        },
        searchFocusNode: searchFocusNode, // Passo il focus node
      ),
      body: Row(
        children: [
          // Menu laterale sinistro
          _buildSidebar(),
          // Contenuto principale
          Expanded(
            child: Container(
              alignment: Alignment
                  .topLeft, // Forza il contenuto ad allinearsi in alto a sinistra
              child: _buildMainContent(),
            ),
          ),
        ],
      ),
    );
  }

  /// Costruisce il menu laterale sinistro
  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSidebarButton(
            index: 0,
            icon: Icons.dashboard,
            title: "Bacheche",
          ),
          _buildSidebarButton(
            index: 1,
            icon: Icons.bookmark_border,
            title: "Modelli",
          ),
          _buildSidebarButton(
            index: 2,
            icon: Icons.home_outlined,
            title: "Pagina iniziale",
          ),
          const SizedBox(height: 32),
          InkWell(
            onTap: () {
              setState(() {
                showWorkspaceItems = !showWorkspaceItems; // Cambia lo stato
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Spazi di lavoro",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.orange),
                ),
                Icon(
                  showWorkspaceItems ? Icons.expand_less : Icons.expand_more,
                  color: Colors.orange,
                ),
              ],
            ),
          ),
          if (showWorkspaceItems) ...[
            const SizedBox(height: 16),
            _buildSidebarWorkspaceTile(
              icon: Icons.table_chart,
              title: "Bacheche",
            ),
            _buildSidebarWorkspaceTile(
              icon: Icons.collections_bookmark,
              title: "Raccolte",
            ),
            _buildSidebarWorkspaceTile(
              icon: Icons.star,
              title: "Punti salienti",
            ),
            _buildSidebarWorkspaceTile(
              icon: Icons.grid_view,
              title: "Viste",
            ),
            _buildSidebarWorkspaceTile(
              icon: Icons.person,
              title: "Membri",
              trailing: IconButton(
                onPressed: () {
                  print("Aggiungi membro");
                },
                icon: const Icon(Icons.add),
              ),
            ),
            _buildSidebarWorkspaceTile(
              icon: Icons.settings,
              title: "Impostazioni",
            ),
            _buildSidebarWorkspaceTile(
              icon: Icons.attach_money,
              title: "Fatturazione",
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSidebarButton({
    required int index,
    required IconData icon,
    required String title,
  }) {
    final isSelected = selectedIndex == index;

    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.orange : Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.orange : Colors.black,
        ),
      ),
      tileColor: isSelected ? Colors.orange[50] : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
    );
  }

  Widget _buildSidebarWorkspaceTile({
    required IconData icon,
    required String title,
    int? badgeCount,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      trailing: badgeCount != null
          ? CircleAvatar(
              backgroundColor: Colors.orange,
              radius: 12,
              child: Text(
                badgeCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            )
          : trailing,
      onTap: () {
        print("Cliccato su $title");
      },
    );
  }

  /// Costruisce il contenuto principale in base al pulsante selezionato
  Widget _buildMainContent() {
    switch (selectedIndex) {
      case 0:
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        color: Colors.grey, size: 20), // Icona orologio
                    const SizedBox(width: 8), // Spaziatura tra icona e testo
                    const Text(
                      "Visualizzate di recente",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [
      _buildRecentCard(context, title: "gestionale", color: Colors.purple),
      _buildRecentCard(context, title: "marketing", color: Colors.blue),
      _buildRecentCard(context, title: "team A", color: Colors.green),
      _buildRecentCard(context, title: "finance", color: Colors.orange),
    ],
  ),
),
                const SizedBox(height: 24),
                const Text(
                  "I TUOI SPAZI DI LAVORO",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                _buildWorkspaceSection(),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      print("Visualizza tutte le bacheche chiuse");
                    },
                    child: const Text("Visualizza tutte le bacheche chiuse"),
                  ),
                ),
              ],
            ),
          ),
        );
      case 1:
        return const Padding(
          padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
          child: Center(
            child: Text(
              "Placeholder per Modelli",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
        );
      case 2:
        return const Padding(
          padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
          child: Center(
            child: Text(
              "Placeholder per Pagina iniziale",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

Widget _buildRecentCard(BuildContext context, {required String title, required Color color}) {
  return Container(
    width: 180, // Larghezza fissa
    height: 120,
    margin: const EdgeInsets.symmetric(horizontal: 8), // Spaziatura orizzontale tra le schede
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

  Widget _buildWorkspaceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Row(
                children: [
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    selectedWorkspace?.name ?? "Nessuno spazio di lavoro",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            // Pulsanti accanto al nome dello spazio di lavoro con testo sotto
            Row(
              children: [
                _buildActionIconWithText(Icons.dashboard, "Bacheche"),
                _buildActionIconWithText(Icons.grid_view, "Viste"),
                _buildActionIconWithText(Icons.person, "Membri"),
                _buildActionIconWithText(Icons.settings, "Impostazioni"),
              ],
            ),
          ],
        ),
        if (isExpanded) ...[
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildWorkspaceCard(context,
                    title: "gestionale", color: Colors.purple),
                _buildWorkspaceCard(context,
                    title: "marketing", color: Colors.blue),
                _buildWorkspaceCard(context,
                    title: "team A", color: Colors.green),
                _buildWorkspaceCard(context,
                    title: "finance", color: Colors.orange),
                _buildWorkspaceCard(context,
                    title: "Crea nuova bacheca", color: Colors.grey[300]!),
              ],
            ),
          ),
        ],
      ],
    );
  }

Widget _buildActionIconWithText(IconData icon, String label) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0), // Padding tra i pulsanti
    child: Row(
      children: [
        Icon(icon, color: Colors.grey[700], size: 20), // Icona
        const SizedBox(width: 4), // Spazio tra icona e testo
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildWorkspaceCard(BuildContext context,
      {required String title, required Color color}) {
    return Container(
      width: 180, // Larghezza fissa
      height: 120,
      margin: const EdgeInsets.symmetric(
          horizontal: 8), // Margine orizzontale tra i riquadri
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: color == Colors.grey[300] ? Colors.black : Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
