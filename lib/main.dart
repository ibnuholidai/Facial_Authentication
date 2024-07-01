import 'package:face_camera/face_camera.dart';
import 'package:facelogin/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:facelogin/home/screens/tabs/widgets/splash_screen.dart';
import 'firebase_options.dart';
import 'package:path_provider/path_provider.dart';

import 'home/blocs/bloc_exports.dart';
import 'home/services/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FaceCamera.initialize(); //Add this
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: await getApplicationDocumentsDirectory());
  runApp(MyApp(
    appRouter: AppRouter(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.appRouter}) : super(key: key);
  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => TasksBloc()),
        BlocProvider(create: (context) => SwitchBloc()),
      ],
      child: BlocBuilder<SwitchBloc, SwitchState>(builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Face Authentication App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch(accentColor: accentColor),
            inputDecorationTheme: InputDecorationTheme(
              contentPadding: const EdgeInsets.all(20),
              filled: true,
              fillColor: primaryWhite,
              hintStyle: TextStyle(
                color: primaryBlack.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
              errorStyle: const TextStyle(
                letterSpacing: 0.8,
                color: Colors.redAccent,
                fontWeight: FontWeight.w500,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          home: const SplashScreen(),
          onGenerateRoute: appRouter.onGenerateRoute,
        );
        
      }),
    );
  }
}
