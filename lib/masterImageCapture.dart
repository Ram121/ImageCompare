import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'dataProvider.dart';

class MasterImageCaptureScreen extends StatefulWidget {
  final String qrInfo;
  final List<CameraDescription> cameras;
  MasterImageCaptureScreen({this.qrInfo, this.cameras});
  @override
  _MasterImageCaptureScreenState createState() => _MasterImageCaptureScreenState();
}

class _MasterImageCaptureScreenState extends State<MasterImageCaptureScreen> {
  CameraController controller;
  String imagePath, dirPath, filePath;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  VideoPlayerController videoController;
  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.cameras[0], ResolutionPreset.ultraHigh);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Take photo of MASTER'),
      ),
      body: Column(
        children: [
          AspectRatio(aspectRatio: controller.value.aspectRatio, child: CameraPreview(controller)),
          IconButton(
              icon: Icon(Icons.camera_alt),
              onPressed: onTakePictureButtonPressed,
              color: Colors.red,
              iconSize: 64),
        ],
      ),
    );
  }

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void logError(String code, String message) => print('Error: $code\nError Message: $message');

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath1) async {
      if (mounted) {
        setState(() {
          imagePath = filePath;
          videoController?.dispose();
          videoController = null;
        });
        if (filePath != null) showInSnackBar('Picture saved to $filePath');
      }
    });
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    dirPath = await DataProvider().getPictureDirectory();
    await Directory(dirPath).create(recursive: true);
    if (File('$dirPath/masterImage.jpg').exists() != null) {
      File('$dirPath/masterImage.jpg')?.delete(recursive: true);
    }
    filePath = '$dirPath/masterImage.jpg';
    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}
