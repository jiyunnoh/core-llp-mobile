import 'package:flutter/material.dart';

import 'enum.dart';

String ksPieSliceIcon = 'assets/images/pie_slice_icon.png';
Image goalsIcon =
    Image.asset(ksPieSliceIcon, scale: 7.0, color: DomainType.goals.color);
Image communityIcon =
    Image.asset(ksPieSliceIcon, scale: 7.0, color: DomainType.community.color);
Image satisfactionIcon = Image.asset(ksPieSliceIcon,
    scale: 7.0, color: DomainType.satisfaction.color);
Image functionIcon =
    Image.asset(ksPieSliceIcon, scale: 7.0, color: DomainType.function.color);
Image comfortIcon =
    Image.asset(ksPieSliceIcon, scale: 7.0, color: DomainType.comfort.color);

Padding pieChartIcon = Padding(
  padding: const EdgeInsets.only(right: 2.0),
  child: Image.asset(
    'assets/images/pie_icon.png',
    scale: 1.5,
  ),
);

Icon patientIcon = const Icon(
  Icons.person,
  size: 22,
);
Image clinicianIcon = Image.asset(
  'assets/images/clinician_logo.png',
  scale: 1.7,
);
Image assistantIcon = Image.asset(
  'assets/images/assistant_logo.png',
  scale: 1.7,
);

String sigDiffDownIcon = 'assets/images/sig_diff_down_icon.png';

String sigDiffUpIcon = 'assets/images/sig_diff_up_icon.png';

String singleArrowDownIcon = 'assets/images/single_arrow_down.png';
String singleArrowUpIcon = 'assets/images/single_arrow_up.png';

String trendDownIcon = 'assets/images/trend_down_icon.png';
String trendUpIcon = 'assets/images/trend_up_icon.png';
String trendStableIcon = 'assets/images/trend_stable_icon.png';
