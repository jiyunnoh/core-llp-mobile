// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encounter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EncounterAdapter extends TypeAdapter<Encounter> {
  @override
  final int typeId = 1;

  @override
  Encounter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Encounter(
      entityId: fields[0] as String?,
      name: fields[1] as String?,
      creationTimeString: fields[2] as String?,
      outcomeMeasures: (fields[3] as List?)?.cast<OutcomeMeasure>(),
      domainWeightDistId: fields[4] as String?,
      domainWeightDist: fields[5] as DomainWeightDistribution?,
      kLevelId: fields[10] as String?,
      kLevel: fields[11] as KLevel?,
      conditionId: fields[8] as String?,
      condition: fields[9] as Condition?,
      unweightedTotalScore: fields[6] as num?,
      encounterCreatedTimeString: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Encounter obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.entityId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.creationTimeString)
      ..writeByte(3)
      ..write(obj.outcomeMeasures)
      ..writeByte(4)
      ..write(obj.domainWeightDistId)
      ..writeByte(5)
      ..write(obj.domainWeightDist)
      ..writeByte(6)
      ..write(obj.unweightedTotalScore)
      ..writeByte(8)
      ..write(obj.conditionId)
      ..writeByte(9)
      ..write(obj.condition)
      ..writeByte(10)
      ..write(obj.kLevelId)
      ..writeByte(11)
      ..write(obj.kLevel)
      ..writeByte(14)
      ..write(obj.encounterCreatedTimeString)
      ..writeByte(7)
      ..write(obj.weightedTotalScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EncounterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
