import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:flutter/foundation.dart' as Foundation;

import '../../../model/question.dart';

class DiscreteScaleResponse extends StatefulWidget {
  final QuestionWithDiscreteScaleResponse question;
  final Function()? answerStateChanged;

  const DiscreteScaleResponse(
      {super.key, required this.question, this.answerStateChanged});

  @override
  _DiscreteScaleResponseState createState() => _DiscreteScaleResponseState();
}

class _DiscreteScaleResponseState extends State<DiscreteScaleResponse> {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var orientation = MediaQuery.of(context).orientation;
    return Container(
        child: Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            // SizedBox(
            //   width: screenSize.width * 0.1,
            // ),
            Expanded(
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
            // SizedBox(
            //   width: screenSize.width * 0.1,
            // ),
          ],
        ),
        SizedBox(height: 30.0),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: <Widget>[
        //     SizedBox(
        //       width: orientation == Orientation.portrait
        //           ? (screenSize.width * 0.1) * 3.50
        //           : (screenSize.width * 0.1) * 2.25,
        //       child: Text(
        //         widget.question.min.toUpperCase(),
        //         textAlign: TextAlign.center,
        //       ),
        //     ),
        //     SizedBox(
        //       width: orientation == Orientation.portrait
        //           ? (screenSize.width * 0.1) * 3.50
        //           : (screenSize.width * 0.1) * 2.25,
        //       child: Text(
        //         widget.question.max.toUpperCase(),
        //         textAlign: TextAlign.center,
        //       ),
        //     ),
        //   ],
        // ),
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
