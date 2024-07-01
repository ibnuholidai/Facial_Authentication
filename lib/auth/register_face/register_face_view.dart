import 'dart:convert';
import 'package:facelogin/common/utils/extract_face_feature.dart';
import 'package:facelogin/common/views/camera_view.dart';
import 'package:facelogin/common/views/custom_button.dart';
import 'package:facelogin/common/utils/extensions/size_extension.dart';
import 'package:facelogin/constants/theme.dart';
import 'package:facelogin/model/user_model.dart';
import 'package:facelogin/auth/register_face/enter_details_view.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class RegisterFaceView extends StatefulWidget {
  const RegisterFaceView({Key? key}) : super(key: key);

  static const id = 'register_screen';

  @override
  State<RegisterFaceView> createState() => _RegisterFaceViewState();
}

class _RegisterFaceViewState extends State<RegisterFaceView> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableTracking: true,
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  FaceFeatures? _faceFeatures;
  String? _image;
  double _detectionProgress = 0.0; // State untuk progress deteksi

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double mediaquery_height_normal = MediaQuery.of(context).size.height;
    // final double mediaquery_width = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: appBarColor,
        title: const Text("Register User"),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: mediaquery_height_normal * 0.9,
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(0.05.sw, 0.025.sh, 0.05.sw, 0.05.sh),
              decoration: BoxDecoration(
                color: overlayContainerClr,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0.03.sh),
                  topRight: Radius.circular(0.03.sh),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CameraView(
                    onImage: (image) {
                      setState(() {
                        _image = base64Encode(image);
                        _detectionProgress = 0.0; // Set progress kembali ke 0%
                      });
                    },
                    onInputImage: (inputImage) async {
                      _detectionProgress = 0.1; // Set initial progress to 10%
                      setState(() {});

                      // Start detecting specific facial features
                      _faceFeatures =
                          await extractFaceFeatures(inputImage, _faceDetector);

                      // Check for eyes
                      if (_faceFeatures?.rightEye != null &&
                          _faceFeatures?.leftEye != null) {
                        _detectionProgress =
                            0.2; // Update progress to 20% after detecting eyes
                        setState(() {});
                      }

                      if (_faceFeatures?.rightEar != null &&
                          _faceFeatures?.leftEar != null) {
                        _detectionProgress =
                            0.3; // Update progress to 30% after detecting ears
                        setState(() {});
                      }

                      if (_faceFeatures?.leftEar != null &&
                          _faceFeatures?.leftEar != null) {
                        _detectionProgress =
                            0.4; // Update progress to 30% after detecting ears
                        setState(() {});
                      }

                      // Check for cheeks
                      if (_faceFeatures?.rightCheek != null &&
                          _faceFeatures?.leftCheek != null) {
                        _detectionProgress =
                            0.5; // Update progress to 40% after detecting cheeks
                        setState(() {});
                      }

                      if (_faceFeatures?.leftCheek != null &&
                          _faceFeatures?.leftCheek != null) {
                        _detectionProgress =
                            0.6; // Update progress to 40% after detecting cheeks
                        setState(() {});
                      }

                      // Check for nose
                      if (_faceFeatures?.noseBase != null) {
                        _detectionProgress =
                            0.7; // Update progress to 60% after detecting nose
                        setState(() {});
                      }

                      // Check for mouth
                      if (_faceFeatures?.rightMouth != null &&
                          _faceFeatures?.leftMouth != null) {
                        _detectionProgress =
                            0.8; // Update progress to 80% after detecting mouth
                        setState(() {});
                      }

                      // Check for bottom mouth
                      if (_faceFeatures?.bottomMouth != null) {
                        _detectionProgress =
                            0.9; // Update progress to 90% after detecting bottom mouth
                        setState(() {});
                      }

                      // Finalize detection
                      _detectionProgress =
                          1.0; // Set progress to 100% after all detections are complete
                      setState(() {});
                    },
                  ),
                  LinearProgressIndicator(
                    value: _detectionProgress,
                    backgroundColor: Colors.grey,
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                  const Spacer(),
                  if (_image != null && _detectionProgress == 1.0)
                    CustomButton(
                      text: "Start Registering",
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => EnterDetailsView(
                                    image: _image!,
                                    faceFeatures: _faceFeatures!,
                                    onRegistrationComplete: (bool) {},
                                  )),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
