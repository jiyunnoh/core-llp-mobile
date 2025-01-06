import 'package:easy_localization/easy_localization.dart';

import '../app/app.locator.dart';
import '../constants/amputation_info.dart';
import '../constants/compass_lead_enum.dart';
import '../services/cloud_service.dart';

import '../services/logger_service.dart';

class Amputation {
  final _apiService = locator<BiotService>();
  final _logger = locator<LoggerService>().getLogger((Amputation).toString());

  String? entityId;
  DateTime? dateOfAmputation;
  AmputationSide? side;
  CauseOfAmputation? cause;
  TypeOfAmputation? type;
  LevelOfAmputation? level;
  YesOrNo? abilityToWalk;
  String? otherPrimaryCause;

  String? get dateOfAmputationString => dateOfAmputation == null
      ? null
      : DateFormat('yyyy-MM-dd').format(dateOfAmputation!);

  Amputation(
      {this.entityId,
      this.side,
      this.cause,
      this.type,
      this.level,
      this.abilityToWalk,
      this.dateOfAmputation,
      this.otherPrimaryCause});

  factory Amputation.fromJson(Map<String, dynamic> data) {
    return Amputation(
      entityId: data['_id'] ?? data['id'],
      dateOfAmputation: DateTime.parse(data['amp_date']),
      side: AmputationSide.values[data['amp_side']],
      cause: CauseOfAmputation.values[data['amp_cause']],
      type: TypeOfAmputation.values[data['amp_type']],
      level: LevelOfAmputation.values[data['amp_level']],
      abilityToWalk: YesOrNo.values[data['ability_to_walk']],
      otherPrimaryCause: data['other_primary_cause'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amp_date': dateOfAmputation!.toUtc().toIso8601String(),
      'amp_side': side!.index,
      'amp_cause': cause!.index,
      'amp_type': type!.index,
      'amp_level': level!.index,
      'ability_to_walk': abilityToWalk!.index,
      'other_primary_cause': otherPrimaryCause
    };
  }

  @override
  operator ==(Object other) =>
      other is Amputation &&
      other.dateOfAmputation == dateOfAmputation &&
      other.side == side &&
      other.cause == cause &&
      other.level == level &&
      other.type == type &&
      other.abilityToWalk == abilityToWalk &&
      other.otherPrimaryCause == otherPrimaryCause;

  @override
  int get hashCode => Object.hash(side, cause, type, level, abilityToWalk,
      dateOfAmputation, otherPrimaryCause);

  Amputation clone() {
    Amputation clone = Amputation();
    clone.entityId = entityId;
    clone.dateOfAmputation = dateOfAmputation;
    clone.side = side;
    clone.cause = cause;
    clone.type = type;
    clone.level = level;
    clone.abilityToWalk = abilityToWalk;
    clone.otherPrimaryCause = otherPrimaryCause;
    return clone;
  }

  Future populate() async {
    _logger.d('populating amputation');

    try {
      Amputation temp =
          await _apiService.getAmputation(amputationId: entityId!);

      side = temp.side;
      cause = temp.cause;
      type = temp.type;
      level = temp.level;
      abilityToWalk = temp.abilityToWalk;
      dateOfAmputation = temp.dateOfAmputation;
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJsonForPDF(int index) {
    Map<String, dynamic> jsonMap = {
      "side_$index": side!.displayName,
      "date_amp_$index": DateFormat('yyyy-MM-dd').format(dateOfAmputation!),
      "primary_cause_$index": cause == CauseOfAmputation.other
          ? otherPrimaryCause
          : cause!.displayName,
      "type_$index": type!.displayName,
      "level_$index": level!.displayName,
      "ability_to_walk_$index": abilityToWalk!.displayName
    };

    return jsonMap;
  }
}
