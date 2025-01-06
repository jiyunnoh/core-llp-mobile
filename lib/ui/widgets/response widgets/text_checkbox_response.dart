import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' as Foundation;

import '../../../generated/locale_keys.g.dart';
import '../../../model/question.dart';
import '../../common/ui_helpers.dart';

class TextCheckBoxResponse extends StatefulWidget {
  final QuestionWithTextCheckBoxResponse question;
  final Function? answerStateChanged;

  TextCheckBoxResponse(
      {super.key, required this.question, this.answerStateChanged});

  @override
  State<TextCheckBoxResponse> createState() => _TextCheckBoxResponseState();
}

class _TextCheckBoxResponseState extends State<TextCheckBoxResponse> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                      child: TextField(
                    controller: _controller,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp("[ 0-9a-zA-Z\\-_./();\\|]"))
                    ],
                    onChanged: (value) {
                      widget.question.value = _controller.text;
                      setState(() {
                        widget.question.isChecked = false;
                      });
                    },
                    textAlignVertical: TextAlignVertical.center,
                    maxLength: 24,
                    style: contentTextStyle,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      suffixIcon: ClipOval(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                              onTap: () {
                                _controller.clear();
                                widget.question.value = null;
                              },
                              child: const Icon(Icons.close)),
                        ),
                      ),
                      alignLabelWithHint: true,
                    ),
                  )),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child:
                        Center(child: Text('- ${LocaleKeys.orAllCap.tr()} -')),
                  ),
                  Row(
                    children: [
                      Checkbox(
                          value: widget.question.isChecked,
                          autofocus: true,
                          onChanged: (value) {
                            setState(() {
                              if (value != null) {
                                widget.question.isChecked = value;
                                if (value) {
                                  _controller.clear();
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
