import 'package:flutter/material.dart';
import 'package:facelogin/common/utils/extensions/size_extension.dart';
import 'package:facelogin/constants/theme.dart';
import 'package:facelogin/home/crud.dart';
import 'package:facelogin/model/user_model.dart';

class UserDetailsView extends StatelessWidget {
  final UserModel user;

  const UserDetailsView({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: appBarColor,
        title: const Text("Authenticated!!!"),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 42,
                backgroundColor: primaryWhite,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: accentColor,
                  child: Icon(
                    Icons.check,
                    color: primaryWhite,
                    size: 44,
                  ),
                ),
              ),
              SizedBox(height: 0.025.sh),
              Text(
                "Halo, ${user.name}!",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 26,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Anda Berhasil Terotentikasi!",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: textColor.withOpacity(0.6),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CrudPage(user: user),
                    ),
                  );
                },
                child: Text("Lanjut ke Halaman"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


