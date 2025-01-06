import 'package:flutter/material.dart';
// import 'package:oi_flutter_comet/src/app/app_constants.dart';
// import 'package:oi_flutter_comet/src/datamodels/question.dart';

import '../../../model/question.dart';
import '../../common/ui_helpers.dart';

class RadioButtonResponse extends StatefulWidget {
  final QuestionWithRadialResponse question;
  final Function? answerStateChanged;

  const RadioButtonResponse(
      {super.key, required this.question, this.answerStateChanged});
  @override
  _RadioButtonResponseState createState() => _RadioButtonResponseState();
}

class _RadioButtonResponseState extends State<RadioButtonResponse> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.question.options.asMap().entries.map((entry) {
        int index = entry.key;
        String option = entry.value;
        return RadioListTile(
          title: Text(option, style: contentTextStyle),
          value: index,
          groupValue: widget.question.value,
          onChanged: (newValue) {
            setState(() {
              widget.question.value = newValue;
              if (widget.answerStateChanged != null) {
                widget.answerStateChanged!();
              }
            });
          },
        );
      }).toList(),
    );
  }
}
