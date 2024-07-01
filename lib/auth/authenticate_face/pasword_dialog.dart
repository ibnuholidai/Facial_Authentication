import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:facelogin/auth/auth_page.dart';
import 'package:facelogin/home/Dasboard.dart';
import 'package:facelogin/home/forgot_password_screen.dart';

class PasswordDialogTab extends StatefulWidget {
  final String email;
  const PasswordDialogTab({Key? key, required this.email}) : super(key: key);

  @override
  _PasswordDialogTabState createState() => _PasswordDialogTabState();
}

class _PasswordDialogTabState extends State<PasswordDialogTab> {
  late String email2 = widget.email.toString();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _obscureText = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double mediaquery_height = MediaQuery.of(context).size.height * 0.2;
    final double mediaquery_width = MediaQuery.of(context).size.width;

    return AlertDialog(
      alignment: Alignment.center,
      title: Text(
        textAlign: TextAlign.center,
        "verifikasi wajah tidak cocok ",
        style: TextStyle(
          fontSize: mediaquery_width * 0.04,
        ),
      ),
      content: Container(
        height: mediaquery_height * 2,
        width: mediaquery_width * 2,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text("Masukan Password"),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 5.0, right: 5.0, bottom: 5),
                      child: TextFormField(
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          enabled: false,
                          labelText: '${widget.email}',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: mediaquery_height * 0.1,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 5.0, right: 5.0, bottom: 5),
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          labelText: 'Insert password',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          } else if (value.length < 8) {
                            return 'Password should be at least 8 characters';
                          }
                          return null;
                        },
                        obscureText: _obscureText,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: !_obscureText,
                            onChanged: (value) {
                              setState(() {
                                _obscureText = !value!;
                              });
                            },
                          ),
                          Text(_obscureText
                              ? 'Tampilkan Password'
                              : 'Sembunyikan Password'),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: mediaquery_width * 0.3,
                      height: mediaquery_height * 0.25,
                      child: FloatingActionButton(
                        elevation: 0,
                        backgroundColor: Colors.blueAccent,
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Error"),
                                  content:
                                      Text("Password kurang dari 8 karakter."),
                                  actions: [
                                    TextButton(
                                      child: Text("OK"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                            return;
                          }

                          _auth
                              .signInWithEmailAndPassword(
                            email: widget.email,
                            password: _passwordController.text,
                          )
                              .then((value) {
                            GetStorage().write('token', value.user!.uid);
                            GetStorage().write('email', value.user!.email);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    Dashboard(userEmail: email2),
                              ),
                            );
                          }).catchError((error) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Error"),
                                  content: Text(
                                      "Password salah. Silakan coba lagi."),
                                  actions: [
                                    TextButton(
                                      child: Text("OK"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          });
                        },
                        child: const Text(
                          'Login',
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ForgotPasswordScreen(userEmail: email2),
                          ),
                        );
                      },
                      child: const Text('Forget Password'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            "Batal",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}
