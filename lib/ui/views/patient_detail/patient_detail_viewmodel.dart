import 'package:biot/constants/compass_lead_enum.dart';
import 'package:biot/mixin/dialog_mixin.dart';
import 'package:biot/model/encounter_collection.dart';
import 'package:biot/model/outcome_measure_collection.dart';
import 'package:biot/services/cloud_service.dart';
import 'package:biot/services/outcome_measure_load_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../model/encounter.dart';
import '../../../model/patient.dart';
import '../../../services/database_service.dart';
import '../../../services/logger_service.dart';
import '../../../services/outcome_measure_selection_service.dart';
import '../amputation/amputation_view.dart';

class PatientDetailViewModel extends BaseViewModel with OIDialog {
  final _navigationService = locator<NavigationService>();
  final _apiService = locator<BiotService>();
  final _outcomeMeasureSelectionService =
      locator<OutcomeMeasureSelectionService>();
  final _outcomeMeasureLoadService = locator<OutcomeMeasureLoadService>();
  final _localdbService = locator<DatabaseService>();
  final _logger =
      locator<LoggerService>().getLogger((PatientDetailViewModel).toString());

  Patient get currentPatient => _localdbService.currentPatient!.value;

  EncounterCollection get encounterCollection =>
      currentPatient.encounterCollection;

  late OutcomeMeasureCollection compassLeadCollection;

  PatientDetailViewModel() {
    _logger.d('');
    compassLeadCollection =
        _outcomeMeasureLoadService.getCollection(id: 'compass');
  }

  Future<void> getEncounters() async {
    _logger.d('');

    setBusy(true);

    currentPatient.encounters ??= await _apiService.getEncounters(
        patientEntityId: currentPatient.entityId!);
    currentPatient.encounterCollection =
        EncounterCollection(currentPatient.encounters!);

    setBusy(false);
  }

  void onTapAmputation() async {
    await _navigationService.navigateToView(const AmputationView());
    notifyListeners();
  }

  void onPostEpisodeButtonTapped() async {
    DialogResponse? response = await showPostEpisodeWarning();
    if (response != null && response.confirmed) {
      onStartPostEpisode();
    }
  }

  void onStartPreEpisode() async {
    DialogResponse? response = await showClientIDWarning(currentPatient.id);
    if (response != null && response.confirmed) {
      startPreEpisode();
    }
  }

  void onStartPostEpisode() async {
    DialogResponse? response = await showClientIDWarning(currentPatient.id);
    if (response != null && response.confirmed) {
      startPostEpisode();
    }
  }

  void onStartEncounter() async {
    DialogResponse? response = await showClientIDWarning(currentPatient.id);
    if (response != null && response.confirmed) {
      startEncounter();
    }
  }

  void startPreEpisode() {
    _logger.d('');
    Encounter encounter = Encounter(prefix: EpisodePrefix.pre);
    _outcomeMeasureSelectionService
        .addOutcomeMeasureCollection(compassLeadCollection);
    _navigationService.navigateToAmputationFormView(
        encounter: encounter, isEdit: false);
  }

  void startPostEpisode() async {
    _logger.d('');
    Encounter encounter = Encounter(prefix: EpisodePrefix.post);
    _outcomeMeasureSelectionService
        .addOutcomeMeasureCollection(compassLeadCollection);
    // link preEpisode to postEpisode
    encounter.preEncounter = currentPatient.encounterCollection.preEncounter;

    if (currentPatient.amputations.isEmpty) {
      _navigationService.navigateToAmputationFormView(
          encounter: encounter, isEdit: false);
    } else {
      _navigationService.navigateToPrePostView(
          encounter: encounter, isEdit: false);
    }
  }

  void startEncounter() {
    _logger.d('');
    Encounter encounter = Encounter(prefix: EpisodePrefix.post);
    _outcomeMeasureSelectionService
        .addOutcomeMeasureCollection(compassLeadCollection);
    _navigationService.navigateToEvaluationView(encounter: encounter);
  }
}
