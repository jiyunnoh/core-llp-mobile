import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:biot/app/app.locator.dart';
import 'package:biot/constants/compass_lead_enum.dart';
import 'package:biot/model/pre_post_episode_of_care.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../helpers/test_helpers.dart';

void main() {
  late PrePostEpisodeOfCare prePost;
  late PdfDocument pdf;
  Map<String, String> matcher = {'date': '2024-04-03'};

  setUp(() async {
    registerServices();

    prePost = PrePostEpisodeOfCare(dateOfCare: DateTime(2024, 4, 3));
    Uint8List data = await File(
            '${Directory.current.path}/test/test_resources/pre_post_page.pdf')
        .readAsBytes();
    pdf = PdfDocument(inputBytes: data);
  });

  tearDown(() => locator.reset());

  group(
      'Verify that all input can be imported into appropriate PDF form for export. - Pre/Post',
      () {
    /// **Test ID**: TC-LPP-005A
    /// **Objective**: Verify that PDF form is correct when all questions are not answered.
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Make sure all answered are not answered except the date which is prefilled.
    ///   2. Complete the process and tap 'Export Report' button.
    ///   3. Verify that PDF form is correctly filled in.
    /// **Automated**: Yes
    test('TC-LPP-005A - Verify that PDF form is correct when all questions are not answered.',
        () {
      expect(prePost.toJsonForPDF(), {'date': '2024-04-03'});
      pdf.form.importData(
          utf8.encode(jsonEncode(prePost.toJsonForPDF())), DataFormat.json);
    });

    /// **Test ID**: TC-LPP-005B
    /// **Objective**: Verify that PDF form is correct for mobility devices/device usage questions.
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Tap all mobility devices to mark them as checked.
    ///   2. Select one of options for all device usage questions.
    ///   3. Complete the process and tap 'Export Report' button.
    ///   4. Verify that PDF form is correctly filled in.
    ///   5. Repeat the process for all other options for device usage questions.
    /// **Automated**: Yes
    test(
        'TC-LPP-005B - Verify that PDF form is correct for mobility devices/device usage questions.',
        () {
      // Select 'In a normal day I don't use it' for usage questions
      prePost.mobilityDevices = MobilityDevice.values.map((e) => e).toList();
      prePost.noWalkingAidsUsage = MobilityDeviceUsage.noUsage;
      prePost.singlePointStickUsage = MobilityDeviceUsage.noUsage;
      prePost.quadBaseWalkingStickUsage = MobilityDeviceUsage.noUsage;
      prePost.singleCrutchUsage = MobilityDeviceUsage.noUsage;
      prePost.pairOfCrutchesUsage = MobilityDeviceUsage.noUsage;
      prePost.walkingFrameWalkerUsage = MobilityDeviceUsage.noUsage;
      prePost.wheeledWalkerUsage = MobilityDeviceUsage.noUsage;
      prePost.manualWheelchairUsage = MobilityDeviceUsage.noUsage;
      prePost.poweredWheeledOrMobilityScooterUsage =
          MobilityDeviceUsage.noUsage;

      prePost.mobilityDevices.map((e) {
        matcher.addAll({'mobility_device_${e.index}': YesOrNo.yes.displayName});
        matcher.addAll({
          'mobility_usage_${e.index}': MobilityDeviceUsage.noUsage.displayName
        });
      }).toList();

      expect(prePost.toJsonForPDF(), matcher);
      pdf.form.importData(
          utf8.encode(jsonEncode(prePost.toJsonForPDF())), DataFormat.json);

      // Select 'Less than 1 hour (a little)' for usage questions
      prePost.mobilityDevices = MobilityDevice.values.map((e) => e).toList();
      prePost.noWalkingAidsUsage = MobilityDeviceUsage.little;
      prePost.singlePointStickUsage = MobilityDeviceUsage.little;
      prePost.quadBaseWalkingStickUsage = MobilityDeviceUsage.little;
      prePost.singleCrutchUsage = MobilityDeviceUsage.little;
      prePost.pairOfCrutchesUsage = MobilityDeviceUsage.little;
      prePost.walkingFrameWalkerUsage = MobilityDeviceUsage.little;
      prePost.wheeledWalkerUsage = MobilityDeviceUsage.little;
      prePost.manualWheelchairUsage = MobilityDeviceUsage.little;
      prePost.poweredWheeledOrMobilityScooterUsage = MobilityDeviceUsage.little;

      prePost.mobilityDevices.map((e) {
        matcher.addAll({'mobility_device_${e.index}': YesOrNo.yes.displayName});
        matcher.addAll({
          'mobility_usage_${e.index}': MobilityDeviceUsage.little.displayName
        });
      }).toList();

      expect(prePost.toJsonForPDF(), matcher);
      pdf.form.importData(
          utf8.encode(jsonEncode(prePost.toJsonForPDF())), DataFormat.json);

      // Select '1-3 hours (some)' for usage questions
      prePost.mobilityDevices = MobilityDevice.values.map((e) => e).toList();
      prePost.noWalkingAidsUsage = MobilityDeviceUsage.some;
      prePost.singlePointStickUsage = MobilityDeviceUsage.some;
      prePost.quadBaseWalkingStickUsage = MobilityDeviceUsage.some;
      prePost.singleCrutchUsage = MobilityDeviceUsage.some;
      prePost.pairOfCrutchesUsage = MobilityDeviceUsage.some;
      prePost.walkingFrameWalkerUsage = MobilityDeviceUsage.some;
      prePost.wheeledWalkerUsage = MobilityDeviceUsage.some;
      prePost.manualWheelchairUsage = MobilityDeviceUsage.some;
      prePost.poweredWheeledOrMobilityScooterUsage = MobilityDeviceUsage.some;

      prePost.mobilityDevices.map((e) {
        matcher.addAll({'mobility_device_${e.index}': YesOrNo.yes.displayName});
        matcher.addAll({
          'mobility_usage_${e.index}': MobilityDeviceUsage.some.displayName
        });
      }).toList();

      expect(prePost.toJsonForPDF(), matcher);
      pdf.form.importData(
          utf8.encode(jsonEncode(prePost.toJsonForPDF())), DataFormat.json);

      // Select '3-6 hours (lots)' for usage questions
      prePost.mobilityDevices = MobilityDevice.values.map((e) => e).toList();
      prePost.noWalkingAidsUsage = MobilityDeviceUsage.lots;
      prePost.singlePointStickUsage = MobilityDeviceUsage.lots;
      prePost.quadBaseWalkingStickUsage = MobilityDeviceUsage.lots;
      prePost.singleCrutchUsage = MobilityDeviceUsage.lots;
      prePost.pairOfCrutchesUsage = MobilityDeviceUsage.lots;
      prePost.walkingFrameWalkerUsage = MobilityDeviceUsage.lots;
      prePost.wheeledWalkerUsage = MobilityDeviceUsage.lots;
      prePost.manualWheelchairUsage = MobilityDeviceUsage.lots;
      prePost.poweredWheeledOrMobilityScooterUsage = MobilityDeviceUsage.lots;

      prePost.mobilityDevices.map((e) {
        matcher.addAll({'mobility_device_${e.index}': YesOrNo.yes.displayName});
        matcher.addAll({
          'mobility_usage_${e.index}': MobilityDeviceUsage.lots.displayName
        });
      }).toList();

      expect(prePost.toJsonForPDF(), matcher);
      pdf.form.importData(
          utf8.encode(jsonEncode(prePost.toJsonForPDF())), DataFormat.json);

      // Select '6+ hours (mostly)' for usage questions
      prePost.mobilityDevices = MobilityDevice.values.map((e) => e).toList();
      prePost.noWalkingAidsUsage = MobilityDeviceUsage.mostly;
      prePost.singlePointStickUsage = MobilityDeviceUsage.mostly;
      prePost.quadBaseWalkingStickUsage = MobilityDeviceUsage.mostly;
      prePost.singleCrutchUsage = MobilityDeviceUsage.mostly;
      prePost.pairOfCrutchesUsage = MobilityDeviceUsage.mostly;
      prePost.walkingFrameWalkerUsage = MobilityDeviceUsage.mostly;
      prePost.wheeledWalkerUsage = MobilityDeviceUsage.mostly;
      prePost.manualWheelchairUsage = MobilityDeviceUsage.mostly;
      prePost.poweredWheeledOrMobilityScooterUsage = MobilityDeviceUsage.mostly;

      prePost.mobilityDevices.map((e) {
        matcher.addAll({'mobility_device_${e.index}': YesOrNo.yes.displayName});
        matcher.addAll({
          'mobility_usage_${e.index}': MobilityDeviceUsage.mostly.displayName
        });
      }).toList();

      expect(prePost.toJsonForPDF(), matcher);
      pdf.form.importData(
          utf8.encode(jsonEncode(prePost.toJsonForPDF())), DataFormat.json);
    });

    /// **Test ID**: TC-LPP-005C
    /// **Objective**: Verify that PDF form is correct for ICF qualifiers questions (participation, ability to work).
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Select one of options for all 4 questions.
    ///   2. Complete the process and tap 'Export Report' button.
    ///   3. Verify that PDF form is correctly filled in.
    ///   4. Repeat the process for all other options for all 4 questions.
    /// **Automated**: Yes
    test(
        'TC-LPP-005C - Verify that PDF form is correct for ICF qualifiers questions (participation, ability to work).',
        () {
      // Select 'NO problem (0-5%)' for all 4 questions
      prePost.communityParticipation = IcfQualifiers.noProblem;
      prePost.communityParticipationWithLimb = IcfQualifiers.noProblem;
      prePost.abilityToWork = IcfQualifiers.noProblem;
      prePost.abilityToWorkWithLimb = IcfQualifiers.noProblem;

      expect(prePost.toJsonForPDF(), {
        'date': '2024-04-03',
        'participation': IcfQualifiers.noProblem.displayName,
        'participation_with_limb': IcfQualifiers.noProblem.displayName,
        'ability_to_work': IcfQualifiers.noProblem.displayName,
        'ability_to_work_with_limb': IcfQualifiers.noProblem.displayName
      });
      pdf.form.importData(
          utf8.encode(jsonEncode(prePost.toJsonForPDF())), DataFormat.json);

      // Select 'MILD problem (6-25%)' for all 4 questions
      prePost.communityParticipation = IcfQualifiers.mildProblem;
      prePost.communityParticipationWithLimb = IcfQualifiers.mildProblem;
      prePost.abilityToWork = IcfQualifiers.mildProblem;
      prePost.abilityToWorkWithLimb = IcfQualifiers.mildProblem;

      expect(prePost.toJsonForPDF(), {
        'date': '2024-04-03',
        'participation': IcfQualifiers.mildProblem.displayName,
        'participation_with_limb': IcfQualifiers.mildProblem.displayName,
        'ability_to_work': IcfQualifiers.mildProblem.displayName,
        'ability_to_work_with_limb': IcfQualifiers.mildProblem.displayName
      });
      pdf.form.importData(
          utf8.encode(jsonEncode(prePost.toJsonForPDF())), DataFormat.json);

      // Select 'MODERATE problem (26-50%)' for all 4 questions
      prePost.communityParticipation = IcfQualifiers.moderateProblem;
      prePost.communityParticipationWithLimb = IcfQualifiers.moderateProblem;
      prePost.abilityToWork = IcfQualifiers.moderateProblem;
      prePost.abilityToWorkWithLimb = IcfQualifiers.moderateProblem;

      expect(prePost.toJsonForPDF(), {
        'date': '2024-04-03',
        'participation': IcfQualifiers.moderateProblem.displayName,
        'participation_with_limb': IcfQualifiers.moderateProblem.displayName,
        'ability_to_work': IcfQualifiers.moderateProblem.displayName,
        'ability_to_work_with_limb': IcfQualifiers.moderateProblem.displayName
      });
      pdf.form.importData(
          utf8.encode(jsonEncode(prePost.toJsonForPDF())), DataFormat.json);

      // Select 'SEVERE problem (51-95%)' for all 4 questions
      prePost.communityParticipation = IcfQualifiers.severeProblem;
      prePost.communityParticipationWithLimb = IcfQualifiers.severeProblem;
      prePost.abilityToWork = IcfQualifiers.severeProblem;
      prePost.abilityToWorkWithLimb = IcfQualifiers.severeProblem;

      expect(prePost.toJsonForPDF(), {
        'date': '2024-04-03',
        'participation': IcfQualifiers.severeProblem.displayName,
        'participation_with_limb': IcfQualifiers.severeProblem.displayName,
        'ability_to_work': IcfQualifiers.severeProblem.displayName,
        'ability_to_work_with_limb': IcfQualifiers.severeProblem.displayName
      });
      pdf.form.importData(
          utf8.encode(jsonEncode(prePost.toJsonForPDF())), DataFormat.json);

      // Select 'COMPLETE problem (96-100%)' for all 4 questions
      prePost.communityParticipation = IcfQualifiers.completeProblem;
      prePost.communityParticipationWithLimb = IcfQualifiers.completeProblem;
      prePost.abilityToWork = IcfQualifiers.completeProblem;
      prePost.abilityToWorkWithLimb = IcfQualifiers.completeProblem;

      expect(prePost.toJsonForPDF(), {
        'date': '2024-04-03',
        'participation': IcfQualifiers.completeProblem.displayName,
        'participation_with_limb': IcfQualifiers.completeProblem.displayName,
        'ability_to_work': IcfQualifiers.completeProblem.displayName,
        'ability_to_work_with_limb': IcfQualifiers.completeProblem.displayName
      });
      pdf.form.importData(
          utf8.encode(jsonEncode(prePost.toJsonForPDF())), DataFormat.json);
    });

    /// **Test ID**: TC-LPP-005D
    /// **Objective**: Verify that PDF form is correct for ambulatory activity level questions (standing, walking).
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Select one of options for all 2 questions.
    ///   2. Complete the process and tap 'Export Report' button.
    ///   3. Verify that PDF form is correctly filled in.
    ///   4. Repeat the process for all other options for all 2 questions.
    /// **Automated**: Yes
    test(
        'Verify that PDF form is correct for ambulatory activity level questions (standing, walking).',
        () {
      // Select 'In a normal day I don't' for all 2 questions
      prePost.standingTimeInHour = AmbulatoryActivityLevel.noActivity;
      prePost.walkingTimeInHour = AmbulatoryActivityLevel.noActivity;
      expect(prePost.toJsonForPDF(), {
        'date': '2024-04-03',
        'standing_time': AmbulatoryActivityLevel.noActivity.displayName,
        'walking_time': AmbulatoryActivityLevel.noActivity.displayName
      });
      pdf.form.importData(
          utf8.encode(jsonEncode(prePost.toJsonForPDF())), DataFormat.json);

      // Select 'Less than 1 hour (a little)' for all 2 questions
      prePost.standingTimeInHour = AmbulatoryActivityLevel.little;
      prePost.walkingTimeInHour = AmbulatoryActivityLevel.little;
      expect(prePost.toJsonForPDF(), {
        'date': '2024-04-03',
        'standing_time': AmbulatoryActivityLevel.little.displayName,
        'walking_time': AmbulatoryActivityLevel.little.displayName
      });
      pdf.form.importData(
          utf8.encode(jsonEncode(prePost.toJsonForPDF())), DataFormat.json);

      // Select '1-3 hours (some)' for all 2 questions
      prePost.standingTimeInHour = AmbulatoryActivityLevel.some;
      prePost.walkingTimeInHour = AmbulatoryActivityLevel.some;
      expect(prePost.toJsonForPDF(), {
        'date': '2024-04-03',
        'standing_time': AmbulatoryActivityLevel.some.displayName,
        'walking_time': AmbulatoryActivityLevel.some.displayName
      });
      pdf.form.importData(
          utf8.encode(jsonEncode(prePost.toJsonForPDF())), DataFormat.json);

      // Select '3-6 hours (lots)' for all 2 questions
      prePost.standingTimeInHour = AmbulatoryActivityLevel.lots;
      prePost.walkingTimeInHour = AmbulatoryActivityLevel.lots;
      expect(prePost.toJsonForPDF(), {
        'date': '2024-04-03',
        'standing_time': AmbulatoryActivityLevel.lots.displayName,
        'walking_time': AmbulatoryActivityLevel.lots.displayName
      });
      pdf.form.importData(
          utf8.encode(jsonEncode(prePost.toJsonForPDF())), DataFormat.json);

      // Select '6+ hours (mostly)' for all 2 questions
      prePost.standingTimeInHour = AmbulatoryActivityLevel.mostly;
      prePost.walkingTimeInHour = AmbulatoryActivityLevel.mostly;
      expect(prePost.toJsonForPDF(), {
        'date': '2024-04-03',
        'standing_time': AmbulatoryActivityLevel.mostly.displayName,
        'walking_time': AmbulatoryActivityLevel.mostly.displayName
      });
      pdf.form.importData(
          utf8.encode(jsonEncode(prePost.toJsonForPDF())), DataFormat.json);
    });

    /// **Test ID**: TC-LPP-005E
    /// **Objective**: Verify that PDF form is correct for fall and following questions.
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Select 'No' for fall question.
    ///   2. Complete the process and tap 'Export Report' button.
    ///   3. Verify that PDF form is correctly filled in.
    ///   4. Select 'Yes' for fall question and each option for all following questions.
    ///   5. Complete the process and verify that PDF form is correct.
    /// **Automated**: Yes
    test('TC-LPP-005E - Verify that PDF form is correct for fall and following questions.',
        () {
      // Select 'No' for fall question
      prePost.fall = YesOrNo.no;
      expect(prePost.toJsonForPDF(),
          {'date': '2024-04-03', 'fall': YesOrNo.no.displayName});
      pdf.form.importData(
          utf8.encode(jsonEncode(prePost.toJsonForPDF())), DataFormat.json);

      // Select 'Yes' for fall question
      prePost.fall = YesOrNo.yes;
      expect(prePost.toJsonForPDF(),
          {'date': '2024-04-03', 'fall': YesOrNo.yes.displayName});
      pdf.form.importData(
          utf8.encode(jsonEncode(prePost.toJsonForPDF())), DataFormat.json);

      // Select 'Yes' for isInjurious question
      prePost.isInjuriousFall = YesOrNo.yes;
      expect(prePost.toJsonForPDF(), {
        'date': '2024-04-03',
        'fall': YesOrNo.yes.displayName,
        'injurious_fall': YesOrNo.yes.displayName
      });
      pdf.form.importData(
          utf8.encode(jsonEncode(prePost.toJsonForPDF())), DataFormat.json);

      // Select 'No' for isInjurious question
      prePost.isInjuriousFall = YesOrNo.no;
      expect(prePost.toJsonForPDF(), {
        'date': '2024-04-03',
        'fall': YesOrNo.yes.displayName,
        'injurious_fall': YesOrNo.no.displayName
      });
      pdf.form.importData(
          utf8.encode(jsonEncode(prePost.toJsonForPDF())), DataFormat.json);

      // Select 'Less than once in 6 months' for fall frequency question
      prePost.fallFrequency = FallFrequency.lessThanOnceIn6Months;
      expect(prePost.toJsonForPDF(), {
        'date': '2024-04-03',
        'fall': YesOrNo.yes.displayName,
        'fall_frequency': FallFrequency.lessThanOnceIn6Months.displayName,
        'injurious_fall': YesOrNo.no.displayName
      });
      pdf.form.importData(
          utf8.encode(jsonEncode(prePost.toJsonForPDF())), DataFormat.json);

      // Select 'A fall every 3-6 months' for fall frequency question
      prePost.fallFrequency = FallFrequency.every3to6Months;
      expect(prePost.toJsonForPDF(), {
        'date': '2024-04-03',
        'fall': YesOrNo.yes.displayName,
        'fall_frequency': FallFrequency.every3to6Months.displayName,
        'injurious_fall': YesOrNo.no.displayName
      });
      pdf.form.importData(
          utf8.encode(jsonEncode(prePost.toJsonForPDF())), DataFormat.json);

      // Select 'A fall every 1-3 months' for fall frequency question
      prePost.fallFrequency = FallFrequency.every1to3Months;
      expect(prePost.toJsonForPDF(), {
        'date': '2024-04-03',
        'fall': YesOrNo.yes.displayName,
        'fall_frequency': FallFrequency.every1to3Months.displayName,
        'injurious_fall': YesOrNo.no.displayName
      });
      pdf.form.importData(
          utf8.encode(jsonEncode(prePost.toJsonForPDF())), DataFormat.json);

      // Select 'In most months I would have a fall' for fall frequency question
      prePost.fallFrequency = FallFrequency.everyMonth;
      expect(prePost.toJsonForPDF(), {
        'date': '2024-04-03',
        'fall': YesOrNo.yes.displayName,
        'fall_frequency': FallFrequency.everyMonth.displayName,
        'injurious_fall': YesOrNo.no.displayName
      });
      pdf.form.importData(
          utf8.encode(jsonEncode(prePost.toJsonForPDF())), DataFormat.json);
    });

    /// **Test ID**: TC-LPP-005F
    /// **Objective**: Verify that PDF form is correct for support and community questions.
    /// **Preconditions**: None.
    /// **Test Steps**:
    ///   1. Select 'No' for support and community questions.
    ///   2. Complete the process and tap 'Export Report' button.
    ///   3. Verify that PDF form is correctly filled in.
    ///   4. Select 'Yes' for support and community questions, and select each option for community service question.
    ///   5. Verify that PDF form is correct and repeat the process for all other options.
    /// **Automated**: Yes
    test('TC-LPP-005F - Verify that PDF form is correct for support and community questions.',
        () {
      // Select 'No' for support and community questions.
      prePost.socialSupportAccess = YesOrNo.no;
      prePost.communityServiceAccess = YesOrNo.no;
      expect(prePost.toJsonForPDF(), {
        'date': '2024-04-03',
        'social_support_access': YesOrNo.no.displayName,
        'community_service_access': YesOrNo.no.displayName
      });
      pdf.form.importData(
          utf8.encode(jsonEncode(prePost.toJsonForPDF())), DataFormat.json);

      // Select 'Yes' for support and community questions, and select 'Government' for community service question.
      prePost.socialSupportAccess = YesOrNo.yes;
      prePost.socialSupportUtil = YesOrNo.yes;
      prePost.communityServiceAccess = YesOrNo.yes;

      prePost.communityService = CommunityService.government;
      expect(prePost.toJsonForPDF(), {
        'date': '2024-04-03',
        'social_support_access': YesOrNo.yes.displayName,
        'social_support_util': YesOrNo.yes.displayName,
        'community_service_access': YesOrNo.yes.displayName,
        'community_service': CommunityService.government.displayName
      });
      pdf.form.importData(
          utf8.encode(jsonEncode(prePost.toJsonForPDF())), DataFormat.json);

      // Select 'Yes' for support and community questions, and select 'Paid/private' for community service question.
      prePost.communityService = CommunityService.paidPrivate;
      expect(prePost.toJsonForPDF(), {
        'date': '2024-04-03',
        'social_support_access': YesOrNo.yes.displayName,
        'social_support_util': YesOrNo.yes.displayName,
        'community_service_access': YesOrNo.yes.displayName,
        'community_service': CommunityService.paidPrivate.displayName
      });
      pdf.form.importData(
          utf8.encode(jsonEncode(prePost.toJsonForPDF())), DataFormat.json);

      // Select 'Yes' for support and community questions, and select 'Ngo/volunteer' for community service question.
      prePost.communityService = CommunityService.ngoVolunteer;
      expect(prePost.toJsonForPDF(), {
        'date': '2024-04-03',
        'social_support_access': YesOrNo.yes.displayName,
        'social_support_util': YesOrNo.yes.displayName,
        'community_service_access': YesOrNo.yes.displayName,
        'community_service': CommunityService.ngoVolunteer.displayName
      });
      pdf.form.importData(
          utf8.encode(jsonEncode(prePost.toJsonForPDF())), DataFormat.json);

      // Select 'Yes' for support and community questions, and select 'Other' for community service question.
      prePost.communityService = CommunityService.other;
      expect(prePost.toJsonForPDF(), {
        'date': '2024-04-03',
        'social_support_access': YesOrNo.yes.displayName,
        'social_support_util': YesOrNo.yes.displayName,
        'community_service_access': YesOrNo.yes.displayName,
        'community_service': CommunityService.other.displayName
      });
      pdf.form.importData(
          utf8.encode(jsonEncode(prePost.toJsonForPDF())), DataFormat.json);
    });
  });
}
