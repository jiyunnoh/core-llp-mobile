import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class FileSaverService {
  Future<ShareResult> saveAndShareFile(List<int> bytes, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = directory.path;
    print('$path/$fileName');
    final File file = File('$path/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    final Map<String, String> argument = <String, String>{
      'file_path': '$path/$fileName'
    };
    return Share.shareXFiles([XFile(file.path)]);
    // await ShareExtend.share(file.path, "file");
  }
}
