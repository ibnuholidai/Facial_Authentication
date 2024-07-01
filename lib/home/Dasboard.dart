import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:facelogin/auth/auth_page.dart';
import 'package:facelogin/constants/theme.dart';

class Dashboard extends StatefulWidget {
  final String userEmail;
  const Dashboard({Key? key, required this.userEmail}) : super(key: key);
  static const id = 'dashboard';

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Future<String?> getNamaUser(String userEmail) async {
    if (userEmail.trim().isEmpty) {
      print("Email kosong.");
      return null;
    }

    var documentRef = FirebaseFirestore.instance
        .collection(userEmail.trim().toString())
        .doc('.data');
    try {
      var docSnapshot = await documentRef.get();
      if (docSnapshot.exists) {
        var data = docSnapshot.data();
        var nama = data?['name'];
        return nama;
      } else {
        print("Dokumen tidak ditemukan.");
        return null;
      }
    } catch (e) {
      print("Terjadi kesalahan: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF8185E2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: appBarColor,
        centerTitle: true,
        leading: Row(
          children: [
            IconButton(
              icon: Icon(Icons.logout_rounded),
              onPressed: () {
                GetStorage().remove('token');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => auth_page(),
                  ),
                );
              },
            ),
          ],
        ),
        title: Text('Dashboard'),
      ),
      body: Center(
        child: FutureBuilder<String?>(
          future: getNamaUser(widget.userEmail),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Text('Nama tidak ditemukan');
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    '${snapshot.data}',
                    style: TextStyle(fontSize: 20),
                  ),
                  // Tambahkan konten dashboard di sini
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
