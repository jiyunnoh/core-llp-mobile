import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import '../app/app.logger.dart';

late File outputFile;

setupLogFileOutput() async {
  initializeDateFormatting();
  Directory dir = await getApplicationDocumentsDirectory();
  var fileName =
      '${dir.path}/log_${DateFormat('MMddyyyy').format(DateTime.now())}.txt';
  outputFile = await File(fileName).exists()
      ? File(fileName)
      : await File(fileName).create();
}

class LoggerService {
  final FileOutput _fileOutput = FileOutput(file: outputFile);

  Logger getLogger(
    String className, {
    bool printCallingFunctionName = true,
    bool printCallstack = false,
    List<String> exludeLogsFromClasses = const [],
    String? showOnlyClass,
  }) {
    return Logger(
        printer: OILogPrinter(
          className,
          printCallingFunctionName: printCallingFunctionName,
          printCallStack: printCallstack,
          showOnlyClass: showOnlyClass,
          exludeLogsFromClasses: exludeLogsFromClasses,
        ),
        output: MultiOutput([
          if (!kReleaseMode) ConsoleOutput(),
          _fileOutput,
        ]),
        filter: ProductionFilter());
  }
}

class FileOutput extends LogOutput {
  final File file;
  final bool overrideExisting;
  final Encoding encoding;
  late IOSink _sink;

  FileOutput({
    required this.file,
    this.overrideExisting = false,
    this.encoding = utf8,
  });

  @override
  void init() {
    _sink = file.openWrite(
      mode: overrideExisting ? FileMode.writeOnly : FileMode.writeOnlyAppend,
      encoding: encoding,
    );
  }

  @override
  void output(OutputEvent event) {
    _sink.writeAll(event.lines, '\n');
  }

  void Function(String)? printToZone;

  @override
  void destroy() async {
    await _sink.flush();
    await _sink.close();
  }
}

class OILogPrinter extends SimpleLogPrinter {
  DateTime? _startTime;

  OILogPrinter(super.className,
      {super.printCallingFunctionName,
      super.printCallStack,
      super.exludeLogsFromClasses,
      super.showOnlyClass});

  @override
  List<String> log(LogEvent event) {
    _startTime ??= DateTime.now();
    var time = getTime();
    List<String> result = super.log(event);
    result[0] = '$time: ${result.first} \n';
    return result;
  }

  String getTime() {
    String threeDigits(int n) {
      if (n >= 100) return '$n';
      if (n >= 10) return '0$n';
      return '00$n';
    }

    String twoDigits(int n) {
      if (n >= 10) return '$n';
      return '0$n';
    }

    var now = DateTime.now();
    var dateFormatter = DateFormat.yMd();
    var h = twoDigits(now.hour);
    var min = twoDigits(now.minute);
    var sec = twoDigits(now.second);
    var ms = threeDigits(now.millisecond);
    return '${dateFormatter.format(now)} $h:$min:$sec.$ms';
  }
}
