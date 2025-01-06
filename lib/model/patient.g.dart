// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PatientAdapter extends TypeAdapter<Patient> {
  @override
  final int typeId = 0;

  @override
  Patient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Patient(
      id: fields[0] as String,
      firstName: fields[1] as String,
      lastName: fields[2] as String,
      email: fields[3] as String,
      entityId: fields[10] as String?,
      dob: fields[11] as DateTime?,
      sexAtBirthIndex: fields[4] as int?,
      currentSex: fields[12] as int?,
      race: fields[13] as int?,
      ethnicity: fields[14] as int?,
      caregiverName: fields[5] as String?,
      domainWeightDistJson: fields[8] as String?,
      conditionJson: fields[15] as String?,
      kLevelJson: fields[16] as String?,
      outcomeMeasures: (fields[17] as List?)?.cast<String?>(),
      creationTime: fields[18] as DateTime?,
    )
      ..isSetToDelete = fields[6] as bool?
      ..encounters = (fields[7] as List?)?.cast<Encounter>();
  }

  @override
  void write(BinaryWriter writer, Patient obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.firstName)
      ..writeByte(2)
      ..write(obj.lastName)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.sexAtBirthIndex)
      ..writeByte(5)
      ..write(obj.caregiverName)
      ..writeByte(6)
      ..write(obj.isSetToDelete)
      ..writeByte(7)
      ..write(obj.encounters)
      ..writeByte(8)
      ..write(obj.domainWeightDistJson)
      ..writeByte(10)
      ..write(obj.entityId)
      ..writeByte(11)
      ..write(obj.dob)
      ..writeByte(12)
      ..write(obj.currentSex)
      ..writeByte(13)
      ..write(obj.race)
      ..writeByte(14)
      ..write(obj.ethnicity)
      ..writeByte(15)
      ..write(obj.conditionJson)
      ..writeByte(16)
      ..write(obj.kLevelJson)
      ..writeByte(17)
      ..write(obj.outcomeMeasures)
      ..writeByte(18)
      ..write(obj.creationTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
