import 'package:biot/app/app.router.dart';
import 'package:biot/mixin/dialog_mixin.dart';
import 'package:biot/services/database_service.dart';
import 'package:biot/ui/views/add_lead/add_lead_view.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../model/patient.dart';
import '../../../services/cloud_service.dart';
import '../../../services/logger_service.dart';

class PatientViewModel extends FutureViewModel<List<Patient>> with OIDialog {
  final _navigationService = locator<NavigationService>();
  final _apiService = locator<BiotService>();
  final _localdbService = locator<DatabaseService>();
  final _logger =
      locator<LoggerService>().getLogger((PatientViewModel).toString());

  // final _dialogService = locator<DialogService>();

  Box<Patient> get patientBox {
    return _localdbService.patientsBox;
  }

  set currentPatient(Patient patient) {
    _localdbService.currentPatient = ReactiveValue<Patient>(patient);

    _localdbService.updateCurrentPatient();
  }

  bool isLoading = false;
  bool filterToggle = false;

  PatientViewModel() {
    _logger.d('');
  }

  @override
  void onData(data) {
    if (data != null) {
      syncToCloud(data);
      notifyListeners();
    }
  }

  @override
  Future<List<Patient>> futureToRun() async {
    return _apiService.getPatients();
  }

  //TODO: convert to local db
  Future<void> filterPatientsByCaregiver() async {
    filterToggle = !filterToggle;
    if (filterToggle) {
      data =
          await _apiService.getPatients(caregiverId: _apiService.caregiverId);
    } else {
      data = await _apiService.getPatients();
    }
    notifyListeners();
  }

  Future<void> onPullRefresh() async {
    _logger.d('');

    await Future.delayed(const Duration(seconds: 1));
    try {
      List<Patient> patients = await _apiService.getPatients();
      syncToCloud(patients);
    } catch (e) {
      handleHTTPError(e);
    }
  }

  void syncToCloud(List<Patient> patients) {
    _logger.d('');

    // Add, update patient
    for (final cloudPatient in patients) {
      var matchIndex = patientBox.values.toList().indexWhere(
            (localDbPatient) => localDbPatient.id == cloudPatient.entityId,
          );

      if (matchIndex == -1) {
        patientBox.put(cloudPatient.entityId, cloudPatient);
      } else {
        patientBox.putAt(matchIndex, cloudPatient);
      }
    }

    // Delete patient
    for (Patient localDbPatient in patientBox.values.toList()) {
      var matchIndex = patients.indexWhere(
          (cloudPatient) => cloudPatient.entityId == localDbPatient.id);

      if (matchIndex == -1) {
        patientBox.delete(localDbPatient.id);
      }
    }
  }

  void onPatientTapped(Patient selectedPatient) async {
    _logger.d(selectedPatient.id);

    showBusyDialog();

    try {
      await selectedPatient.populate();
      _localdbService.currentPatient = ReactiveValue<Patient>(selectedPatient);
      _localdbService.updateCurrentPatient();

      closeBusyDialog();

      navigateToPatientDetailView();
    } catch (e) {
      closeBusyDialog();

      handleHTTPError(e);
    }
  }

  void addPatient(Patient patient) async {
    await Future.delayed(const Duration(milliseconds: 300));
    showBusyDialog();

    try {
      await _apiService.addPatientWithDetails(patient);

      patient.isPopulated = true;

      _localdbService.addPatient(patient);
      print('success');
      closeBusyDialog();
    } catch (e) {
      print('error adding');
      closeBusyDialog();

      handleHTTPError(e);
    }
  }

  Future<void> editPatient(Patient patient) async {
    await Future.delayed(const Duration(milliseconds: 300));
    showBusyDialog();

    try {
      await _apiService.editPatient(patient);

      _localdbService.editPatient(patient);
      closeBusyDialog();
    } catch (e) {
      closeBusyDialog();

      handleHTTPError(e);
    }
  }

  void navigateToAddLeadView({bool isEdit = false, Patient? patient}) {
    _navigationService.navigateToView(
        AddLeadView(addPatient, isEdit: isEdit, patient: patient),
        fullscreenDialog: true);
  }

  void navigateToPatientDetailView() {
    _navigationService.navigateToPatientDetailView();
  }

  // void showConfirmDeleteDialog(Patient patient) async {
  //   DialogResponse? response = await _dialogService.showCustomDialog(
  //       variant: DialogType.confirmAlert,
  //       title: 'Are you sure you wish to delete this patient?',
  //       data: patient,
  //       mainButtonTitle: 'Cancel',
  //       secondaryButtonTitle: 'Delete');
  //
  //   if (response != null && response.confirmed) {
  //     try {
  //       bool canDelete =
  //           await _apiService.deletePatient(patient);
  //       if (!canDelete) {
  //         showCannotDeleteDialog();
  //       }
  //     } catch (e) {
  //       handleHTTPError(e);
  //     }
  //   }
  // }

  @override
  List<ListenableServiceMixin> get listenableServices => [_localdbService];
}
