part of '../../camera.dart';

class CameraRepository {
  Future<File?> generateFileFromBytes(String bytes) async {
    LoggerService.logTrace('CameraRepository -> generateFileFromBytes()');
    try {
      final decodedBytes = base64Decode(bytes);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/reconstructed-${bytes.split('').fold(0, (prev, current) => prev + current.codeUnitAt(0))}-${DateTime.now().millisecondsSinceEpoch}.jpg');
      return await file.writeAsBytes(decodedBytes);
    } on Exception catch (e) {
      LoggerService.logError('Exception while converting bytes', exception: e);
    }

    return null;
  }

  Future<XFile> compressXFileToMaxSize(XFile xFile, double maxSizeMB, int maxHeightPx, int maxWidthPx) async {
    LoggerService.logTrace('CameraRepository -> compressXFileToMaxSize(maxSize: ${maxSizeMB.toStringAsFixed(2)} MB, maxHeight: ${maxHeightPx}px, maxWidth: ${maxWidthPx}px)');
    final file = File(xFile.path);
    final originalImage = img.decodeImage(file.readAsBytesSync())!;
    File compressedFile = file;

    ui.Image? temporalImage;
    ui.decodeImageFromList(file.readAsBytesSync(), (image) {
      temporalImage = image;
      LoggerService.logInfo('CameraRepository -> compressXFileToMaxSize() before compressing -> size: ${(file.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB, height: ${image.height}px, width: ${image.width}px, quality: 100');
    });

    while (temporalImage == null) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    if (temporalImage!.height > maxHeightPx || temporalImage!.width > maxWidthPx) {
      /// Calculate scale factor
      final heightRatio = maxHeightPx / originalImage.height;
      final widthRatio = maxWidthPx / originalImage.width;
      final scale = widthRatio < heightRatio ? widthRatio : heightRatio;

      final targetHeight = (originalImage.height * scale).round();
      final targetWidth = (originalImage.width * scale).round();
      final newPath = file.path.replaceAll('.jpg', '_resized.jpg');

      /// Compressing constraints
      final resizedFile = await FlutterImageCompress.compressAndGetFile(
        file.path,
        newPath,
        minWidth: targetWidth,
        minHeight: targetHeight,
        quality: 100,
        format: CompressFormat.jpeg,
      );

      compressedFile = resizedFile?.path != null ? File(resizedFile!.path) : compressedFile;
    }

    final maxBytes = maxSizeMB * 1024 * 1024;
    int quality = 90; /// Start high, reduce gradually
    bool isCompressed = false;

    /// Compressing size
    while (compressedFile.lengthSync() > maxBytes && quality > 5) {
      final newPath = file.path.replaceAll('.jpg', '_min.jpg');
      final result = await FlutterImageCompress.compressAndGetFile(
        compressedFile.path,
        newPath,
        quality: quality,
        format: CompressFormat.jpeg,
      );

      if (result == null) break;
      compressedFile = File(result.path);
      quality -= 10; /// Reduce compression quality gradually
      isCompressed = true;
    }

    ui.decodeImageFromList(compressedFile.readAsBytesSync(), (image) {
      LoggerService.logInfo('CameraRepository -> compressXFileToMaxSize() after compressing -> size: ${(compressedFile.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB, height: ${image.height}px, width: ${image.width}px, quality: ${isCompressed ? quality : 100}');
    });

    return XFile(compressedFile.path);
  }
}