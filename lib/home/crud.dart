import 'package:flutter/material.dart';
import 'package:facelogin/model/user_model.dart';

class CrudPage extends StatelessWidget {
  final UserModel user;

  const CrudPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Halaman CRUD - ${user.name}"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Ini adalah halaman CRUD untuk pengguna ${user.name}",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
              },
              child: Text("Tambah Data"),
            ),
          ],
        ),
      ),
    );
  }
}
