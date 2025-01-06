import 'package:biot/ui/widgets/response%20widgets/peq_slider_comp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as Foundation;

import '../../../model/question.dart';

class VasResponse extends StatefulWidget {
  final QuestionWithVasResponse question;
  final Function? answerStateChanged;

  VasResponse({super.key, required this.question, this.answerStateChanged});

  @override
  _VasResponseState createState() => _VasResponseState();
}

class _VasResponseState extends State<VasResponse> {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var orientation = MediaQuery.of(context).orientation;
    return Container(
        child: Column(
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
                      ? Colors.orange
                      : Colors.black.withAlpha(0),
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
        SizedBox(height: 30.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(
              width: orientation == Orientation.portrait
                  ? (screenSize.width * 0.1) * 2.00
                  : (screenSize.width * 0.1) * 2.25,
              child: Text(
                widget.question.min.toUpperCase(),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: orientation == Orientation.portrait
                  ? (screenSize.width * 0.1) * 2.00
                  : (screenSize.width * 0.1) * 2.25,
              child: Text(
                widget.question.max.toUpperCase(),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        if (Foundation.kDebugMode)
          Container(
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
    ));
  }
}
