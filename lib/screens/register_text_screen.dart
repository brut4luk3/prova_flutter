import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobx/mobx.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

part 'register_text_screen.g.dart';

class RegisterTextScreen extends StatelessWidget {
  final TextRegisterStore store = TextRegisterStore();

  RegisterTextScreen(List<String>? savedTexts) {
    if (savedTexts != null) {
      store.setTexts(savedTexts);
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
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.elliptical(5, 70),
                            topRight: Radius.elliptical(5, 70),
                            bottomLeft: Radius.elliptical(5, 70),
                            bottomRight: Radius.elliptical(5, 70),
                          )
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: _buildTextItems(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        TextField(
                          textAlign: TextAlign.center,
                          controller: TextEditingController(text: store.text),
                          onChanged: store.setText,
                          onEditingComplete: () => _saveText(context),
                          decoration: InputDecoration(
                            hintText: 'Digite seu texto',
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black,
                            ),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (value) {
                            if (value.isEmpty) {
                              Fluttertoast.showToast(
                                msg: 'Você precisa digitar algum texto!',
                              );
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Texto salvo!",
                              );
                              _saveText(context);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 100),
                GestureDetector(
                  onTap: openPrivacyPolicy,
                  child: const Text(
                    'Política de Privacidade',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
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

  void openPrivacyPolicy() async {
    const url = 'https://www.google.com.br';
    Uri new_url = Uri.parse(url);
    if (await canLaunchUrl(new_url)) {
      await launchUrl(new_url);
    } else {
      Fluttertoast.showToast(msg: 'Não foi possível abrir a política de privacidade.');
    }
  }

  List<Widget> _buildTextItems(BuildContext context) {
    final List<Widget> textItems = [];
    for (String text in store.texts) {
      textItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _editText(context, text),
                      child: Text(
                        _truncateText(text),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.mode_edit),
                    color: Colors.black,
                    iconSize: 50,
                    onPressed: () => _editText(context, text),
                  ),
                  IconButton(
                    icon: Icon(Icons.cancel_rounded),
                    color: Colors.red.shade600,
                    iconSize: 50,
                    onPressed: () =>
                        _showDeleteConfirmationDialog(context, text),
                  ),
                ],
              ),
              const Divider(color: Colors.black),
            ],
          ),
        ),
      );
    }
    return textItems;
  }

  String _truncateText(String text) {
    const int maxLength = 20;
    return text.length <= maxLength
        ? text
        : '${text.substring(0, maxLength)}...';
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, String text) async {
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
                store.removeText(text);
                Navigator.of(context).pop();
              },
              child: Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editText(BuildContext context, String text) async {
    TextEditingController editController = TextEditingController(text: text);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Texto'),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(
              hintText: 'Digite seu texto',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                store.editText(text, editController.text);
                Navigator.of(context).pop();
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  bool saving = false;

  Future<void> _saveText(BuildContext context) async {
    if (!saving && store.text != null && store.text!.isNotEmpty) {
      saving = true;
      store.addText(store.text!);
      await store.saveTextsToSharedPreferences();
      store.clearText();
      saving = false;
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

  @action
  void editText(String oldText, String newText) {
    if (texts.contains(oldText)) {
      final index = texts.indexOf(oldText);
      texts[index] = newText;
      saveTextsToSharedPreferences();
    }
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
