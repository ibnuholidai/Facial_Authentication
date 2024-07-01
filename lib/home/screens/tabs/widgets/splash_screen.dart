import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:facelogin/auth/auth_page.dart';
import 'package:facelogin/home/Dasboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final GetStorage _getStorage = GetStorage();
  @override
  initState(){
    openNextPage(context);
    super.initState();
  }

 openNextPage(BuildContext context){
   Timer(const Duration(milliseconds: 2000), (){
     if(_getStorage.read('token') == null || _getStorage.read('token') == ''){
       Navigator.pushReplacementNamed(context, auth_page.id);
     }else{
       Navigator.pushReplacementNamed(context, Dashboard.id);
     }
   });
 }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
