import 'package:facelogin/auth/auth_page.dart';
import 'package:facelogin/auth/authenticate_face/authenticate_face_view.dart';
import 'package:facelogin/auth/register_face/register_face_view.dart';
import 'package:facelogin/home/Dasboard.dart';

import '../forgot_password_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  Route? onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {

      case Dashboard.id:
        return MaterialPageRoute(
          builder: (_) => const Dashboard(userEmail: '',),
        );
      case RegisterFaceView.id:
        return MaterialPageRoute(
          builder: (_) => const RegisterFaceView(),
        );
      case AuthenticateFaceView.id:
        return MaterialPageRoute(
          builder: (_) => const AuthenticateFaceView(userEmail: '',),
        );
      case ForgotPasswordScreen.id:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(userEmail: '',),
        );
      case auth_page.id:
        return MaterialPageRoute(
          builder: (_) => const auth_page(),
        );
      default:
        return null;
    }
  }
}
