import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobx/mobx.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

part 'register_text_screen.g.dart';

class RegisterTextScreen extends StatelessWidget {
  final TextRegisterStore store = TextRegisterStore();
  final List<String>? savedTexts; // Lista de textos salvos

  // Construtor modificado para receber a lista de textos
  RegisterTextScreen(this.savedTexts) {
    // Se há textos salvos, adiciona à store
    if (savedTexts != null && savedTexts!.isNotEmpty) {
      store.setTexts(savedTexts!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade700,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueGrey.shade700,
              Colors.grey,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Observer(
                    builder: (_) => Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: _buildTextItems(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: TextEditingController(text: store.text),
                      onChanged: store.setText,
                      onEditingComplete: () => _saveText(context),
                      decoration: InputDecoration(
                        hintText: 'Digite seu texto',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTextItems(BuildContext context) {
    final List<Widget> textItems = [];

    // Adicione o texto atual como primeiro item
    textItems.add(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                store.text ?? 'Digite seu texto',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );

    for (String text in store.texts) {
      textItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _editText(context, text),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _showDeleteConfirmationDialog(context, text),
              ),
            ],
          ),
        ),
      );
    }
    return textItems;
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, String? text) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar exclusão'),
          content: Text('Tem certeza de que deseja excluir o texto?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                store.removeText(text ?? ''); // Usar valor padrão se text for nulo
                Navigator.of(context).pop();
              },
              child: Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editText(BuildContext context, [String? text]) async {
    // Implemente a lógica de edição do texto aqui
    // Pode abrir um novo dialog com um campo de texto pré-preenchido
    // Você pode usar o método setText para atualizar o texto na store
  }

  Future<void> _saveText(BuildContext context) async {
    if (store.text != null && store.text!.isNotEmpty) {
      store.addText(store.text!);
      await store.saveTextsToSharedPreferences();
      store.clearText();
    }
  }
}

class TextRegisterStore = _TextRegisterStore with _$TextRegisterStore;

abstract class _TextRegisterStore with Store {
  @observable
  String? text;

  @observable
  ObservableList<String> texts = ObservableList<String>();

  @action
  void setText(String value) {
    text = value;
  }

  @action
  void clearText() {
    text = null;
  }

  @action
  void addText(String text) {
    if (text.isNotEmpty) {
      texts.add(text);
    }
  }

  @action
  void removeText(String text) {
    texts.remove(text);
    saveTextsToSharedPreferences();
  }

  @action
  void setTexts(List<String> texts) {
    this.texts = ObservableList<String>.of(texts);
  }

  Future<void> saveTextsToSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('savedTexts', texts);
  }

  Future<void> loadTextsFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTexts = prefs.getStringList('savedTexts');
    if (savedTexts != null) {
      setTexts(savedTexts);
    }
  }
}