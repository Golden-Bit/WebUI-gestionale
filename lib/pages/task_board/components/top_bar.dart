import 'package:flutter/material.dart';

class TopBarWidget extends StatelessWidget {
  final String boardName; // Nome della board attuale
  final VoidCallback onVisibilityPressed; // Callback per il pulsante Visibilità
  final VoidCallback onFilterPressed; // Callback per il pulsante Filtri
  final BoardView currentView; // Vista attuale
  final Function(BoardView) onViewSelected; // Callback per cambiare vista

  const TopBarWidget({
    Key? key,
    required this.boardName,
    required this.onVisibilityPressed,
    required this.onFilterPressed,
    required this.currentView,
    required this.onViewSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          bottom: BorderSide(color: Colors.grey, width: 1), // Bordo inferiore
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sezione sinistra: Nome board, stella, Visibilità e Tipologie di vista
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Nome board e icona stella
              Row(
                children: [
                  Text(
                    boardName, // Nome della board
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.star_border, color: Colors.black), // Stella
                ],
              ),
              const SizedBox(width: 16),

              // Pulsante Visibilità
              TextButton.icon(
                onPressed: onVisibilityPressed,
                icon: const Icon(Icons.group, color: Colors.black), // Icona gruppo
                label: const Text(
                  'Visibilità',
                  style: TextStyle(color: Colors.black),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[200], // Sfondo grigio chiaro
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4), // Angoli arrotondati
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Tipologie di vista
              Row(
                children: [
                  _ViewButton(
                    label: 'Bacheca',
                    icon: Icons.view_column,
                    isSelected: currentView == BoardView.board,
                    onPressed: () => onViewSelected(BoardView.board),
                  ),
                  _ViewButton(
                    label: 'Tabella',
                    icon: Icons.table_chart,
                    isSelected: currentView == BoardView.table,
                    onPressed: () => onViewSelected(BoardView.table),
                  ),
                  _ViewButton(
                    label: 'Calendario',
                    icon: Icons.calendar_today,
                    isSelected: currentView == BoardView.calendar,
                    onPressed: () => onViewSelected(BoardView.calendar),
                  ),
                ],
              ),
            ],
          ),

          // Sezione destra: Pulsanti Power-Up, Automazione, Filtri, Condividi e Menu
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Pulsante Power-Up
              _RightButton(
                icon: Icons.rocket_launch_outlined,
                label: 'Power-Up',
              ),
              const SizedBox(width: 8),

              // Pulsante Automazione
              _RightButton(
                icon: Icons.flash_on,
                label: 'Automazione',
              ),
              const SizedBox(width: 8),

              // Pulsante Filtri
              _RightButton(
                icon: Icons.filter_alt_outlined,
                label: 'Filtri',
                onPressed: onFilterPressed, // Usa il callback per Filtri
              ),
              const SizedBox(width: 8),

              // Pulsante Condividi
              _RightButton(
                icon: Icons.person_add_alt_1_outlined,
                label: 'Condividi',
              ),
              const SizedBox(width: 8),

              // Menu a tre pallini
              IconButton(
                onPressed: () {}, // Nessuna logica per ora
                icon: const Icon(
                  Icons.more_horiz,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ViewButton extends StatelessWidget {
  final String label; // Etichetta del pulsante
  final IconData icon; // Icona del pulsante
  final bool isSelected; // Indica se il pulsante è selezionato
  final VoidCallback onPressed; // Callback per il pulsante

  const _ViewButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.black,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? Colors.grey[700] : Colors.grey[200], // Sfondo
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4), // Angoli arrotondati
          ),
        ),
      ),
    );
  }
}

class _RightButton extends StatelessWidget {
  final String label; // Etichetta del pulsante
  final IconData icon; // Icona del pulsante
  final VoidCallback? onPressed; // Callback per il pulsante

  const _RightButton({
    Key? key,
    required this.label,
    required this.icon,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed, // Callback quando il pulsante è premuto
      icon: Icon(
        icon,
        color: Colors.black,
      ),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: Colors.grey[200], // Sfondo grigio chiaro
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4), // Angoli arrotondati
        ),
      ),
    );
  }
}

/// Enum per rappresentare le viste disponibili
enum BoardView { board, table, calendar }
