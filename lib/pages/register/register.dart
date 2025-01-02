import 'package:flutter/material.dart';
import 'package:flutter_app/user_manager/auth_service.dart';
import 'package:flutter_app/user_manager/user_model.dart';


class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _register() async {
    if (_formKey.currentState!.validate()) {
      User user = User(
        username: _usernameController.text,
        email: _emailController.text,
        fullName: _fullNameController.text,
      );

      try {
        await _authService.register(user, _passwordController.text);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Registrazione avvenuta con successo'),
        ));
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Errore durante la registrazione: $e'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: IntrinsicHeight(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Registrazione',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(labelText: 'Username'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Inserisci il tuo username';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(labelText: 'Email'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Inserisci la tua email';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _fullNameController,
                          decoration: InputDecoration(labelText: 'Full Name'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Inserisci il tuo nome completo';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Inserisci la tua password';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(labelText: 'Conferma Password'),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Conferma la tua password';
                            }
                            if (value != _passwordController.text) {
                              return 'Le password non coincidono';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton(
                            onPressed: _register,
                            child: Text('Register'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
