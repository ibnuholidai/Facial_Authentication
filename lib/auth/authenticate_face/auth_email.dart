import 'package:flutter/material.dart';
import 'package:facelogin/auth/authenticate_face/authenticate_face_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facelogin/common/utils/custom_text_field.dart';
import 'package:facelogin/common/views/custom_button.dart';
import 'package:facelogin/constants/theme.dart';

class AuthEmail extends StatefulWidget {
  const AuthEmail({Key? key}) : super(key: key);

  @override
  _AuthEmailState createState() => _AuthEmailState();
}

class _AuthEmailState extends State<AuthEmail> {
  final _formFieldKey4 = GlobalKey<FormFieldState>();
  late TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Fungsi untuk mengambil dokumen pengguna berdasarkan email dari Firestore
  void _fetchUserByEmail(String email) {
    final double mediaquery_width = MediaQuery.of(context).size.width;

    FirebaseFirestore.instance
        .collection(_emailController.text.trim().toString())
        .where('email', isEqualTo: email)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AuthenticateFaceView(
              userEmail: email,
            ),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Email tidak ditemukan.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: mediaquery_width * 0.5,
                    decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(10)),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        '   OK   ',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    }).catchError((error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan. Mohon coba lagi.'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: appBarColor,
        title: const Text("Masukan Email"),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextField(
                enable: true,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                hintText: "Email",
                validatorText: "Nama tidak boleh kosong",
                formFieldKey: _formFieldKey4,
                obscureText: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomButton(
                onTap: () {
                  String email = _emailController.text.trim();
                  _fetchUserByEmail(email);
                },
                text: 'Submit',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AuthEmail(),
  ));
}
