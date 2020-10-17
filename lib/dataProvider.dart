import 'dart:io';
import 'package:diff_image/diff_image.dart';
import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';

Image imageComp, imageMast;
var decodedImageComp, decodedImageMast;
List<int> imageBytesComp, imageBytesMast;
Directory directory;
String dirPath;
var firstImageFromMemory, secondImageFromMemory;

class DataProvider {
  Future<bool> checkMasterImagePresent() async {
    bool isMasterImagePresent = false;
    dirPath = await getPictureDirectory();
    final String filePath = '$dirPath/masterImage.jpg';
    File _masterImage = File(filePath);
    if (await _masterImage.exists()) {
      isMasterImagePresent = true;
    } else {
      isMasterImagePresent = false;
    }
    return isMasterImagePresent;
  }

  getPictureDirectory() async {
    directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/pictures';
  }

  getDirectories() async {
    getPictureDirectory();
    File pickedImageComp = File('$dirPath/componentImage.jpg');
    imageBytesComp = pickedImageComp.readAsBytesSync();
    File pickedImageMast = File('$dirPath/masterImage.jpg');
    imageBytesMast = pickedImageMast.readAsBytesSync();
    firstImageFromMemory = decodeImage(
      File(
        '$dirPath/componentImage.jpg',
      ).readAsBytesSync(),
    );
    secondImageFromMemory = decodeImage(
      File(
        '$dirPath/masterImage.jpg',
      ).readAsBytesSync(),
    );
  }

  calculateDifference() async {
    getDirectories();
    DiffImgResult diff = DiffImage.compareFromMemory(
      firstImageFromMemory,
      secondImageFromMemory,
      asPercentage: true,
    );
    // print('The difference between images is: ${diff.diffValue} percent');
    return diff.diffValue;
  }
}
