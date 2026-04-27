import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as p;

class ImageCompressor {
  /// Force compresses any image into a high-quality but small JPEG.
  /// This ensures PNGs and high-res camera shots are always small.
  static Future<File?> compress(String filePath) async {
    final file = File(filePath);
    final size = await file.length();
    
    // If it's already under 200KB and it's a JPEG, skip extra processing
    if (size < 200 * 1024 && filePath.toLowerCase().endsWith('.jpg')) {
      return file;
    }

    final tempDir = await path_provider.getTemporaryDirectory();
    final targetPath = p.join(tempDir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');

    final result = await FlutterImageCompress.compressAndGetFile(
      filePath,
      targetPath,
      quality: 60,
      minWidth: 1024,
      minHeight: 1024,
      format: CompressFormat.jpeg, // FORCE JPEG for everything
    );

    if (result == null) return null;
    return File(result.path);
  }
}
