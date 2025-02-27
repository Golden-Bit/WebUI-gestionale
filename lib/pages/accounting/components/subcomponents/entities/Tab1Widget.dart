import 'package:flutter/material.dart';

class ContattiIndirizziTab extends StatefulWidget {
  /// Elenco dei contatti iniziali. Ogni contatto è una mappa con i campi:
  /// 'tipo' => "Contatto"/"Fattura"/"Consegna"/"Indirizzo sollecito"/"Altro"
  /// 'nome' => string
  /// 'email' => string
  /// 'posizione' => string (solo se tipo == "Contatto")
  /// 'indirizzo', 'indirizzo2', 'citta', ... (solo se tipo != "Contatto")
  /// 'telefono', 'mobile', etc.
  final List<Map<String, String>> contacts;

  /// Callback invocata quando la lista contatti cambia (aggiunta, modifica).
  final ValueChanged<List<Map<String, String>>> onContactsChanged;

  const ContattiIndirizziTab({
    Key? key,
    required this.contacts,
    required this.onContactsChanged,
  }) : super(key: key);

  @override
  _ContattiIndirizziTabState createState() => _ContattiIndirizziTabState();
}

class _ContattiIndirizziTabState extends State<ContattiIndirizziTab> {
  /// Lista interna di contatti, clonata da widget.contacts
  late List<Map<String, String>> _contacts;

  /// Icone per i 5 tipi
  final Map<String, IconData> _typeIcons = {
    "Contatto": Icons.person,
    "Fattura": Icons.email,
    "Consegna": Icons.local_shipping,
    "Indirizzo sollecito": Icons.autorenew,
    "Altro": Icons.extension,
  };

  @override
  void initState() {
    super.initState();
    // Creiamo una copia locale per poter modificare e poi notificare
    _contacts = List<Map<String, String>>.from(widget.contacts);
  }

  /// Aggiorna la lista contatti e notifica il padre
  void _updateContacts(List<Map<String, String>> newContacts) {
    setState(() {
      _contacts = newContacts;
    });
    widget.onContactsChanged(newContacts);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pulsante "Aggiungi" in alto a sinistra
          Align(
            alignment: Alignment.topLeft,
            child: TextButton(
              onPressed: () => _showCreateContactDialog(context),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFEAEAEA),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text(
                "Aggiungi",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Se ci sono contatti, mostriamo la griglia di card
          if (_contacts.isNotEmpty)
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: List.generate(_contacts.length, (index) {
                final c = _contacts[index];
                final tipo = c["tipo"] ?? "Contatto";
                final iconData = _typeIcons[tipo] ?? Icons.help_outline;
                // Mostriamo come testo il "nome" del contatto
                final nome = c["nome"] ?? "(senza nome)";

                return MouseRegion(
                  cursor: SystemMouseCursors.click, // cursore "click"
                  child: GestureDetector(
                    onTap: () {
                      // Modalità modifica
                      _showCreateContactDialog(context, editIndex: index);
                    },
                    child: Container(
                      width: 120,
                      height: 80,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(iconData, size: 24, color: Colors.blueGrey),
                          const SizedBox(height: 4),
                          Text(
                            nome,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  /// Mostra il dialog “Crea/Modifica Contatto”.
  /// Se [editIndex] != null, allora è modalità modifica (carichiamo i valori esistenti).
  Future<void> _showCreateContactDialog(BuildContext context, {int? editIndex}) async {
    // Se stiamo modificando, recuperiamo la mappa esistente
    Map<String, String>? existing;
    if (editIndex != null) {
      existing = _contacts[editIndex];
    }

    // Radio di default o valore esistente
    String tipoContatto = existing?["tipo"] ?? "Contatto";

    final TextEditingController nomeCtrl = TextEditingController(
      text: existing?["nome"] ?? "ad es. Nuovo indirizzo",
    );
    final TextEditingController emailCtrl = TextEditingController(
      text: existing?["email"] ?? "",
    );
    final TextEditingController posizioneCtrl = TextEditingController(
      text: existing?["posizione"] ?? "",
    );

    // Campi indirizzo (solo se tipoContatto != "Contatto")
    final TextEditingController indirizzoCtrl = TextEditingController(
      text: existing?["indirizzo"] ?? "",
    );
    final TextEditingController indirizzo2Ctrl = TextEditingController(
      text: existing?["indirizzo2"] ?? "",
    );
    final TextEditingController cittaCtrl = TextEditingController(
      text: existing?["citta"] ?? "",
    );
    final TextEditingController provinciaCtrl = TextEditingController(
      text: existing?["provincia"] ?? "",
    );
    final TextEditingController capCtrl = TextEditingController(
      text: existing?["cap"] ?? "",
    );
    final TextEditingController nazioneCtrl = TextEditingController(
      text: existing?["nazione"] ?? "",
    );

    // Telefono e Dispositivo mobile (sempre)
    final TextEditingController telefonoCtrl = TextEditingController(
      text: existing?["telefono"] ?? "",
    );
    final TextEditingController mobileCtrl = TextEditingController(
      text: existing?["mobile"] ?? "",
    );

    // Funzione interna per creare/aggiornare un contatto (mappa) dai campi
    Map<String, String> _buildContactFromFields() {
      if (tipoContatto == "Contatto") {
        return {
          "tipo": tipoContatto,
          "nome": nomeCtrl.text.trim(),
          "email": emailCtrl.text.trim(),
          "posizione": posizioneCtrl.text.trim(),
          "telefono": telefonoCtrl.text.trim(),
          "mobile": mobileCtrl.text.trim(),
        };
      } else {
        return {
          "tipo": tipoContatto,
          "nome": nomeCtrl.text.trim(),
          "email": emailCtrl.text.trim(),
          "indirizzo": indirizzoCtrl.text.trim(),
          "indirizzo2": indirizzo2Ctrl.text.trim(),
          "citta": cittaCtrl.text.trim(),
          "provincia": provinciaCtrl.text.trim(),
          "cap": capCtrl.text.trim(),
          "nazione": nazioneCtrl.text.trim(),
          "telefono": telefonoCtrl.text.trim(),
          "mobile": mobileCtrl.text.trim(),
        };
      }
    }

    // Funzione per svuotare i campi (nel caso di "Salva e nuovo" in creazione)
    void _resetFields() {
      tipoContatto = "Contatto";
      nomeCtrl.text = "ad es. Nuovo indirizzo";
      emailCtrl.clear();
      posizioneCtrl.clear();
      indirizzoCtrl.clear();
      indirizzo2Ctrl.clear();
      cittaCtrl.clear();
      provinciaCtrl.clear();
      capCtrl.clear();
      nazioneCtrl.clear();
      telefonoCtrl.clear();
      mobileCtrl.clear();
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              child: Container(
                width: 800, // dimensioni indicative
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Titolo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          editIndex == null ? "Crea Contatto" : "Modifica Contatto",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Riga con i 5 radio button
                    Row(
                      children: [
                        _buildRadioTipo("Contatto", tipoContatto, (val) {
                          setStateDialog(() {
                            tipoContatto = val;
                          });
                        }),
                        const SizedBox(width: 16),
                        _buildRadioTipo("Fattura", tipoContatto, (val) {
                          setStateDialog(() {
                            tipoContatto = val;
                          });
                        }),
                        const SizedBox(width: 16),
                        _buildRadioTipo("Consegna", tipoContatto, (val) {
                          setStateDialog(() {
                            tipoContatto = val;
                          });
                        }),
                        const SizedBox(width: 16),
                        _buildRadioTipo("Indirizzo sollecito", tipoContatto, (val) {
                          setStateDialog(() {
                            tipoContatto = val;
                          });
                        }),
                        const SizedBox(width: 16),
                        _buildRadioTipo("Altro", tipoContatto, (val) {
                          setStateDialog(() {
                            tipoContatto = val;
                          });
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // RIGA 1: Nome - E-mail
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nome
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Nome"),
                              const SizedBox(height: 4),
                              TextField(
                                controller: nomeCtrl,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // E-mail
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("E-mail"),
                              const SizedBox(height: 4),
                              TextField(
                                controller: emailCtrl,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Se tipoContatto == "Contatto", mostriamo "Posizione lavorativa"
                    if (tipoContatto == "Contatto") ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Posizione lavorativa"),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: posizioneCtrl,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      // Altrimenti, mostriamo i campi Indirizzo, Indirizzo 2, etc.

                      // RIGA 2: Indirizzo - Indirizzo 2
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Indirizzo
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Indirizzo"),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: indirizzoCtrl,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Indirizzo 2
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Indirizzo 2"),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: indirizzo2Ctrl,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // RIGA 3: Città - Provincia - CAP - Nazione
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Città
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Città"),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: cittaCtrl,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Provincia
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Provincia"),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: provinciaCtrl,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // CAP
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("CAP"),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: capCtrl,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Nazione
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Nazione"),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: nazioneCtrl,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // RIGA 4: Telefono - Dispositivo mobile (sempre)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Telefono
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Telefono"),
                              const SizedBox(height: 4),
                              TextField(
                                controller: telefonoCtrl,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Dispositivo mobile
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Dispositivo mobile"),
                              const SizedBox(height: 4),
                              TextField(
                                controller: mobileCtrl,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // RIGA PULSANTI IN BASSO
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Salva e chiudi
                        TextButton(
                          onPressed: () {
                            final updatedContact = _buildContactFromFields();

                            setState(() {
                              if (editIndex != null) {
                                // Aggiorniamo contatto esistente
                                _contacts[editIndex!] = updatedContact;
                              } else {
                                // Aggiungiamo nuovo contatto
                                _contacts.add(updatedContact);
                              }
                            });
                            // Notifichiamo il padre
                            widget.onContactsChanged(_contacts);

                            Navigator.of(ctx).pop(); // chiude il dialog
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF6B3A5B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: const Text("Salva e chiudi"),
                        ),
                        const SizedBox(width: 8),

                        // Salva e nuovo (solo se in creazione, non in modifica)
                        if (editIndex == null) ...[
                          TextButton(
                            onPressed: () {
                              final newContact = _buildContactFromFields();
                              setState(() {
                                _contacts.add(newContact);
                              });
                              widget.onContactsChanged(_contacts);
                              _resetFields();
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFF6B3A5B),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            child: const Text("Salva e nuovo"),
                          ),
                          const SizedBox(width: 8),
                        ],

                        // Abbandona
                        OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: const BorderSide(color: Colors.grey),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: const Text(
                            "Abbandona",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Costruisce un singolo radio per "tipo contatto"
  Widget _buildRadioTipo(
    String label,
    String currentValue,
    ValueChanged<String> onChanged,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: label,
          groupValue: currentValue,
          onChanged: (val) {
            if (val != null) {
              onChanged(val);
            }
          },
        ),
        Text(label),
      ],
    );
  }
}
