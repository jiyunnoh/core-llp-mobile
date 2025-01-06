import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileService {
  // Find the path to the documents directory.
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    print(directory.path);
    return directory.path;
  }

  // Create a reference to the file's full location.
  Future<File> _localFile(String fileName) async {
    final path = await _localPath;
    String filePathWithExtension = '$path/$fileName';
    if (!(filePathWithExtension.contains('.csv'))) {
      filePathWithExtension = filePathWithExtension + '.csv';
    }
    return File(filePathWithExtension);
  }

  // Write the file
  Future<File> writeFile(String fileBody, String fileName) async {
    final file = await _localFile(fileName);
    return file.writeAsString(fileBody);
  }
}
