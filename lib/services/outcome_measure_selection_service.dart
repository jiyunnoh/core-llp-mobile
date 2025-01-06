import 'package:biot/model/outcome_measure_collection.dart';
import 'package:stacked/stacked.dart';

import '../constants/enum.dart';
import '../model/outcome_measures/outcome_measure.dart';

class OutcomeMeasureSelectionService with ListenableServiceMixin {
  ReactiveValue<List<OutcomeMeasure>> individualOutcomeMeasures =
      ReactiveValue([]);
  ReactiveValue<List<OutcomeMeasureCollection>> outcomeMeasureCollections =
      ReactiveValue([]);

  List<OutcomeMeasure> get selectedOutcomeMeasures {
    List<OutcomeMeasure> outcomeMeasures = [];
    outcomeMeasures.addAll(individualOutcomeMeasures.value);
    for (OutcomeMeasureCollection outcomeMeasureCollection
        in outcomeMeasureCollections.value) {
      outcomeMeasures.addAll(outcomeMeasureCollection.outcomeMeasures);
    }
    return outcomeMeasures.toSet().toList();
  }

  Map<DomainType, List<OutcomeMeasure>> get outcomeMeasuresMapByDomainType {
    Map<DomainType, List<OutcomeMeasure>> map = {};
    // If it is not editing, display the number of domain types of outcomeMeasures in om select view.
    for (OutcomeMeasure outcomeMeasure in selectedOutcomeMeasures) {
      // If the key is not present in the map, create an empty list for it
      map[outcomeMeasure.domainType] ??= [];
      map[outcomeMeasure.domainType]!.add(outcomeMeasure);
    }

    return map;
  }

  int get patientTimeToComplete => selectedOutcomeMeasures.fold<int>(
      0, (previousValue, element) => previousValue + element.estTimeToComplete);

  int get assistantTimeToComplete => selectedOutcomeMeasures.fold<int>(
      0,
      (previousValue, element) => element.isAssistantNeeded
          ? previousValue + element.estTimeToComplete
          : previousValue + 0);

  int get clinicianTimeToComplete {
    int temp = 0;

    return temp;
  }

  OutcomeMeasureSelectionService() {
    listenToReactiveValues(
        [individualOutcomeMeasures, outcomeMeasureCollections]);
  }

  void clear() {
    individualOutcomeMeasures.value.clear();
    outcomeMeasureCollections.value.clear();

    notifyListeners();
  }

  void addOutcomeMeasure(OutcomeMeasure outcomeMeasure) {
    individualOutcomeMeasures.value.add(outcomeMeasure);

    notifyListeners();
  }

  // Remove individual outcome measure
  void removeOutcomeMeasure(OutcomeMeasure outcomeMeasure) {
    individualOutcomeMeasures.value.remove(outcomeMeasure);

    notifyListeners();
  }

  void addOutcomeMeasureCollection(
      OutcomeMeasureCollection outcomeMeasureCollection) {
    outcomeMeasureCollections.value.add(outcomeMeasureCollection);

    notifyListeners();
  }

  void removeOutcomeMeasureCollection(
      OutcomeMeasureCollection outcomeMeasureCollection) {
    outcomeMeasureCollections.value.remove(outcomeMeasureCollection);

    notifyListeners();
  }
}
