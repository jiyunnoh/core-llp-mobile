import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:flutter/foundation.dart' as Foundation;
// import 'package:easy_localization/easy_localization.dart';
// import 'package:oi_flutter_comet/generated/locale_keys.g.dart';

import '../../../model/question.dart';
import '../../common/ui_helpers.dart';

class DiscreteScaleCheckBoxResponse extends StatefulWidget {
  // final Key key;
  final QuestionWithDiscreteScaleCheckBoxResponse question;
  final Function()? answerStateChanged;

  DiscreteScaleCheckBoxResponse(
      {super.key, required this.question, this.answerStateChanged});

  @override
  State<DiscreteScaleCheckBoxResponse> createState() =>
      _DiscreteScaleCheckBoxResponseState();
}

class _DiscreteScaleCheckBoxResponseState
    extends State<DiscreteScaleCheckBoxResponse> {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var orientation = MediaQuery.of(context).orientation;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            // SizedBox(
            //   width: screenSize.width * 0.05,
            // ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: SfSlider(
                      activeColor: widget.question.value != null
                          ? Colors.orange
                          : Colors.transparent,
                      min: widget.question.min,
                      max: widget.question.max,
                      value: widget.question.scaleValue,
                      interval: 1.0,
                      showTicks: true,
                      showLabels: true,
                      stepSize: 1.0,
                      onChangeStart: (dynamic value) {
                        setState(() {
                          widget.question.scaleValue = value;
                        });
                      },
                      onChanged: (dynamic value) {
                        setState(() {
                          widget.question.scaleValue = value;
                        });
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 30),
                    // child: Center(child: Text('- ${LocaleKeys.orAllCap.tr()} -')),
                    child: Center(child: Text('- OR -')),
                  ),
                  Row(
                    children: [
                      Checkbox(
                          value: widget.question.isChecked,
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
                        widget.question.tapQuestion,
                        style: contentTextStyle,
                      )),
                    ],
                  ),
                ],
              ),
            ),
            // SizedBox(
            //   width: screenSize.width * 0.05,
            // ),
          ],
        ),
        const SizedBox(height: 30.0),
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
