import 'package:biot/ui/widgets/response%20widgets/peq_slider_comp.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as Foundation;

import '../../../generated/locale_keys.g.dart';
import '../../../model/question.dart';
import '../../common/ui_helpers.dart';

class VasCheckboxResponse extends StatefulWidget {
  final QuestionWithVasCheckboxResponse question;
  final Function? answerStateChanged;

  VasCheckboxResponse(
      {super.key, required this.question, this.answerStateChanged});

  @override
  State<VasCheckboxResponse> createState() => _VasCheckboxResponseState();
}

class _VasCheckboxResponseState extends State<VasCheckboxResponse> {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var orientation = MediaQuery.of(context).orientation;
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            SizedBox(
              width: screenSize.width * 0.1,
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackShape: PeqSliderTrackShape(),
                  trackHeight: 2.0,
                  thumbColor: widget.question.value != null
                      ? Colors.black
                      : Colors.transparent,
                  thumbShape: const PeqSliderThumbShape(),
                  overlayColor: Colors.purple.withAlpha(0),
                ),
                child: Slider(
                  min: 0.0,
                  max: 100.0,
                  value: widget.question.scaleValue,
                  onChanged: (double newValue) {
                    setState(() {
                      widget.question.scaleValue = newValue;
                      if (widget.answerStateChanged != null) {
                        widget.answerStateChanged!();
                      }
                    });
                  },
                ),
              ),
            ),
            SizedBox(
              width: screenSize.width * 0.1,
            ),
          ],
        ),
        const SizedBox(height: 30.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(
              width: orientation == Orientation.portrait
                  ? (screenSize.width * 0.1) * 3.50
                  : (screenSize.width * 0.1) * 2.25,
              child: Text(
                widget.question.min.toUpperCase(),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: orientation == Orientation.portrait
                  ? (screenSize.width * 0.1) * 3.50
                  : (screenSize.width * 0.1) * 2.25,
              child: Text(
                widget.question.max.toUpperCase(),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Center(child: Text('- ${LocaleKeys.orAllCap.tr()} -')),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4.0, 10.0, 20.0, 10.0),
          child: Row(
            children: <Widget>[
              Checkbox(
                  value: widget.question.isChecked,
                  // activeColor: kPEQGreen,
                  // checkColor: kPEQGreen,
                  onChanged: (value) {
                    setState(() {
                      if (value != null) {
                        widget.question.isChecked = value;
                        if (value) {
                          widget.question.value = null;
                        }
                      }
                    });
                  }),
              Expanded(
                  child: Text(
                widget.question.alternativeQuestion,
                style: contentTextStyle,
              ))
            ],
          ),
        ),
        if (Foundation.kDebugMode)
          SizedBox(
            height: 30.0,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 5.0),
                child: Text(
                  widget.question.id,
                  style: TextStyle(fontSize: 10.0, color: Colors.grey.shade500),
                ),
              ),
            ),
          )
      ],
    );
  }
}
