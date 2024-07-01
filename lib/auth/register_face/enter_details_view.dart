import 'dart:developer';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:facelogin/auth/auth_page.dart';
import 'package:uuid/uuid.dart';

import 'package:facelogin/common/utils/custom_snackbar.dart';
import 'package:facelogin/common/utils/custom_text_field.dart';
import 'package:facelogin/common/views/custom_button.dart';
import 'package:facelogin/constants/theme.dart';
import 'package:facelogin/model/user_model.dart';

class EnterDetailsView extends StatefulWidget {
  static const id = 'register_screen';
  final Function(bool) onRegistrationComplete;
  final String image;
  final FaceFeatures faceFeatures;

  const EnterDetailsView({
    Key? key,
    required this.image,
    required this.faceFeatures,
    required this.onRegistrationComplete,
  }) : super(key: key);

  @override
  State<EnterDetailsView> createState() => _EnterDetailsViewState();
}

class _EnterDetailsViewState extends State<EnterDetailsView> {
  final _formKey = GlobalKey<FormState>();
  final _formFieldKey = GlobalKey<FormFieldState>();
  final _formFieldKey2 = GlobalKey<FormFieldState>();
  final _formFieldKey3 = GlobalKey<FormFieldState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _obscureText = true;

  Future<bool> checkEmailExists(String email) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection(email)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    return documents.isNotEmpty;
  }

  void _showErrorDialog(String message) {
        final double mediaquery_width = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(child: Text('Error')),
        content: Text(message),
        actions: [
          Center(
            child: Container(
              width: mediaquery_width * 0.5,
              decoration: BoxDecoration(
                
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(10)
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('   OK   ',style: TextStyle(color: Colors.black),),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: appBarColor,
        title: const Text("Tambahkan Detail"),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scaffoldTopGradientClr,
              scaffoldBottomGradientClr,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextField(
                    enable: true,
                    formFieldKey: _formFieldKey,
                    keyboardType: TextInputType.text,
                    controller: _nameController,
                    hintText: "Nama",
                    validatorText: "Nama tidak boleh kosong",
                    obscureText: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama is required';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    enable: true,
                    formFieldKey: _formFieldKey2,
                    controller: _emailController,
                    hintText: "Email",
                    validatorText: "Email tidak valid",
                    keyboardType: TextInputType.emailAddress,
                    obscureText: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                          .hasMatch(value)) {
                        return 'Masukkan email yang valid';
                      }
                      return null;
                    },
                  ),
                  
                  CustomTextField(
                    enable: true,
                    formFieldKey: _formFieldKey3,
                    controller: _passwordController,
                    hintText: "Password",
                    validatorText: "Password tidak valid",
                    keyboardType: TextInputType.text,
                    obscureText: _obscureText,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      } else if (value.length < 8) {
                        return 'Password should be at least 8 characters';
                      }
                      return null;
                    },
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
                  CustomButton(
                    text: "Daftar Sekarang",
                    onTap: () async {
                      if (_formKey.currentState!.validate()) {
                        String email = _emailController.text.trim().toString();
                        String password =
                            _passwordController.text.trim().toString();

                        if (!email.endsWith('@gmail.com')) {
                          _showErrorDialog('Masukkan email yang valid');
                          return;
                        }

                        if (password.length < 8) {
                          _showErrorDialog('Password harus minimal 8 karakter');
                          return;
                        }

                        // String userId = Uuid().v1();
                        bool emailExists = await checkEmailExists(
                            _emailController.text.trim().toString());

                        if (emailExists) {
                          // Navigator.of(context).pop();
                          _showErrorDialog("Email sudah terdaftar!");
                        } else {
                          FocusScope.of(context).unfocus();
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(
                                color: accentColor,
                              ),
                            ),
                          );

                          String userId = Uuid().v1();
                          UserModel user = UserModel(
                            id: userId,
                          password: _passwordController.text.trim().toString(),
                          name: _nameController.text.trim().toString(),
                          email: _emailController.text.trim().toString(),
                            image: widget.image,
                            registeredOn: DateFormat('yyyy-MM-dd-HH:mm')
                                .format(DateTime.now()),
                            faceFeatures: widget.faceFeatures,
                          );

                          try {
                            await FirebaseFirestore.instance
                                .collection(
                                    _emailController.text.trim().toString())
                                .doc(".data")
                                .set(user.toJson());

                            Navigator.of(context).pop();
                            CustomSnackBar.successSnackBar(
                                "Registrasi Berhasil!");
                            widget.onRegistrationComplete(true);

                            Timer(
                              
                              Duration(seconds: 1),
                              () {
                                _auth
                                    .createUserWithEmailAndPassword(
                                        email: _emailController.text,
                                        password: _passwordController.text)
                                    .then((value) {
                                  Navigator.pushReplacementNamed(
                                      context, auth_page.id);
                                }).onError((error, stackTrace) {
                                  var snackBar = SnackBar(
                                    duration:
                                        const Duration(milliseconds: 5000),
                                    content: Text(
                                      'An Error occurred: $error',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.redAccent,
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                });
                              },
                            );
                          } catch (error) {
                            log("Registrasi Error: $error");
                            Navigator.of(context).pop();
                            _showErrorDialog("Registrasi Gagal! Coba Lagi.");
                          }
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
