import 'dart:async';
import 'dart:math';

import 'package:biot/ui/common/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../generated/locale_keys.g.dart';
import '../../../model/outcome_measures/outcome_measure.dart';
import '../../../model/question.dart';
import '../../common/ui_helpers.dart';

class TminwtView extends StatefulWidget {
  final OutcomeMeasure outcomeMeasure;

  const TminwtView({super.key, required this.outcomeMeasure});

  @override
  State<TminwtView> createState() => _TminwtViewState();
}

class _TminwtViewState extends State<TminwtView> {
  final Stopwatch _stopwatch = Stopwatch();
  final NumberFormat _numFormat = NumberFormat('00');
  Timer? _timer;
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  late Question distanceTraveledQuestion;
  late Question assistiveDeviceUsedQuestion;
  late Duration duration;
  bool canStartTimer = true;

  @override
  void initState() {
    super.initState();
    distanceTraveledQuestion =
        widget.outcomeMeasure.questionCollection.getQuestionById("tminwt_1")!;
    assistiveDeviceUsedQuestion =
        widget.outcomeMeasure.questionCollection.getQuestionById("tminwt_2")!;
    if (distanceTraveledQuestion.value != null) {
      _distanceController.text = distanceTraveledQuestion.value.toString();
    }
    if (assistiveDeviceUsedQuestion.value != null) {
      _controller.text = assistiveDeviceUsedQuestion.value.toString();
    }
    _setDuration();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    distanceTraveledQuestion =
        widget.outcomeMeasure.questionCollection.getQuestionById("tminwt_1")!;
    assistiveDeviceUsedQuestion =
        widget.outcomeMeasure.questionCollection.getQuestionById("tminwt_2")!;
  }

  void _setDuration() {
    duration = const Duration(minutes: 2);
  }

  void _startStopwatch() {
    _stopwatch.start();
    const oneMSec = Duration(milliseconds: 10);
    _timer = Timer.periodic(oneMSec, (timer) {
      setState(() {});
      if (duration.inMilliseconds - _stopwatch.elapsedMilliseconds <= 0) {
        _stopStopwatch();
      }
    });
  }

  void _stopStopwatch() {
    _stopwatch.stop();
    _cancelTimer();
    canStartTimer = false;
  }

  void _resetStopwatch() {
    _cancelTimer();
    _stopwatch.reset();
    _setDuration();
    canStartTimer = true;
  }

  void _cancelTimer() {
    _timer?.cancel();
  }

  int _getMilliseconds(int milliseconds) {
    double value = (milliseconds % 1000) / 10;
    return value.toInt();
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: [
          Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      assistiveDeviceUsedQuestion.text,
                      style: contentTextStyle,
                    )),
              ),
              TextField(
                controller: _controller,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp("[ 0-9a-zA-Z\\-_./();\\|]"))
                ],
                onChanged: (value) {
                  // Setting assistive device used value
                  print(_controller.text);
                  assistiveDeviceUsedQuestion.value = _controller.text;
                },
                textAlignVertical: TextAlignVertical.center,
                maxLength: 36,
                style: contentTextStyle,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  suffixIcon: ClipOval(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                          onTap: () {
                            _controller.clear();
                            assistiveDeviceUsedQuestion.value = null;
                          },
                          child: const Icon(Icons.close)),
                    ),
                  ),
                  hintText: LocaleKeys.assistDeviceHint.tr(),
                  alignLabelWithHint: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      distanceTraveledQuestion.text,
                      style: contentTextStyle,
                    )),
              ),
              TextField(
                controller: _distanceController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^(\d+)?\.?\d{0,2}'))
                ],
                onChanged: (value) {
                  // Setting assistive device used value
                  print(_distanceController.text);
                  distanceTraveledQuestion.value =
                      double.parse(_distanceController.text);
                },
                textAlignVertical: TextAlignVertical.center,
                style: contentTextStyle,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  suffixIcon: ClipOval(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                          onTap: () {
                            _distanceController.clear();
                            distanceTraveledQuestion.value = null;
                          },
                          child: const Icon(Icons.close)),
                    ),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
          Container(
            height: size.longestSide * 0.4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: timerWidth,
                    child: Center(
                        child: Text(
                      _numFormat
                          .format((duration - _stopwatch.elapsed).inMinutes),
                      style: timerTextStyle,
                    ))),
                Text(
                  ':',
                  style: timerTextStyle,
                ),
                SizedBox(
                    width: timerWidth,
                    child: Center(
                        child: Text(
                      _numFormat.format(
                          ((duration - _stopwatch.elapsed).inSeconds % 60)),
                      style: timerTextStyle,
                    ))),
                Text(
                  '.',
                  style: timerTextStyle,
                ),
                SizedBox(
                    width: timerWidth,
                    child: Center(
                        child: Text(
                      _numFormat.format(_getMilliseconds(max(
                          0, (duration - _stopwatch.elapsed).inMilliseconds))),
                      style: timerTextStyle,
                    )))
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              RawMaterialButton(
                onPressed: _stopwatch.isRunning
                    ? null
                    : () {
                        setState(() {
                          _resetStopwatch();
                        });
                      },
                elevation: 2.0,
                fillColor: _stopwatch.isRunning ? Colors.grey : kcBackgroundColor,
                padding: const EdgeInsets.all(30.0),
                shape: const CircleBorder(),
                child: const Text(LocaleKeys.reset, style: TextStyle(color: Colors.white),).tr(),
              ),
              RawMaterialButton(
                onPressed: canStartTimer
                    ? () {
                        setState(() {
                          _stopwatch.isRunning
                              ? _stopStopwatch()
                              : _startStopwatch();
                        });
                      }
                    : null,
                elevation: 2.0,
                fillColor: canStartTimer ? kcBackgroundColor : Colors.grey,
                padding: const EdgeInsets.all(30.0),
                shape: const CircleBorder(),
                child: _stopwatch.isRunning
                    ? const Text(LocaleKeys.stop, style: TextStyle(color: Colors.white),).tr()
                    : const Text(LocaleKeys.start, style: TextStyle(color: Colors.white),).tr(),
              )
            ],
          )
        ],
      ),
    );
  }
}
