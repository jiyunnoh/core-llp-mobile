import '../constants/enum.dart';
import 'outcome_measures/outcome_measure.dart';

class OutcomeMeasureCollection {
  String id = '';
  String title = '';
  bool isSelected = false;
  bool isEditing = false;
  bool canModify = true;

  List<OutcomeMeasure> outcomeMeasures;

  List<OutcomeMeasure> tempOutcomeMeasures = [];

  Map<DomainType, List<OutcomeMeasure>> get outcomeMeasuresMapByDomainType {
    Map<DomainType, List<OutcomeMeasure>> map = {};
    if (isEditing) {
      // If it is editing, display the number of domain types of tempOutcomeMeasures in bottom sheet.
      for (OutcomeMeasure outcomeMeasure in tempOutcomeMeasures) {
        // If the key is not present in the map, create an empty list for it
        map[outcomeMeasure.domainType] ??= [];
        map[outcomeMeasure.domainType]!.add(outcomeMeasure);
      }
    } else {
      // If it is not editing, display the number of domain types of outcomeMeasures in om select view.
      for (OutcomeMeasure outcomeMeasure in outcomeMeasures) {
        // If the key is not present in the map, create an empty list for it
        map[outcomeMeasure.domainType] ??= [];
        map[outcomeMeasure.domainType]!.add(outcomeMeasure);
      }
    }

    return map;
  }

  int get patientTimeToComplete => isEditing
      ? tempOutcomeMeasures.fold<int>(0,
          (previousValue, element) => previousValue + element.estTimeToComplete)
      : outcomeMeasures.fold<int>(
          0,
          (previousValue, element) =>
              previousValue + element.estTimeToComplete);

  int get assistantTimeToComplete => isEditing
      ? tempOutcomeMeasures.fold<int>(
          0,
          (previousValue, element) => element.isAssistantNeeded
              ? previousValue + element.estTimeToComplete
              : previousValue + 0)
      : outcomeMeasures.fold<int>(
          0,
          (previousValue, element) => element.isAssistantNeeded
              ? previousValue + element.estTimeToComplete
              : previousValue + 0);

  int clinicianTimeToComplete = 0;

  OutcomeMeasureCollection(
      {required this.outcomeMeasures,
      this.canModify = true,
      this.title = '',
      this.id = ''}) {
    tempOutcomeMeasures = List.of(outcomeMeasures);
  }

  void addOutcomeMeasure(OutcomeMeasure outcomeMeasure) {
    tempOutcomeMeasures.add(outcomeMeasure);
  }

  void removeOutcomeMeasure(OutcomeMeasure outcomeMeasure) {
    tempOutcomeMeasures.remove(outcomeMeasure);
  }

  OutcomeMeasure getOutcomeMeasureById(String id) {
    //TODO:JK - need to change 10mwt to tmwt
    String omId = id;
    if (omId == 'tmwt') {
      omId = '10mwt';
    }
    return outcomeMeasures.firstWhere((element) => element.id == omId);
  }

  void save() {
    outcomeMeasures = tempOutcomeMeasures;
  }
}
