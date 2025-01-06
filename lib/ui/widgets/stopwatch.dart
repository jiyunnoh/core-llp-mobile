import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../app/app.locator.dart';
import '../../generated/locale_keys.g.dart';
import '../../services/app_locale_service.dart';
import '../common/ui_helpers.dart';

class StopWatchWidget extends StatefulWidget {
  Duration elapsedTime;
  final Function(Duration elapsed) onStop;
  final Function() onReset;

  /// Override stop watch locale
  final Locale? locale;

  StopWatchWidget(this.elapsedTime,
      {super.key, required this.onStop, required this.onReset, this.locale});

  @override
  State<StopWatchWidget> createState() => _StopWatchWidgetState();
}

class _StopWatchWidgetState extends State<StopWatchWidget> {
  Locale? _locale;
  Locale get locale => _locale ??= context.locale;
  final _localeService = locator<AppLocaleService>();
  final Stopwatch _stopwatch = Stopwatch();
  final NumberFormat _numFormat = NumberFormat('00');
  Timer? _timer;
  bool canStartTimer = true;

  _StopWatchWidgetState();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _locale = widget.locale;
  }

  void _timerResetAlert(context) {
    Alert(
      context: context,
      style: kAlertStyle,
      type: AlertType.warning,
      title: _localeService.tr(locale, LocaleKeys.resetTrialTime),
      desc: _localeService.tr(locale, LocaleKeys.resetConfirmation),
      buttons: [
        DialogButton(
          height: kAlertButtonHeight,
          color: Colors.orange,
          onPressed: () => Navigator.pop(context),
          child: Text(
            _localeService.tr(locale, LocaleKeys.cancel),
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        DialogButton(
          height: kAlertButtonHeight,
          color: Colors.orange,
          onPressed: () {
            Navigator.pop(context);
            setState(() {
              _resetStopwatch();
            });
          },
          child: Text(
            _localeService.tr(locale, LocaleKeys.reset),
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
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
    widget.elapsedTime = _stopwatch.elapsed;
    widget.onStop(_stopwatch.elapsed);
    _cancelTimer();
    canStartTimer = false;
  }

  void _resetStopwatch() {
    _cancelTimer();
    _stopwatch.reset();
    widget.onReset();
    widget.elapsedTime = const Duration();
    canStartTimer = true;
  }

  void _cancelTimer() {
    _timer?.cancel();
  }

  int _getMilliseconds(int milliseconds) {
    double value = (milliseconds % 1000) / 10;
    return value.toInt();
  }

  Widget _getResetButton() {
    return RawMaterialButton(
      onPressed: _stopwatch.isRunning
          ? null
          : () {
              if (widget.elapsedTime != const Duration())
                _timerResetAlert(context);
            },
      elevation: 2.0,
      fillColor: _stopwatch.isRunning ? Colors.grey : Colors.orange,
      padding: const EdgeInsets.all(30.0),
      shape: const CircleBorder(),
      child: Text(_localeService.tr(locale, LocaleKeys.reset)),
    );
  }

  Widget _getStartButton() {
    return RawMaterialButton(
      onPressed: canStartTimer
          ? () {
              setState(() {
                _stopwatch.isRunning ? _stopStopwatch() : _startStopwatch();
              });
            }
          : null,
      elevation: 2.0,
      fillColor: canStartTimer ? Colors.orange : Colors.grey,
      padding: const EdgeInsets.all(30.0),
      shape: const CircleBorder(),
      child: _stopwatch.isRunning
          ? Text(_localeService.tr(locale, LocaleKeys.stop))
          : Text(_localeService.tr(locale, LocaleKeys.start)),
    );
  }

  Widget _getTimerDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
            width: timerWidth,
            child: Center(
                child: Text(_numFormat.format(_stopwatch.elapsed.inMinutes),
                    style: timerTextStyle))),
        Text(':', style: timerTextStyle),
        SizedBox(
            width: timerWidth,
            child: Center(
                child: Text(
                    _numFormat.format((_stopwatch.elapsed.inSeconds % 60)),
                    style: timerTextStyle))),
        Text('.', style: timerTextStyle),
        SizedBox(
            width: timerWidth,
            child: Center(
                child: Text(
                    _numFormat.format(
                        _getMilliseconds(_stopwatch.elapsed.inMilliseconds)),
                    style: timerTextStyle)))
      ],
    );
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _cancelTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // var size = MediaQuery.of(context).size;
    // final bool useMobileLayout = size.shortestSide < 600;
    return Device.get().isPhone
        ? Column(
            children: [
              _getTimerDisplay(),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [_getResetButton(), _getStartButton()]),
            ],
          )
        : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _getResetButton(),
            _getTimerDisplay(),
            _getStartButton()
          ]);
  }
}
