import 'package:flutter/material.dart';
import 'package:flutter_app/pages/accounting/components/subcomponents/products/Tab1Widget.dart';
import 'package:flutter_app/pages/accounting/components/subcomponents/products/Tab2Widget.dart';
import 'package:flutter_app/pages/accounting/components/subcomponents/products/products_actions_bar.dart';

/// Esempio di enum (qui non viene usato direttamente, ma potrebbe essere utile altrove)
enum EntityType { persona, azienda }

class EntityDetailsWidget extends StatefulWidget {
  const EntityDetailsWidget({Key? key}) : super(key: key);

  @override
  State<EntityDetailsWidget> createState() => _EntityDetailsWidgetState();
}

class _EntityDetailsWidgetState extends State<EntityDetailsWidget>
    with SingleTickerProviderStateMixin {
  // Di default "Acquisto" è spuntato (cioè _isAcquisto = true) e "Vendita" non spuntato.
  bool _isVendita = false;
  bool _isAcquisto = true;

  // Controller per il campo "Nome"
  final TextEditingController nameController =
      TextEditingController(text: "es. cheese burger");

  // Mappa per "Altre informazioni" (rimane invariata, se serve per altri scopi)
  Map<String, dynamic> myAdditionalInfoMap = {
    "entityType": "azienda",
    "selectedCompanyName": "Nessuna azienda",
    // ... altri campi se necessari ...
  };

  // Mappa "productInfo" per il tab "Informazioni generali"
  Map<String, dynamic> generalProductInfo = {
    "productType": "Beni",
    "salePrice": "1.00",
    "saleTax": "IVA 22%",
    "cost": "0.00",
    "purchaseTax": "Nessuna imposta",
    "category": "Nessuna categoria",
    "reference": "",
    "barcode": "",
    "internalNote": "Questa nota è solo per uso interno.",
    // Nuova chiave per controllare la visualizzazione delle imposte d'acquisto:
    "showPurchaseTax": true,
  };

  // Dati per la sezione "Contabilità" (Tab 2)
  Map<String, dynamic> myAccountingDataMap = {
    "creditAccount": "",
    "debitAccount": ""
  };

  // Tab Controller (2 tab: "Informazioni generali", "Contabilità")
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Aggiorniamo la chiave "showPurchaseTax" in base al checkbox "Acquisto"
    generalProductInfo["showPurchaseTax"] = _isAcquisto;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Colonna sinistra (2/3 della larghezza)
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // 1) Action Bar in alto (sempre visibile)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: InvoiceActionsBar(
                    onConfirm: () {
                      debugPrint("Conferma premuto");
                    },
                    onCancel: () {
                      debugPrint("Annulla premuto");
                    },
                    defaultIsDraft: true,
                  ),
                ),
                // 2) Container con bordo, margini e Tab
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // A) Parte TOP (nome + icona stella + fotocamera + checkbox Vendita/Acquisto)
                          _buildTopSection(),
                          // B) TabBar e TabBarView
                          Expanded(
                            child: Column(
                              children: [
                                TabBar(
                                  controller: _tabController,
                                  labelColor: Colors.black,
                                  indicatorColor: Colors.teal,
                                  tabs: const [
                                    Tab(text: "Informazioni generali"),
                                    Tab(text: "Contabilità"),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: TabBarView(
                                    controller: _tabController,
                                    children: [
                                      ProductDetailsWidget(
                                        productInfo: generalProductInfo,
                                        onProductInfoChanged: (newInfo) {
                                          setState(() {
                                            generalProductInfo = newInfo;
                                          });
                                        },
                                      ),
                                      AccountingTabWidget(
                                        accountingData: myAccountingDataMap,
                                        onChanged: (newData) {
                                          setState(() {
                                            myAccountingDataMap = newData;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Colonna destra (1/3 della larghezza) vuota
          Expanded(
            flex: 1,
            child: Container(color: Colors.transparent),
          ),
        ],
      ),
    );
  }

  /// Sezione TOP: include il titolo "Prodotto" sopra il campo Nome, l'icona stella a sinistra (cliccabile),
  /// il campo Nome e l'icona fotocamera fissa a destra; sotto i due checkbox "Vendita" e "Acquisto".
  Widget _buildTopSection() {
    return Column(
      children: [
        // Riga con: icona stella, colonna con titolo "Prodotto" e TextField, e icona fotocamera
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icona stella toggle
            const _StarToggleIcon(),
            const SizedBox(width: 8),
            // Colonna con titolo "Prodotto" e TextField per il nome
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Prodotto",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: "p. es. Lumber Inc",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Icona fotocamera fissa (96x96)
            SizedBox(
              width: 96,
              height: 96,
              child: IconButton(
                iconSize: 48,
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.grey,
                    ),
                  ],
                ),
                onPressed: () {
                  debugPrint("Carica immagine...");
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Riga con due checkbox: "Vendita" e "Acquisto"
        Row(
          children: [
            Checkbox(
              value: _isVendita,
              onChanged: (val) {
                setState(() {
                  _isVendita = val ?? false;
                });
              },
            ),
            const Text("Vendita"),
            const SizedBox(width: 16),
            Checkbox(
              value: _isAcquisto,
              onChanged: (val) {
                setState(() {
                  _isAcquisto = val ?? false;
                });
              },
            ),
            const Text("Acquisto"),
          ],
        ),
      ],
    );
  }
}

/// Widget per l'icona stella che si può selezionare/deselezionare.
class _StarToggleIcon extends StatefulWidget {
  const _StarToggleIcon({Key? key}) : super(key: key);

  @override
  __StarToggleIconState createState() => __StarToggleIconState();
}

class __StarToggleIconState extends State<_StarToggleIcon> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isSelected ? Icons.star : Icons.star_border,
        color: _isSelected ? Colors.yellow[700] : Colors.grey,
      ),
      onPressed: () {
        setState(() {
          _isSelected = !_isSelected;
        });
      },
    );
  }
}
