import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

const double _tinySize = 5.0;
const double _smallSize = 10.0;
const double _mediumSize = 25.0;
const double _largeSize = 50.0;
const double _massiveSize = 120.0;

const Widget horizontalSpaceTiny = SizedBox(width: _tinySize);
const Widget horizontalSpaceSmall = SizedBox(width: _smallSize);
const Widget horizontalSpaceMedium = SizedBox(width: _mediumSize);
const Widget horizontalSpaceLarge = SizedBox(width: _largeSize);

const Widget verticalSpaceTiny = SizedBox(height: _tinySize);
const Widget verticalSpaceSmall = SizedBox(height: _smallSize);
const Widget verticalSpaceMedium = SizedBox(height: _mediumSize);
const Widget verticalSpaceLarge = SizedBox(height: _largeSize);
const Widget verticalSpaceMassive = SizedBox(height: _massiveSize);

const TextStyle navigatorButtonStyle = TextStyle(fontSize: 16);

ButtonStyle elevatedButtonColor =
    ElevatedButton.styleFrom(backgroundColor: Colors.black);

Widget spacedDivider = Column(
  children: const <Widget>[
    verticalSpaceMedium,
    Divider(color: Colors.blueGrey, height: 5.0),
    verticalSpaceMedium,
  ],
);

Widget verticalSpace(double height) => SizedBox(height: height);

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

double screenHeightFraction(BuildContext context,
        {int dividedBy = 1, double offsetBy = 0, double max = 3000}) =>
    min((screenHeight(context) - offsetBy) / dividedBy, max);

double screenWidthFraction(BuildContext context,
        {int dividedBy = 1, double offsetBy = 0, double max = 3000}) =>
    min((screenWidth(context) - offsetBy) / dividedBy, max);

double halfScreenWidth(BuildContext context) =>
    screenWidthFraction(context, dividedBy: 2);

double thirdScreenWidth(BuildContext context) =>
    screenWidthFraction(context, dividedBy: 3);

double quarterScreenWidth(BuildContext context) =>
    screenWidthFraction(context, dividedBy: 4);

double getResponsiveHorizontalSpaceMedium(BuildContext context) =>
    screenWidthFraction(context, dividedBy: 10);
double getResponsiveSmallFontSize(BuildContext context) =>
    getResponsiveFontSize(context, fontSize: 14, max: 15);

double getResponsiveMediumFontSize(BuildContext context) =>
    getResponsiveFontSize(context, fontSize: 16, max: 17);

double getResponsiveLargeFontSize(BuildContext context) =>
    getResponsiveFontSize(context, fontSize: 21, max: 31);

double getResponsiveExtraLargeFontSize(BuildContext context) =>
    getResponsiveFontSize(context, fontSize: 25);

double getResponsiveMassiveFontSize(BuildContext context) =>
    getResponsiveFontSize(context, fontSize: 30);

double getResponsiveFontSize(BuildContext context,
    {double? fontSize, double? max}) {
  max ??= 100;

  var responsiveSize = min(
      screenWidthFraction(context, dividedBy: 10) * ((fontSize ?? 100) / 100),
      max);

  return responsiveSize;
}

const kAlertButtonHeight = 60.0;

const kAlertStyle = AlertStyle(
    animationType: AnimationType.grow,
    isCloseButton: false,
    isOverlayTapDismiss: true,
    animationDuration: Duration(milliseconds: 400),
    titleStyle: TextStyle(fontWeight: FontWeight.bold));

double get stickyHeaderHeight {
  if (Device.get().isPhone) {
    return 140;
  } else {
    return 160;
  }
}

double get timerWidth {
  if (Device.get().isPhone) {
    return 80;
  } else {
    return 120;
  }
}

TextStyle get timerTextStyle {
  if (Device.get().isPhone) {
    return const TextStyle(fontSize: 40);
  } else {
    return const TextStyle(fontSize: 80);
  }
}

TextStyle get contentTextStyle {
  if (Device.get().isPhone) {
    return const TextStyle(fontSize: 18);
  } else {
    return const TextStyle(fontSize: 20);
  }
}

TextStyle get buttonTextStyle {
  if (Device.get().isPhone) {
    return const TextStyle(color: Colors.white, fontSize: 20);
  } else {
    return const TextStyle(color: Colors.white, fontSize: 24);
  }
}

TextStyle get evalHeaderStyle {
  if (Device.get().isPhone) {
    return const TextStyle(fontSize: 17);
  } else {
    return const TextStyle(fontSize: 22);
  }
}

TextStyle get episodeHeaderTextStyle {
  if (Device.get().isPhone) {
    return const TextStyle(fontSize: 18, fontWeight: FontWeight.w700);
  } else {
    return const TextStyle(fontSize: 20, fontWeight: FontWeight.w700);
  }
}

TextStyle get episodeOptionsTextStyle {
  if (Device.get().isPhone) {
    return const TextStyle(fontSize: 16);
  } else {
    return const TextStyle(fontSize: 18);
  }
}
