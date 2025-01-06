enum Profession {
  prosthetist,
  physiotherapist,
  occupationalTherapist,
  socialWorker,
  psychologist,
  rehabilitationMedicineDoctor,
  peerSupport,
  communityBasedRehabilitation,
  communityHealthWorker,
  nurse;

  String get displayName {
    switch (this) {
      case Profession.prosthetist:
        return 'Prosthetist';
      case Profession.physiotherapist:
        return 'Physiotherapist';
      case Profession.occupationalTherapist:
        return 'Occupational therapist';
      case Profession.socialWorker:
        return 'Social worker';
      case Profession.psychologist:
        return 'Psychologist';
      case Profession.rehabilitationMedicineDoctor:
        return 'Rehabilitation medicine doctor';
      case Profession.peerSupport:
        return 'Peer support';
      case Profession.communityBasedRehabilitation:
        return 'Community based rehabilitation';
      case Profession.communityHealthWorker:
        return 'Community health worker';
      case Profession.nurse:
        return 'Nurse';
    }
  }
}

enum RehabilitationServices {
  compressionTherapy,
  gaitTraining,
  adaptiveSportTraining;

  String get displayName {
    switch (this) {
      case RehabilitationServices.compressionTherapy:
        return 'Compression therapy';
      case RehabilitationServices.gaitTraining:
        return 'Gait training';
      case RehabilitationServices.adaptiveSportTraining:
        return 'Adaptive sport training';
    }
  }
}

enum CompressionTherapy {
  shrinker,
  bandage,
  premadeSilicone,
  removableRigidDressing,
  other;

  String get displayName {
    switch (this) {
      case CompressionTherapy.shrinker:
        return 'Shrinker';
      case CompressionTherapy.bandage:
        return 'Bandage';
      case CompressionTherapy.premadeSilicone:
        return 'Premade silicone/elastomer liner inflatable compression';
      case CompressionTherapy.removableRigidDressing:
        return 'Removable rigid dressing';
      case CompressionTherapy.other:
        return 'Other';
    }
  }
}

enum ProstheticIntervention {
  prosthesis('prosthesis'),
  socketReplacement('socketReplacement'),
  repairAdjustments('repairAdjustments');

  final String type;

  const ProstheticIntervention(this.type);

  factory ProstheticIntervention.fromType(String type) {
    return values.firstWhere((e) => e.type == type);
  }

  String get displayName {
    switch (this) {
      case ProstheticIntervention.prosthesis:
        return 'Prosthesis';
      case ProstheticIntervention.socketReplacement:
        return 'Socket replacement';
      case ProstheticIntervention.repairAdjustments:
        return 'Repair/adjustments';
    }
  }
}

enum ProstheticFootType {
  hardRubberBareFootDesign,
  sach,
  singleAxis,
  multiaxial,
  dynamicResponse,
  pneumatic,
  hydraulic,
  microprocessor,
  powered,
  specialActivity;

  String get displayName {
    switch (this) {
      case ProstheticFootType.hardRubberBareFootDesign:
        return 'Hard rubber bare foot design';
      case ProstheticFootType.sach:
        return 'SACH';
      case ProstheticFootType.singleAxis:
        return 'Single axis';
      case ProstheticFootType.multiaxial:
        return 'Multiaxial';
      case ProstheticFootType.dynamicResponse:
        return 'Dynamic response';
      case ProstheticFootType.pneumatic:
        return 'Pneumatic';
      case ProstheticFootType.hydraulic:
        return 'Hydraulic';
      case ProstheticFootType.microprocessor:
        return 'Microprocessor';
      case ProstheticFootType.powered:
        return 'Powered';
      case ProstheticFootType.specialActivity:
        return 'Special activity';
    }
  }
}

enum ProstheticKneeType {
  singleAxis,
  multiaxial,
  pneumatic,
  hydraulic,
  microprocessor,
  externallyPowered;

  String get displayName {
    switch (this) {
      case ProstheticKneeType.singleAxis:
        return 'Single axis';
      case ProstheticKneeType.multiaxial:
        return 'Multiaxial';
      case ProstheticKneeType.pneumatic:
        return 'Pneumatic';
      case ProstheticKneeType.hydraulic:
        return 'Hydraulic';
      case ProstheticKneeType.microprocessor:
        return 'Microprocessor';
      case ProstheticKneeType.externallyPowered:
        return 'Externally powered';
    }
  }
}

enum ProstheticHipType {
  singleAxis('singleAxis'),
  multiaxial('multiaxial'),
  pneumatic('pneumatic'),
  hydraulic('hydraulic');

  final String type;

  const ProstheticHipType(this.type);

  factory ProstheticHipType.fromType(String type) {
    return values.firstWhere((e) => e.type == type);
  }

  String get displayName {
    switch (this) {
      case ProstheticHipType.singleAxis:
        return 'Single axis';
      case ProstheticHipType.multiaxial:
        return 'Multiaxial';
      case ProstheticHipType.pneumatic:
        return 'Pneumatic';
      case ProstheticHipType.hydraulic:
        return 'Hydraulic';
    }
  }
}

enum TobaccoUsage {
  never('never'),
  onceOrTwice('onceOrTwice'),
  monthly('monthly'),
  weekly('weekly'),
  dailyOrAlmostDaily('dailyOrAlmostDaily');

  final String type;

  const TobaccoUsage(this.type);

  factory TobaccoUsage.fromType(String type) {
    return values.firstWhere((e) => e.type == type);
  }

  String get displayName {
    switch (this) {
      case TobaccoUsage.never:
        return 'Never';
      case TobaccoUsage.onceOrTwice:
        return 'Once or twice';
      case TobaccoUsage.monthly:
        return 'Monthly';
      case TobaccoUsage.weekly:
        return 'Weekly';
      case TobaccoUsage.dailyOrAlmostDaily:
        return 'Daily or almost daily';
    }
  }
}

enum MaxEducationLevel {
  noFormalEducation('noFormalEducation'),
  earlyChildhoodEducation('earlyChildhoodEducation'),
  primarySchool('primarySchool'),
  lowerSecondaryEducation('lowerSecondaryEducation'),
  secondarySchool('secondarySchool'),
  postSecondaryTechnicalQualification('postSecondaryTechnicalQualification'),
  universityDegree('universityDegree'),
  postgraduateDegree('postgraduateDegree');

  final String type;

  const MaxEducationLevel(this.type);

  factory MaxEducationLevel.fromType(String type) {
    return values.firstWhere((e) => e.type == type);
  }

  String get displayName {
    switch (this) {
      case MaxEducationLevel.noFormalEducation:
        return 'No formal education attended';
      case MaxEducationLevel.earlyChildhoodEducation:
        return 'Early childhood education completed';
      case MaxEducationLevel.primarySchool:
        return 'Primary school completed';
      case MaxEducationLevel.lowerSecondaryEducation:
        return 'Lower secondary education completed';
      case MaxEducationLevel.secondarySchool:
        return 'Secondary school completed';
      case MaxEducationLevel.postSecondaryTechnicalQualification:
        return 'Post-secondary technical qualification';
      case MaxEducationLevel.universityDegree:
        return 'University degree completed';
      case MaxEducationLevel.postgraduateDegree:
        return 'Postgraduate degree completed';
    }
  }
}

enum MobilityDevice {
  noWalkingAids,
  singlePointStick,
  quadBaseWalkingStick,
  singleCrutch,
  pairOfCrutches,
  walkingFrameWalker,
  wheeledWalker,
  manualWheelchair,
  poweredWheelchairOrMobilityScooter;

  String get displayName {
    switch (this) {
      case MobilityDevice.noWalkingAids:
        return 'No walking aids';
      case MobilityDevice.singlePointStick:
        return 'Single point stick';
      case MobilityDevice.quadBaseWalkingStick:
        return 'Quad base walking stick';
      case MobilityDevice.singleCrutch:
        return 'Single crutch';
      case MobilityDevice.pairOfCrutches:
        return 'Pair of crutches';
      case MobilityDevice.walkingFrameWalker:
        return 'Walking frame/walker';
      case MobilityDevice.wheeledWalker:
        return 'Wheeled walker';
      case MobilityDevice.manualWheelchair:
        return 'Manual wheelchair';
      case MobilityDevice.poweredWheelchairOrMobilityScooter:
        return 'Powered wheelchair or mobility scooter';
    }
  }
}

enum MobilityDeviceUsage {
  noUsage('noUsage'),
  little('little'),
  some('some'),
  lots('lots'),
  mostly('mostly');

  final String type;

  const MobilityDeviceUsage(this.type);

  factory MobilityDeviceUsage.fromType(String type) {
    return values.firstWhere((e) => e.type == type);
  }

  String get displayName {
    switch (this) {
      case MobilityDeviceUsage.noUsage:
        return 'In a normal day I don\'t use it';
      case MobilityDeviceUsage.little:
        return 'Less than 1 hour (a little)';
      case MobilityDeviceUsage.some:
        return '1-3 hours (some)';
      case MobilityDeviceUsage.lots:
        return '3-6 hours (lots)';
      case MobilityDeviceUsage.mostly:
        return '6+ hours (mostly)';
    }
  }
}

enum IcfQualifiers {
  noProblem('noProblem'),
  mildProblem('mildProblem'),
  moderateProblem('moderateProblem'),
  severeProblem('severeProblem'),
  completeProblem('completeProblem');

  final String type;

  const IcfQualifiers(this.type);

  factory IcfQualifiers.fromType(String type) {
    return values.firstWhere((e) => e.type == type);
  }

  String get displayName {
    switch (this) {
      case IcfQualifiers.noProblem:
        return 'NO problem (0-5%)';
      case IcfQualifiers.mildProblem:
        return 'MILD problem (6-25%)';
      case IcfQualifiers.moderateProblem:
        return 'MODERATE problem (26-50%)';
      case IcfQualifiers.severeProblem:
        return 'SEVERE problem (51-95%)';
      case IcfQualifiers.completeProblem:
        return 'COMPLETE problem (96-100%)';
    }
  }
}

enum AmbulatoryActivityLevel {
  noActivity('noActivity'),
  little('little'),
  some('some'),
  lots('lots'),
  mostly('mostly');

  final String type;

  const AmbulatoryActivityLevel(this.type);

  factory AmbulatoryActivityLevel.fromType(String type) {
    return values.firstWhere((e) => e.type == type);
  }

  String get displayName {
    switch (this) {
      case AmbulatoryActivityLevel.noActivity:
        return 'In a normal day I don\'t';
      case AmbulatoryActivityLevel.little:
        return 'Less than 1 hour (a little)';
      case AmbulatoryActivityLevel.some:
        return '1-3 hours (some)';
      case AmbulatoryActivityLevel.lots:
        return '3-6 hours (lots)';
      case AmbulatoryActivityLevel.mostly:
        return '6+ hours (mostly)';
    }
  }
}

enum FallFrequency {
  lessThanOnceIn6Months('lessThanOnceIn6Months'),
  every3to6Months('every3to6Months'),
  every1to3Months('every1to3Months'),
  everyMonth('everyMonth');

  final String type;

  const FallFrequency(this.type);

  factory FallFrequency.fromType(String type) {
    return values.firstWhere((e) => e.type == type);
  }

  String get displayName {
    switch (this) {
      case FallFrequency.lessThanOnceIn6Months:
        return 'Less than once in 6 months';
      case FallFrequency.every3to6Months:
        return 'A fall every 3-6 months';
      case FallFrequency.every1to3Months:
        return 'A fall every 1-3 months';
      case FallFrequency.everyMonth:
        return 'In most months I would have a fall';
    }
  }
}

enum CommunityService {
  government('government'),
  paidPrivate('paidPrivate'),
  ngoVolunteer('ngoVolunteer'),
  other('other');

  final String type;

  const CommunityService(this.type);

  factory CommunityService.fromType(String type) {
    return values.firstWhere((e) => e.type == type);
  }

  String get displayName {
    switch (this) {
      case CommunityService.government:
        return 'Government';
      case CommunityService.paidPrivate:
        return 'Paid/private';
      case CommunityService.ngoVolunteer:
        return 'NGO/volunteer';
      case CommunityService.other:
        return 'Other';
    }
  }
}

enum YesOrNo {
  no('no'),
  yes('yes');

  final String type;

  const YesOrNo(this.type);

  factory YesOrNo.fromType(String type) {
    return values.firstWhere((e) => e.type == type);
  }

  String get displayName {
    switch (this) {
      case YesOrNo.no:
        return 'No';
      case YesOrNo.yes:
        return 'Yes';
    }
  }
}

enum Socket {
  partialFoot('partialFoot'),
  ankleDisarticulation('ankleDisarticulation'),
  transTibial('transTibial'),
  kneeDisarticulation('kneeDisarticulation'),
  transfemoral('transfemoral'),
  hipDisarticulation('hipDisarticulation'),
  hemiPelvectomy('hemiPelvectomy'),
  hemicorporectomy('hemicorporectomy');

  final String type;

  const Socket(this.type);

  factory Socket.fromType(String type) {
    return values.firstWhere((e) => e.type == type);
  }

  bool get isHip {
    return this == Socket.hipDisarticulation ||
        this == Socket.hemiPelvectomy ||
        this == Socket.hemicorporectomy;
  }

  bool get isAboveKnee {
    return this == Socket.kneeDisarticulation ||
        this == Socket.transfemoral ||
        this == Socket.hipDisarticulation ||
        this == Socket.hemiPelvectomy ||
        this == Socket.hemicorporectomy;
  }

  String get displayName {
    switch (this) {
      case Socket.partialFoot:
        return 'Partial foot';
      case Socket.ankleDisarticulation:
        return 'Ankle disarticulation';
      case Socket.transTibial:
        return 'Transtibial';
      case Socket.kneeDisarticulation:
        return 'Knee disarticulation';
      case Socket.transfemoral:
        return 'Transfemoral';
      case Socket.hipDisarticulation:
        return 'Hip disarticulation';
      case Socket.hemiPelvectomy:
        return 'Hemi-Pelvectomy';
      case Socket.hemicorporectomy:
        return 'Hemicorporectomy';
    }
  }
}

enum PartialFootDesign {
  withinShoe('withinShoe'),
  ankleImmobilized('ankleImmobilized'),
  ankleImmobilizedWgtBorneProx('ankleImmobilizedWgtBorneProx');

  final String type;

  const PartialFootDesign(this.type);

  factory PartialFootDesign.fromType(String type) {
    return values.firstWhere((e) => e.type == type);
  }

  String get displayName {
    switch (this) {
      case PartialFootDesign.withinShoe:
        return 'Within shoe';
      case PartialFootDesign.ankleImmobilized:
        return 'Ankle immobilised';
      case PartialFootDesign.ankleImmobilizedWgtBorneProx:
        return 'Ankle immobilised and weight borne proximally';
    }
  }
}

enum AnkleDisarticulationDesign {
  splitSocket('splitSocket'),
  window('window'),
  totalSurfaceBearing('totalSurfaceBearing');

  final String type;

  const AnkleDisarticulationDesign(this.type);

  factory AnkleDisarticulationDesign.fromType(String type) {
    return values.firstWhere((e) => e.type == type);
  }

  String get displayName {
    switch (this) {
      case AnkleDisarticulationDesign.splitSocket:
        return 'Split socket';
      case AnkleDisarticulationDesign.window:
        return 'Window';
      case AnkleDisarticulationDesign.totalSurfaceBearing:
        return 'Total surface bearing';
    }
  }
}

enum TransTibialDesign {
  patellaTendonBearing('patellaTendonBearing'),
  specificWeightBearing('specificWeightBearing'),
  totalSurfaceBearing('totalSurfaceBearing'),
  hydrostatic('hydrostatic'),
  thighLacer('thighLacer'),
  osseointegration('osseointegration');

  final String type;

  const TransTibialDesign(this.type);

  factory TransTibialDesign.fromType(String type) {
    return values.firstWhere((e) => e.type == type);
  }

  String get displayName {
    switch (this) {
      case TransTibialDesign.patellaTendonBearing:
        return 'Patella tendon bearing';
      case TransTibialDesign.specificWeightBearing:
        return 'Specific weight bearing';
      case TransTibialDesign.totalSurfaceBearing:
        return 'Total surface bearing';
      case TransTibialDesign.hydrostatic:
        return 'Hydrostatic';
      case TransTibialDesign.thighLacer:
        return 'Thigh lacer';
      case TransTibialDesign.osseointegration:
        return 'Osseointegration';
    }
  }
}

enum KneeDisarticulationDesign {
  window('window'),
  noWindow('noWindow');

  final String type;

  const KneeDisarticulationDesign(this.type);

  factory KneeDisarticulationDesign.fromType(String type) {
    return values.firstWhere((e) => e.type == type);
  }

  String get displayName {
    switch (this) {
      case KneeDisarticulationDesign.window:
        return 'Window';
      case KneeDisarticulationDesign.noWindow:
        return 'No window';
    }
  }
}

enum TransfemoralDesign {
  quadrilateral('quadrilateral'),
  narrowMl('narrowMl'),
  plugFit('plugFit'),
  ischialContainment('ischialContainment'),
  subIschial('subIschial'),
  osseointegration('osseointegration');

  final String type;

  const TransfemoralDesign(this.type);

  factory TransfemoralDesign.fromType(String type) {
    return values.firstWhere((e) => e.type == type);
  }

  String get displayName {
    switch (this) {
      case TransfemoralDesign.quadrilateral:
        return 'Quadrilateral (Ischial support and Narrow AP)';
      case TransfemoralDesign.narrowMl:
        return 'Narrow ML';
      case TransfemoralDesign.plugFit:
        return 'Plug fit';
      case TransfemoralDesign.ischialContainment:
        return 'Ischial containment';
      case TransfemoralDesign.subIschial:
        return 'Sub Ischial';
      case TransfemoralDesign.osseointegration:
        return 'Osseointegration';
    }
  }
}

enum SocketType {
  fiberglassLamination,
  carbonFiberLamination,
  thermoplastic,
  threeDPrinted,
  adjustableSocketSolution;

  String get displayName {
    switch (this) {
      case SocketType.fiberglassLamination:
        return 'Fiberglass lamination';
      case SocketType.carbonFiberLamination:
        return 'Carbon fiber lamination';
      case SocketType.thermoplastic:
        return 'Thermoplastic';
      case SocketType.threeDPrinted:
        return '3D printed';
      case SocketType.adjustableSocketSolution:
        return 'Adjustable socket solution';
    }
  }
}

enum Liner {
  noLiner('noLiner'),
  foamPelite('foamPelite'),
  silicone('silicone'),
  urethane('urethane'),
  gel('gel');

  final String type;

  const Liner(this.type);

  factory Liner.fromType(String type) {
    return values.firstWhere((e) => e.type == type);
  }

  String get displayName {
    switch (this) {
      case Liner.noLiner:
        return 'No liner';
      case Liner.foamPelite:
        return 'Foam/pelite';
      case Liner.silicone:
        return 'Silicone';
      case Liner.urethane:
        return 'Urethane';
      case Liner.gel:
        return 'Gel';
    }
  }
}

enum Suspension {
  selfSuspending('selfSuspending'),
  cuffStrap('cuffStrap'),
  pin('pin'),
  lanyard('lanyard'),
  sleeve('sleeve'),
  expulsionValve('expulsionValve');

  final String type;

  const Suspension(this.type);

  factory Suspension.fromType(String type) {
    return values.firstWhere((e) => e.type == type);
  }

  String get displayName {
    switch (this) {
      case Suspension.selfSuspending:
        return 'Self-suspending';
      case Suspension.cuffStrap:
        return 'Cuff/strap';
      case Suspension.pin:
        return 'Pin';
      case Suspension.lanyard:
        return 'Lanyard';
      case Suspension.sleeve:
        return 'Sleeve';
      case Suspension.expulsionValve:
        return 'Expulsion valve';
    }
  }
}

enum EpisodePrefix {
  pre,
  post;

  String get displayName {
    switch (this) {
      case EpisodePrefix.pre:
        return 'Pre';
      case EpisodePrefix.post:
        return 'Post';
    }
  }
}

enum Submit { initial, finish }
