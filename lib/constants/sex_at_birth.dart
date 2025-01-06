enum SexAtBirth {
  male('male'),
  female('female'),
  unknown('neither'),
  neither('unknown');

  final String type;

  const SexAtBirth(this.type);

  factory SexAtBirth.fromType(String type) {
    return values.firstWhere((e) => e.type == type);
  }

  String get displayName {
    switch (this) {
      case SexAtBirth.male:
        return "Male";
      case SexAtBirth.female:
        return "Female";
      case SexAtBirth.neither:
        return "Neither";
      default:
        return "Unknown";
    }
  }

  String get shortStrValue {
    switch (this) {
      case SexAtBirth.male:
        return "M";
      case SexAtBirth.female:
        return "F";
      case SexAtBirth.neither:
        return "N";
      default:
        return "U";
    }
  }
}
