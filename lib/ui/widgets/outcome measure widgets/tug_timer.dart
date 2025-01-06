import 'dart:async';

import 'package:biot/ui/common/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../generated/locale_keys.g.dart';
import '../../../model/outcome_measures/outcome_measure.dart';
import '../../../model/question.dart';
import '../../common/ui_helpers.dart';

class TugTimer extends StatefulWidget {
  final OutcomeMeasure outcomeMeasure;

  const TugTimer({super.key, required this.outcomeMeasure});

  @override
  State<TugTimer> createState() => _TugTimerState();
}

class _TugTimerState extends State<TugTimer> {
  final Stopwatch _stopwatch = Stopwatch();
  final NumberFormat _numFormat = NumberFormat('00');
  Timer? _timer;
  final TextEditingController _controller = TextEditingController();
  late Question elapsedTimeQuestion;
  late Question assistiveDeviceUsedQuestion;
  bool canStartTimer = true;
  // late Duration elapsedTime;

  @override
  void initState() {
    super.initState();
    elapsedTimeQuestion =
        widget.outcomeMeasure.questionCollection.getQuestionById("tug_1")!;
    assistiveDeviceUsedQuestion =
        widget.outcomeMeasure.questionCollection.getQuestionById("tug_2")!;
    if (assistiveDeviceUsedQuestion.value != null) {
      _controller.text = assistiveDeviceUsedQuestion.value.toString();
    }
    if (elapsedTimeQuestion.value != null) {
      canStartTimer = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    elapsedTimeQuestion =
        widget.outcomeMeasure.questionCollection.getQuestionById("tug_1")!;
    assistiveDeviceUsedQuestion =
        widget.outcomeMeasure.questionCollection.getQuestionById("tug_2")!;
  }

  void _timerResetAlert(context) {
    Alert(
      context: context,
      style: kAlertStyle,
      title: LocaleKeys.resetTrialTime.tr(),
      desc: LocaleKeys.resetConfirmation.tr(),
      buttons: [
        DialogButton(
          height: kAlertButtonHeight,
          radius: BorderRadius.circular(kAlertButtonHeight/2),
          color: Colors.red,
          onPressed: () {
            Navigator.pop(context);
            setState(() {
              _resetStopwatch();
            });
          },
          child: const Text(
            LocaleKeys.reset,
            style: TextStyle(fontSize: 18, color: Colors.white),
            textAlign: TextAlign.center,
          ).tr(),
        ),
        DialogButton(
          height: kAlertButtonHeight,
          color: kcBackgroundColor,
          radius: BorderRadius.circular(kAlertButtonHeight/2),
          onPressed: () => Navigator.pop(context),
          child: const Text(
            LocaleKeys.cancel,
            style: TextStyle(fontSize: 18, color: Colors.white),
          ).tr(),
        ),
      ],
    ).show();
  }

  void _startStopwatch() {
    _stopwatch.start();
    const oneMSec = Duration(milliseconds: 10);
    _timer = Timer.periodic(oneMSec, (timer) {
      setState(() {});
    });
  }

  void _stopStopwatch() {
    _stopwatch.stop();
    elapsedTimeQuestion.value = _stopwatch.elapsed;
    _cancelTimer();
    canStartTimer = false;
  }

  void _resetStopwatch() {
    _cancelTimer();
    _stopwatch.reset();
    elapsedTimeQuestion.value = null;
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
                      _numFormat.format(elapsedTimeQuestion.value == null
                          ? _stopwatch.elapsed.inMinutes
                          : (elapsedTimeQuestion.value as Duration).inMinutes),
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
                      _numFormat.format(elapsedTimeQuestion.value == null
                          ? (_stopwatch.elapsed.inSeconds % 60)
                          : (elapsedTimeQuestion.value as Duration).inSeconds %
                              60),
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
                      _numFormat.format(_getMilliseconds(
                          elapsedTimeQuestion.value == null
                              ? _stopwatch.elapsed.inMilliseconds
                              : (elapsedTimeQuestion.value as Duration)
                                  .inMilliseconds)),
                      style: timerTextStyle,
                    )))
              ],
            ),
            //Center(child: Text('${_numFormat.format(_stopwatch.elapsed.inMinutes)}:${_numFormat.format((_stopwatch.elapsed.inSeconds%60))}.${_numFormat.format((_stopwatch.elapsed.inMilliseconds%100))}', style: TextStyle(fontSize: 80),)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              RawMaterialButton(
                onPressed: _stopwatch.isRunning
                    ? null
                    : () {
                        if (elapsedTimeQuestion.value != null) {
                          _timerResetAlert(context);
                        }
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
