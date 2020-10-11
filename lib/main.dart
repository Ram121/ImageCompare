import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_compare/dataProvider.dart';
import 'package:image_compare/imageCaptureScreen.dart';
import 'package:image_compare/masterImageCapture.dart';

List<CameraDescription> cameras;
bool isMasterImagePresent = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(CamApp());
}

class CamApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    checkMasterPresent();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark));
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
          appBarTheme: AppBarTheme(brightness: Brightness.dark),
          primaryColor: Colors.blue,
          scaffoldBackgroundColor: Colors.blue,
          colorScheme: ColorScheme.light(primary: Colors.blue),
          accentColor: Colors.blue),
      title: 'CamP',
      home: isMasterImagePresent ? MasterImageCaptureScreen(cameras: cameras) : ImageCaptureScreen(cameras: cameras),
    );
  }

  checkMasterPresent() async {
    isMasterImagePresent = await DataProvider().checkMasterImagePresent();
  }
}
