import 'package:flutter/material.dart';
import 'package:flutter_app/pages/accounting/components/appbar.dart';
import 'package:flutter_app/pages/accounting/components/appbar_actions_menu.dart';
import 'package:flutter_app/pages/accounting/components/search_menu.dart';
import 'package:flutter_app/pages/accounting/components/body.dart';

class AccountingPage extends StatefulWidget {
  const AccountingPage({Key? key}) : super(key: key);

  @override
  State<AccountingPage> createState() => _AccountingPageState();
}

class _AccountingPageState extends State<AccountingPage> {
  String selectedFilter = "Fatture"; // Per gestire i filtri selezionati
  int selectedViewIndex = 0; // Indice per gestire lo stato dei pulsanti
  final LayerLink _searchLayerLink = LayerLink(); // LayerLink per la barra di ricerca
  final LayerLink _clientiLayerLink = LayerLink(); // LayerLink per il pulsante "Clienti"
  final LayerLink _fornitoriLayerLink = LayerLink(); // LayerLink per il pulsante "Fornitori"
  final LayerLink _contabilitaLayerLink = LayerLink(); // LayerLink per il pulsante "Contabilità"
  final LayerLink _rendicontazioneLayerLink = LayerLink(); // LayerLink per il pulsante "Rendicontazione"
  final LayerLink _configurazioneLayerLink = LayerLink(); // LayerLink per il pulsante "Configurazione"
  OverlayEntry? _searchMenuOverlay; // Overlay menu entry
  OverlayEntry? _actionsMenuOverlay; // Overlay per il menu a tendina
  final FocusNode _searchFocusNode = FocusNode(); // Focus per la barra di ricerca

  void _showSearchMenu() {
    if (_searchMenuOverlay != null) return;

    _searchMenuOverlay = createOverlayMenu(
      context: context,
      layerLink: _searchLayerLink,
      closeOverlayMenu: _closeSearchMenu,
    );

    Overlay.of(context).insert(_searchMenuOverlay!);
  }

  void _closeSearchMenu() {
    _searchMenuOverlay?.remove();
    _searchMenuOverlay = null;
  }

  void _showAppbarActionsDropdownMenu(String buttonTitle, LayerLink link) {
    if (_actionsMenuOverlay != null) _closeDropdownMenu();

    _actionsMenuOverlay = createDropdownMenu(
      context: context,
      link: link,
      onClose: _closeDropdownMenu,
      content: AppbarActionsMenu(
        menuTitle: buttonTitle,
        onTapActions: {
          "Fatture": () => print("Fatture selezionato"),
          "Note di credito": () => print("Note di credito selezionato"),
          "Pagamenti": () => print("Pagamenti selezionato"),
          "Ordini": () => print("Ordini selezionato"),
          "Bilancio": () => print("Bilancio selezionato"),
        },
      ),
    );

    Overlay.of(context).insert(_actionsMenuOverlay!);
  }

  void _closeDropdownMenu() {
    _actionsMenuOverlay?.remove();
    _actionsMenuOverlay = null;
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120), // Altezza personalizzata
        child: CustomAppBar(
          searchLayerLink: _searchLayerLink,
          searchFocusNode: _searchFocusNode,
          searchMenuOverlay: _searchMenuOverlay,
          showOverlayMenu: _showSearchMenu,
          closeOverlayMenu: _closeSearchMenu,
          selectedViewIndex: selectedViewIndex,
          onViewChanged: (index) {
            setState(() {
              selectedViewIndex = index;
            });
          },
          onDropDownMenuButtonPressed: (buttonTitle) {
            // Collega il menu al pulsante corretto
            LayerLink? link;
            switch (buttonTitle) {
              case "Clienti":
                link = _clientiLayerLink;
                break;
              case "Fornitori":
                link = _fornitoriLayerLink;
                break;
              case "Contabilità":
                link = _contabilitaLayerLink;
                break;
              case "Rendicontazione":
                link = _rendicontazioneLayerLink;
                break;
              case "Configurazione":
                link = _configurazioneLayerLink;
                break;
              default:
                link = null; // Fallback
            }

            _showAppbarActionsDropdownMenu(buttonTitle, link!);
          },
          onMenuButtonPressed: (buttonTitle) {
            print("'$buttonTitle' selezionato");
          },
                  // Passaggio dei LayerLinks specifici per ciascun pulsante
        clientiLayerLink: _clientiLayerLink,
        fornitoriLayerLink: _fornitoriLayerLink,
        contabilitaLayerLink: _contabilitaLayerLink,
        rendicontazioneLayerLink: _rendicontazioneLayerLink,
        configurazioneLayerLink: _configurazioneLayerLink,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          // Chiude i menu se sono aperti
          if (_searchMenuOverlay != null) _closeSearchMenu();
          if (_actionsMenuOverlay != null) _closeDropdownMenu();
        },
        child: Stack(
          children: [
            Center(
              child: Builder(
                builder: (context) {
                  // Controllo del widget da mostrare in base alla vista selezionata
                  switch (selectedViewIndex) {
                    case 0: // Elenco
                      return buildListPlaceholder();
                    case 1: // Kanban
                      return buildKanbanPlaceholder();
                    case 2: // Attività
                      return buildActivityPlaceholder();
                    default:
                      return const Text("Errore: Vista non trovata");
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}