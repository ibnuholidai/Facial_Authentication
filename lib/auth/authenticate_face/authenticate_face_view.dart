import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:facelogin/auth/authenticate_face/pasword_dialog.dart';
import 'package:facelogin/auth/authenticate_face/scanning_animation/animated_view.dart';
import 'package:facelogin/common/utils/custom_snackbar.dart';
import 'package:facelogin/common/utils/extensions/size_extension.dart';
import 'package:facelogin/common/utils/extract_face_feature.dart';
import 'package:facelogin/common/views/camera_view.dart';
import 'package:facelogin/common/views/custom_button.dart';
import 'package:facelogin/constants/theme.dart';
import 'package:facelogin/home/Dasboard.dart';
import 'package:facelogin/model/user_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_face_api/face_api.dart' as regula;
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class AuthenticateFaceView extends StatefulWidget {
  static const id = 'login_screen';
  final String userEmail; // Tambahkan properti userEmail
  const AuthenticateFaceView({Key? key, required this.userEmail})
      : super(key: key);

  @override
  State<AuthenticateFaceView> createState() => _AuthenticateFaceViewState();
}

class _AuthenticateFaceViewState extends State<AuthenticateFaceView> {
  late String email2 = widget.userEmail.toString();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableTracking: true,
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  FaceFeatures? _faceFeatures;
  var image1 = regula.MatchFacesImage();
  var image2 = regula.MatchFacesImage();

  String _similarity = "";
  bool _canAuthenticate = false;
  List<dynamic> users = [];
  bool userExists = false;
  UserModel? loggingUser;
  bool isMatching = false;
  int trialNumber = 1;
  String? _password;

  Future<String?> getPassword(String email) async {
    // Referensi ke koleksi dan dokumen berdasarkan email dan .data
    var documentRef = FirebaseFirestore.instance
        .collection(email.trim().toString()) // Koleksi berdasarkan email
        .doc('.data'); // Dokumen bernama .data
    try {
      // Mendapatkan dokumen dari Firestore
      var docSnapshot = await documentRef.get();
      if (docSnapshot.exists) {
        // Memeriksa apakah dokumen ada
        var data = docSnapshot.data(); // Mendapatkan data dari dokumen
        var password = data?['password']; // Mengambil field 'password'
        return password; // Mengembalikan nilai password
      } else {
        print("Dokumen tidak ditemukan.");
        return null; // Jika dokumen tidak ditemukan
      }
    } catch (e) {
      print("Terjadi kesalahan: $e");
      return null; // Jika terjadi kesalahan selama pengambilan data
    }
  }

  @override
  void dispose() {
    _faceDetector.close();
    // _audioPlayer.dispose();
    super.dispose();
  }

  // get _playScanningAudio => _audioPlayer
  //   ..setReleaseMode(ReleaseMode.loop)
  //   ..play(AssetSource("scan_beep.wav"));

  // get _playFailedAudio => _audioPlayer
  //   ..stop()
  //   ..setReleaseMode(ReleaseMode.release)
  //   ..play(AssetSource("failed.mp3"));

  @override
  Widget build(BuildContext context) {
    final double mediaquery_height_normal = MediaQuery.of(context).size.height;
    final double mediaquery_width = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: appBarColor,
        title: const Text("Autentikasi Wajah"),
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constrains) => Stack(
          children: [
            Container(
              width: mediaquery_width,
              height: mediaquery_height_normal,
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
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 0.85.sh,
                      width: double.infinity,
                      padding:
                          EdgeInsets.fromLTRB(0.05.sw, 0.025.sh, 0.05.sw, 0),
                      decoration: BoxDecoration(
                        color: overlayContainerClr,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(0.03.sh),
                          topRight: Radius.circular(0.03.sh),
                        ),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              CameraView(onImage: (image) {
                                _setImage(image as Uint8List);
                              }, onInputImage: (inputImage) async {
                                setState(() => isMatching = true);
                                _faceFeatures = await extractFaceFeatures(
                                    inputImage as InputImage, _faceDetector);
                                setState(() => isMatching = false);
                              }),
                              if (isMatching)
                                Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 0.064.sh),
                                    child: const AnimatedView(),
                                  ),
                                ),
                            ],
                          ),
                          const Spacer(),
                          if (_canAuthenticate)
                            CustomButton(
                              text: "Autentikasi",
                              onTap: () {
                                setState(() => isMatching = true);
                                _fetchUsersAndMatchFace();
                              },
                            ),
                          SizedBox(height: 0.038.sh),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future _setImage(Uint8List imageToAuthenticate) async {
    image2.bitmap = base64Encode(imageToAuthenticate);
    image2.imageType = regula.ImageType.PRINTED;

    setState(() {
      _canAuthenticate = true;
    });
  }

  double compareFaces(FaceFeatures face1, FaceFeatures face2) {
    double distEar1 = euclideanDistance(face1.rightEar!, face1.leftEar!);
    double distEar2 = euclideanDistance(face2.rightEar!, face2.leftEar!);

    double ratioEar = distEar1 / distEar2;

    double distEye1 = euclideanDistance(face1.rightEye!, face1.leftEye!);
    double distEye2 = euclideanDistance(face2.rightEye!, face2.leftEye!);

    double ratioEye = distEye1 / distEye2;

    double distCheek1 = euclideanDistance(face1.rightCheek!, face1.leftCheek!);
    double distCheek2 = euclideanDistance(face2.rightCheek!, face2.leftCheek!);

    double ratioCheek = distCheek1 / distCheek2;

    double distMouth1 = euclideanDistance(face1.rightMouth!, face1.leftMouth!);
    double distMouth2 = euclideanDistance(face2.rightMouth!, face2.leftMouth!);

    double ratioMouth = distMouth1 / distMouth2;

    double distNoseToMouth1 =
        euclideanDistance(face1.noseBase!, face1.bottomMouth!);
    double distNoseToMouth2 =
        euclideanDistance(face2.noseBase!, face2.bottomMouth!);

    double ratioNoseToMouth = distNoseToMouth1 / distNoseToMouth2;

    double ratio =
        (ratioEye + ratioEar + ratioCheek + ratioMouth + ratioNoseToMouth) / 5;
    log(ratio.toString(), name: "Rasio");

    return ratio;
  }

  double euclideanDistance(Points p1, Points p2) {
    final sqr =
        math.sqrt(math.pow((p1.x! - p2.x!), 2) + math.pow((p1.y! - p2.y!), 2));
    return sqr;
  }

  _fetchUsersAndMatchFace() {
    FirebaseFirestore.instance
        .collection(widget.userEmail)
        .where("email", isEqualTo: widget.userEmail)
        .get()
        .catchError((e) {
      log("Error Mengambil Pengguna: $e");
      setState(() => isMatching = false);
      CustomSnackBar.errorSnackBar("Terjadi kesalahan. Silakan coba lagi.");
    }).then((snap) {
      if (snap.docs.isNotEmpty) {
        users.clear();
        log(snap.docs.length.toString(), name: "Total Pengguna Terdaftar");
        for (var doc in snap.docs) {
          UserModel user = UserModel.fromJson(doc.data());
          double similarity = compareFaces(_faceFeatures!, user.faceFeatures!);
          if (similarity >= 0.8 && similarity <= 1.5) {
            users.add([user, similarity]);
          }
        }
        log(users.length.toString(), name: "Pengguna yang Difilter");
        setState(() {
          users.sort((a, b) => (((a.last as double) - 1).abs())
              .compareTo(((b.last as double) - 1).abs()));
        });

        _matchFaces();
      } else {
        _showFailureDialog(
          title: "wajah Tidak Ditemukan",
          description: "coba lagi",
        );
      }
    });
  }

  _matchFaces() async {
    bool faceMatched = false;
    for (List user in users) {
      UserModel currentUser = user.first;
      image1.bitmap = currentUser.image;
      image1.imageType = regula.ImageType.PRINTED;

      var request = regula.MatchFacesRequest();
      request.images = [image1, image2];
      dynamic value = await regula.FaceSDK.matchFaces(jsonEncode(request));

      var response = regula.MatchFacesResponse.fromJson(json.decode(value));
      dynamic str = await regula.FaceSDK.matchFacesSimilarityThresholdSplit(
          jsonEncode(response!.results), 0.75);
      var split =
          regula.MatchFacesSimilarityThresholdSplit.fromJson(json.decode(str));
      setState(() {
        _similarity = split!.matchedFaces.isNotEmpty
            ? (split.matchedFaces[0]!.similarity! * 100).toStringAsFixed(2)
            : "error";
        log("similarity: $_similarity");

        if (_similarity != "error" && double.parse(_similarity) > 90.00) {
          faceMatched = true;
          loggingUser = currentUser;
        } else {
          faceMatched = false;
        }
      });
      if (faceMatched) {
        // _audioPlayer
        //   ..stop()
        //   ..setReleaseMode(ReleaseMode.release)
        //   ..play(AssetSource("success.mp3"));

        setState(() {
          trialNumber = 1;
          isMatching = false;
        });

        if (mounted) {
          Future<void> _fetchPassword() async {
            try {
              var password = await getPassword(
                  widget.userEmail); // Mengambil password dari Firestore
              if (mounted) {
                setState(() {
                  _password = password; // Simpan password dalam state
                });
              }
              _auth
                  .signInWithEmailAndPassword(
                      email: widget.userEmail, password: _password.toString())
                  .then((value) {
                GetStorage().write('token', value.user!.uid);
                GetStorage().write('email', value.user!.email);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Dashboard(userEmail: email2),
                  ),
                );
              }).onError((error, stackTrace) {
                var snackBar = SnackBar(
                  duration: const Duration(milliseconds: 5000),
                  content: Text(
                    'An Error occurred: $error',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              });
            } catch (e) {
              if (mounted) {
                _showFailureDialog(
                  title: "Terjadi Kesalahan",
                  description: "Gagal mengambil password: $e",
                );
              }
            }
          }

          _fetchPassword();
        }
      }
    }
    if (!faceMatched) {
      setState(() {
        trialNumber = 1;
        isMatching = false;
      });
      // _audioPlayer..stop();
      showDialog(
        context: context,
        builder: (context) {
          return PasswordDialogTab(email: widget.userEmail);
        },
      );
    }
  }

  _fetchUserByName(String orgID) {
    FirebaseFirestore.instance
        .collection(widget.userEmail)
        .where("organizationId", isEqualTo: orgID)
        .get()
        .catchError((e) {
      log("Error Mengambil Pengguna: $e");
      setState(() => isMatching = false);
      CustomSnackBar.errorSnackBar("Terjadi kesalahan. Silakan coba lagi.");
    }).then((snap) {
      if (snap.docs.isNotEmpty) {
        users.clear();

        for (var doc in snap.docs) {
          setState(() {
            users.add([UserModel.fromJson(doc.data()), 1]);
          });
        }
        _matchFaces();
      } else {
        setState(() => trialNumber = 1);
        _showFailureDialog(
          title: "Pengguna Tidak Ditemukan",
          description:
              "Pengguna belum terdaftar. Daftarkan terlebih dahulu untuk melakukan autentikasi.",
        );
      }
    });
  }

  _showFailureDialog({
    required String title,
    required String description,
  }) {
    setState(() => isMatching = false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Ok",
                style: TextStyle(
                  color: accentColor,
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
