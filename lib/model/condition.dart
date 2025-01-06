import '../app/app.locator.dart';
import '../constants/app_strings.dart';
import '../services/cloud_service.dart';

class Condition {
  String? entityId;
  List<String>? conditionsList;

  final _apiService = locator<BiotService>();

  Condition({this.entityId, this.conditionsList});

  factory Condition.fromJson(Map<String, dynamic> data) {
    List<String>? conditionsList;
    if (data['condition_type'] != null) {
      conditionsList =
          (data['condition_type'] as List).map((e) => e.toString()).toList();
    }

    Condition conditions = Condition(
      // fromJson in Patient -> data['id']
      // fromJson in getCondition -> data['_id']
      entityId: data['id'] ?? data['_id'],
      conditionsList: conditionsList,
    );
    return conditions;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> body = {
      "_templateId": ksConditionsTemplateId,
      "condition_type": conditionsList
    };

    if (entityId != null) {
      body.addAll({"id": entityId});
    }

    return body;
  }
}
