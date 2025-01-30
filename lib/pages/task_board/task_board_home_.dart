import 'package:flutter/material.dart';
import 'package:flutter_app/pages/task_board/components/task_board_app_bar.dart';
import 'package:flutter_app/pages/task_board/components/task_board_class.dart';
import 'package:flutter_app/pages/task_board/components/task_board_service.dart';
import 'package:flutter_app/pages/task_board/components/workspace_helpers.dart';
import 'package:flutter_app/pages/task_board/task_board.dart';
import 'package:flutter_app/user_manager/auth_service.dart';
//import 'package:flutter_app/user_manager/user_model.dart';

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

// Stato per tracciare quali spazi di lavoro sono espansi
  late List<bool> isExpandedList;
  Map<String, List<Board>> workspaceBoards = {};

  @override
  void initState() {
    super.initState();
    _loadWorkspaces(); // Simulazione caricamento workspaces
  }

  /// Simula il caricamento degli spazi di lavoro
  void _loadWorkspaces() async {
    // Ottenere l'utente corrente utilizzando il token
    final authService = AuthService();
    final user = await authService.fetchCurrentUser(widget.token);

    try {
      // Carica gli spazi di lavoro dal database
      final loadedWorkspaces = await loadWorkspaces(
        token: widget.token,
        dbName: 'appData',
      );

      // Inizializza la mappa con le board per ogni workspace
      final Map<String, List<Board>> loadedBoards = {};
      for (final workspace in loadedWorkspaces) {
        final boards = await loadBoardsFromDatabase(
          widget.token,
          workspace.associatedDatabase!.replaceFirst('${user.username}-', ''),
        );
        loadedBoards[workspace.associatedDatabase!] = boards;
      }

      setState(() {
        workspaces = loadedWorkspaces;
        workspaceBoards = loadedBoards;

        // Inizializza lo stato espanso: tutti i menu sono collassati di default
        isExpandedList = List.generate(workspaces.length, (_) => false);

        print('Workspaces: $workspaces');
        print('Boards: $workspaceBoards');
      });
    } catch (e) {
      print("Errore durante il caricamento degli spazi di lavoro: $e");
    }
  }

  /*Future<List<Board>> _loadBoardsForWorkspace(String? associatedDbName) async {
    // Ottenere l'utente corrente utilizzando il token
    final authService = AuthService();
    final user = await authService.fetchCurrentUser(widget.token);
    List<Board> boards;

    try {
      boards = await loadBoardsFromDatabase(widget.token,
          associatedDbName!.replaceFirst('${user.username}-', ''));
      print('associated db: $associatedDbName');
      print('boards: $boards');

      return loadBoardsFromDatabase(
          widget.token,
          associatedDbName!
              .replaceFirst('${user.username}-', '')); // Non usare await qui
    } catch (e) {
      print(
          "Errore durante il caricamento delle board asocaita al db $associatedDbName: $e");
      return [];
    }
  }*/

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

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pulsanti principali in alto
          SidebarButton(
            index: 0,
            icon: Icons.dashboard,
            title: "Bacheche",
            selectedIndex: selectedIndex,
            onSelected: (index) {
              setState(() {
                selectedIndex = index; // Aggiorna il pulsante selezionato
              });
            },
          ),
          SidebarButton(
            index: 1,
            icon: Icons.bookmark_border,
            title: "Modelli",
            selectedIndex: selectedIndex,
            onSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),
          SidebarButton(
            index: 2,
            icon: Icons.home_outlined,
            title: "Pagina iniziale",
            selectedIndex: selectedIndex,
            onSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),
          const SizedBox(height: 32),
          const Text(
            "Spazi di lavoro",
            style: TextStyle(
              fontSize: 12,
              //fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 0),
          // Generazione dinamica del menu per ogni spazio di lavoro
          Expanded(
            child: ListView.builder(
              itemCount: workspaces.length,
              itemBuilder: (context, index) {
                final workspace = workspaces[index];
                final isExpanded = isExpandedList[index];
                final isHovered = ValueNotifier(false);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MouseRegion(
                        onEnter: (_) => isHovered.value = true,
                        onExit: (_) => isHovered.value = false,
                        cursor: SystemMouseCursors
                            .click, // Cambia il cursore al passaggio
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isExpandedList[index] = !isExpandedList[index];
                            });
                          },
                          child: ValueListenableBuilder(
                            valueListenable: isHovered,
                            builder: (context, hover, _) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 4.0),
                                decoration: BoxDecoration(
                                  color: isExpanded
                                      ? Colors.grey[700]
                                      : hover
                                          ? Colors.grey[400]
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 30,
                                          height: 30,
                                          margin:
                                              const EdgeInsets.only(right: 8),
                                          decoration: BoxDecoration(
                                            color: _getColorForInitial(
                                                workspace.name[0]),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Center(
                                            child: Text(
                                              workspace.name[0],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          workspace.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: isExpanded
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      isExpanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      color: isExpanded
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      if (isExpanded) ...[
                        const SizedBox(height: 12),
                        _buildSidebarWorkspaceTile(
                          icon: Icons.dashboard,
                          title: "Bacheche",
                          onTap: () {
                            print(
                                "Apertura delle bacheche dello spazio di lavoro ${workspace.name}");
                            // Logica per aprire la sezione Bacheche
                          },
                        ),
                        _buildSidebarWorkspaceTile(
                          icon: Icons.collections_bookmark,
                          title: "Raccolte",
                          onTap: () {
                            print(
                                "Apertura delle raccolte dello spazio di lavoro ${workspace.name}");
                            // Logica per aprire la sezione Raccolte
                          },
                        ),
                        _buildSidebarWorkspaceTile(
                          icon: Icons.star,
                          title: "Punti salienti",
                          onTap: () {
                            print(
                                "Visualizzazione dei punti salienti dello spazio di lavoro ${workspace.name}");
                            // Logica per aprire la sezione Punti salienti
                          },
                        ),
                        _buildSidebarWorkspaceTile(
                          icon: Icons.grid_view,
                          title: "Viste",
                          onTap: () {
                            print(
                                "Navigazione alla pagina delle viste dello spazio di lavoro ${workspace.name}");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskBoard(
                                  token: widget.token,
                                  dbName: workspace.associatedDatabase ??
                                      '', // Passa il database associato
                                ),
                              ),
                            );
                          },
                        ),
                        _buildSidebarWorkspaceTile(
                          icon: Icons.person,
                          title: "Membri",
                          onTap: () {
                            print(
                                "Visualizzazione dei membri dello spazio di lavoro ${workspace.name}");
                            // Logica per aprire la sezione Membri
                          },
                        ),
                        _buildSidebarWorkspaceTile(
                          icon: Icons.settings,
                          title: "Impostazioni",
                          onTap: () {
                            print(
                                "Apertura delle impostazioni dello spazio di lavoro ${workspace.name}");
                            // Logica per aprire la sezione Impostazioni
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarWorkspaceTile({
    required IconData icon,
    required String title,
    int? badgeCount,
    Widget? trailing,
    VoidCallback? onTap, // Aggiungi un callback opzionale
  }) {
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap, // Esegui il callback al clic
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
              decoration: BoxDecoration(
                color: isHovered ? Colors.grey[400] : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.grey[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  if (badgeCount != null)
                    CircleAvatar(
                      backgroundColor: Colors.black,
                      radius: 12,
                      child: Text(
                        badgeCount.toString(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  if (trailing != null) trailing,
                ],
              ),
            ),
          ),
        );
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
                const Row(
                  children: [
                    Icon(Icons.access_time,
                        color: Colors.grey, size: 20), // Icona orologio
                    SizedBox(width: 8), // Spaziatura tra icona e testo
                    Text(
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
                      _buildRecentCard(context,
                          title: "gestionale", color: Colors.purple),
                      _buildRecentCard(context,
                          title: "marketing", color: Colors.blue),
                      _buildRecentCard(context,
                          title: "team A", color: Colors.green),
                      _buildRecentCard(context,
                          title: "finance", color: Colors.orange),
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
                const SizedBox(
                    width: 260,
                    child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: ActionIconWithText(
                            icon: null,
                            label: "Visualizza tutte le bacheche chiuse")))
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

  Widget _buildRecentCard(BuildContext context,
      {required String title, required Color color}) {
    return Container(
      width: 180, // Larghezza fissa
      height: 120,
      margin: const EdgeInsets.symmetric(
          horizontal: 8), // Spaziatura orizzontale tra le schede
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
      children: workspaces.map((workspace) {
        // Ottieni le board dalla mappa caricata
        final boards = workspaceBoards[workspace.associatedDatabase] ?? [];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nome dello spazio di lavoro
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Icona quadrata con l'iniziale dello spazio di lavoro
                      Container(
                        width: 40, // Larghezza dell'icona
                        height: 40, // Altezza dell'icona
                        margin: const EdgeInsets.only(
                            right: 8), // Spazio tra icona e testo
                        decoration: BoxDecoration(
                          color: _getColorForInitial(workspace.name[0]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            workspace.name[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // Nome dello spazio di lavoro
                      Text(
                        workspace.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  // Pulsanti accanto al nome dello spazio di lavoro
                  Row(
                    children: [
                      ActionIconWithText(
                        icon: Icons.dashboard,
                        label: "Bacheche",
                        onTap: () {
                          print(
                              "Navigazione alla sezione Bacheche dello spazio di lavoro ${workspace.name}");
                          // Logica per navigare alla sezione Bacheche, se necessario
                        },
                      ),
                      ActionIconWithText(
                        icon: Icons.grid_view,
                        label: "Viste",
                        onTap: () {
                          print(
                              "Navigazione alla pagina delle viste dello spazio di lavoro");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaskBoard(
                                token: widget.token,
                                dbName: workspace.associatedDatabase ?? '',
                              ),
                            ),
                          );
                        },
                      ),
                      ActionIconWithText(
                        icon: Icons.person,
                        label: "Membri",
                        onTap: () {
                          print(
                              "Visualizzazione dei membri dello spazio di lavoro ${workspace.name}");
                          // Logica per navigare alla sezione Membri, se necessario
                        },
                      ),
                      ActionIconWithText(
                        icon: Icons.settings,
                        label: "Impostazioni",
                        onTap: () {
                          print(
                              "Apertura delle impostazioni dello spazio di lavoro ${workspace.name}");
                          // Logica per aprire la sezione Impostazioni, se necessario
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Griglia delle board
              LayoutBuilder(
                builder: (context, constraints) {
                  // Larghezza dello schermo disponibile
                  final double screenWidth = constraints.maxWidth;

                  // Calcolo del numero di colonne in base alla larghezza minima
                  const double minItemWidth = 180; // Larghezza minima
                  const double itemSpacing = 8; // Spaziatura tra gli elementi
                  final int crossAxisCount =
                      (screenWidth / (minItemWidth + itemSpacing)).floor();

                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: itemSpacing,
                      mainAxisSpacing: itemSpacing,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: boards.length + 1,
                    itemBuilder: (context, index) {
                      if (index == boards.length) {
                        // Ultima scheda: "Crea nuova bacheca"
                        return _buildWorkspaceCard(
                          context,
                          title: "Crea nuova bacheca",
                          color: Colors.grey[300]!,
                        );
                      } else {
                        final board = boards[index];
                        return _buildWorkspaceCard(
                          context,
                          title: board.name,
                          color: Colors.white,
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        );
      }).toList(),
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
          color: color == Colors.grey[300] || color == Colors.white
              ? Colors.black
              : Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

Color _getColorForInitial(String initial) {
  const colorMap = {
    'A': Colors.red,
    'B': Colors.blue,
    'C': Colors.green,
    'D': Colors.orange,
    'E': Colors.purple,
    'F': Colors.teal,
    'G': Colors.brown,
    'H': Colors.indigo,
    'I': Colors.pink,
    'J': Colors.cyan,
    'K': Colors.lime,
    'L': Colors.amber,
    'M': Colors.deepOrange,
    'N': Colors.lightBlue,
    'O': Colors.lightGreen,
    'P': Colors.deepPurple,
    'Q': Colors.grey,
    'R': Colors.yellow,
    'S': Colors.blueAccent,
    'T': Colors.greenAccent,
    'U': Colors.orangeAccent,
    'V': Colors.purpleAccent,
    'W': Colors.redAccent,
    'X': Colors.tealAccent,
    'Y': Colors.limeAccent,
    'Z': Colors.indigoAccent,
  };

  // Restituisce il colore basato sull'iniziale, o un colore di default (grigio)
  return colorMap[initial.toUpperCase()] ?? Colors.grey;
}

class SidebarButton extends StatefulWidget {
  final int index;
  final IconData icon;
  final String title;
  final int selectedIndex;
  final Function(int) onSelected;

  const SidebarButton({
    super.key,
    required this.index,
    required this.icon,
    required this.title,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SidebarButtonState createState() => _SidebarButtonState();
}

class _SidebarButtonState extends State<SidebarButton> {
  bool isHovered = false; // Stato locale per l'hover

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.index == widget.selectedIndex;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onSelected(widget.index),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.grey[700] // Grigio scuro se selezionato
                : isHovered
                    ? Colors.grey[400] // Grigio chiaro se hover
                    : Colors.transparent, // Trasparente altrimenti
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              const SizedBox(width: 8),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActionIconWithText extends StatefulWidget {
  final IconData? icon;
  final String label;
  final VoidCallback? onTap;

  const ActionIconWithText({
    super.key,
    this.icon,
    required this.label,
    this.onTap,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ActionIconWithTextState createState() => _ActionIconWithTextState();
}

class _ActionIconWithTextState extends State<ActionIconWithText> {
  bool isHovered = false; // Stato per l'hover

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click, // Cambia il cursore al passaggio
      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
            decoration: BoxDecoration(
              color: isHovered
                  ? Colors.grey[400] // Colore di sfondo più scuro quando hover
                  : Colors.grey[200], // Colore normale
              borderRadius: BorderRadius.circular(4), // Bordi arrotondati
            ),
            child: Row(
              children: [
                if (widget.icon != null)
                  Icon(widget.icon, color: Colors.grey[700], size: 20), // Icona
                if (widget.icon != null) const SizedBox(width: 4), // Spaziatura
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black, // Testo nero
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
