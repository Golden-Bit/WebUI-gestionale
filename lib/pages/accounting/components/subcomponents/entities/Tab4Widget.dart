import 'package:flutter/material.dart';

/// Widget per il tab "NOTE ESTERNE"
/// Aggiungiamo due proprietà: 
/// - initialNote: il valore iniziale delle note
/// - onNoteChanged: callback chiamata ogni volta che il valore cambia
class NoteEsterneTab extends StatefulWidget {
  final String initialNote;
  final ValueChanged<String> onNoteChanged;

  const NoteEsterneTab({
    Key? key,
    required this.initialNote,
    required this.onNoteChanged,
  }) : super(key: key);

  @override
  _NoteEsterneTabState createState() => _NoteEsterneTabState();
}

class _NoteEsterneTabState extends State<NoteEsterneTab> {
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.initialNote);
    // Aggiungiamo un listener per tracciare le modifiche e invocare la callback
    _notesController.addListener(() {
      widget.onNoteChanged(_notesController.text);
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _notesController,
        decoration: const InputDecoration(
          labelText: "Note Esterne",
          border: OutlineInputBorder(),
        ),
        maxLines: null, // Consente l'inserimento di più righe
        keyboardType: TextInputType.multiline,
      ),
    );
  }
}