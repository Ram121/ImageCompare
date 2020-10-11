import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:diff_image/diff_image.dart' hide Image;
import 'package:image/image.dart' as compImage;
import 'package:path_provider/path_provider.dart';

Image imageComp, imageMast;
var decodedImageComp, decodedImageMast;
List<int> imageBytesComp, imageBytesMast;
Directory directory;
String dirPath;

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
    imageComp = Image.file(File('$dirPath/componentImage.jpg'));
    imageMast = Image.file(File('$dirPath/masterImage.jpg'));
    decodedImageComp = await decodeImageFromList(pickedImageComp.readAsBytesSync());
    decodedImageMast = await decodeImageFromList(pickedImageMast.readAsBytesSync());
  }

  calculateDifference() async {
    await getDirectories();
    var firstImageFromMemoryComp =
        compImage.Image.fromBytes(decodedImageComp.width.toInt(), decodedImageComp.height.toInt(), imageBytesComp);
    var secondImageFromMemoryMast =
        compImage.Image.fromBytes(decodedImageMast.width.toInt(), decodedImageMast.height.toInt(), imageBytesMast);
    DiffImgResult diff = DiffImage.compareFromMemory(
      firstImageFromMemoryComp,
      secondImageFromMemoryMast,
      asPercentage: true,
    );
    print('The difference between images is: ${diff.diffValue} percent');
  }
}
