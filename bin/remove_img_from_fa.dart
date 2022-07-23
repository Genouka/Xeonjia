import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart';

// Remove 'imageData' property from .fa files (in assets/images/metadata/raw)
// Use this command to run the script: flutter pub run bin/remove_img_from_fa.dart
void main() {
  Directory('assets/images/metadata/raw').listSync().forEach((fsEntity) {
    if (fsEntity is File && extension(fsEntity.path) == '.fa') {
      Map<String, dynamic> map = jsonDecode(
          utf8.decode(GZipDecoder().decodeBytes(fsEntity.readAsBytesSync())))
        ..remove('imageData');
      File('assets/images/metadata/${basenameWithoutExtension(fsEntity.path)}.xfa')
          .writeAsBytes(GZipEncoder().encode(utf8.encode(jsonEncode(map)))!);
    }
  });
  // ignore: avoid_print
  print('.xfa files successfully updated!');
}
