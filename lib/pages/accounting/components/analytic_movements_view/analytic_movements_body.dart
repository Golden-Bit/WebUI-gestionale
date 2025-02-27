import 'package:flutter/material.dart';
import 'package:flutter_app/pages/accounting/components/analytic_movements_view/analytic_movements_viewer.dart';

/*Widget buildListPlaceholder() {
  return const Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.list, size: 64, color: Colors.blue),
      SizedBox(height: 16),
      Text(
        "Placeholder Elenco",
        style: TextStyle(color: Colors.blue, fontSize: 18),
      ),
    ],
  );
}*/

Widget buildListPlaceholder() {
  return AnalyticMovementsPage();
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
