import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' as Foundation;

import '../../../model/question.dart';

class TextResponse extends StatefulWidget {
  final QuestionWithTextResponse question;
  final Function? answerStateChanged;

  TextResponse({super.key, required this.question, this.answerStateChanged});

  @override
  _TextResponseState createState() => _TextResponseState();
}

class _TextResponseState extends State<TextResponse> {
  final TextEditingController _controller = TextEditingController();

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
                    child: TextField(
                      controller: _controller,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp("[ 0-9a-zA-Z\\-_./();\\|]"))
                      ],
                      onChanged: (value) {
                        widget.question.value = _controller.text;
                      },
                      textAlignVertical: TextAlignVertical.center,
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
                    ),
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
