import 'package:flutter/material.dart';
import 'package:flutter_app/pages/accounting/components/appbar_v2.dart';
import 'package:flutter_app/pages/accounting/components/appbar_actions_menu.dart';
import 'package:flutter_app/pages/accounting/components/search_menu.dart';
import 'package:flutter_app/pages/accounting/components/payment_view/payment_body.dart';
import 'package:flutter_app/pages/accounting/products.dart';

class ProductsViewPage extends StatefulWidget {
  const ProductsViewPage({Key? key}) : super(key: key);

  @override
  State<ProductsViewPage> createState() => _ProductsViewPageState();
}

class _ProductsViewPageState extends State<ProductsViewPage> {
  //String selectedFilter = "Fatture"; // Per gestire i filtri selezionati
  int selectedViewIndex = 0;         // Indice per gestire lo stato dei pulsanti

  // -------------------------- VARIABILI DI PAGINAZIONE --------------------------
  int currentPage = 0;    // Pagina corrente
  int pageSize = 30;      // Quanti elementi per pagina
  int totalItems = 100;   // Totale di default (aggiornato via callback)

  final LayerLink _searchLayerLink = LayerLink(); 
  final LayerLink _clientiLayerLink = LayerLink();
  final LayerLink _fornitoriLayerLink = LayerLink();
  final LayerLink _contabilitaLayerLink = LayerLink();
  final LayerLink _rendicontazioneLayerLink = LayerLink();
  final LayerLink _configurazioneLayerLink = LayerLink();

  OverlayEntry? _searchMenuOverlay;  // Overlay menu entry
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
      // La CustomAppBar ha i parametri di paginazione e la callback
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120), // Altezza personalizzata
        child: CustomAppBar(
          searchLayerLink: _searchLayerLink,
          searchFocusNode: _searchFocusNode,
          searchMenuOverlay: _searchMenuOverlay,
          showOverlayMenu: _showSearchMenu,
          closeOverlayMenu: _closeSearchMenu,
          selectedViewIndex: selectedViewIndex,
                    onNuovoPressed: () => {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProductsEditorPage()))
          },
          onCaricaPressed: () => {},
          onViewChanged: (index) {
            setState(() {
              selectedViewIndex = index;
            });
          },
          onDropDownMenuButtonPressed: (buttonTitle) {
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
                link = null;
            }
            if (link != null) {
              _showAppbarActionsDropdownMenu(buttonTitle, link);
            }
          },
          onMenuButtonPressed: (buttonTitle) {
            print("'$buttonTitle' selezionato");
          },
          clientiLayerLink: _clientiLayerLink,
          fornitoriLayerLink: _fornitoriLayerLink,
          contabilitaLayerLink: _contabilitaLayerLink,
          rendicontazioneLayerLink: _rendicontazioneLayerLink,
          configurazioneLayerLink: _configurazioneLayerLink,

          // -------------------- PASSIAMO I PARAMETRI DI PAGINAZIONE --------------------
          currentPage: currentPage,
          totalItems: totalItems,
          pageSize: pageSize,
          onPageChanged: (newPage) {
            // Quando l'utente clicca sulle frecce, aggiorniamo la pagina
            setState(() {
              currentPage = newPage;
            });
          },
        ),
      ),
      body: GestureDetector(
        onTap: () {
          // Chiude eventuali menu Overlay se l'utente fa tap altrove
          if (_searchMenuOverlay != null) _closeSearchMenu();
          if (_actionsMenuOverlay != null) _closeDropdownMenu();
        },
        child: Stack(
          children: [
            //Center(
              //child: 
              Builder(
                builder: (context) {
                  switch (selectedViewIndex) {
                    case 0: // Elenco
                      return buildListPlaceholder(
                        collectionName: "products",
                        // Usiamo i nostri parametri di stato (reactive)
                        initialPageSize: pageSize,
                        initialPageNumber: currentPage,
                        onTotalCountChanged: (total) {
                          // Aggiorniamo il valore totale in modo che si rifletta in AppBar
                          setState(() {
                            totalItems = total;
                          });
                          print("Totale pagamenti: $total");
                        },
                      );

                    case 1: // Kanban
                      return Center(child: buildKanbanPlaceholder());

                    case 2: // Attività
                      return Center(child: buildActivityPlaceholder());

                    default:
                      return const Text("Errore: Vista non trovata");
                  }
                },
              ),
            //),
          ],
        ),
      ),
    );
  }
}
