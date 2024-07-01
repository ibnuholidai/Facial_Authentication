import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:face_camera/face_camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:facelogin/common/utils/extensions/size_extension.dart';
import 'package:facelogin/constants/theme.dart';

class CameraView extends StatefulWidget {
  const CameraView({
    Key? key,
    required this.onImage,
    required this.onInputImage,
  }) : super(key: key);

  final Function(Uint8List image) onImage;
  final Function(InputImage inputImage) onInputImage;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  File? _image;
  // ignore: unused_field
  ImagePicker? _imagePicker;

  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    final double mediaquery_height_normal = MediaQuery.of(context).size.height;
    final double mediaquery_width = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 0.06.sh),
        _image != null
            ? Container(
                alignment: Alignment.center,
                width: mediaquery_width,
                height: 0.3.sh,
                // ignore: sort_child_properties_last
                child: Container(
                  alignment: Alignment.center,
                  width: 0.3.sh,
                  height: 0.3.sh,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xffD9D9D9),
                    image: DecorationImage(
                      filterQuality: FilterQuality.high,
                      image: FileImage(_image!),
                      isAntiAlias: true,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xffD9D9D9),
                  // image: DecorationImage(
                  //   filterQuality: FilterQuality.high,
                  //   image: FileImage(_image!),
                  //   isAntiAlias: true,
                  //   fit: BoxFit.fitWidth,
                  // ),
                ),
              )
            : CircleAvatar(
                radius: 0.15.sh,
                backgroundColor: const Color(0xffD9D9D9),
                child: Icon(
                  Icons.camera_alt,
                  size: 0.09.sh,
                  color: const Color(0xff2E2E2E),
                ),
              ),
        SizedBox(
          height: 0.10.sh,
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => cameraa(
                  onCaptureComplete: (File capturedImage) {
                    setState(() {
                      _image = capturedImage;
                    });

                    Uint8List imageBytes = capturedImage.readAsBytesSync();
                    widget.onImage(imageBytes);

                    InputImage inputImage =
                        InputImage.fromFilePath(capturedImage.path);
                    widget.onInputImage(inputImage);
                  },
                ),
              ),
            );
          },
          iconSize: 0.09.sh,
          icon: Icon(Icons.camera),
        ),
        Text(
          _image != null
              ? "Klik untuk mengambil gambar ulang"
              : "Klik untuk mengambil gambar",
          style: TextStyle(
            fontSize: 14,
            color: primaryWhite.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

class cameraa extends StatefulWidget {
  final Function(File capturedImage) onCaptureComplete;

  const cameraa({
    Key? key,
    required this.onCaptureComplete,
  }) : super(key: key);

  @override
  State<cameraa> createState() => _CameraaState();
}

class _CameraaState extends State<cameraa> {
  // ignore: unused_field
  File? _capturedImage;
  bool _canCapture =
      false; // Variabel untuk menentukan kelayakan pengambilan gambar

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Kamera'),
      ),
      body: Builder(builder: (context) {
        return SmartFaceCamera(
          performanceMode: FaceDetectorMode.accurate,
          autoCapture: false,
          enableAudio: false,
          imageResolution: ImageResolution.high,
          defaultCameraLens: CameraLens.front,
          onCapture: (File? filecamera) {
            if (_canCapture) {
              // Hanya mengizinkan pengambilan gambar jika wajah terdeteksi dengan benar
              setState(() => _capturedImage = filecamera);
              widget.onCaptureComplete(filecamera!);
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      'Tolong posisikan wajah Anda dengan benar sebelum mengambil gambar.')));
            }
          },
          onFaceDetected: (Face? face) {
            if (face != null) {
              setState(() => _canCapture = true);
            } else {
              setState(() => _canCapture = false);
            }
          },
          messageBuilder: (context, face) {
            if (face == null) {
              return _message('Tolong arahkan wajah ke kamera');
            }
            if (!face.wellPositioned) {
              return _message('Wajah tidak terdeteksi');
            }
            return const SizedBox.shrink();
          },
        );
      }),
    );
  }

  Widget _message(String msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 15),
      child: Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          height: 1.5,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
