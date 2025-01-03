
import 'package:flutter/material.dart';

class MultiSelectDialog extends StatefulWidget {
  final String title;
  final List<String> options;
  final List<String> selectedValues;

  MultiSelectDialog({
    required this.title,
    required this.options,
    required this.selectedValues,
  });

  @override
  _MultiSelectDialogState createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late List<String> selected;

  @override
  void initState() {
    super.initState();
    selected = List.from(widget.selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5, // Altezza fissa al 50% dello schermo
        child: Scrollbar(
          thumbVisibility: true, // Mostra il thumb dello scrollbar
          child: ListView(
            children: widget.options
                .map(
                  (option) => CheckboxListTile(
                    title: Text(option),
                    value: selected.contains(option),
                    onChanged: (bool? checked) {
                      setState(() {
                        if (checked == true) {
                          selected.add(option);
                        } else {
                          selected.remove(option);
                        }
                      });
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: Text("Annulla"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, selected),
          child: Text("Conferma"),
        ),
      ],
    );
  }
}
