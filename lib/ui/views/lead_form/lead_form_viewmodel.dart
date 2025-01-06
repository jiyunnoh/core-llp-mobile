import 'package:biot/model/patient.dart';
import 'package:biot/services/cloud_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../constants/sex_at_birth.dart';
import '../../../model/condition.dart';
import '../../../model/domain_weight_distribution.dart';
import '../../../model/kLevel.dart';
import '../../../services/logger_service.dart';

class LeadFormViewModel extends BaseViewModel {
  final _apiService = locator<BiotService>();
  final _navigationService = locator<NavigationService>();
  final _logger =
  locator<LoggerService>().getLogger((LeadFormViewModel).toString());

  int get currentYear => DateTime.now().year;
  int get startYear => currentYear - 99;

  //TODO: Jung - programmatically calculate the initial scroll offset
  ScrollController yearController = ScrollController(initialScrollOffset: 1052);

  late DateTime dobPickedDate;
  Patient? patient;
  Function(Patient patient) onClickedDone;

  bool isEdit;
  bool isDobModified = false;
  bool isSexAtBirthModified = false;

  int? birthYear;

  String get birthYearHeader =>
      'Year of Birth ${birthYear == null ? '' : '- ${startYear + birthYear!}'}';
  SexAtBirth? selectedSexAtBirth;

  String get sexHeader => 'Sex';

  LeadFormViewModel(this.onClickedDone, {this.isEdit = false, this.patient}) {
    _logger.d('');

    if (isEdit) {
      dobPickedDate = patient!.dob!;
      birthYear = patient!.dob!.year - startYear;
      selectedSexAtBirth = patient!.sexAtBirth;
    }
  }

  void onChangeBirthYear(bool selected, int index) {
    if (selected) {
      birthYear = index;
      // picking fake birth month and day as June 1 in PST
      dobPickedDate = DateTime(startYear + birthYear!, 6, 1);

      notifyListeners();
    }
  }

  void onChangeSexAtBirth(bool selected, SexAtBirth sex) {
    if (selected) {
      selectedSexAtBirth = sex;
      notifyListeners();
    }
  }

  void formValidated() {
    _logger.d('');

    if (birthYear != null && selectedSexAtBirth != null) {
      if (isEdit) {
        patient!.sexAtBirthIndex = selectedSexAtBirth!.index;
        patient!.dob = dobPickedDate;
      } else {
        print('add form validated');
        String orgCode = _apiService.ownerOrganizationCode;
        print(orgCode);
        String epochTime =
            DateTime.now().millisecondsSinceEpoch.toRadixString(16);
        // Last 4 digits of milliseconds since epoch time
        String last4Digits = epochTime.substring(epochTime.length - 4).toUpperCase();
        String clientInfo =
            '${dobPickedDate.year.toString().substring(2)}${selectedSexAtBirth!.shortStrValue}';
        String uniqueId = '$orgCode-$last4Digits-$clientInfo';

        patient = Patient(
            lastName: '$orgCode-',
            firstName: '$last4Digits-$clientInfo',
            email: '$epochTime@lead.com',
            id: uniqueId,
            dob: dobPickedDate,
            sexAtBirthIndex: selectedSexAtBirth!.index);

        patient!.domainWeightDist = DomainWeightDistribution.equalDistribute();
        patient!.condition = Condition(conditionsList: ['lower', 'prosthetic']);
        patient!.kLevel = KLevel(kLevelValue: 0);
      } //new
      onClickedDone(patient!);
      navigateBack();
    }
  }

  void navigateBack() {
    _navigationService.back();
  }
}
