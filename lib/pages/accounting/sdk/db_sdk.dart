import 'dart:async';

class FakePaymentSdk {
  /// Restituisce lo schema JSON associato alla collection specificata.
  static Future<Map<String, dynamic>> getSchema({
    required String collectionName,
  }) async {
    // Simula un delay di rete.
    await Future.delayed(const Duration(milliseconds: 200));
    if (collectionName == "payments") {
      return {
        "selected": {"type": "bool", "label": "Seleziona"},
        "Data": {"type": "date", "label": "Data"},
        "Numero": {"type": "string", "label": "Numero"},
        "Registro": {"type": "string", "label": "Registro"},
        "Metodo pagamento": {"type": "string", "label": "Metodo"},
        "Partner": {"type": "string", "label": "Partner"},
        "Pagamento aggregato": {"type": "bool", "label": "Aggregato"},
        "Importo IVA inc.": {"type": "number", "label": "Importo"},
        "Valuta pagamento": {"type": "string", "label": "Valuta"},
        "Saldo/Pagato": {"type": "number", "label": "Saldo/Pagato"},
        "Attività": {"type": "bool", "label": "Attività"},
        "Stato": {"type": "string", "label": "Stato"},
      };
    } else if (collectionName == "invoices") {
      return {
        "selected": {"type": "bool", "label": "Seleziona"},
        "Data": {"type": "date", "label": "Data Fattura"},
        "InvoiceNumber": {"type": "string", "label": "Numero Fattura"},
        "Client": {"type": "string", "label": "Cliente"},
        "Amount": {"type": "number", "label": "Importo"},
        "Status": {"type": "string", "label": "Stato"},
      };
    } else if (collectionName == "orders") {
      return {
        "selected": {"type": "bool", "label": "Seleziona"},
        "OrderDate": {"type": "date", "label": "Data Ordine"},
        "OrderNumber": {"type": "string", "label": "Numero Ordine"},
        "Customer": {"type": "string", "label": "Cliente"},
        "Total": {"type": "number", "label": "Totale"},
        "DeliveryDate": {"type": "date", "label": "Data Consegna"},
        "Status": {"type": "string", "label": "Stato"},
      };
    }
    return {};
  }

  /// Simula una "database" come mappa: nome della collection -> lista di documenti (oggetti).
  static final Map<String, List<Map<String, dynamic>>> _database = {
    // Collection "payments" con 149 oggetti.
    "payments": List.generate(149, (index) {
      return {
        "selected": false,
        "Data": DateTime(2023, 1, 1).add(Duration(days: index)),
        "Numero": "PAY-${(index + 1).toString().padLeft(3, '0')}",
        "Registro": (index % 2 == 0) ? "Banca" : "Cassa",
        "Metodo pagamento": [
          "Manual Payment",
          "Bonifico bancario",
          "Carta di credito",
          "Assegno"
        ][index % 4],
        "Partner": "Partner ${index % 10}",
        "Pagamento aggregato": (index % 3 == 0),
        "Importo IVA inc.": 100.0 + index,
        "Valuta pagamento": (index % 2 == 0) ? "EUR" : "USD",
        "Saldo/Pagato": 50.0 + index,
        "Attività": (index % 5 == 0),
        "Stato": (index % 4 == 0) ? "PAGATO" : "IN ATTESA",
      };
    }),
    // Collection "invoices" con 75 oggetti.
    "invoices": List.generate(75, (index) {
      return {
        "selected": false,
        "Data": DateTime(2023, 2, 1).add(Duration(days: index)),
        "InvoiceNumber": "INV-${(index + 1).toString().padLeft(4, '0')}",
        "Client": "Cliente ${index % 15}",
        "Amount": 500.0 + (index * 10),
        "Status": (index % 3 == 0) ? "Pagata" : "In attesa",
      };
    }),
    // Collection "orders" con 60 oggetti.
    "orders": List.generate(60, (index) {
      return {
        "selected": false,
        "OrderDate": DateTime(2023, 3, 1).add(Duration(days: index)),
        "OrderNumber": "ORD-${(index + 1).toString().padLeft(3, '0')}",
        "Customer": "Cliente ${index % 20}",
        "Total": 300.0 + (index * 5),
        "DeliveryDate": DateTime(2023, 3, 15).add(Duration(days: index)),
        "Status": (index % 2 == 0) ? "Consegnato" : "In elaborazione",
      };
    }),
  };

  /// Permette di impostare (o sovrascrivere) una collection con una lista di documenti.
  static void setCollection(String collectionName, List<Map<String, dynamic>> items) {
    _database[collectionName] = items;
  }

  /// Restituisce una porzione (pagina) della lista dalla collection specificata,
  /// simulando una chiamata di rete.
  static Future<List<Map<String, dynamic>>> getPayments({
    required String collectionName,
    int skip = 0,
    int maxSize = 50,
  }) async {
    // Simula un delay di rete.
    await Future.delayed(const Duration(milliseconds: 500));
    final collection = _database[collectionName] ?? [];
    return collection.skip(skip).take(maxSize).toList();
  }

  /// Restituisce il numero totale di elementi presenti nella collection specificata.
  static Future<int> getTotalCount({required String collectionName}) async {
    final collection = _database[collectionName] ?? [];
    return collection.length;
  }
}
