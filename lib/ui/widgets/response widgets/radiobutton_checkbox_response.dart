import 'package:flutter/material.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:oi_flutter_comet/generated/locale_keys.g.dart';

import '../../../model/question.dart';
import '../../common/ui_helpers.dart';

class RadioButtonCheckBoxResponse extends StatefulWidget {
  final QuestionWithRadialCheckBoxResponse question;
  final Function()? answerStateChanged;

  const RadioButtonCheckBoxResponse(
      {super.key, required this.question, this.answerStateChanged});
  @override
  _RadioButtonCheckBoxResponseState createState() =>
      _RadioButtonCheckBoxResponseState();
}

class _RadioButtonCheckBoxResponseState
    extends State<RadioButtonCheckBoxResponse> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
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
                  widget.question.isChecked = false;
                  if (widget.answerStateChanged != null) {
                    widget.answerStateChanged!();
                  }
                });
              },
            );
          }).toList(),
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
            Text(
              widget.question.tapQuestion,
              style: contentTextStyle,
            ),
          ],
        ),
      ],
    );
  }
}
