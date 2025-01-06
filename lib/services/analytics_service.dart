import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver getAnalyticsObserver() =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future logScreen({required String name}) async {
    //Remove "Model" from name
    String viewName = name.replaceAll('Model', '');
    await _analytics.logScreenView(screenName: viewName);
  }

  Future logLogin() async {
    await _analytics.logLogin();
  }

  Future logLogout() async {
    await _analytics.logEvent(name: 'logout');
  }

  Future logEpisodeUploadFail() async {
    await _analytics.logEvent(name: 'encounter_upload_fail');
  }
}
