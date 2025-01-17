import 'package:flutter/material.dart';
import 'package:flutter_app/databases_manager/database_pages.dart';
import 'package:flutter_app/document_manager/documents_utils.dart';
import 'package:flutter_app/document_manager/file_manager_service.dart';
import 'package:flutter_app/esg_data_manager/euroistat.dart';
import 'package:flutter_app/esg_data_manager/yahoo_finance.dart';
import 'package:flutter_app/pages/calendar/calendar.dart';
import 'package:flutter_app/pages/contacts/contacts.dart';
import 'package:flutter_app/pages/generic_object_page/generic_object_page.dart';
import 'package:flutter_app/pages/products/products.dart';
import 'package:flutter_app/pages/services/services.dart';
import 'package:flutter_app/pages/settings/settings.dart';
import 'package:flutter_app/pages/task_board/task_board.dart';
import 'package:flutter_app/pages/task_board/components/workspace_helpers.dart';
import 'package:flutter_app/pages/task_board/task_board_home.dart';
import 'dart:html' as html;

import 'package:flutter_app/user_manager/user_model.dart';

class WorkspaceBody extends StatelessWidget {
  final Workspace? selectedWorkspace;
  final Token token;
  final User user;

  const WorkspaceBody({
    Key? key,
    required this.selectedWorkspace,
    required this.user,
    required this.token,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          double gridWidth =
              constraints.maxWidth < 400 ? constraints.maxWidth : 400;
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
                            AccountSettingsPage(user: user, token: token),
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
                        builder: (context) => DatabasePage(
                            databases: user.databases,
                            token: token.accessToken,
                            user: user),
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
                          token: token.accessToken,
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
                          token: token.accessToken,
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
                          token: token.accessToken,
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
                          token: token.accessToken,
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
                          token: token.accessToken,
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
                          token: token.accessToken,
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
                          token: token.accessToken,
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
                  icon: Icons.bar_chart,
                  label: 'TaskBoard Home',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskBoardHome(
                          token: token.accessToken,
                          dbName: selectedWorkspace?.associatedDatabase ?? '',
                        ),
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
    );
  }

  Widget _buildGridCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
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
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.identity()..scale(isHovered ? 1.05 : 1.0),
              curve: Curves.easeInOut,
              child: Card(
                elevation: isHovered ? 8.0 : 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      4.0), // Cambia il valore per arrotondare di più o di meno
                ),
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 32.0),
                        const SizedBox(height: 4.0),
                        Text(
                          label,
                          style: const TextStyle(fontSize: 12.0),
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
