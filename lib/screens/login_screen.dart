import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool validateFields() {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Preencha todos os campos.');
      return false;
    }
    if (passwordController.text.length < 2) {
      Fluttertoast.showToast(msg: 'A senha deve ter pelo menos dois caracteres.');
      return false;
    }
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(passwordController.text)) {
      Fluttertoast.showToast(msg: 'A senha não pode conter caracteres especiais.');
      return false;
    }
    if (usernameController.text.length > 20 || passwordController.text.length > 20) {
      Fluttertoast.showToast(msg: 'Os campos não podem ter mais de 20 caracteres.');
      return false;
    }
    if (usernameController.text.endsWith(' ') || passwordController.text.endsWith(' ')) {
      Fluttertoast.showToast(msg: 'Os campos não podem terminar com espaço.');
      return false;
    }
    return true;
  }

  void login() async {
    if (validateFields()) {
      final String apiUrl =
          'https://657e14533e3f5b18946381a9.mockapi.io/pls-hire-me/api/v1/authentication';
      final response = await http.get(
        Uri.parse('$apiUrl?username=${usernameController.text}&password=${passwordController.text}'),
      );

      if (response.statusCode == 200) {
        print('Login bem-sucedido');
      } else {
        Fluttertoast.showToast(msg: 'Falha na autenticação. Verifique suas credenciais.');
      }
    }
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
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Usuário',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: TextField(
                            controller: usernameController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(left: 0),
                                child: Icon(Icons.person, color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Senha',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(left: 0),
                                child: Icon(Icons.lock, color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen[300],
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                  ),
                  child: const Text('Entrar', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
                const SizedBox(height: 200),
                GestureDetector(
                  onTap: openPrivacyPolicy,
                  child: const Text(
                    'Política de Privacidade',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}