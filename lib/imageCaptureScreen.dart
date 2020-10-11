import 'dart:io';
import 'package:camera/camera.dart';
import 'package:diff_image/diff_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_player/video_player.dart';
import 'dataProvider.dart';
import 'masterImageCapture.dart';

class ImageCaptureScreen extends StatefulWidget {
  final bool isMasterImagePresent;
  final String qrInfo;
  final List<CameraDescription> cameras;
  ImageCaptureScreen({this.qrInfo, this.cameras, this.isMasterImagePresent});
  @override
  _ImageCaptureScreenState createState() => _ImageCaptureScreenState();
}

class _ImageCaptureScreenState extends State<ImageCaptureScreen> {
  CameraController controller;
  String imagePath, dirPath;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  VideoPlayerController videoController;
  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.cameras[0], ResolutionPreset.low);
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
      appBar: _appBar(),
      body: Column(
        children: [
          AspectRatio(aspectRatio: controller.value.aspectRatio, child: CameraPreview(controller)),
          IconButton(
              icon: Icon(Icons.camera_alt), onPressed: onTakePictureButtonPressed, color: Colors.white, iconSize: 64),
          IconButton(
              icon: Icon(Icons.arrow_right_alt),
              iconSize: 64,
              color: Colors.white,
              onPressed: () async {
                await DataProvider().calculateDifference();
              })
        ],
      ),
    );
  }

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void logError(String code, String message) => print('Error: $code\nError Message: $message');

  void onTakePictureButtonPressed() async {
    takePicture().then((String filePath) async {
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
    File('$dirPath/componentImage.jpg')?.delete(recursive: true);
    final String filePath = '$dirPath/componentImage.jpg';
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

  Widget _appBar() {
    return AppBar(
      title: Text('Photo of Component'),
      elevation: 0,
      actions: [
        _threeDotMenu(),
      ],
    );
  }

  Widget _threeDotMenu() {
    return PopupMenuButton(
      onSelected: _choiceAction,
      icon: Icon(
        Icons.more_vert,
        color: Colors.white,
      ),
      itemBuilder: (BuildContext context) {
        return Constants.choices
            .map(
              (String choice) => PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              ),
            )
            .toList();
      },
    );
  }

  void _choiceAction(dynamic choice) {
    switch (choice) {
      case Constants.setMasterImage:
        masterImageCaptureScreen();
        break;
    }
  }

  Future masterImageCaptureScreen() {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MasterImageCaptureScreen(cameras: widget.cameras)),
    );
  }
}

class Constants {
  static const String setMasterImage = 'Set Master Image';

  static const List<String> choices = <String>[setMasterImage];
}
