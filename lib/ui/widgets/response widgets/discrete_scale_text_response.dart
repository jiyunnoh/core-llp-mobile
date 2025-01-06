import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:flutter/foundation.dart' as Foundation;

import '../../../model/question.dart';

class DiscreteScaleTextResponse extends StatefulWidget {
  final QuestionWithDiscreteScaleTextResponse question;
  final Function()? answerStateChanged;

  DiscreteScaleTextResponse(
      {super.key, required this.question, this.answerStateChanged});

  @override
  _DiscreteScaleTextResponseState createState() =>
      _DiscreteScaleTextResponseState();
}

class _DiscreteScaleTextResponseState extends State<DiscreteScaleTextResponse> {
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _controller.text = widget.question.textResponse;
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var orientation = MediaQuery.of(context).orientation;
    return Container(
        child: Column(
      children: <Widget>[
        Container(
          height: 100,
          child: TextField(
            controller: _controller,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                  RegExp("[ 0-9a-zA-Z\\-_./();\\|]"))
            ],
            onChanged: (value) {
              // Setting assistive device used value
              widget.question.textResponse = _controller.text;
            },
            textAlignVertical: TextAlignVertical.center,
            maxLength: 30,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
              suffixIcon: ClipOval(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                      onTap: () {
                        _controller.clear();
                        widget.question.value = null;
                      },
                      child: Icon(Icons.close)),
                ),
              ),
              alignLabelWithHint: true,
            ),
          ),
        ),
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
          ],
        ),
        SizedBox(height: 30.0),
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
