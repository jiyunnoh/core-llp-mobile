import '../app/app.locator.dart';
import '../constants/app_strings.dart';
import '../services/cloud_service.dart';

class KLevel {
  String? entityId;
  int? kLevelValue;

  final _apiService = locator<BiotService>();

  KLevel({this.entityId, this.kLevelValue});

  factory KLevel.fromJson(Map<String, dynamic> data) {
    KLevel kLevel =
        // fromJson in Patient -> data['id']
        // fromJson in getKLevel -> data['_id']
        KLevel(entityId: data['id'] ?? data['_id'], kLevelValue: data['k_level']);
    return kLevel;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> body = {
      "_templateId": ksKLevelTemplateId,
      "k_level": kLevelValue
    };

    if (entityId != null) {
      body.addAll({"id" : entityId});
    }

    return body;
  }
}
