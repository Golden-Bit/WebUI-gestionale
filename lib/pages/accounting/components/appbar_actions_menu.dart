import 'package:flutter/material.dart';
import 'package:flutter_app/pages/accounting/accounting_records_view.dart';
import 'package:flutter_app/pages/accounting/analytic_movements_view.dart';
import 'package:flutter_app/pages/accounting/assets_view.dart';
import 'package:flutter_app/pages/accounting/entIties_view.dart';
import 'package:flutter_app/pages/accounting/grouped_payments_view.dart';
import 'package:flutter_app/pages/accounting/invoice_view.dart';
import 'package:flutter_app/pages/accounting/loans_view.dart';
import 'package:flutter_app/pages/accounting/payment_view.dart';
import 'package:flutter_app/pages/accounting/products_view.dart';
import 'package:flutter_app/pages/accounting/transfers_view.dart';

class AppbarActionsMenu extends StatelessWidget {
  final String menuTitle;
  final Map<String, VoidCallback> onTapActions;

  const AppbarActionsMenu({
    Key? key,
    required this.menuTitle,
    required this.onTapActions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Widget>> menuItems = {
      "Clienti": [
        _buildHoverableListTile(
          title: "Fatture",
          onTap: onTapActions["Fatture"] ?? () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => InvoiceViewPage()),
      ),
        ),
        _buildHoverableListTile(
          title: "Note di credito",
          onTap: onTapActions["Note di credito"] ?? () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => InvoiceViewPage()),
      ),
        ),
        _buildHoverableListTile(
          title: "Pagamenti",
          onTap: onTapActions["Pagamenti"] ?? () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PaymentViewPage()),
      ),
        ),
        _buildHoverableListTile(
          title: "Pagamenti raggruppati",
          onTap: onTapActions["Pagamenti raggruppati"] ?? () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GroupedPaymentsViewPage()),
      ),
        ),
        _buildHoverableListTile(
          title: "Prodotti",
          onTap: onTapActions["Prodotti"] ?? () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProductsViewPage()),
      ),
        ),
        _buildHoverableListTile(
          title: "Clienti",
          onTap: onTapActions["Clienti"] ?? () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EntitiesViewPage()),
      ),
        ),
      ],
      //
      "Fornitori": [
        _buildHoverableListTile(
          title: "Fatture fornitore",
          onTap: onTapActions["Fatture fornitore"] ?? () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => InvoiceViewPage()),
      ),
        ),
        _buildHoverableListTile(
          title: "Note di credito",
          onTap: onTapActions["Note di credito"] ?? () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => InvoiceViewPage()),
      ),
        ),
        _buildHoverableListTile(
          title: "Pagamenti",
          onTap: onTapActions["Pagamenti"] ?? () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PaymentViewPage()),
      ),
        ),
        _buildHoverableListTile(
          title: "Pagamenti raggruppati",
          onTap: onTapActions["Pagamenti raggruppati"] ?? () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GroupedPaymentsViewPage()),
      ),
        ),
        _buildHoverableListTile(
          title: "Prodotti",
          onTap: onTapActions["Prodotti"] ?? () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProductsViewPage()),
      ),
        ),
        _buildHoverableListTile(
          title: "Fornitori",
          onTap: onTapActions["Fornitori"] ?? () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EntitiesViewPage()),
      ),
        ),
      ],
      //
      "Contabilità": [
        _buildHoverableListTile(
          title: "Registrazioni contabili",
          onTap: onTapActions["Registrazioni contabili"] ?? () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AccountingRecordsViewPage()),
      ),
        ),
        _buildHoverableListTile(
          title: "Movimenti contabili",
          onTap: onTapActions["Movimenti contabili"] ?? () => {},
        ),
        _buildHoverableListTile(
          title: "Trasferimenti",
          onTap: onTapActions["Trasferimenti"] ?? () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TransfersViewPage()),
      ),
        ),
        _buildHoverableListTile(
          title: "Movimenti analitici",
          onTap: onTapActions["Movimenti analitici"] ?? () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AnalyticMovementsViewPage()),
      ),
        ),
        _buildHoverableListTile(
          title: "Cespiti",
          onTap: onTapActions["Cespiti"] ?? () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AssetsViewPage()),
      ),
        ),
        _buildHoverableListTile(
          title: "Prestiti",
          onTap: onTapActions["Prestiti"] ?? () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoansViewPage()),
      ),
        ),
        _buildHoverableListTile(
          title: "Riconcilia",
          onTap: onTapActions["Riconcilia"] ?? () => {}
        ),
        _buildHoverableListTile(
          title: "Data blocco",
          onTap: onTapActions["Data blocco"] ?? () => {}
          )
      ],
      //
      "Rendicontazione": [
        _buildTitleTile("Resoconti estratto conto"), // Titolo
        _buildHoverableListTile(
          title: "Stato patrimoniale",
          onTap: onTapActions["Stato patrimoniale"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildHoverableListTile(
          title: "Conto economico",
          onTap: onTapActions["Conto economico"] ?? () {},
          horizontalPadding: 16,
          
        ),
        _buildHoverableListTile(
          title: "Rendiconto finanziario",
          onTap: onTapActions["Rendiconto finanziario"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildHoverableListTile(
          title: "Sintesi esecutiva",
          onTap: onTapActions["Sintesi esecutiva"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildHoverableListTile(
          title: "Dichiarazione dei redditi",
          onTap: onTapActions["Dichiarazione dei redditi"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildHoverableListTile(
          title: "Elenco di vendita CE",
          onTap: onTapActions["Elenco di vendita CE"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildTitleTile("Resoconti revisione"), // Titolo
        _buildHoverableListTile(
          title: "Libro mastro",
          onTap: onTapActions["Libro mastro"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildHoverableListTile(
          title: "Bilancio di verifica",
          onTap: onTapActions["Bilancio di verifica"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildHoverableListTile(
          title: "Registri IVA",
          onTap: onTapActions["Registri IVA"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildTitleTile("Rendiconti partner"), // Titolo
        _buildHoverableListTile(
          title: "Partitario clienti/fornitori",
          onTap: onTapActions["Partitario clienti/fornitori"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildHoverableListTile(
          title: "Crediti esigibili",
          onTap: onTapActions["Crediti esigibili"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildHoverableListTile(
          title: "Debiti scaduti",
          onTap: onTapActions["Debiti scaduti"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildTitleTile("Amministrazione"), // Titolo
        _buildHoverableListTile(
          title: "Analisi fatture",
          onTap: onTapActions["Analisi fatture"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildHoverableListTile(
          title: "Rendiconto analitico",
          onTap: onTapActions["Rendiconto analitico"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildHoverableListTile(
          title: "Risconto attivo",
          onTap: onTapActions["Risconto attivo"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildHoverableListTile(
          title: "Risconto passivo",
          onTap: onTapActions["Risconto passivo"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildHoverableListTile(
          title: "Piano di ammortamento",
          onTap: onTapActions["Piano di ammortamento"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildHoverableListTile(
          title: "Spese non deducibili",
          onTap: onTapActions["Spese non deducibili"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildHoverableListTile(
          title: "Analisi prestiti",
          onTap: onTapActions["Analisi prestiti"] ?? () {},
          horizontalPadding: 16,
        ),
      ],
      //
      "Configurazione": [
        _buildHoverableListTile(
          title: "Impostazioni",
          onTap: onTapActions["Impostazioni"] ?? () {},
        ),
        _buildTitleTile("Fatturazione"), // Titolo
        _buildHoverableListTile(
          title: "Termini di pagamento",
          onTap: onTapActions["Termini di pagamento"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildHoverableListTile(
          title: "Livelli di sollecito",
          onTap: onTapActions["Livelli di sollecito"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildTitleTile("Banche"), // Titolo
        _buildHoverableListTile(
          title: "Aggiungi conto bancario",
          onTap: onTapActions["Aggiungi conto bancario"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildHoverableListTile(
          title: "Aggiungi un conto carta di credito",
          onTap: onTapActions["Aggiungi un conto carta di credito"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildHoverableListTile(
          title: "Modelli di riconciliazione",
          onTap: onTapActions["Modelli di riconciliazione"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildTitleTile("Contabilità"), // Titolo
        _buildHoverableListTile(
          title: "Piano dei conti",
          onTap: onTapActions["Piano dei conti"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildHoverableListTile(
          title: "Imposte",
          onTap: onTapActions["Imposte"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildHoverableListTile(
          title: "Registri",
          onTap: onTapActions["Registri"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildHoverableListTile(
          title: "Valute",
          onTap: onTapActions["Valute"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildHoverableListTile(
          title: "Posizioni fiscali",
          onTap: onTapActions["Posizioni fiscali"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildHoverableListTile(
          title: "Libro mastro multiplo",
          onTap: onTapActions["Libro mastro multiplo"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildHoverableListTile(
          title: "Bilanci finanziari",
          onTap: onTapActions["Bilanci finanziari"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildTitleTile("Pagamenti online"), // Titolo
        _buildHoverableListTile(
          title: "Fornitori di pagamenti",
          onTap: onTapActions["Fornitori di pagamenti"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildHoverableListTile(
          title: "Metodi di pagamento",
          onTap: onTapActions["Metodi di pagamento"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildTitleTile("Amministrazione"), // Titolo
        _buildHoverableListTile(
          title: "Modelli cespite",
          onTap: onTapActions["Modelli cespite"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildHoverableListTile(
          title: "Categorie",
          onTap: onTapActions["Categorie"] ?? () {},
          horizontalPadding: 16,
        ),
        _buildHoverableListTile(
          title: "Categorie spese non deducibili",
          onTap: onTapActions["Categorie spese non deducibili"] ?? () {},
          horizontalPadding: 16,
        ),
      ],
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: menuItems[menuTitle] ?? [],
    );
  }

  Widget _buildHoverableListTile({
    required String title,
    required VoidCallback onTap,
    Widget? leading,
    Widget? trailing,
    double horizontalPadding = 8.0,
    double verticalPadding = 6.0,
  }) {
    Color backgroundColor = Colors.white; // Colore di sfondo iniziale

    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) {
            setState(() {
              backgroundColor = Colors.grey[200]!; // Colore hover
            });
          },
          onExit: (_) {
            setState(() {
              backgroundColor = Colors.white; // Ripristina colore normale
            });
          },
          child: InkWell(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  //shape: BoxShape.rectangle,
                  color: backgroundColor), // Sfondo dinamico basato sull'hover
              padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding, vertical: verticalPadding),
              child: Row(
                children: [
                  if (leading != null) leading, // Icona opzionale a sinistra
                  const SizedBox(width: 8), // Spaziatura tra leading e titolo
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  if (trailing != null) trailing, // Icona opzionale a destra
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// **Titolo (non cliccabile)**
  Widget _buildTitleTile(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600, // Semi-bold per distinguere i titoli
          color: Colors.black87, // Colore leggermente più scuro per i titoli
        ),
      ),
    );
  }
}
