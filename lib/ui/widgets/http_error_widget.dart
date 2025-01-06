import 'package:biot/services/cloud_service.dart';
import 'package:flutter/material.dart';

import '../common/ui_helpers.dart';

class HttpErrorWidget extends StatelessWidget {
  final VoidCallback onRetryPressed;
  String message;
  final AppException error;

  HttpErrorWidget(
      {super.key,
      required this.onRetryPressed,
      this.message = 'Something went wrong',
      required this.error}) {
    if (error is BadRequestException) {
      message = error.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sentiment_dissatisfied_rounded, size: 80),
          verticalSpaceSmall,
          Text(message, style: const TextStyle(fontSize: 24)),
          verticalSpaceLarge,
          // 'Internet is not available.
          MaterialButton(
              color: Colors.black,
              child: const Text(
                'Try again',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: onRetryPressed)
        ],
      ),
    );
  }
}
