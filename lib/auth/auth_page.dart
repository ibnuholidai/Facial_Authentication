import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:facelogin/auth/authenticate_face/auth_email.dart';
import 'package:facelogin/common/utils/custom_snackbar.dart';
import 'package:facelogin/common/utils/screen_size_util.dart';
import 'package:facelogin/auth/delayed_animation.dart';
import 'package:facelogin/auth/register_face/register_face_view.dart';

class auth_page extends StatefulWidget {
  static const id = 'start_screen';
  const auth_page({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<auth_page> with SingleTickerProviderStateMixin {
  void initializeUtilContexts(BuildContext context) {
    ScreenSizeUtil.context = context;
    CustomSnackBar.context = context;
  }

  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    initializeUtilContexts(context);
    final double mediaquery_height_normal = MediaQuery.of(context).size.height;
    final double mediaquery_width = MediaQuery.of(context).size.width;
    final color = Colors.white;
    _scale = 1 - _controller.value;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          backgroundColor: Color(0xFF8185E2),
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  AvatarGlow(
                    duration: Duration(seconds: 2),
                    glowColor: Colors.white,
                    repeat: true,
                    startDelay: Duration(seconds: 1),
                    child: Material(
                        surfaceTintColor: Colors.transparent,
                        color: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: CircleBorder(),
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Image.asset("assets/face id.png"),
                          radius: 50.0,
                        )),
                  ),
                  SizedBox(
                    height: mediaquery_height_normal * 0.1,
                  ),
                  DelayedAnimation(
                    child: Text(
                      "Welcome",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: mediaquery_width * 0.1,
                          color: color),
                    ),
                    delay: 2000,
                  ),
                  SizedBox(
                    height: mediaquery_height_normal * 0.07,
                  ),
                  DelayedAnimation(
                    child: Text(
                      "Protect your data with ",
                      style: TextStyle(
                          fontSize: mediaquery_width * 0.05, color: color),
                    ),
                    delay: 3000,
                  ),
                  DelayedAnimation(
                    child: Text(
                      "facial authentication",
                      style: TextStyle(
                          fontSize: mediaquery_width * 0.05, color: color),
                    ),
                    delay: 3000,
                  ),
                  // SizedBox(
                  //   height: mediaquery_height_normal * 0.1,
                  // ),
                  Container(
                    // color: Colors.red,
                    height: mediaquery_height_normal * 0.2,
                    width: mediaquery_width * 0.7,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        DelayedAnimation(
                          child: Container(
                            width: mediaquery_width * 0.7,
                            height: mediaquery_height_normal * 0.07,
                            child: ElevatedButton(
                              onPressed: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterFaceView(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: color, // Background color
                                textStyle: TextStyle(
                                  fontSize: mediaquery_width * 0.05,
                                  fontWeight: FontWeight.bold,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8.0), // Rounded corners
                                ),
                              ),
                              child: Text('Register'), // Moved 'child' to the end
                            ),
                          ),
                          delay: 4000,
                        ),
                        // SizedBox(
                        //   height: mediaquery_height_normal * 0.1,
                        // ),
                        DelayedAnimation(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AuthEmail(),
                                ),
                              );
                            },
                            child: Text(
                              "Login".toUpperCase(),
                              style: TextStyle(
                                  fontSize: mediaquery_width * 0.05,
                                  fontWeight: FontWeight.bold,
                                  color: color),
                            ),
                          ),
                          delay: 5000,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  // Widget get _animatedButtonUI => Container(
  //       height: 60,
  //       width: 270,
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(100.0),
  //         color: Colors.white,
  //       ),
  //       child: GestureDetector(
  //         onTap: () {
  //           Navigator.of(context).push(
  //             MaterialPageRoute(
  //               builder: (context) => const RegisterFaceView(),
  //             ),
  //           );
  //         },
  //         child: Center(
  //           child: Text(
  //             'Register',
  //             style: TextStyle(
  //               fontSize: 20.0,
  //               fontWeight: FontWeight.bold,
  //               color: Color(0xFF8185E2),
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
}
