//TODO: Jiyun - merge AmputationSide, AmputeeSide?
enum AmputationSide {
  left('left'),
  right('right'),
  hemicorporectomy('hemicorporectomy');

  final String type;

  const AmputationSide(this.type);

  factory AmputationSide.fromType(String type) {
    return values.firstWhere((e) => e.type == type);
  }

  String get displayName {
    switch (this) {
      case AmputationSide.left:
        return 'Left';
      case AmputationSide.right:
        return 'Right';
      case AmputationSide.hemicorporectomy:
        return 'Hemicorporectomy';
    }
  }
}

enum CauseOfAmputation {
  trauma('trauma'),
  diabetes('diabetes'),
  vascular('vascular'),
  cancer('cancer'),
  infection('infection'),
  congenital('congenital'),
  other('other');

  final String type;

  const CauseOfAmputation(this.type);

  factory CauseOfAmputation.fromType(String type) {
    return values.firstWhere((e) => e.type == type);
  }

  String get displayName {
    switch (this) {
      case CauseOfAmputation.trauma:
        return 'Trauma';
      case CauseOfAmputation.diabetes:
        return 'Diabetes';
      case CauseOfAmputation.vascular:
        return 'Vascular';
      case CauseOfAmputation.cancer:
        return 'Cancer';
      case CauseOfAmputation.infection:
        return 'Infection';
      case CauseOfAmputation.congenital:
        return 'Congenital';
      default:
        return 'Other';
    }
  }
}

enum TypeOfAmputation {
  majorAmputation('majorAmputation'),
  boneRevisionAtSameLevel('boneRevisionAtSameLevel'),
  softTissueRevisionAtSameLevel('softTissueRevisionAtSameLevel');

  final String type;

  const TypeOfAmputation(this.type);

  factory TypeOfAmputation.fromType(String type) {
    return values.firstWhere((e) => e.type == type);
  }

  String get displayName {
    switch (this) {
      case TypeOfAmputation.majorAmputation:
        return 'Major Amputation';
      case TypeOfAmputation.boneRevisionAtSameLevel:
        return 'Bone Revision At Same Level';
      case TypeOfAmputation.softTissueRevisionAtSameLevel:
        return 'Soft Tissue Revision At Same Level';
    }
  }
}

enum LevelOfAmputation {
  toeAmputation('toeAmputation'),
  metatarsalphalangealDisarticulation('metatarsalphalangealDisarticulation'),
  rayResection('rayResection'),
  transMetatarsalAmputation('transMetatarsalAmputation'),
  tarsalMetatarsalAmputation('tarsalMetatarsalAmputation'),
  transTarsalAmputation('transTarsalAmputation'),
  ankleDisarticulation('ankleDisarticulation'),
  transtibial('transtibial'),
  kneeDisarticulation('kneeDisarticulation'),
  transfemoral('transfemoral'),
  hipDisarticulation('hipDisarticulation'),
  hemipelvectomy('hemipelvectomy'),
  hemicorporectomy('hemicorporectomy');

  final String type;

  const LevelOfAmputation(this.type);

  factory LevelOfAmputation.fromType(String type) {
    return values.firstWhere((e) => e.type == type);
  }

  String get displayName {
    switch (this) {
      case LevelOfAmputation.toeAmputation:
        return 'Toe amputation';
      case LevelOfAmputation.metatarsalphalangealDisarticulation:
        return 'Metatarsalphalangeal disarticulation';
      case LevelOfAmputation.rayResection:
        return 'Ray resection (meta-tarsal and toe)';
      case LevelOfAmputation.transMetatarsalAmputation:
        return 'Trans metatarsal amputation';
      case LevelOfAmputation.tarsalMetatarsalAmputation:
        return 'Tarsal Metatarsal amputation';
      case LevelOfAmputation.transTarsalAmputation:
        return 'Trans tarsal amputation (Chopart)';
      case LevelOfAmputation.ankleDisarticulation:
        return 'Ankle disarticulation (Symes)';
      case LevelOfAmputation.transtibial:
        return 'Transtibial (BK)';
      case LevelOfAmputation.kneeDisarticulation:
        return 'Knee disarticulation';
      case LevelOfAmputation.transfemoral:
        return 'Transfemoral (AK)';
      case LevelOfAmputation.hipDisarticulation:
        return 'Hip Disarticulation';
      case LevelOfAmputation.hemipelvectomy:
        return 'Hemipelvectomy';
      case LevelOfAmputation.hemicorporectomy:
        return 'Hemicorporectomy';
    }
  }
}
