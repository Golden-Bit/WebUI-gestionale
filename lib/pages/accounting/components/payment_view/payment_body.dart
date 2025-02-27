import 'package:flutter/material.dart';
import 'package:flutter_app/pages/accounting/components/payment_view/payment_viewer.dart';

/// Funzione che restituisce il widget PaymentDetailsWidget con paginazione.
/// 
/// [initialPageSize]: numero di elementi per pagina (default 50)
/// [initialPageNumber]: numero di pagina iniziale (0-indexed, default 0)
/// [onTotalCountChanged]: callback che restituisce il totale degli elementi
Widget buildListPlaceholder({
  int initialPageSize = 50,
  int initialPageNumber = 0,
  required String collectionName,
  required ValueChanged<int> onTotalCountChanged,
}) {
  return PaymentDetailsWidget(
    collectionName:collectionName,
    initialPageSize: initialPageSize,
    initialPageNumber: initialPageNumber,
    onTotalCountChanged: onTotalCountChanged,
  );
}

Widget buildKanbanPlaceholder() {
  return const Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.view_kanban, size: 64, color: Colors.orange),
      SizedBox(height: 16),
      Text(
        "Placeholder Kanban",
        style: TextStyle(color: Colors.orange, fontSize: 18),
      ),
    ],
  );
}

Widget buildActivityPlaceholder() {
  return const Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.local_activity, size: 64, color: Colors.green),
      SizedBox(height: 16),
      Text(
        "Placeholder Attività",
        style: TextStyle(color: Colors.green, fontSize: 18),
      ),
    ],
  );
}
